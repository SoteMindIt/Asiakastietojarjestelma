package fi.sotemindit.astori.controller;

import java.math.BigDecimal;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import fi.sotemindit.astori.model.Tuote;
import fi.sotemindit.astori.model.TuoteYksikko;
import fi.sotemindit.astori.model.Kayttaja;
import fi.sotemindit.astori.model.Yritystiedot;
import fi.sotemindit.astori.repository.TuoteRepository;
import fi.sotemindit.astori.repository.KayttajaRepository;
import fi.sotemindit.astori.repository.YritystiedotRepository;
import jakarta.servlet.http.HttpSession;

@Controller
public class AsetuksetController {

	@Autowired
	private TuoteRepository tuoteRepository;

	@Autowired
	private KayttajaRepository kayttajaRepository;

	@Autowired
	private YritystiedotRepository yritystiedotRepository;

	@Autowired
	private BCryptPasswordEncoder passwordEncoder;

	// 1. REITTI: Näyttää asetussivun
	@GetMapping("/asetukset")
	public String naytaAsetukset(HttpSession session, Model model) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		List<Tuote> tuotteet = tuoteRepository.findAll();
		List<Kayttaja> kayttajat = kayttajaRepository.findAll();
		Yritystiedot yritys = yritystiedotRepository.findById(1L).orElse(new Yritystiedot());

		model.addAttribute("tuotteet", tuotteet);
		model.addAttribute("kayttajat", kayttajat);
		model.addAttribute("yritys", yritys);

		return "asetukset";
	}

	// 2. REITTI: Näyttää tuotteen lisäyslomakkeen
	@GetMapping("/asetukset/uusi")
	public String naytaLisaaTuoteSivu(HttpSession session) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}
		return "lisaa-tuote";
	}

	// 3. REITTI: Tuotteen tallennus
	@PostMapping("/asetukset/lisaa-tuote")
	public String lisaaTuote(HttpSession session, @RequestParam String nimi, @RequestParam String kuvaus,
			@RequestParam BigDecimal hinta, @RequestParam TuoteYksikko yksikko) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		Tuote uusiTuote = new Tuote(nimi, kuvaus, hinta, yksikko);
		tuoteRepository.save(uusiTuote);

		return "redirect:/asetukset";
	}
	// 4. REITTI: Ottaa vastaan uuden käyttäjän tiedot ja tallentaa ne turvallisesti
	@PostMapping("/asetukset/lisaa-kayttaja")
	public String lisaaKayttaja(HttpSession session, @RequestParam String tunnus, @RequestParam String salasana,
			@RequestParam String etunimi, @RequestParam String sukunimi, @RequestParam String sahkoposti,
			@RequestParam String puhelin, Model model) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		// Varmistetaan, ettei tunnus ole jo varattu
		if (kayttajaRepository.findByKayttajatunnus(tunnus).isPresent()) {
			return "redirect:/asetukset?virhe=tunnus_varattu";
		}

		// Kryptataan salasana ennen tallennusta
		String suojattuSalasana = passwordEncoder.encode(salasana);

		Kayttaja uusiKayttaja = new Kayttaja(tunnus, suojattuSalasana, etunimi, sukunimi, sahkoposti, puhelin);
		kayttajaRepository.save(uusiKayttaja);

		return "redirect:/asetukset";
	}

	// 5. REITTI: Ottaa vastaan yrityksen tiedot ja tallentaa/päivittää ne kiinteälle ID:lle 1
	@PostMapping("/asetukset/tallenna-yritys")
	public String tallennaYritystiedot(HttpSession session, @RequestParam String nimi, @RequestParam String yTunnus,
			@RequestParam String sahkoposti, @RequestParam String puhelin, @RequestParam String osoite,
			@RequestParam String iban, @RequestParam String bic) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		// Haetaan olemassa oleva rivi tai luodaan uusi, jos tietokanta on tyhjä
		Yritystiedot yritys = yritystiedotRepository.findById(1L).orElse(new Yritystiedot());

		// Päivitetään lomakkeen kentät
		yritys.setNimi(nimi);
		yritys.setyTunnus(yTunnus);
		yritys.setSahkoposti(sahkoposti);
		yritys.setPuhelin(puhelin);
		yritys.setOsoite(osoite);
		yritys.setIban(iban);
		yritys.setBic(bic);

		// Tallennetaan PostgreSQL:ään
		yritystiedotRepository.save(yritys);

		return "redirect:/asetukset?tallennettu=true";
	}
}
