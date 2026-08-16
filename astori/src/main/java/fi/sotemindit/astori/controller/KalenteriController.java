package fi.sotemindit.astori.controller;

import java.time.LocalDateTime;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import fi.sotemindit.astori.model.Kayttaja;
import fi.sotemindit.astori.model.Tapahtuma;
import fi.sotemindit.astori.model.TapahtumaTyyppi;
import fi.sotemindit.astori.repository.AsiakasRepository;
import fi.sotemindit.astori.repository.TapahtumaRepository;
import fi.sotemindit.astori.repository.KayttajaRepository;
import jakarta.servlet.http.HttpSession;

@Controller
public class KalenteriController {

	@Autowired
	private TapahtumaRepository tapahtumaRepository;

	@Autowired
	private AsiakasRepository asiakasRepository;

	@Autowired
	private KayttajaRepository kayttajaRepository; // Lisää tämä repositorio alkuun

	// 1. REITTI: Näyttää VAIN OMAN kalenterin
	@GetMapping("/kalenteri")
	public String naytaKalenteri(HttpSession session, Model model) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		model.addAttribute("asiakkaat", asiakasRepository.findAll());
		model.addAttribute("tyypit", TapahtumaTyyppi.values());

		// Päivitetty vastaamaan uutta siistiä metodin nimeä
		model.addAttribute("tapahtumat", tapahtumaRepository.findByKayttajatunnus(istuntoTunnus));

		return "kalenteri";
	}

	// 2. REITTI: Tallentaa uuden kalenterimerkinnän ja linkittää sen käyttäjään
	@PostMapping("/kalenteri/lisaa")
	public String lisaaKalenteriTapahtuma(@RequestParam String otsikko, @RequestParam String kuvaus,
			@RequestParam String ajankohtaStr, @RequestParam TapahtumaTyyppi tyyppi, @RequestParam Long asiakasId,
			HttpSession session) {

		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		LocalDateTime ajankohta = LocalDateTime.parse(ajankohtaStr);

		fi.sotemindit.astori.model.Asiakas asiakas = asiakasRepository.findById(asiakasId)
				.orElseThrow(() -> new IllegalArgumentException("Asiakasta ei löytynyt"));

		// HAETAAN KIRJAUTUNUT KÄYTTÄJÄ TIETOKANNASTA
		Kayttaja nykyinenKayttaja = kayttajaRepository.findByKayttajatunnus(istuntoTunnus)
				.orElseThrow(() -> new IllegalArgumentException("Käyttäjää ei löytynyt"));

		// Luodaan tapahtuma ja annetaan sille myös nykyinen käyttäjä
		Tapahtuma uusiTapahtuma = new Tapahtuma(otsikko, kuvaus, ajankohta, tyyppi, asiakas, nykyinenKayttaja);
		tapahtumaRepository.save(uusiTapahtuma);

		return "redirect:/kalenteri";
	}

	// 3. REITTI: Poistaa kalenteritapahtuman
	@PostMapping("/kalenteri/poista")
	public String poistaKalenteriTapahtuma(@RequestParam Long tapahtumaId, HttpSession session) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		// Haetaan poistettava tapahtuma
		Tapahtuma tapahtuma = tapahtumaRepository.findById(tapahtumaId)
				.orElseThrow(() -> new IllegalArgumentException("Tapahtumaa ei löytynyt id-numerolla: " + tapahtumaId));

		// TIETOTURVAVARMISTUS: Varmistetaan, että tapahtuma kuuluu kirjautuneelle
		// käyttäjälle
		if (!tapahtuma.getKayttaja().getKayttajatunnus().equals(istuntoTunnus)) {
			throw new SecurityException("Sinulla ei ole oikeutta poistaa tämän käyttäjän tapahtumia!");
		}

		// Poistetaan tapahtuma tietokannasta
		tapahtumaRepository.delete(tapahtuma);

		return "redirect:/kalenteri"; // Palataan takaisin kalenterinäkymään
	}

}
