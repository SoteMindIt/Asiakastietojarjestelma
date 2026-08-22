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

	// 1. REITTI: Näyttää järjestelmän asetussivun ja lataa kaikki tarvittavat
	// tiedot
	@GetMapping("/asetukset")
	public String naytaAsetukset(HttpSession session, Model model) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		// Haetaan nykyisen käyttäjän tiedot roolitarkistusta varten
		kayttajaRepository.findByKayttajatunnus(istuntoTunnus)
				.orElseThrow(() -> new IllegalArgumentException("Käyttäjää ei löydy"));


		// Viedään kaikki käyttäjät listaukseen (tämä korjaa aiemman virheen)
		List<Kayttaja> kaikkiKayttajat = kayttajaRepository.findAll();
		model.addAttribute("kayttajat", kaikkiKayttajat);

		// Viedään tuoterekisterin tiedot
		List<Tuote> kaikkiTuotteet = tuoteRepository.findAll();
		model.addAttribute("tuotteet", kaikkiTuotteet);

		// Tähän voit lisätä oman yrityksesi tiedon hakemisen, jos sinulla on sille oma
		// repo:
		// model.addAttribute("yritys", yritysRepository.findFirst());

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
		Kayttaja muokattava = kayttajaRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Muokattavaa käyttäjää ei löydy ID:llä: " + id));

		// Päivitetään muuttuneet perustiedot ja rooli
		muokattava.setEtunimi(etunimi);
		muokattava.setSukunimi(sukunimi);
		muokattava.setSahkoposti(sahkoposti);
		muokattava.setPuhelin(puhelin);
		muokattava.setRooli(rooli);

		kayttajaRepository.save(muokattava);
		return "redirect:/asetukset?success=user_updated";
	}
}
