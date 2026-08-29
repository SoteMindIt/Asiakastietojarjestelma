package fi.sotemindit.astori.controller;

import java.util.List;
import jakarta.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import fi.sotemindit.astori.model.Kayttaja;
import fi.sotemindit.astori.model.Tuote;
import fi.sotemindit.astori.model.Yritystiedot;
import fi.sotemindit.astori.repository.KayttajaRepository;
import fi.sotemindit.astori.repository.TuoteRepository;

@Controller
public class AsetuksetController {

	@Autowired
	private KayttajaRepository kayttajaRepository;

	@Autowired
	private TuoteRepository tuoteRepository;

	@Autowired
	private BCryptPasswordEncoder passwordEncoder;

	@Autowired
	private fi.sotemindit.astori.repository.YritystiedotRepository yritystiedotRepository;

	// 1. REITTI: Näyttää järjestelmän asetussivun ja lataa kaikki tarvittavat
	// tiedot
	@GetMapping("/asetukset")
	public String naytaAsetukset(HttpSession session, Model model) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		// Haetaan nykyisen käyttäjän tiedot ja varmistetaan olemassaolo
		kayttajaRepository.findByKayttajatunnus(istuntoTunnus)
				.orElseThrow(() -> new IllegalArgumentException("Käyttäjää ei löydy"));

		// Viedään kaikki käyttäjät listaukseen
		List<Kayttaja> kaikkiKayttajat = kayttajaRepository.findAll();
		model.addAttribute("kayttajat", kaikkiKayttajat);

		// Viedään tuoterekisterin tiedot
		List<Tuote> kaikkiTuotteet = tuoteRepository.findAll();
		model.addAttribute("tuotteet", kaikkiTuotteet);
		
		Yritystiedot yritys = yritystiedotRepository.findById(1L).orElse(null);
		model.addAttribute("yritys", yritys);

