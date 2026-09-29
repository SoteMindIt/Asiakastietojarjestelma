package fi.sotemindit.astori.controller;

import fi.sotemindit.astori.model.Asiakas;
import fi.sotemindit.astori.model.AsiakasAjo;
import fi.sotemindit.astori.model.Loki;
import fi.sotemindit.astori.repository.AsiakasAjoRepository;
import fi.sotemindit.astori.repository.AsiakasRepository;
import fi.sotemindit.astori.repository.LokiRepository;
import jakarta.servlet.http.HttpSession;
import java.math.BigDecimal;
import java.time.LocalDate;
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
	private LokiRepository lokiRepository;

	@PostMapping("/raportit/ajot/lisaa")
	public String lisaaAjo(@RequestParam Long asiakasId, @RequestParam LocalDate paivamaara,
			@RequestParam String lahtopaikka, @RequestParam String kohde, @RequestParam String tarkoitus,
			@RequestParam BigDecimal alkumatkamittari, @RequestParam BigDecimal loppumatkamittari,
			@RequestParam(defaultValue = "false") boolean edestakainen,
			@RequestParam(required = false) String laskuviite, HttpSession session) {
		String tunnus = kirjautunutKayttaja(session);
		if (tunnus == null) {
			return "redirect:/login";
		}

		Asiakas asiakas = omaAsiakas(asiakasId, tunnus);
		if (asiakas == null || !kelvollinenAjo(lahtopaikka, kohde, tarkoitus, alkumatkamittari, loppumatkamittari)) {
			return "redirect:/raportit?tab=ajotSisalto&ajoVirhe=virheellinen";
		}

		AsiakasAjo ajo = new AsiakasAjo();
		paivitaAjonTiedot(ajo, asiakas, paivamaara, lahtopaikka, kohde, tarkoitus, alkumatkamittari,
				loppumatkamittari, edestakainen, laskuviite);
		asiakasAjoRepository.save(ajo);
		lokiRepository.save(new Loki(tunnus, "LISÄYS", "Lisätty asiakasajo asiakkaalle " + asiakas.getNimi() + "."));
		return ajonRaporttiUrl(ajo);
	}

	@PostMapping("/raportit/ajot/muokkaa/{id}")
	public String muokkaaAjo(@PathVariable Long id, @RequestParam Long asiakasId,
			@RequestParam LocalDate paivamaara, @RequestParam String lahtopaikka, @RequestParam String kohde,
			@RequestParam String tarkoitus, @RequestParam BigDecimal alkumatkamittari,
			@RequestParam BigDecimal loppumatkamittari, @RequestParam(defaultValue = "false") boolean edestakainen,
			@RequestParam(required = false) String laskuviite,
			HttpSession session) {
		String tunnus = kirjautunutKayttaja(session);
		if (tunnus == null) {
			return "redirect:/login";
		}

		AsiakasAjo ajo = omaAjo(id, tunnus);
		Asiakas asiakas = omaAsiakas(asiakasId, tunnus);
		if (ajo == null || asiakas == null
				|| !kelvollinenAjo(lahtopaikka, kohde, tarkoitus, alkumatkamittari, loppumatkamittari)) {
			return "redirect:/raportit?tab=ajotSisalto&ajoVirhe=virheellinen";
		}

		paivitaAjonTiedot(ajo, asiakas, paivamaara, lahtopaikka, kohde, tarkoitus, alkumatkamittari,
				loppumatkamittari, edestakainen, laskuviite);
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

	private Asiakas omaAsiakas(Long asiakasId, String tunnus) {
		return asiakasRepository.findById(asiakasId)
				.filter(asiakas -> asiakas.getKayttaja() != null
						&& tunnus.equals(asiakas.getKayttaja().getKayttajatunnus()))
				.orElse(null);
	}

	private AsiakasAjo omaAjo(Long id, String tunnus) {
		return asiakasAjoRepository.findById(id)
				.filter(ajo -> ajo.getAsiakas().getKayttaja() != null
						&& tunnus.equals(ajo.getAsiakas().getKayttaja().getKayttajatunnus()))
				.orElse(null);
	}

	private boolean kelvollinenAjo(String lahtopaikka, String kohde, String tarkoitus, BigDecimal alku,
			BigDecimal loppu) {
		return lahtopaikka != null && !lahtopaikka.isBlank() && kohde != null && !kohde.isBlank()
				&& tarkoitus != null && !tarkoitus.isBlank() && alku != null && loppu != null
				&& alku.signum() >= 0 && loppu.compareTo(alku) >= 0;
	}

	private void paivitaAjonTiedot(AsiakasAjo ajo, Asiakas asiakas, LocalDate paivamaara, String lahtopaikka,
			String kohde, String tarkoitus, BigDecimal alku, BigDecimal loppu, boolean edestakainen, String laskuviite) {
		ajo.setAsiakas(asiakas);
		ajo.setPaivamaara(paivamaara);
		ajo.setLahtopaikka(lahtopaikka.trim());
		ajo.setKohde(kohde.trim());
		ajo.setTarkoitus(tarkoitus.trim());
		ajo.setEdestakainen(edestakainen);
		ajo.setAlkumatkamittari(alku);
		ajo.setLoppumatkamittari(loppu);
		ajo.setLaskuviite(laskuviite == null || laskuviite.isBlank() ? null : laskuviite.trim());
	}

	private String ajonRaporttiUrl(AsiakasAjo ajo) {
		String paivamaara = ajo.getPaivamaara().toString();
		return "redirect:/raportit?tab=ajotSisalto&ajoAlku=" + paivamaara + "&ajoLoppu=" + paivamaara
				+ "&ajoAsiakas=" + ajo.getAsiakas().getId();
	}
}