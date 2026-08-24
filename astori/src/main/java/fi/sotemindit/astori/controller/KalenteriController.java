package fi.sotemindit.astori.controller;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import fi.sotemindit.astori.model.Kayttaja;
import fi.sotemindit.astori.model.Tapahtuma;
import fi.sotemindit.astori.model.TapahtumaTyyppi;
import fi.sotemindit.astori.model.Loki;
import fi.sotemindit.astori.repository.AsiakasRepository;
import fi.sotemindit.astori.repository.TapahtumaRepository;
import fi.sotemindit.astori.repository.KayttajaRepository;
import fi.sotemindit.astori.repository.LokiRepository;
import jakarta.servlet.http.HttpSession;

@Controller
public class KalenteriController {

	@Autowired
	private TapahtumaRepository tapahtumaRepository;

	@Autowired
	private AsiakasRepository asiakasRepository;

	@Autowired
	private KayttajaRepository kayttajaRepository;

	@Autowired
	private LokiRepository lokiRepository; // Auditoitavuutta varten

	// 1. REITTI: Näyttää kalenterin (Riippuen roolista: ADMIN näkee kaikki, USER vain omansa)
	@GetMapping("/kalenteri")
	public String naytaKalenteri(HttpSession session, Model model) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		// Haetaan kirjautunut käyttäjä roolitarkistusta varten
		Kayttaja nykyinenKayttaja = kayttajaRepository.findByKayttajatunnus(istuntoTunnus)
				.orElseThrow(() -> new IllegalArgumentException("Käyttäjää ei löytynyt"));

		model.addAttribute("asiakkaat", asiakasRepository.findAll());
		model.addAttribute("tyypit", TapahtumaTyyppi.values());

		List<Tapahtuma> tapahtumat;
		
		// Jos käyttäjä on ADMIN, ladataan kaikki järjestelmän kalenterimerkinnät
		if ("ADMIN".equals(nykyinenKayttaja.getRooli())) {
			tapahtumat = tapahtumaRepository.findAll();
			lokiRepository.save(new Loki(istuntoTunnus, "KATSELU", "Pääkäyttäjä avasi kaikkien työntekijöiden kalenterinäkymän."));
		} else {
			// Tavallinen työntekijä näkee vain omansa
			tapahtumat = tapahtumaRepository.findByKayttajatunnus(istuntoTunnus);
		}
		
		model.addAttribute("tapahtumat", tapahtumat);
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

		Kayttaja nykyinenKayttaja = kayttajaRepository.findByKayttajatunnus(istuntoTunnus)
				.orElseThrow(() -> new IllegalArgumentException("Käyttäjää ei löytynyt"));

		Tapahtuma uusiTapahtuma = new Tapahtuma(otsikko, kuvaus, ajankohta, tyyppi, asiakas, nykyinenKayttaja);
		tapahtumaRepository.save(uusiTapahtuma);

		// Lisätään lokimerkintä uuden tapahtuman luonnista
		lokiRepository.save(new Loki(istuntoTunnus, "LISÄYS", "Luotu uusi kalenteritapahtuma: '" + otsikko + "' asiakkaalle ID: " + asiakasId));

		return "redirect:/kalenteri";
	}

	// 3. REITTI: Poistaa kalenteritapahtuman (Sallittu omistajalle tai ADMINille)
	@PostMapping("/kalenteri/poista")
	public String poistaKalenteriTapahtuma(@RequestParam Long tapahtumaId, HttpSession session) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		Tapahtuma tapahtuma = tapahtumaRepository.findById(tapahtumaId)
				.orElseThrow(() -> new IllegalArgumentException("Tapahtumaa ei löytynyt id-numerolla: " + tapahtumaId));

		Kayttaja nykyinenKayttaja = kayttajaRepository.findByKayttajatunnus(istuntoTunnus)
				.orElseThrow(() -> new IllegalArgumentException("Käyttäjää ei löytynyt"));

		// TIETOTURVAVARMISTUS: Sallitaan poisto, jos käyttäjä on tapahtuman luoja TAI jos käyttäjä on ADMIN
		boolean onOmistaja = tapahtuma.getKayttaja().getKayttajatunnus().equals(istuntoTunnus);
		boolean onAdmin = "ADMIN".equals(nykyinenKayttaja.getRooli());

		if (!onOmistaja && !onAdmin) {
			throw new SecurityException("Sinulla ei ole oikeutta poistaa tämän käyttäjän tapahtumia!");
		}

		tapahtumaRepository.delete(tapahtuma);

		// Lokitetaan poisto
		lokiRepository.save(new Loki(istuntoTunnus, "POISTO", "Poistettu kalenteritapahtuma ID: " + tapahtumaId + " (Otsikko: " + tapahtuma.getOtsikko() + ")"));

		return "redirect:/kalenteri";
	}
}
