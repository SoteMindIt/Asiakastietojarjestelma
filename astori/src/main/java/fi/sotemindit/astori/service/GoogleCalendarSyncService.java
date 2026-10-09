package fi.sotemindit.astori.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriUtils;

import fi.sotemindit.astori.model.Kayttaja;
import fi.sotemindit.astori.model.Tapahtuma;
import fi.sotemindit.astori.model.TapahtumaTyyppi;
import fi.sotemindit.astori.repository.TapahtumaRepository;

@Service
public class GoogleCalendarSyncService {

    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();

    private final RestTemplate restTemplate = new RestTemplate();

    public List<Tapahtuma> parseEvents(String jsonBody, Kayttaja kayttaja, TapahtumaTyyppi googleTyyppi) {
        if (jsonBody == null || jsonBody.isBlank()) {
            return List.of();
        }

        try {
            JsonNode root = OBJECT_MAPPER.readTree(jsonBody);
            JsonNode items = root.path("items");
            if (!items.isArray()) {
                return List.of();
            }

            List<Tapahtuma> tapahtumat = new ArrayList<>();
            for (JsonNode item : items) {
                if (item == null || item.isNull()) {
                    continue;
                }

                String status = item.path("status").asText(null);
                if ("cancelled".equalsIgnoreCase(status)) {
                    continue;
                }

                LocalDateTime aloitus = parseGoogleDateNode(item.path("start"));
                if (aloitus == null) {
                    continue;
                }

                Tapahtuma tapahtuma = new Tapahtuma();
                String otsikko = item.path("summary").asText(null);
                tapahtuma.setOtsikko(otsikko == null || otsikko.isBlank() ? "(Ilman otsikkoa)" : otsikko);
                tapahtuma.setKuvaus(item.path("description").asText(null));
                tapahtuma.setAjankohta(aloitus);
                tapahtuma.setLoppuaika(parseGoogleDateNode(item.path("end")));
                tapahtuma.setTyyppi(googleTyyppi);
                tapahtuma.setKayttaja(kayttaja);
                tapahtumat.add(tapahtuma);
            }

            return tapahtumat;
        } catch (Exception e) {
            throw new IllegalStateException("Google Calendar JSON:n käsittely epäonnistui", e);
        }
    }

    public int syncGoogleCalendarToApp(
            String calendarId,
            String apiKey,
            String accessToken,
            Kayttaja kayttaja,
            TapahtumaTyyppi googleTyyppi,
            TapahtumaRepository tapahtumaRepository) {

        String resolvedCalendarId = (calendarId == null || calendarId.isBlank()) ? "primary" : calendarId;
        StringBuilder urlBuilder = new StringBuilder();
        urlBuilder.append("https://www.googleapis.com/calendar/v3/calendars/")
                .append(UriUtils.encode(resolvedCalendarId, StandardCharsets.UTF_8))
            .append("/events?singleEvents=true&orderBy=startTime&maxResults=2500");

        if (apiKey != null && !apiKey.isBlank() && (accessToken == null || accessToken.isBlank())) {
            urlBuilder.append("&key=")
                    .append(UriUtils.encode(apiKey, StandardCharsets.UTF_8));
        }

        HttpHeaders headers = new HttpHeaders();
        headers.setAccept(List.of(MediaType.APPLICATION_JSON));
        if (accessToken != null && !accessToken.isBlank()) {
            headers.setBearerAuth(accessToken);
        }

        HttpEntity<Void> request = new HttpEntity<>(headers);
        List<Tapahtuma> googleEvents = new ArrayList<>();
        String pageToken = null;
        do {
            String pageUrl = urlBuilder.toString();
            if (pageToken != null && !pageToken.isBlank()) {
                pageUrl += "&pageToken=" + UriUtils.encode(pageToken, StandardCharsets.UTF_8);
            }

            ResponseEntity<String> response = restTemplate.exchange(
                    pageUrl,
                    HttpMethod.GET,
                    request,
                    String.class
            );

            if (!response.getStatusCode().is2xxSuccessful()) {
                throw new IllegalStateException("Google Calendar API palautti virheen: " + response.getStatusCode());
            }

            googleEvents.addAll(parseEvents(response.getBody(), kayttaja, googleTyyppi));
            try {
                JsonNode responseBody = OBJECT_MAPPER.readTree(response.getBody());
                pageToken = responseBody.path("nextPageToken").asText(null);
            } catch (Exception e) {
                throw new IllegalStateException("Google Calendar JSON:n sivutustietojen käsittely epäonnistui", e);
            }
        } while (pageToken != null && !pageToken.isBlank());

        List<Tapahtuma> nykyisetTapahtumat = tapahtumaRepository.findByKayttajatunnus(kayttaja.getKayttajatunnus());

        int tallennettuja = 0;
        for (Tapahtuma googleTapahtuma : googleEvents) {
            boolean onJoOlemassa = nykyisetTapahtumat.stream().anyMatch(existing ->
                    Objects.equals(existing.getOtsikko(), googleTapahtuma.getOtsikko())
                            && Objects.equals(existing.getAjankohta(), googleTapahtuma.getAjankohta())
                            && existing.getTyyppi() != null
                            && existing.getTyyppi().getNimi() != null
                            && existing.getTyyppi().getNimi().equalsIgnoreCase(googleTyyppi.getNimi()));

            if (onJoOlemassa) {
                continue;
            }

            tapahtumaRepository.save(googleTapahtuma);
            nykyisetTapahtumat.add(googleTapahtuma);
            tallennettuja++;
        }

        return tallennettuja;
    }

    private LocalDateTime parseGoogleDateValue(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }

        if (value.contains("T")) {
            return OffsetDateTime.parse(value).toLocalDateTime();
        }
        return LocalDate.parse(value).atStartOfDay();
    }

    private LocalDateTime parseGoogleDateNode(JsonNode dateNode) {
        if (dateNode == null || dateNode.isNull()) {
            return null;
        }

        if (dateNode.has("dateTime")) {
            return parseGoogleDateValue(dateNode.path("dateTime").asText(null));
        }

        if (dateNode.has("date")) {
            return LocalDate.parse(dateNode.path("date").asText()).atStartOfDay();
        }

        return null;
    }
}
