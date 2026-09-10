package fi.sotemindit.astori.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import fi.sotemindit.astori.model.Asiakas;
import fi.sotemindit.astori.model.AsiakasTuote;
import fi.sotemindit.astori.model.AsiakkaanTila;
import fi.sotemindit.astori.model.Hyvinvointialue;
import fi.sotemindit.astori.model.Kirjaus;
import fi.sotemindit.astori.model.Liitetiedosto;
import fi.sotemindit.astori.model.Loki;
import fi.sotemindit.astori.model.Tapahtuma;
import fi.sotemindit.astori.model.Tarjous;
import fi.sotemindit.astori.model.Tuote;
import fi.sotemindit.astori.model.Yhteyshenkilo;
import fi.sotemindit.astori.repository.AsiakasRepository;
import fi.sotemindit.astori.repository.AsiakasTuoteRepository;
import fi.sotemindit.astori.repository.KayttajaRepository;
import fi.sotemindit.astori.repository.KirjausRepository;
import fi.sotemindit.astori.repository.LiitetiedostoRepository;
import fi.sotemindit.astori.repository.TarjousRepository;
import fi.sotemindit.astori.repository.TuoteRepository;
import fi.sotemindit.astori.repository.YhteyshenkiloRepository;
import fi.sotemindit.astori.repository.LokiRepository;
import fi.sotemindit.astori.repository.TapahtumaRepository;
import fi.sotemindit.astori.repository.PalveluyksikkoRepository;

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

	@Autowired
	private TarjousRepository tarjousRepository;

	@Autowired
	private LokiRepository lokiRepository;

	@Autowired
	private TapahtumaRepository tapahtumaRepository;

	@Autowired
	private fi.sotemindit.astori.repository.PalveluyksikkoRepository palveluyksikkoRepository;

	// 1a. PÄIVITETTY ETUSIVU: Lasketaan reaaliaikaiset tiedot tietolaatikoihin
	// (Dashboard)
	@GetMapping("/")
	public String naytaEtusivu(jakarta.servlet.http.HttpSession session, Model model) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		// 1. Haetaan palvelimen reaaliaikainen kellonaika tapahtumille
		java.time.LocalDateTime nyt = java.time.LocalDateTime.now();

		// 2. Haetaan tulevat kalenterimerkinnät etusivun koosteeseen
		List<Tapahtuma> tulevatTapahtumat = tapahtumaRepository
				.findByKayttajaKayttajatunnusAndAjankohtaAfterOrderByAjankohtaAsc(istuntoTunnus, nyt);

		// 📈 3. DYNAAMISET LASKURIT TIETOKANNASTA DASHBOARD-KORTEILLE:
		// Lasketaan vain kyseisen kirjautuneen käyttäjän omat datat
		long asiakkaatYhteensa = asiakasRepository.countByKayttajaKayttajatunnus(istuntoTunnus);
		long tarjouksetYhteensa = tarjousRepository.countByAsiakasKayttajaKayttajatunnus(istuntoTunnus);

		// Tehtävät tälle päivälle (haetaan tämän vuorokauden loppuun asti olevat
		// tehtävät)
		java.time.LocalDateTime vuorokaudenLoppu = java.time.LocalDate.now().atTime(23, 59, 59);
		long tehtavatTanaan = tapahtumaRepository.countByKayttajaKayttajatunnusAndAjankohtaBetween(istuntoTunnus, nyt,
				vuorokaudenLoppu);

		// 🗳️ 4. Viedään laskurit ja datat JSP-sivulle (dashboard.jsp)
		model.addAttribute("tulevatTapahtumat", tulevatTapahtumat);
		model.addAttribute("asiakkaatLaskuri", asiakkaatYhteensa);
		model.addAttribute("tarjouksetLaskuri", tarjouksetYhteensa);
		model.addAttribute("tehtavatLaskuri", tehtavatTanaan);
		model.addAttribute("asiakkaatLaskuri", asiakkaatYhteensa);
		model.addAttribute("tarjouksetLaskuri", tarjouksetYhteensa);
		model.addAttribute("tehtavatLaskuri", tehtavatTanaan);

		return "dashboard";
	}

	// 1b. ASIAKKAAT OMA SIVU: Kaikki asiakkaat, haku ja sivutus siirretty tänne
	@GetMapping("/asiakkaat")
	public String listaaAsiakkaat(jakarta.servlet.http.HttpSession session, @RequestParam(defaultValue = "0") int page,
			@RequestParam(value = "haku", required = false) String haku, Model model) {

		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		// Luodaan sivutuspyyntö: 10 alkiota per sivu, järjestetty nimen mukaan
		// nousevasti
		Pageable pageable = org.springframework.data.domain.PageRequest.of(page, 10,
				org.springframework.data.domain.Sort.by(org.springframework.data.domain.Sort.Direction.ASC, "nimi"));
		Page<Asiakas> asiakasSivu;

		// 🔍 Tarkistetaan hakusana:
		if (haku != null && !haku.trim().isEmpty()) {
			String hakusana = haku.trim();
			asiakasSivu = asiakasRepository.findByKayttajaKayttajatunnusAndHaku(istuntoTunnus, hakusana, pageable);
		} else {
			asiakasSivu = asiakasRepository.findByKayttajaKayttajatunnus(istuntoTunnus, pageable);
		}

		// Viedään tiedot asiakkaat.jsp-sivulle
		model.addAttribute("asiakkaat", asiakasSivu.getContent());
		model.addAttribute("currentPage", page);
		model.addAttribute("totalPages", asiakasSivu.getTotalPages());
		model.addAttribute("tilat", AsiakkaanTila.values());
		model.addAttribute("haku", haku != null ? haku.trim() : "");

		return "asiakkaat"; // 💡 KORJATTU: Avaa uuden asiakkaat.jsp -sivun!
	}

	// 2. ASIAKKAAN LISÄYS: Tallentaa uuden asiakkaan tiedot osoitteineen ja
	// kotisivuineen
	@PostMapping("/lisaa-asiakas")
	public String lisaaAsiakas(jakarta.servlet.http.HttpSession session, @RequestParam String nimi,
			@RequestParam(value = "yTunnus", required = false) String yTunnus,
			@RequestParam(required = false) String kuvaus, // 💡 LISÄTTY PYYNTÖÖN
			@RequestParam(required = false) String sahkoposti, @RequestParam(required = false) String puhelin,
			@RequestParam AsiakkaanTila tila, @RequestParam(required = false) String katuosoite,
			@RequestParam(required = false) String postinumero, @RequestParam(required = false) String postitoimipaikka,
			@RequestParam(required = false) String kotisivu,
			@RequestParam(required = false) Hyvinvointialue hyvinvointialue) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		fi.sotemindit.astori.model.Kayttaja nykyinenKayttaja = kayttajaRepository.findByKayttajatunnus(istuntoTunnus)
				.orElseThrow(() -> new IllegalArgumentException("Käyttäjää ei löydy"));

		// Luodaan uusi asiakas päivitettyyn 10-muuttujaiseen konstruktoriin
		Asiakas uusiAsiakas = new Asiakas(nimi, puhelin, sahkoposti, katuosoite, postinumero, postitoimipaikka,
				kotisivu, tila, yTunnus, kuvaus, hyvinvointialue);

		uusiAsiakas.setKayttaja(nykyinenKayttaja);
		asiakasRepository.save(uusiAsiakas);
		return "redirect:/asiakkaat";
	}

	// 3. ASIAKASPROFIILI: Näyttää yhden asiakkaan tarkemmat tiedot, yhteyshenkilöt,
	// kirjaukset ja tarjoukset
	@Transactional
	@GetMapping("/asiakas/{id}")
	public String naytaAsiakas(@PathVariable Long id, jakarta.servlet.http.HttpSession session, Model model) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		Asiakas asiakas = asiakasRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Asiakasta ei löytynyt ID-numerolla: " + id));

		// KÄYTTÖLOKITUS: Tallennetaan tieto tietokantaan, että profiilia on katseltu
		String kuvaus = "Katseltu asiakkaan '" + asiakas.getNimi() + "' (ID: " + id + ") tietoja.";
		lokiRepository.save(new Loki(istuntoTunnus, "KATSELU", kuvaus));

		List<Liitetiedosto> liitteet = liitetiedostoRepository.findByAsiakasIdOrderByLatausaikaDesc(id);
		List<Yhteyshenkilo> yhteyshenkilot = yhteyshenkiloRepository.findByAsiakasId(id);
		List<Kirjaus> kirjaukset = kirjausRepository.findByAsiakasIdOrderByLuontiaikaDesc(id);

		List<Tuote> tuoteLista = tuoteRepository.findAll();
		List<AsiakasTuote> ostetutTuotteet = asiakasTuoteRepository.findByAsiakasId(id);
		List<Tarjous> tarjoukset = tarjousRepository.findByAsiakasId(id);

		model.addAttribute("asiakas", asiakas);
		model.addAttribute("liitteet", liitteet);
		model.addAttribute("yhteyshenkilot", yhteyshenkilot);
		model.addAttribute("kirjaukset", kirjaukset);
		model.addAttribute("ostetutTuotteet", ostetutTuotteet);
		model.addAttribute("kaikkiTuotteet", tuoteLista);
		model.addAttribute("tarjoukset", tarjoukset);
		model.addAttribute("tarjouksetMaara", tarjoukset != null ? tarjoukset.size() : 0);
		model.addAttribute("hyvinvointialueet", Hyvinvointialue.values());
		//viedään alv kannat profiilisivulle
		model.addAttribute("alvKannat", fi.sotemindit.astori.model.AlvKanta.values());
		// Viedään myyntiputken tilat profiilisivulle muokkausta varten
		model.addAttribute("tilat", AsiakkaanTila.values());
		
		return "asiakasprofiili";
	}

	// 4. YHTEYSHENKILÖN LISÄYS: Linkittää uuden henkilön tiettyyn asiakkaaseen
	@PostMapping("/asiakas/{asiakasId}/lisaa-yhteyshenkilo")
	public String lisaaYhteyshenkilo(jakarta.servlet.http.HttpSession session, @PathVariable Long asiakasId,
			@RequestParam String nimi, @RequestParam String rooli, @RequestParam String sahkoposti,
			@RequestParam String puhelin,
			@RequestParam(value = "palveluyksikkoId", required = false) Long palveluyksikkoId) { // 💡 UUSI PARAMETRI
																									// LOMAKKEELTA

		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}
		Asiakas asiakas = asiakasRepository.findById(asiakasId)
				.orElseThrow(() -> new IllegalArgumentException("Asiakasta ei löytynyt"));

		Yhteyshenkilo uusiHenkilo;

		// 💡 TARKISTETAAN: Kytketäänkö henkilö tiettyyn palveluyksikköön vai onko hän
		// yleinen kontakti
		if (palveluyksikkoId != null) {
			fi.sotemindit.astori.model.Palveluyksikko py = palveluyksikkoRepository.findById(palveluyksikkoId)
					.orElseThrow(() -> new IllegalArgumentException(
							"Palveluyksikköä ei löytynyt ID:llä: " + palveluyksikkoId));

			// Käytetään uutta laajennettua konstruktoria
			uusiHenkilo = new Yhteyshenkilo(nimi, rooli, sahkoposti, puhelin, asiakas, py);
		} else {
			// Käytetään vanhaa tuttua konstruktoria yleiselle kontaktille
			uusiHenkilo = new Yhteyshenkilo(nimi, rooli, sahkoposti, puhelin, asiakas);
		}

		yhteyshenkiloRepository.save(uusiHenkilo);

		return "redirect:/asiakas/" + asiakasId;
	}

	// 🔌 UUSI REITTI: Tallentaa uuden palveluyksikön sidottuna tiettyyn
	// pääasiakkaaseen
	@PostMapping("/asiakas/{asiakasId}/lisaa-palveluyksikko")
	public String lisaaPalveluyksikko(@PathVariable Long asiakasId, @RequestParam String nimi,
			@RequestParam(required = false) String katuosoite, @RequestParam(required = false) String postinumero,
			@RequestParam(required = false) String postitoimipaikka, @RequestParam(required = false) String puhelin,
			@RequestParam(required = false) String sahkoposti, @RequestParam(required = false) String kuvaus,
			@RequestParam(required = false) fi.sotemindit.astori.model.Hyvinvointialue hyvinvointialue,
			// 💡 UUDET PARAMETRIT: Otetaan vastaan yksikön ensimmäisen yhteyshenkilön
			// tiedot
			@RequestParam(required = false) String yhNimi, @RequestParam(required = false) String yhRooli,
			@RequestParam(required = false) String yhSahkoposti, @RequestParam(required = false) String yhPuhelin,
			jakarta.servlet.http.HttpSession session) {

		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		Asiakas asiakas = asiakasRepository.findById(asiakasId)
				.orElseThrow(() -> new IllegalArgumentException("Asiakasta ei löytynyt ID-numerolla: " + asiakasId));

		// 1. Luodaan ja tallennetaan uusi palveluyksikkö kantaan ensin
		fi.sotemindit.astori.model.Palveluyksikko uusiYksikko = new fi.sotemindit.astori.model.Palveluyksikko(nimi,
				katuosoite, postinumero, postitoimipaikka, puhelin, sahkoposti, kuvaus, hyvinvointialue, asiakas);
		palveluyksikkoRepository.save(uusiYksikko);

		// 2. 💡 JOS LOMAKKEELLA ANNETTIIN YHTEYSHENKILÖ, LUODAAN JA LIITETÄÄN SE TÄHÄN
		// YKSIKKÖÖN
		if (yhNimi != null && !yhNimi.trim().isEmpty()) {
			Yhteyshenkilo vastuuhenkilo = new Yhteyshenkilo(yhNimi.trim(), yhRooli != null ? yhRooli.trim() : "",
					yhSahkoposti != null ? yhSahkoposti.trim() : "", yhPuhelin != null ? yhPuhelin.trim() : "", asiakas,
					uusiYksikko // Kytketään lennosta juuri luotuun palveluyksikköön
			);
			yhteyshenkiloRepository.save(vastuuhenkilo);
		}

		// 3. Kirjataan lisäys järjestelmälokiin
		String lokiKuvaus = "Lisätty uusi palveluyksikkö '" + nimi + "' asiakkaalle '" + asiakas.getNimi() + "'.";
		lokiRepository.save(new Loki(istuntoTunnus, "LISÄYS", lokiKuvaus));

		return "redirect:/asiakas/" + asiakasId;
	}

	// 6. TUOTEMYYNNIN KIRJAUS
		@PostMapping("/asiakas/{asiakasId}/lisaa-tuote")
		public String kirjaaMyynti(@PathVariable Long asiakasId, @RequestParam Long tuoteId, @RequestParam Integer maara,
				@RequestParam String alvKanta, // Vastaanotetaan valittu ALV-kanta lomakkeelta
				jakarta.servlet.http.HttpSession session, @RequestParam(required = false) String ostopaivamaara) {
			String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
			if (istuntoTunnus == null) {
				return "redirect:/login";
			}

			Asiakas asiakas = asiakasRepository.findById(asiakasId)
					.orElseThrow(() -> new IllegalArgumentException("Asiakasta ei löytynyt"));
			Tuote tuote = tuoteRepository.findById(tuoteId)
					.orElseThrow(() -> new IllegalArgumentException("Tuotetta ei löytynyt"));

			fi.sotemindit.astori.model.AsiakasTuote uusiMyynti = new fi.sotemindit.astori.model.AsiakasTuote(asiakas, tuote,
					tuote.getHinta(), maara);

			// Muunnetaan merkkijono enumiksi ja asetetaan olion kenttään
			if (alvKanta != null && !alvKanta.trim().isEmpty()) {
				try {
					uusiMyynti.setAlvKanta(fi.sotemindit.astori.model.AlvKanta.valueOf(alvKanta));
				} catch (IllegalArgumentException e) {
					uusiMyynti.setAlvKanta(fi.sotemindit.astori.model.AlvKanta.ALV_25_5); // Varmuuskopio-oletus virhetilanteessa
				}
			}

			if (ostopaivamaara != null && !ostopaivamaara.trim().isEmpty()) {
				uusiMyynti.setOstopaivamaara(java.time.LocalDate.parse(ostopaivamaara));
			} else {
				uusiMyynti.setOstopaivamaara(java.time.LocalDate.now()); // Oletus: tämä päivä
			}

			asiakasTuoteRepository.save(uusiMyynti);

			return "redirect:/asiakas/" + asiakasId;
		}


	// 7. ASIAKKAAN MUOKKAUS: Päivittää asiakkaan perustiedot, tilan, osoitteet,
	// kotisivun ja Y-TUNNUKSEN
	// 💡 KORJATTU: Mukana nyt dynaaminen kuvaus-parametrin vastaanotto ja tallennus
	// muokkauksessa
	@PostMapping("/asiakas/{id}/muokkaa")
	public String muokkaaAsiakasta(@PathVariable Long id, @RequestParam String nimi,
			@RequestParam(value = "yTunnus", required = false) String yTunnus,
			@RequestParam(required = false) String kuvaus, // 💡 LISÄTTY: Vastaanotetaan laaja kuvausteksti lomakkeelta
			@RequestParam(required = false) String sahkoposti, @RequestParam(required = false) String puhelin,
			@RequestParam AsiakkaanTila tila, @RequestParam(required = false) String katuosoite,
			@RequestParam(required = false) String postinumero, @RequestParam(required = false) String postitoimipaikka,
			@RequestParam(required = false) String kotisivu,
			@RequestParam(required = false) Hyvinvointialue hyvinvointialue, jakarta.servlet.http.HttpSession session) {

		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		Asiakas asiakas = asiakasRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Asiakasta ei löydy ID:llä: " + id));

		// Päivitetään kaikki arvot standardinmukaisesti, mukana nyt laaja kuvaus
		asiakas.setNimi(nimi);
		asiakas.setyTunnus(yTunnus);
		asiakas.setKuvaus(kuvaus); // 💡 LISÄTTY: Asetetaan uusi teksti oliolle
		asiakas.setSahkoposti(sahkoposti);
		asiakas.setPuhelin(puhelin);
		asiakas.setTila(tila);
		asiakas.setKatuosoite(katuosoite);
		asiakas.setPostinumero(postinumero);
		asiakas.setPostitoimipaikka(postitoimipaikka);
		asiakas.setKotisivu(kotisivu);
		asiakas.setHyvinvointialue(hyvinvointialue);

		asiakasRepository.save(asiakas);

		return "redirect:/asiakas/" + id;
	}

	// 7b. ASIAKKAAN POISTO: Poistaa asiakkaan ja kaikki siihen liittyvät tiedot
	// (Cascade)
	@Transactional
	@PostMapping("/asiakas/{id}/poista")
	public String poistaAsiakas(@PathVariable Long id, jakarta.servlet.http.HttpSession session) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		Asiakas asiakas = asiakasRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Asiakasta ei löytynyt ID-numerolla: " + id));

		// KÄYTTÖLOKITUS: Otetaan nimi talteen ennen poistoa, jotta se saadaan lokiin
		String kuvaus = "Poistettu asiakas '" + asiakas.getNimi() + "' (ID: " + id + ") ja kaikki sen liitostiedot.";
		lokiRepository.save(new Loki(istuntoTunnus, "POISTO", kuvaus));

		// Varmistetaan, että asiakas on olemassa ennen poistoa
		if (!asiakasRepository.existsById(id)) {
			throw new IllegalArgumentException("Asiakasta ei löytynyt ID-numerolla: " + id);
		}

		// Poistetaan asiakas (CascadeType.ALL hoitaa liitostaulujen siivouksen
		// automaattisesti)
		asiakasRepository.deleteById(id);

		// Palataan onnistuneen poiston jälkeen takaisin pääsivun asiakaslistaukseen
		return "redirect:/asiakkaat";
	}

	// 💡 LISÄTTY: Täydellinen Live Search, joka palauttaa pelkät valmiit
	// taulukkorivit koko kannasta
	@org.springframework.web.bind.annotation.GetMapping("/asiakkaat/live-haku")
	@org.springframework.web.bind.annotation.ResponseBody
	public String liveHaku(jakarta.servlet.http.HttpSession session,
			@org.springframework.web.bind.annotation.RequestParam("haku") String haku) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null || haku == null || haku.trim().isEmpty()) {
			return "";
		}

		// Haetaan max 50 osumaa aakkosjärjestyksessä koko tietokannasta yli
		// sivutusrajojen
		org.springframework.data.domain.Pageable maxOsumat = org.springframework.data.domain.PageRequest.of(0, 50,
				org.springframework.data.domain.Sort.by(org.springframework.data.domain.Sort.Direction.ASC, "nimi"));

		org.springframework.data.domain.Page<fi.sotemindit.astori.model.Asiakas> tulokset = asiakasRepository
				.findByKayttajaKayttajatunnusAndHaku(istuntoTunnus, haku.trim(), maxOsumat);

		// Rakennetaan dynaamiset taulukkorivit puhtaaksi tekstiksi ilman erillistä
		// JSP-tiedostoa
		StringBuilder html = new StringBuilder();
		String contextPath = session.getServletContext().getContextPath();

		for (fi.sotemindit.astori.model.Asiakas a : tulokset.getContent()) {
			html.append("<tr>");
			html.append("<td><strong><a href=\"").append(contextPath).append("/asiakas/").append(a.getId())
					.append("\" class=\"text-decoration-none text-dark\">").append(a.getNimi())
					.append("</a></strong></td>");
			html.append("<td>").append(a.getyTunnus() != null ? a.getyTunnus() : "").append("</td>");
			html.append("<td>").append(a.getPuhelin() != null ? a.getPuhelin() : "").append("</td>");
			html.append("<td>").append(a.getSahkoposti() != null ? a.getSahkoposti() : "").append("</td>");
			html.append("<td><span class=\"badge bg-primary\">").append(a.getTila()).append("</span></td>");
			html.append("<td class=\"text-end\"><a href=\"").append(contextPath).append("/asiakas/").append(a.getId())
					.append("\" class=\"btn btn-sm btn-outline-primary fw-bold\">Avaa profiili</a></td>");
			html.append("</tr>");
		}

		if (tulokset.getContent().isEmpty()) {
			html.append(
					"<tr><td colspan=\"6\" class=\"text-center py-4 text-muted\">Hakuehdolla ei löytynyt yhtään asiakasta koko tietokannasta.</td></tr>");
		}

		return html.toString();
	}

	// Yhteyshenkilön muokkaaminen
	@PostMapping("/yhteyshenkilo/muokkaa/{id}")
	public String muokkaaYhteyshenkilo(@PathVariable Long id, @RequestParam String nimi, @RequestParam String rooli,
			@RequestParam String sahkoposti, @RequestParam String puhelin, @RequestParam Long asiakasId,
			jakarta.servlet.http.HttpSession session) {

		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		// Haetaan olemassa oleva yhteyshenkilö
		Yhteyshenkilo yh = yhteyshenkiloRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Yhteyshenkilöä ei löytynyt ID-numerolla: " + id));

		// Päivitetään uudet tiedot
		yh.setNimi(nimi);
		yh.setRooli(rooli);
		yh.setSahkoposti(sahkoposti);
		yh.setPuhelin(puhelin);

		yhteyshenkiloRepository.save(yh);

		// Kirjataan muokkaus järjestelmälokiin
		lokiRepository.save(new Loki(istuntoTunnus, "MUOKKAUS",
				"Muokattu yhteyshenkilön tietoja: " + nimi + " (ID: " + id + ") asiakkaalle ID: " + asiakasId));

		// Ohjataan takaisin asiakasprofiiliin
		return "redirect:/asiakas/" + asiakasId;
	}

	@Transactional
	@PostMapping("/kirjaus/muokkaa/{id}")
	public String muokkaaKirjausta(@PathVariable Long id, @RequestParam String teksti, @RequestParam Long asiakasId,
			jakarta.servlet.http.HttpSession session) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		fi.sotemindit.astori.model.Kirjaus kirjaus = kirjausRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Merkintää ei löytynyt ID-numerolla: " + id));

		// Päivitetään uusi muokattu teksti
		kirjaus.setTeksti(teksti);
		kirjausRepository.save(kirjaus);

		// Ohjataan siististi takaisin kyseisen asiakkaan profiiliin
		return "redirect:/asiakas/" + asiakasId;
	}

	@Transactional
	@PostMapping("/palvelu/muokkaa/{id}")
	public String muokkaaMyytyaPalvelua(@PathVariable Long id, @RequestParam Integer maara,
			@RequestParam java.math.BigDecimal myyntihinta, @RequestParam String ostopaivamaara,
			@RequestParam Long asiakasId, jakarta.servlet.http.HttpSession session) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		fi.sotemindit.astori.model.AsiakasTuote palvelu = asiakasTuoteRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Myytyä palvelua ei löytynyt ID-numerolla: " + id));

		// Päivitetään muuttuneet kentät
		palvelu.setMaara(maara);
		palvelu.setMyyntihinta(myyntihinta);
		palvelu.setOstopaivamaara(java.time.LocalDate.parse(ostopaivamaara));

		asiakasTuoteRepository.save(palvelu);

		// Palataan siististi takaisin asiakkaan profiiliin
		return "redirect:/asiakas/" + asiakasId;
	}

	// 🔌 UUSI REITTI: Muokkaa olemassa olevan palveluyksikön tietoja
	// 🔌 PÄIVITETTY REITTI: Muokkaa palveluyksikköä ja sen ensisijaista
	// yhteyshenkilöä
	@PostMapping("/palveluyksikko/muokkaa/{id}")
	public String muokkaaPalveluyksikkaa(@PathVariable Long id, @RequestParam String nimi,
			@RequestParam(required = false) String katuosoite, @RequestParam(required = false) String postinumero,
			@RequestParam(required = false) String postitoimipaikka, @RequestParam(required = false) String puhelin,
			@RequestParam(required = false) String sahkoposti, @RequestParam(required = false) String kuvaus,
			@RequestParam(required = false) fi.sotemindit.astori.model.Hyvinvointialue hyvinvointialue,
			// 💡 UUDET PARAMETRIT: Yksikön yhteyshenkilön muokkaus
			@RequestParam(required = false) Long yhId, @RequestParam(required = false) String yhNimi,
			@RequestParam(required = false) String yhRooli, @RequestParam(required = false) String yhSahkoposti,
			@RequestParam(required = false) String yhPuhelin, @RequestParam Long asiakasId,
			jakarta.servlet.http.HttpSession session) {

		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		// 1. Päivitetään palveluyksikön omat tiedot
		fi.sotemindit.astori.model.Palveluyksikko py = palveluyksikkoRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Palveluyksikköä ei löytynyt ID:llä: " + id));

		py.setNimi(nimi);
		py.setKatuosoite(katuosoite);
		py.setPostinumero(postinumero);
		py.setPostitoimipaikka(postitoimipaikka);
		py.setPuhelin(puhelin);
		py.setSahkoposti(sahkoposti);
		py.setKuvaus(kuvaus);
		py.setHyvinvointialue(hyvinvointialue);
		palveluyksikkoRepository.save(py);

		// 2. 💡 PÄIVITETÄÄN TAI LUODAAN YHTEYSHENKILÖ
		Asiakas asiakas = asiakasRepository.findById(asiakasId).orElse(null);

		if (yhNimi != null && !yhNimi.trim().isEmpty()) {
			Yhteyshenkilo yh;
			if (yhId != null) {
				// Päivitetään olemassa oleva yhteyshenkilö
				yh = yhteyshenkiloRepository.findById(yhId).orElse(new Yhteyshenkilo());
			} else {
				// Luodaan uusi, jos yksikölle lisätään vasta nyt yhteyshenkilö
				yh = new Yhteyshenkilo();
				yh.setAsiakas(asiakas);
				yh.setPalveluyksikko(py);
			}
			yh.setNimi(yhNimi.trim());
			yh.setRooli(yhRooli != null ? yhRooli.trim() : "");
			yh.setSahkoposti(yhSahkoposti != null ? yhSahkoposti.trim() : "");
			yh.setPuhelin(yhPuhelin != null ? yhPuhelin.trim() : "");
			yhteyshenkiloRepository.save(yh);
		}

		String lokiKuvaus = "Muokattu palveluyksikön '" + nimi + "' (ID: " + id + ") tietoja asiakkaalle ID: "
				+ asiakasId;
		lokiRepository.save(new Loki(istuntoTunnus, "MUOKKAUS", lokiKuvaus));

		return "redirect:/asiakas/" + asiakasId;
	}

	// Tallentaa uuden lokimerkinnän asiakkaan profiiliin
	@PostMapping("/asiakas/{asiakasId}/lisaa-kirjaus")
	public String lisaaKirjaus(@PathVariable Long asiakasId, @RequestParam String teksti,
			jakarta.servlet.http.HttpSession session) {

		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		// 1. Haetaan asiakas tietokannasta ja varmistetaan olemassaolo
		Asiakas asiakas = asiakasRepository.findById(asiakasId)
				.orElseThrow(() -> new IllegalArgumentException("Asiakasta ei löytynyt ID-numerolla: " + asiakasId));

		// 2. Luodaan uusi kirjausolio (asettaa automaattisesti nykyhetken luontiajaksi)
		fi.sotemindit.astori.model.Kirjaus uusiKirjaus = new fi.sotemindit.astori.model.Kirjaus();
		uusiKirjaus.setAsiakas(asiakas);
		uusiKirjaus.setTeksti(teksti);
		uusiKirjaus.setLuontiaika(java.time.LocalDateTime.now());

		// 3. Tallennetaan kirjaus PostgreSQL-tietokantaan (JPA hoitaa)
		kirjausRepository.save(uusiKirjaus);

		// 4. Kirjataan toiminto Audit Trailiin
		String lokiKuvaus = "Lisätty uusi lokimerkintä asiakkaalle '" + asiakas.getNimi() + "' (ID: " + asiakasId
				+ ").";
		lokiRepository.save(new Loki(istuntoTunnus, "LISÄYS", lokiKuvaus));

		// 5. Palataan takaisin asiakkaan profiiliin
		return "redirect:/asiakas/" + asiakasId;
	}

	// 🔌 UUSI REITTI: Poistaa lokikirjauksen ja tallentaa alkuperäisen tekstin
	// Audit Trailiin
	@PostMapping("/kirjaus/poista/{id}")
	public String poistaKirjaus(@PathVariable Long id, @RequestParam Long asiakasId,
			jakarta.servlet.http.HttpSession session) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		// 1. Haetaan poistettava kirjaus tietokannasta, jotta saadaan sen teksti
		// talteen
		fi.sotemindit.astori.model.Kirjaus kirjaus = kirjausRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Kirjausta ei löytynyt ID-numerolla: " + id));

		// 2. 💡 TÄRKEÄÄ: Otetaan alkuperäinen teksti talteen JÄRJESTELMÄLOKIIN ennen
		// poistoa
		String vanhaTeksti = kirjaus.getTeksti();
		String lokiKuvaus = "Poistettu lokimerkintä asiakkaalta (ID: " + asiakasId + "). Alkuperäinen teksti oli: \""
				+ vanhaTeksti + "\"";

		// Tallennetaan Audit Trailiin (POISTO-tyypillä)
		lokiRepository.save(new Loki(istuntoTunnus, "POISTO", lokiKuvaus));

		// 3. Poistetaan kirjaus lopullisesti kirjaukset-taulusta
		kirjausRepository.delete(kirjaus);

		// 4. Palataan takaisin asiakasprofiiliin
		return "redirect:/asiakas/" + asiakasId;
	}


	// 2. REITTI: Poistaa tuotteen / palvelun asiakkaan kortilta kokonaan
	@PostMapping("/palvelu/poista/{id}")
	public String poistaAsiakasTuote(jakarta.servlet.http.HttpSession session, @PathVariable Long id) {

		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		AsiakasTuote poistettava = asiakasTuoteRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Poistettavaa riviä ei löytynyt ID-numerolla: " + id));

		Long asiakasId = poistettava.getAsiakas().getId();

		// Poistetaan tietokantarivi
		asiakasTuoteRepository.delete(poistettava);

		return "redirect:/asiakas/" + asiakasId + "?success=service_deleted";
	}
}
