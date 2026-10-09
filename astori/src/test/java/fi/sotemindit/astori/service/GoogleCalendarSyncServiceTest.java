package fi.sotemindit.astori.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

import java.util.List;

import org.junit.jupiter.api.Test;

import fi.sotemindit.astori.model.Kayttaja;
import fi.sotemindit.astori.model.Tapahtuma;
import fi.sotemindit.astori.model.TapahtumaTyyppi;

class GoogleCalendarSyncServiceTest {

    @Test
    void shouldParseGoogleCalendarEventsIntoAppEvents() {
        GoogleCalendarSyncService service = new GoogleCalendarSyncService();

        Kayttaja kayttaja = new Kayttaja();
        kayttaja.setKayttajatunnus("demo");

        TapahtumaTyyppi googleTyyppi = new TapahtumaTyyppi();
        googleTyyppi.setNimi("Google");
        googleTyyppi.setVari("#4285F4");

        List<Tapahtuma> tapahtumat = service.parseEvents("""
            {
              "items": [
                {
                  "summary": "Päivätyö",
                  "description": "Aloitus",
                  "start": { "dateTime": "2026-10-02T09:00:00+03:00" },
                  "end": { "dateTime": "2026-10-02T10:30:00+03:00" }
                },
                {
                  "summary": "Kokous",
                  "description": "Jakso",
                  "start": { "date": "2026-10-03" },
                  "end": { "date": "2026-10-04" }
                }
              ]
            }
            """, kayttaja, googleTyyppi);

        assertEquals(2, tapahtumat.size());
        assertEquals("Päivätyö", tapahtumat.get(0).getOtsikko());
        assertEquals("Aloitus", tapahtumat.get(0).getKuvaus());
        assertNotNull(tapahtumat.get(0).getAjankohta());
        assertEquals("Kokous", tapahtumat.get(1).getOtsikko());
        assertNotNull(tapahtumat.get(1).getKayttaja());
    }

    @Test
    void shouldParseGoogleCalendarPayloadWithRealisticFieldOrder() {
        GoogleCalendarSyncService service = new GoogleCalendarSyncService();

        Kayttaja kayttaja = new Kayttaja();
        kayttaja.setKayttajatunnus("demo");

        TapahtumaTyyppi googleTyyppi = new TapahtumaTyyppi();
        googleTyyppi.setNimi("Google");
        googleTyyppi.setVari("#4285F4");

        String payload = """
            {
              "kind": "calendar#events",
              "items": [
                {
                  "id": "evt-1",
                  "status": "confirmed",
                  "htmlLink": "https://calendar.google.com/calendar/event?eid=evt-1",
                  "created": "2026-09-01T10:00:00.000Z",
                  "updated": "2026-09-02T11:00:00.000Z",
                  "summary": "Sopimuspalaveri",
                  "description": "Kuvaus realistisesta tapahtumasta",
                  "start": { "dateTime": "2026-10-05T09:15:00+03:00" },
                  "end": { "dateTime": "2026-10-05T10:00:00+03:00" },
                  "transparency": "opaque",
                  "organizer": { "email": "user@example.com" }
                },
                {
                  "id": "evt-2",
                  "status": "cancelled",
                  "summary": "Peruttu tapahtuma",
                  "start": { "date": "2026-10-06" },
                  "end": { "date": "2026-10-07" }
                }
              ]
            }
            """;

        List<Tapahtuma> tapahtumat = service.parseEvents(payload, kayttaja, googleTyyppi);

        assertEquals(1, tapahtumat.size());
        assertEquals("Sopimuspalaveri", tapahtumat.get(0).getOtsikko());
        assertEquals("Kuvaus realistisesta tapahtumasta", tapahtumat.get(0).getKuvaus());
    }

      @Test
      void shouldKeepLongGoogleEventDescriptions() {
        GoogleCalendarSyncService service = new GoogleCalendarSyncService();
        Kayttaja kayttaja = new Kayttaja();
        TapahtumaTyyppi googleTyyppi = new TapahtumaTyyppi();
        String description = "Tapahtuman lisätieto ".repeat(30);
        String payload = """
          {"items":[{"summary":"Pitkä kuvaus","description":"%s",
           "start":{"dateTime":"2026-10-05T09:15:00+03:00"}}]}
          """.formatted(description);

        List<Tapahtuma> tapahtumat = service.parseEvents(payload, kayttaja, googleTyyppi);

        assertEquals(description, tapahtumat.get(0).getKuvaus());
      }
}