		return "asetukset"; // Avaa asetukset.jsp
	}

	// 2. REITTI: Luo uuden käyttäjätunnuksen roolivalinnalla (Vain Admin)
	@PostMapping("/asetukset/lisaa-kayttaja")
	public String lisaaKayttaja(HttpSession session, @RequestParam("tunnus") String tunnus,
			@RequestParam("salasana") String salasana, @RequestParam("etunimi") String etunimi,
			@RequestParam("sukunimi") String sukunimi, @RequestParam("sahkoposti") String sahkoposti,
			@RequestParam("puhelin") String puhelin, @RequestParam("rooli") String rooli) {

		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		// Varmistetaan, että tekijä on ADMIN
		Kayttaja tekija = kayttajaRepository.findByKayttajatunnus(istuntoTunnus)
				.orElseThrow(() -> new IllegalArgumentException("Käyttäjää ei löydy"));
		if (!"ADMIN".equals(tekija.getRooli())) {
			return "redirect:/?error=access_denied";
		}

		// Tarkistetaan, onko käyttäjätunnus jo varattu
		if (kayttajaRepository.findByKayttajatunnus(tunnus).isPresent()) {
			return "redirect:/asetukset?virhe=tunnus_varattu";
		}

		// Kryptataan salasana ennen tallennusta tietokantaan
		String kryptattuSalasana = passwordEncoder.encode(salasana);

		// Luodaan uusi käyttäjäolio ja asetetaan sille lomakkeelta tullut rooli
		Kayttaja uusiKayttaja = new Kayttaja(tunnus, kryptattuSalasana, etunimi, sukunimi, sahkoposti, puhelin);
		uusiKayttaja.setRooli(rooli);

		kayttajaRepository.save(uusiKayttaja);
		return "redirect:/asetukset?success=user_created";
	}

	// 3. REITTI: Muokkaa olemassa olevan käyttäjän tietoja ja roolia (Vain Admin)
	@PostMapping("/asetukset/muokkaa-kayttajaa/{id}")
	public String muokkaaKayttajaa(HttpSession session, @PathVariable Long id, @RequestParam String etunimi,
			@RequestParam String sukunimi, @RequestParam String sahkoposti, @RequestParam String puhelin,
			@RequestParam String rooli) {

		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		// Varmistetaan, että muokkaaja on ADMIN
		Kayttaja tekija = kayttajaRepository.findByKayttajatunnus(istuntoTunnus)
				.orElseThrow(() -> new IllegalArgumentException("Käyttäjää ei löydy"));
		if (!"ADMIN".equals(tekija.getRooli())) {
			return "redirect:/?error=access_denied";
		}

		// Haetaan muokattava työntekijä tietokannasta
		Kayttaja muokattava = kayttajaRepository.findById(id).orElseThrow(
				() -> new IllegalArgumentException("Muokattavaa käyttäjää ei löytynyt ID-numerolla: " + id));

		// Päivitetään muuttuneet perustiedot ja rooli
		muokattava.setEtunimi(etunimi);
		muokattava.setSukunimi(sukunimi);
		muokattava.setSahkoposti(sahkoposti);
		muokattava.setPuhelin(puhelin);
		muokattava.setRooli(rooli);

		kayttajaRepository.save(muokattava);
		return "redirect:/asetukset?success=user_updated";
	}

	// 4. REITTI: Näyttää uuden tuotteen lisäyslomakkeen (lisaa-tuote.jsp)
	@GetMapping("/asetukset/lisaa-tuote")
	public String naytaUusiTuoteLomake(HttpSession session) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		// Palauttaa sinun "lisaa-tuote.jsp" -tiedostosi
		return "lisaa-tuote";
	}

	// 5. REITTI: Ottaa vastaan sinun lomakkeesi tiedot sisältäen yksikön
	@PostMapping("/asetukset/lisaa-tuote")
	public String tallennaUusiTuote(HttpSession session, @RequestParam String nimi, @RequestParam String kuvaus,
			@RequestParam java.math.BigDecimal hinta, @RequestParam String yksikko) {

		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		// Luodaan uusi tuoteolio ja asetetaan lomakkeeltasi tulleet arvot
		Tuote uusiTuote = new Tuote();
		uusiTuote.setNimi(nimi);
		uusiTuote.setKuvaus(kuvaus);
		uusiTuote.setHinta(hinta);

		// Muunnetaan lomakkeelta tullut teksti (esim. "KPL") enumin arvoksi.
		try {
			uusiTuote.setYksikko(fi.sotemindit.astori.model.TuoteYksikko.valueOf(yksikko));
		} catch (IllegalArgumentException e) {
			// Jos arvo ei täsmää enumiin, virhe napataan kiinni tässä ilman sovelluksen
			// kaatumista
		}

		tuoteRepository.save(uusiTuote);

		// Ohjataan takaisin asetussivulle onnistumisilmoituksen kanssa
		return "redirect:/asetukset?success=product_created";
	}

	// 6. REITTI: Muokkaa olemassa olevan tuotteen tietoja (UUSI)
	@PostMapping("/asetukset/muokkaa-tuotetta/{id}")
	public String muokkaaTuotetta(HttpSession session, @PathVariable Long id, @RequestParam String nimi,
			@RequestParam String kuvaus, @RequestParam java.math.BigDecimal hinta, @RequestParam String yksikko) {

		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		// Haetaan muokattava tuote tietokannasta
		Tuote muokattava = tuoteRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Tuotetta ei löytynyt ID-numerolla: " + id));

		// Päivitetään uudet tiedot
		muokattava.setNimi(nimi);
		muokattava.setKuvaus(kuvaus);
		muokattava.setHinta(hinta);

		try {
			muokattava.setYksikko(fi.sotemindit.astori.model.TuoteYksikko.valueOf(yksikko));
		} catch (IllegalArgumentException e) {
			// Virheen sattuessa pidetään vanha yksikkö
		}

		tuoteRepository.save(muokattava);
		return "redirect:/asetukset?success=product_updated";
	}

	@PostMapping("/asetukset/tallenna-yritys")
	public String tallennaYrityksenTiedot(HttpSession session, @RequestParam String nimi, @RequestParam String yTunnus,
			@RequestParam(required = false) String sahkoposti, @RequestParam(required = false) String puhelin,
			@RequestParam(required = false) String osoite, @RequestParam(required = false) String iban,
			@RequestParam(required = false) String bic) {

		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		// Haetaan olemassa oleva yritystietorivi tai luodaan uusi, jos kanta on tyhjä
		fi.sotemindit.astori.model.Yritystiedot yritys = yritystiedotRepository.findById(1L)
				.orElse(new fi.sotemindit.astori.model.Yritystiedot());

		// Varmistetaan kiinteä ID 1, jotta rivejä ei synny useampia
		yritys.setId(1L);
		yritys.setNimi(nimi);
		yritys.setyTunnus(yTunnus);
		yritys.setSahkoposti(sahkoposti);
		yritys.setPuhelin(puhelin);
		yritys.setOsoite(osoite);
		yritys.setIban(iban);
		yritys.setBic(bic);

		yritystiedotRepository.save(yritys);

		return "redirect:/asetukset?success=company_updated";
	}

}
