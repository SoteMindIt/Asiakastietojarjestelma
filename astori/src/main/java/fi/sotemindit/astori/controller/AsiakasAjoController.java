package fi.sotemindit.astori.controller;

import fi.sotemindit.astori.model.Asiakas;
import fi.sotemindit.astori.model.AsiakasAjo;
import fi.sotemindit.astori.model.Kayttaja;
import fi.sotemindit.astori.model.Loki;
import fi.sotemindit.astori.repository.AsiakasAjoRepository;
import fi.sotemindit.astori.repository.AsiakasRepository;
import fi.sotemindit.astori.repository.KayttajaRepository;
import fi.sotemindit.astori.repository.LokiRepository;
import jakarta.servlet.http.HttpSession;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class AsiakasAjoController {

	@Autowired
	private AsiakasAjoRepository asiakasAjoRepository;

	@Autowired
	private AsiakasRepository asiakasRepository;

	@Autowired
	private KayttajaRepository kayttajaRepository;

	@Autowired
	private LokiRepository lokiRepository;

	@PostMapping("/raportit/ajot/lisaa")
	public String lisaaAjo(@RequestParam(required = false) List<Long> asiakasIds, @RequestParam LocalDate paivamaara,
			@RequestParam String lahtopaikka, @RequestParam String kohde, @RequestParam String tarkoitus,
			@RequestParam BigDecimal alkumatkamittari, @RequestParam BigDecimal loppumatkamittari,
			@RequestParam(defaultValue = "false") boolean edestakainen, HttpSession session) {
		String tunnus = kirjautunutKayttaja(session);
		if (tunnus == null) {
			return "redirect:/login";
		}

		Kayttaja luoja = kayttajaRepository.findByKayttajatunnus(tunnus).orElse(null);
		List<Asiakas> asiakkaat = omatAsiakkaat(asiakasIds, tunnus);
		if (luoja == null || asiakkaat == null
				|| !kelvollinenAjo(lahtopaikka, kohde, tarkoitus, alkumatkamittari, loppumatkamittari)) {
			return "redirect:/raportit?tab=ajotSisalto&ajoVirhe=virheellinen";
		}

		AsiakasAjo ajo = new AsiakasAjo();
		paivitaAjonTiedot(ajo, asiakkaat, luoja, paivamaara, lahtopaikka, kohde, tarkoitus,
				alkumatkamittari, loppumatkamittari, edestakainen);
		asiakasAjoRepository.save(ajo);
		lokiRepository.save(new Loki(tunnus, "LISÄYS", "Lisätty ajopäiväkirjamerkintä."));
		return ajonRaporttiUrl(ajo);
	}

	@PostMapping("/raportit/ajot/muokkaa/{id}")
	public String muokkaaAjo(@PathVariable Long id, @RequestParam(required = false) List<Long> asiakasIds,
			@RequestParam LocalDate paivamaara, @RequestParam String lahtopaikka, @RequestParam String kohde,
			@RequestParam String tarkoitus, @RequestParam BigDecimal alkumatkamittari,
			@RequestParam BigDecimal loppumatkamittari, @RequestParam(defaultValue = "false") boolean edestakainen,
			HttpSession session) {
		String tunnus = kirjautunutKayttaja(session);
		if (tunnus == null) {
			return "redirect:/login";
		}

		Kayttaja luoja = kayttajaRepository.findByKayttajatunnus(tunnus).orElse(null);
		AsiakasAjo ajo = omaAjo(id, tunnus);
		List<Asiakas> asiakkaat = omatAsiakkaat(asiakasIds, tunnus);
		if (luoja == null || ajo == null || asiakkaat == null
				|| !kelvollinenAjo(lahtopaikka, kohde, tarkoitus, alkumatkamittari, loppumatkamittari)) {
			return "redirect:/raportit?tab=ajotSisalto&ajoVirhe=virheellinen";
		}

		paivitaAjonTiedot(ajo, asiakkaat, luoja, paivamaara, lahtopaikka, kohde, tarkoitus,
				alkumatkamittari, loppumatkamittari, edestakainen);
		asiakasAjoRepository.save(ajo);
		lokiRepository.save(new Loki(tunnus, "MUOKKAUS", "Muokattu asiakasajo (ID: " + id + ")."));
		return ajonRaporttiUrl(ajo);
	}

	@PostMapping("/raportit/ajot/poista/{id}")
	public String poistaAjo(@PathVariable Long id, HttpSession session) {
		String tunnus = kirjautunutKayttaja(session);
		if (tunnus == null) {
			return "redirect:/login";
		}

		AsiakasAjo ajo = omaAjo(id, tunnus);
		if (ajo != null) {
			asiakasAjoRepository.delete(ajo);
			lokiRepository.save(new Loki(tunnus, "POISTO", "Poistettu asiakasajo (ID: " + id + ")."));
		}
		return "redirect:/raportit?tab=ajotSisalto";
	}

	private String kirjautunutKayttaja(HttpSession session) {
		return (String) session.getAttribute("kirjautunutKayttaja");
	}

	private List<Asiakas> omatAsiakkaat(List<Long> asiakasIds, String tunnus) {
		if (asiakasIds == null || asiakasIds.isEmpty()) {
			return List.of();
		}

		List<Long> yksilollisetIds = asiakasIds.stream().distinct().toList();
		List<Asiakas> asiakkaat = new ArrayList<>();
		asiakasRepository.findAllById(yksilollisetIds).forEach(asiakkaat::add);
		if (asiakkaat.size() != yksilollisetIds.size()
				|| asiakkaat.stream().anyMatch(asiakas -> asiakas.getKayttaja() == null
						|| !tunnus.equals(asiakas.getKayttaja().getKayttajatunnus()))) {
			return null;
		}
		return asiakkaat;
	}

	private AsiakasAjo omaAjo(Long id, String tunnus) {
		return asiakasAjoRepository.findById(id)
				.filter(ajo -> (ajo.getLuoja() != null && tunnus.equals(ajo.getLuoja().getKayttajatunnus()))
						|| (!ajo.getAsiakkaat().isEmpty() && ajo.getAsiakkaat().stream()
								.allMatch(asiakas -> asiakas.getKayttaja() != null
										&& tunnus.equals(asiakas.getKayttaja().getKayttajatunnus()))))
				.orElse(null);
	}

	private boolean kelvollinenAjo(String lahtopaikka, String kohde, String tarkoitus, BigDecimal alku,
			BigDecimal loppu) {
		return lahtopaikka != null && !lahtopaikka.isBlank() && kohde != null && !kohde.isBlank()
				&& tarkoitus != null && !tarkoitus.isBlank() && alku != null && loppu != null
				&& alku.signum() >= 0 && loppu.compareTo(alku) >= 0;
	}

	private void paivitaAjonTiedot(AsiakasAjo ajo, List<Asiakas> asiakkaat, Kayttaja luoja,
			LocalDate paivamaara, String lahtopaikka, String kohde, String tarkoitus,
			BigDecimal alku, BigDecimal loppu, boolean edestakainen) {
		ajo.setAsiakkaat(asiakkaat);
		ajo.setLuoja(luoja);
		ajo.setPaivamaara(paivamaara);
		ajo.setLahtopaikka(lahtopaikka.trim());
		ajo.setKohde(kohde.trim());
		ajo.setTarkoitus(tarkoitus.trim());
		ajo.setEdestakainen(edestakainen);
		ajo.setAlkumatkamittari(alku);
		ajo.setLoppumatkamittari(loppu);
	}

	private String ajonRaporttiUrl(AsiakasAjo ajo) {
		String paivamaara = ajo.getPaivamaara().toString();
		return "redirect:/raportit?tab=ajotSisalto&ajoAlku=" + paivamaara + "&ajoLoppu=" + paivamaara;
	}
}