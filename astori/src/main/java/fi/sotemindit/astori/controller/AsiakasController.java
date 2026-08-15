package fi.sotemindit.astori.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import org.springframework.web.multipart.MultipartFile;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpHeaders;
import fi.sotemindit.astori.model.Liitetiedosto;
import fi.sotemindit.astori.repository.LiitetiedostoRepository;
import fi.sotemindit.astori.model.Asiakas;
import fi.sotemindit.astori.model.AsiakasTuote;
import fi.sotemindit.astori.model.AsiakkaanTila;
import fi.sotemindit.astori.model.Kirjaus;
import fi.sotemindit.astori.model.Tuote;
import fi.sotemindit.astori.model.Yhteyshenkilo;
import fi.sotemindit.astori.repository.AsiakasRepository;
import fi.sotemindit.astori.repository.KayttajaRepository;
import fi.sotemindit.astori.repository.KirjausRepository;
import fi.sotemindit.astori.repository.YhteyshenkiloRepository;
import fi.sotemindit.astori.repository.TuoteRepository;
import fi.sotemindit.astori.repository.AsiakasTuoteRepository;

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

	@Autowired
	private TuoteRepository tuoteRepository;

	@Autowired
	private AsiakasTuoteRepository asiakasTuoteRepository;

	@Autowired
	private LiitetiedostoRepository liitetiedostoRepository;

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
			@RequestParam String sahkoposti, @RequestParam String puhelin, @RequestParam AsiakkaanTila tila) { // LISÄTTY
																												// PARAMETRI
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		fi.sotemindit.astori.model.Kayttaja nykyinenKayttaja = kayttajaRepository.findByKayttajatunnus(istuntoTunnus)
				.orElseThrow(() -> new IllegalArgumentException("Käyttäjää ei löydy"));

		// Luodaan asiakas uudella konstruktorilla
		Asiakas uusiAsiakas = new Asiakas(nimi, sahkoposti, puhelin, tila);
		uusiAsiakas.setKayttaja(nykyinenKayttaja);

		asiakasRepository.save(uusiAsiakas);
		return "redirect:/";
	}

	// 3. ASIAKASPROFIILI: Näyttää yhden asiakkaan tarkemmat tiedot, yhteyshenkilöt
	// ja kirjaukset
	@GetMapping("/asiakas/{id}")
	public String naytaAsiakas(@PathVariable Long id, jakarta.servlet.http.HttpSession session, Model model) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		Asiakas asiakas = asiakasRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Asiakasta ei löytynyt ID-numerolla: " + id));
		List<Liitetiedosto> liitteet = liitetiedostoRepository.findByAsiakasIdOrderByLatausaikaDesc(id);
		List<Yhteyshenkilo> yhteyshenkilot = yhteyshenkiloRepository.findByAsiakasId(id);
		List<Kirjaus> kirjaukset = kirjausRepository.findByAsiakasIdOrderByLuontiaikaDesc(id);

		// HAETAAN REKISTERISTÄ TUOTTEET JA ASIAKKAAN OSTOT:
		List<Tuote> tuoteLista = tuoteRepository.findAll();
		List<AsiakasTuote> ostetutTuotteet = asiakasTuoteRepository.findByAsiakasId(id);

		model.addAttribute("asiakas", asiakas);
		model.addAttribute("liitteet", liitteet);
		model.addAttribute("yhteyshenkilot", yhteyshenkilot);
		model.addAttribute("kirjaukset", kirjaukset);
		model.addAttribute("ostetutTuotteet", ostetutTuotteet);
		model.addAttribute("kaikkiTuotteet", tuoteLista);
		liitetiedostoRepository.findByAsiakasIdOrderByLatausaikaDesc(id);
		model.addAttribute("liitteet", liitteet);

		return "asiakasprofiili";
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

	@PostMapping("/asiakas/{asiakasId}/lisaa-tuote")
	public String kirjaaMyynti(@PathVariable Long asiakasId, @RequestParam Long tuoteId, @RequestParam Integer maara, // UUSI
																														// LOMAKEPARAMETRI
			jakarta.servlet.http.HttpSession session) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		Asiakas asiakas = asiakasRepository.findById(asiakasId)
				.orElseThrow(() -> new IllegalArgumentException("Asiakasta ei löytynyt"));
		Tuote tuote = tuoteRepository.findById(tuoteId)
				.orElseThrow(() -> new IllegalArgumentException("Tuotetta ei löytynyt"));

		// Tallennetaan myynti annetulla määrällä ja tuotteen sen hetkisellä hinnalla
		fi.sotemindit.astori.model.AsiakasTuote uusiMyynti = new fi.sotemindit.astori.model.AsiakasTuote(asiakas, tuote,
				tuote.getHinta(), maara);

		asiakasTuoteRepository.save(uusiMyynti);

		return "redirect:/asiakas/" + asiakasId;
	}

	// 7. ASIAKKAAN MUOKKAUS: Päivittää asiakkaan perustiedot ja tilan
	@PostMapping("/asiakas/{id}/muokkaa")
	public String muokkaaAsiakasta(@PathVariable Long id, @RequestParam String nimi, @RequestParam String sahkoposti,
			@RequestParam String puhelin, @RequestParam fi.sotemindit.astori.model.AsiakkaanTila tila,
			jakarta.servlet.http.HttpSession session) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		Asiakas asiakas = asiakasRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Asiakasta ei löytynyt ID-numerolla: " + id));

		// Päivitetään uudet tiedot entiteettiin
		asiakas.setNimi(nimi);
		asiakas.setSahkoposti(sahkoposti);
		asiakas.setPuhelin(puhelin);
		asiakas.setTila(tila);

		asiakasRepository.save(asiakas); // Tallentaa muutokset PostgreSQL-tietokantaan

		return "redirect:/asiakas/" + id;
	}

	// 8. ASIAKKAAN POISTO: Poistaa asiakkaan ja kaikki siihen liittyvät tiedot
	// cascade-ominaisuudella
	@PostMapping("/asiakas/{id}/poista")
	public String poistaAsiakas(@PathVariable Long id, jakarta.servlet.http.HttpSession session) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login"; // Tietoturvatarkistus
		}

		// Varmistetaan, että asiakas on olemassa ennen poistoa
		if (asiakasRepository.existsById(id)) {
			asiakasRepository.deleteById(id); // Suorittaa poiston
		}

		return "redirect:/"; // Poiston jälkeen palataan suoraan pääsivulle asiakaslistaukseen
	}

	// 9. LIITETIEDOSTON TALLENNUS: Ottaa vastaan PDF-tiedoston ja tallentaa sen
	// kantaan tavuina
	@PostMapping("/asiakas/{asiakasId}/lisaa-liite")
	public String lisaaLiitetiedosto(@PathVariable Long javaAsiakasId, // Käytetään polkumuuttujaa
			@PathVariable("asiakasId") Long asiakasId, @RequestParam("tiedosto") MultipartFile tiedosto,
			@RequestParam String kuvaus, jakarta.servlet.http.HttpSession session) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		if (!tiedosto.isEmpty()) {
			try {
				// Varmistetaan, että kyseessä on PDF-tiedosto
				String contentType = tiedosto.getContentType();
				if (contentType == null || !contentType.equalsIgnoreCase("application/pdf")) {
					return "redirect:/asiakas/" + asiakasId + "?virhe=vain_pdf_sallittu";
				}

				Asiakas asiakas = asiakasRepository.findById(asiakasId)
						.orElseThrow(() -> new IllegalArgumentException("Asiakasta ei löytynyt"));

				// Luodaan uusi liitetiedosto-olio ja luetaan tiedoston sisältö tavutaulukoksi
				Liitetiedosto uusiLiite = new Liitetiedosto(tiedosto.getOriginalFilename(), kuvaus, tiedosto.getBytes(),
						asiakas);

				liitetiedostoRepository.save(uusiLiite);

			} catch (Exception e) {
				return "redirect:/asiakas/" + asiakasId + "?virhe=lataus_epaonnistui";
			}
		}
		return "redirect:/asiakas/" + asiakasId;
	}

	// 10. LIITETIEDOSTON LATAUS: Hakee PDF-tiedoston kannasta ja lähettää sen
	// selaimelle avattavaksi
	@GetMapping("/liite/{liiteId}")
	public ResponseEntity<byte[]> lataaLiitetiedosto(@PathVariable Long liiteId,
			jakarta.servlet.http.HttpSession session) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return ResponseEntity.status(403).build(); // Kielletty ilman kirjautumista
		}

		Liitetiedosto liite = liitetiedostoRepository.findById(liiteId)
				.orElseThrow(() -> new IllegalArgumentException("Tiedostoa ei löytynyt"));

		// Rakennetaan HTTP-vastaus, joka käskee selainta avaamaan tai lataamaan
		// tiedoston PDF-muodossa
		return ResponseEntity.ok()
				.header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + liite.getTiedostonNimi() + "\"")
				.header(HttpHeaders.CONTENT_TYPE, "application/pdf").body(liite.getData());
	}

}