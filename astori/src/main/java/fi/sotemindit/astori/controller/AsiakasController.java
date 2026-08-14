package fi.sotemindit.astori.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import fi.sotemindit.astori.model.Asiakas;
import fi.sotemindit.astori.model.Kirjaus;
import fi.sotemindit.astori.model.Yhteyshenkilo;
import fi.sotemindit.astori.repository.AsiakasRepository;
import fi.sotemindit.astori.repository.KayttajaRepository;
import fi.sotemindit.astori.repository.KirjausRepository;
import fi.sotemindit.astori.repository.YhteyshenkiloRepository;

@Controller
public class AsiakasController {

	@Autowired
	private AsiakasRepository asiakasRepository;

	@Autowired
	private YhteyshenkiloRepository yhteyshenkiloRepository;

	@Autowired
	private KirjausRepository kirjausRepository;

	@Autowired
	private KayttajaRepository kayttajaRepository;

	// 1. PÄÄSIVU: Listaa kaikki asiakkaat
	@GetMapping("/")
	public String listaaAsiakkaat(jakarta.servlet.http.HttpSession session, Model model) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login"; // Jos ei ole kirjautunut, heitetään kirjautumissivulle
		}

		List<Asiakas> asiakkaat = asiakasRepository.findAll();
		model.addAttribute("asiakkaat", asiakkaat);
		return "index";
	}

	// 2. ASIAKKAAN LISÄYS: Tallentaa uuden asiakkaan tiedot
	@PostMapping("/lisaa-asiakas")
	public String lisaaAsiakas(jakarta.servlet.http.HttpSession session, @RequestParam String nimi,
			@RequestParam String sahkoposti, @RequestParam String puhelin) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		// Etsitään kuka on kirjautunut sisään
		fi.sotemindit.astori.model.Kayttaja nykyinenKayttaja = kayttajaRepository.findByKayttajatunnus(istuntoTunnus)
				.orElseThrow(() -> new IllegalArgumentException("Käyttäjää ei löydy"));

		// Luodaan asiakas ja asetetaan hänelle tämä käyttäjä omistajaksi
		Asiakas uusiAsiakas = new Asiakas(nimi, sahkoposti, puhelin);
		uusiAsiakas.setKayttaja(nykyinenKayttaja); // TÄMÄ LINKITTÄÄ ASIAKKAAN KÄYTTÄJÄÄN

		asiakasRepository.save(uusiAsiakas);
		return "redirect:/";
	}

	// 3. ASIAKASPROFIILI: Näyttää yhden asiakkaan tarkemmat tiedot, yhteyshenkilöt
	// ja kirjaukset
	@GetMapping("/asiakas/{id}")
	public String naytaAsiakas(jakarta.servlet.http.HttpSession session, @PathVariable Long id, Model model) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login"; // Jos ei ole kirjautunut, heitetään kirjautumissivulle
		}

		Asiakas asiakas = asiakasRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Asiakasta ei löytynyt ID-numerolla: " + id));

		List<Yhteyshenkilo> yhteyshenkilot = yhteyshenkiloRepository.findByAsiakasId(id);
		List<Kirjaus> kirjaukset = kirjausRepository.findByAsiakasIdOrderByLuontiaikaDesc(id);

		model.addAttribute("asiakas", asiakas);
		model.addAttribute("yhteyshenkilot", yhteyshenkilot);
		model.addAttribute("kirjaukset", kirjaukset);

		return "asiakasprofiili"; // Etsii asiakasprofiili-nimistä näkymää
	}

	// 4. YHTEYSHENKILÖN LISÄYS: Linkittää uuden henkilön tiettyyn asiakkaaseen
	@PostMapping("/asiakas/{asiakasId}/lisaa-yhteyshenkilo")
	public String lisaaYhteyshenkilo(jakarta.servlet.http.HttpSession session, @PathVariable Long asiakasId,
			@RequestParam String nimi, @RequestParam String rooli, @RequestParam String sahkoposti,
			@RequestParam String puhelin) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login"; // Jos ei ole kirjautunut, heitetään kirjautumissivulle
		}
		Asiakas asiakas = asiakasRepository.findById(asiakasId)
				.orElseThrow(() -> new IllegalArgumentException("Asiakasta ei löytynyt"));

		Yhteyshenkilo uusiHenkilo = new Yhteyshenkilo(nimi, rooli, sahkoposti, puhelin, asiakas);
		yhteyshenkiloRepository.save(uusiHenkilo);

		return "redirect:/asiakas/" + asiakasId; // Palaa profiiliin
	}

	// 5. KIRJAUKSEN LISÄYS: Tallentaa uuden lokimerkinnän asiakkaalle
	@PostMapping("/asiakas/{asiakasId}/lisaa-kirjaus")
	public String lisaaKirjaus(jakarta.servlet.http.HttpSession session, @PathVariable Long asiakasId,
			@RequestParam String teksti) {

		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login"; // Jos ei ole kirjautunut, heitetään kirjautumissivulle
		}
		Asiakas asiakas = asiakasRepository.findById(asiakasId)
				.orElseThrow(() -> new IllegalArgumentException("Asiakasta ei löytynyt"));

		Kirjaus uusiKirjaus = new Kirjaus(teksti, asiakas);
		kirjausRepository.save(uusiKirjaus);

		return "redirect:/asiakas/" + asiakasId; // Palaa profiiliin
	}
}