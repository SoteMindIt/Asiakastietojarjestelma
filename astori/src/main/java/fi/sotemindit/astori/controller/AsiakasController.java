package fi.sotemindit.astori.controller;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.text.Normalizer;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.server.ResponseStatusException;

import fi.sotemindit.astori.model.Asiakas;
import fi.sotemindit.astori.model.AsiakasTuote;
import fi.sotemindit.astori.model.AsiakkaanTila;
import fi.sotemindit.astori.model.Hyvinvointialue;
import fi.sotemindit.astori.model.Kirjaus;
import fi.sotemindit.astori.model.Kayttaja;
import fi.sotemindit.astori.model.Liitetiedosto;
import fi.sotemindit.astori.model.Loki;
import fi.sotemindit.astori.model.Tarjous;
import fi.sotemindit.astori.model.Tuote;
import fi.sotemindit.astori.model.Yhteyshenkilo;
import fi.sotemindit.astori.model.Yritystiedot;
import fi.sotemindit.astori.repository.AsiakasRepository;
import fi.sotemindit.astori.repository.AsiakasTuoteRepository;
import fi.sotemindit.astori.repository.KayttajaRepository;
import fi.sotemindit.astori.repository.KirjausRepository;
import fi.sotemindit.astori.repository.LiitetiedostoRepository;
import fi.sotemindit.astori.repository.TarjousRepository;
import fi.sotemindit.astori.repository.TuoteRepository;
import fi.sotemindit.astori.repository.YhteyshenkiloRepository;
import fi.sotemindit.astori.repository.LokiRepository;
import fi.sotemindit.astori.repository.YritystiedotRepository;
import fi.sotemindit.astori.service.SopimusPdfPalvelu;

import com.lowagie.text.DocumentException;

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
	private YritystiedotRepository yritystiedotRepository;

	@Autowired
	private SopimusPdfPalvelu sopimusPdfPalvelu;

	@Autowired
	private fi.sotemindit.astori.repository.KirjaustyyppiRepository kirjaustyyppiRepository;

	// 1b. Asiakaslista: haku, sivutus sekä hyvinvointialue- ja tilasuodatus
		@GetMapping("/asiakkaat")
		public String listaaAsiakkaat(jakarta.servlet.http.HttpSession session, @RequestParam(defaultValue = "0") int page,
				@RequestParam(value = "haku", required = false) String haku,
				@RequestParam(value = "alue", required = false) String alue,
				@RequestParam(value = "tila", required = false) String tila,
				Model model) {

			String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
			if (istuntoTunnus == null) {
				return "redirect:/login";
			}

			// Luodaan sivutuspyyntö: 10 alkiota per sivu, järjestetty nimen mukaan nousevasti
			Pageable pageable = org.springframework.data.domain.PageRequest.of(page, 10,
					org.springframework.data.domain.Sort.by(org.springframework.data.domain.Sort.Direction.ASC, "nimi"));
			Page<Asiakas> asiakasSivu;

			// Siistitään hakumuuttujat
			String hakusana = (haku != null && !haku.trim().isEmpty()) ? haku.trim() : null;

			Hyvinvointialue valittuAlue = null;
			if (alue != null && !alue.trim().isEmpty()) {
				try {
					valittuAlue = Hyvinvointialue.valueOf(alue.trim());
				} catch (IllegalArgumentException e) {
					valittuAlue = null;
				}
			}

			AsiakkaanTila valittuTila = null;
			if (tila != null && !tila.trim().isEmpty()) {
				try {
					valittuTila = AsiakkaanTila.valueOf(tila.trim());
				} catch (IllegalArgumentException e) {
					valittuTila = null;
				}
			}

			asiakasSivu = asiakasRepository.haeSuodattimilla(istuntoTunnus, valittuTila, valittuAlue,
					hakusana != null ? hakusana : "", pageable);

			// Viedään tiedot asiakkaat.jsp-sivulle
			model.addAttribute("asiakkaat", asiakasSivu.getContent());
			model.addAttribute("currentPage", page);
			model.addAttribute("totalPages", asiakasSivu.getTotalPages());
			model.addAttribute("tilat", AsiakkaanTila.values());
			model.addAttribute("haku", hakusana != null ? hakusana : "");
			model.addAttribute("valittuAlue", valittuAlue != null ? valittuAlue.name() : "");
			model.addAttribute("valittuTila", valittuTila != null ? valittuTila.name() : "");

			model.addAttribute("hyvinvointialueet", fi.sotemindit.astori.model.Hyvinvointialue.values());

			return "asiakkaat";
		}

	// 2. ASIAKKAAN LISÄYS: Tallentaa uuden asiakkaan tiedot osoitteineen ja
	// kotisivuineen
	@PostMapping("/lisaa-asiakas")
	public String lisaaAsiakas(jakarta.servlet.http.HttpSession session, @RequestParam String nimi,
			@RequestParam(value = "yTunnus", required = false) String yTunnus,
			@RequestParam(required = false) String kuvaus, @RequestParam(required = false) String sahkoposti,
			@RequestParam(required = false) String puhelin, @RequestParam AsiakkaanTila tila,
			@RequestParam(required = false) String katuosoite, @RequestParam(required = false) String postinumero,
			@RequestParam(required = false) String postitoimipaikka, @RequestParam(required = false) String kotisivu,
			@RequestParam(required = false) Hyvinvointialue hyvinvointialue) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		fi.sotemindit.astori.model.Kayttaja nykyinenKayttaja = kayttajaRepository.findByKayttajatunnus(istuntoTunnus)
				.orElseThrow(() -> new IllegalArgumentException("Käyttäjää ei löydy"));

		// Luodaan uusi asiakas
		Asiakas uusiAsiakas = new Asiakas(nimi, puhelin, sahkoposti, katuosoite, postinumero, postitoimipaikka,
				kotisivu, tila, yTunnus, kuvaus, hyvinvointialue);

		uusiAsiakas.setKayttaja(nykyinenKayttaja);
		asiakasRepository.save(uusiAsiakas);

		lokiRepository.save(new Loki(istuntoTunnus, "LISÄYS",
				"Luotu uusi asiakasorganisaatio: " + uusiAsiakas.getNimi() + " (ID: " + uusiAsiakas.getId() + ")"));

		return "redirect:/asiakkaat";
	}

	// ❌ UUSI: Poistaa asiakkaan ja kaikki siihen liittyvät tiedot järjestelmästä
	@Transactional
	@PostMapping("/asiakas/{id}/poista")
	public String poistaAsiakas(@PathVariable Long id, jakarta.servlet.http.HttpSession session,
			org.springframework.web.servlet.mvc.support.RedirectAttributes redirectAttributes) {

		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		// 1. Haetaan asiakas tietokannasta
		java.util.Optional<Asiakas> asiakasOpt = asiakasRepository.findById(id);

		if (asiakasOpt.isPresent()) {
			Asiakas asiakas = asiakasOpt.get();
			String asiakkaanNimi = asiakas.getNimi();

			// 2. Poistetaan asiakas (JPA hoitaa cascade-siivoukset)
			asiakasRepository.delete(asiakas);

			// 3. KÄYTTÖLOKITUS: Audit Trail -merkintä
			String lokiViesti = "POISTETTU ASIAKAS: '" + asiakkaanNimi + "' (ID: " + id
					+ ") ja kaikki sen liittyvät tiedot.";
			lokiRepository.save(new Loki(istuntoTunnus, "POISTO", lokiViesti));

			redirectAttributes.addFlashAttribute("viesti", "Asiakas " + asiakkaanNimi + " poistettu onnistuneesti.");
			return "redirect:/asiakkaat"; // Palataan onnistuneen poiston jälkeen yleiseen listaukseen
		}

		redirectAttributes.addFlashAttribute("virhe", "Asiakkaan poisto epäonnistui. Asiakasta ei löytynyt.");
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
		List<Liitetiedosto> sopimukset = liitteet.stream()
				.filter(liite -> "PALVELUSOPIMUS".equals(liite.getKuvaus()))
				.toList();
		List<Yhteyshenkilo> yhteyshenkilot = yhteyshenkiloRepository.findByAsiakasId(id);
		List<Kirjaus> kirjaukset = kirjausRepository.findByAsiakasIdOrderByLuontiaikaDesc(id);

		List<Tuote> tuoteLista = tuoteRepository.findAll();
		List<AsiakasTuote> ostetutTuotteet = asiakasTuoteRepository.findByAsiakasId(id);
		List<Tarjous> tarjoukset = tarjousRepository.findByAsiakasId(id);

		model.addAttribute("asiakas", asiakas);
		model.addAttribute("liitteet", liitteet);
		model.addAttribute("sopimukset", sopimukset);
		model.addAttribute("yhteyshenkilot", yhteyshenkilot);
		model.addAttribute("kirjaukset", kirjaukset);
		model.addAttribute("ostetutTuotteet", ostetutTuotteet);
		model.addAttribute("kaikkiTuotteet", tuoteLista);
		model.addAttribute("tarjoukset", tarjoukset);
		model.addAttribute("tarjouksetMaara", tarjoukset != null ? tarjoukset.size() : 0);
		model.addAttribute("hyvinvointialueet", Hyvinvointialue.values());
		// Viedään myyntiputken tilat profiilisivulle muokkausta varten
		model.addAttribute("tilat", AsiakkaanTila.values());

		// Haetaan kaikki järjestelmän merkinnät linkitys-alasvetovalikkoa varten
		List<Kirjaus> kaikkiUusimmat = kirjausRepository.findAll();
		model.addAttribute("kaikkiViimeisymmatKirjaukset", kaikkiUusimmat);
		//Haetaan kirjaustyypit profiilisivulle
		model.addAttribute("kirjaustyypit", kirjaustyyppiRepository.findAll());
		model.addAttribute("yritystiedot",
				yritystiedotRepository.findById(1L).orElseGet(Yritystiedot::new));
		Kayttaja kirjautunutKayttaja = kayttajaRepository.findByKayttajatunnus(istuntoTunnus).orElse(null);
		model.addAttribute("palveluntarjoajanEdustaja",
				muodostaKayttajanNimi(kirjautunutKayttaja, istuntoTunnus));
		model.addAttribute("sopimusPaivamaara", LocalDate.now());

		return "asiakasprofiili";
	}

	@Transactional
	@PostMapping("/asiakas/{asiakasId}/sopimus")
	public String luoSopimus(@PathVariable Long asiakasId, jakarta.servlet.http.HttpSession session,
			@RequestParam String palveluntarjoajanNimi, @RequestParam String palveluntarjoajanYTunnus,
			@RequestParam String palveluntarjoajanOsoite, @RequestParam String sopimuksenKohdeJaSisalto,
			@RequestParam String hintaJaMaksuehdot,
			@RequestParam LocalDate aloituspaiva, @RequestParam String palveluntarjoajanEdustaja,
			@RequestParam String asiakkaanEdustaja, @RequestParam String allekirjoitustapa,
			org.springframework.web.servlet.mvc.support.RedirectAttributes redirectAttributes)
			throws IOException, DocumentException {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		Asiakas asiakas = haeOmistettuAsiakas(asiakasId, istuntoTunnus);
		if (!Set.of("paperinen", "sahkoinen").contains(allekirjoitustapa)
				|| !onKelvollinenTeksti(palveluntarjoajanNimi, 150)
				|| !onKelvollinenTeksti(palveluntarjoajanYTunnus, 20)
				|| !onKelvollinenTeksti(palveluntarjoajanOsoite, 250)
				|| !onKelvollinenTeksti(sopimuksenKohdeJaSisalto, 5000)
				|| !onKelvollinenTeksti(hintaJaMaksuehdot, 5000)
				|| !onKelvollinenTeksti(palveluntarjoajanEdustaja, 150)
				|| !onKelvollinenTeksti(asiakkaanEdustaja, 150)) {
			redirectAttributes.addFlashAttribute("virhe", "Tarkista sopimuksen lomaketiedot.");
			return "redirect:/asiakas/" + asiakasId;
		}

		String asiakkaanOsoite = muodostaAsiakkaanOsoite(asiakas);
		SopimusPdfPalvelu.SopimusTiedot sopimustiedot = new SopimusPdfPalvelu.SopimusTiedot(
				palveluntarjoajanNimi.trim(), palveluntarjoajanYTunnus.trim(), palveluntarjoajanOsoite.trim(),
				asiakas.getNimi(), asiakas.getyTunnus(), asiakkaanOsoite, sopimuksenKohdeJaSisalto.trim(),
				hintaJaMaksuehdot.trim(), aloituspaiva,
				palveluntarjoajanEdustaja.trim(), asiakkaanEdustaja.trim(), "sahkoinen".equals(allekirjoitustapa));
		byte[] pdf = sopimusPdfPalvelu.luoSopimusPdf(sopimustiedot);
		String tiedostonNimi = muodostaSopimuksenTiedostonNimi(asiakas.getNimi(), LocalDateTime.now());
		liitetiedostoRepository.save(new Liitetiedosto(tiedostonNimi, "PALVELUSOPIMUS", pdf, asiakas));
		lokiRepository.save(new Loki(istuntoTunnus, "LISÄYS",
				"Luotu palvelusopimus asiakkaalle '" + asiakas.getNimi() + "' (ID: " + asiakasId + ")."));
		redirectAttributes.addFlashAttribute("viesti", "Palvelusopimus luotu ja tallennettu asiakkaalle.");
		return "redirect:/asiakas/" + asiakasId;
	}

	@GetMapping("/asiakas/{asiakasId}/sopimus/{sopimusId}/lataa")
	public ResponseEntity<byte[]> lataaSopimus(@PathVariable Long asiakasId, @PathVariable Long sopimusId,
			jakarta.servlet.http.HttpSession session) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
		}

		haeOmistettuAsiakas(asiakasId, istuntoTunnus);
		Liitetiedosto sopimus = liitetiedostoRepository.findById(sopimusId)
				.filter(liite -> liite.getAsiakas().getId().equals(asiakasId)
						&& "PALVELUSOPIMUS".equals(liite.getKuvaus()))
				.orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Sopimusta ei löytynyt."));

		HttpHeaders otsakkeet = new HttpHeaders();
		otsakkeet.setContentType(MediaType.APPLICATION_PDF);
		otsakkeet.setContentDisposition(ContentDisposition.attachment()
				.filename(sopimus.getTiedostonNimi(), StandardCharsets.UTF_8).build());
		otsakkeet.setContentLength(sopimus.getData().length);
		return new ResponseEntity<>(sopimus.getData(), otsakkeet, HttpStatus.OK);
	}

	@Transactional
	@PostMapping("/asiakas/{asiakasId}/sopimus/{sopimusId}/poista")
	public String poistaSopimus(@PathVariable Long asiakasId, @PathVariable Long sopimusId,
			jakarta.servlet.http.HttpSession session,
			org.springframework.web.servlet.mvc.support.RedirectAttributes redirectAttributes) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		Asiakas asiakas = haeOmistettuAsiakas(asiakasId, istuntoTunnus);
		Liitetiedosto sopimus = liitetiedostoRepository.findById(sopimusId)
				.filter(liite -> liite.getAsiakas().getId().equals(asiakasId)
						&& "PALVELUSOPIMUS".equals(liite.getKuvaus()))
				.orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Sopimusta ei löytynyt."));

		liitetiedostoRepository.delete(sopimus);
		lokiRepository.save(new Loki(istuntoTunnus, "POISTO",
				"Poistettu palvelusopimus '" + sopimus.getTiedostonNimi() + "' asiakkaalta '"
						+ asiakas.getNimi() + "' (ID: " + asiakasId + ")."));
		redirectAttributes.addFlashAttribute("viesti", "Palvelusopimus poistettu.");
		return "redirect:/asiakas/" + asiakasId;
	}

	private Asiakas haeOmistettuAsiakas(Long asiakasId, String istuntoTunnus) {
		Asiakas asiakas = asiakasRepository.findById(asiakasId)
				.orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Asiakasta ei löytynyt."));
		if (asiakas.getKayttaja() == null
				|| !istuntoTunnus.equals(asiakas.getKayttaja().getKayttajatunnus())) {
			throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Asiakasta ei löytynyt.");
		}
		return asiakas;
	}

	private boolean onKelvollinenTeksti(String arvo, int enimmainspituus) {
		return arvo != null && !arvo.isBlank() && arvo.length() <= enimmainspituus;
	}

	private String muodostaKayttajanNimi(Kayttaja kayttaja, String kayttajatunnus) {
		if (kayttaja == null) {
			return kayttajatunnus;
		}
		String nimi = ((kayttaja.getEtunimi() == null ? "" : kayttaja.getEtunimi().trim()) + " "
				+ (kayttaja.getSukunimi() == null ? "" : kayttaja.getSukunimi().trim())).trim();
		return nimi.isEmpty() ? kayttajatunnus : nimi;
	}

	private String muodostaAsiakkaanOsoite(Asiakas asiakas) {
		StringBuilder osoite = new StringBuilder();
		if (asiakas.getKatuosoite() != null && !asiakas.getKatuosoite().isBlank()) {
			osoite.append(asiakas.getKatuosoite().trim());
		}
		String postiosoite = ((asiakas.getPostinumero() == null ? "" : asiakas.getPostinumero().trim()) + " "
				+ (asiakas.getPostitoimipaikka() == null ? "" : asiakas.getPostitoimipaikka().trim())).trim();
		if (!postiosoite.isEmpty()) {
			if (!osoite.isEmpty()) {
				osoite.append(", ");
			}
			osoite.append(postiosoite);
		}
		return osoite.toString();
	}

	private String muodostaSopimuksenTiedostonNimi(String asiakkaanNimi, LocalDateTime luontiaika) {
		String turvallinenNimi = Normalizer.normalize(asiakkaanNimi, Normalizer.Form.NFD)
				.replaceAll("\\p{M}+", "")
				.replaceAll("[^A-Za-z0-9._-]+", "_");
		if (turvallinenNimi.isBlank()) {
			turvallinenNimi = "asiakas";
		}
		String aikaleima = luontiaika.format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
		return "Palvelusopimus_" + turvallinenNimi + "_" + aikaleima + ".pdf";
	}

	// 6. TUOTTEEN LISAAMINEN ASIAKKAALLE
	@PostMapping("/asiakas/{asiakasId}/lisaa-tuote")
	public String kirjaaMyynti(@PathVariable Long asiakasId, @RequestParam Long tuoteId,
			@RequestParam java.math.BigDecimal maara, @RequestParam java.math.BigDecimal myyntihinta,
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
				myyntihinta, maara);

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

	// 💡 LISÄTTY: Täydellinen Live Search, joka palauttaa pelkät valmiit
	// taulukkorivit koko kannasta
	@org.springframework.web.bind.annotation.GetMapping("/asiakkaat/live-haku")
	@org.springframework.web.bind.annotation.ResponseBody
	public String liveHaku(jakarta.servlet.http.HttpSession session,
			@org.springframework.web.bind.annotation.RequestParam(value = "haku", required = false, defaultValue = "") String haku,
			@org.springframework.web.bind.annotation.RequestParam(value = "alue", required = false) String alue,
			@org.springframework.web.bind.annotation.RequestParam(value = "tila", required = false) String tila) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "";
		}

		Hyvinvointialue valittuAlue = null;
		if (alue != null && !alue.isBlank()) {
			try {
				valittuAlue = Hyvinvointialue.valueOf(alue.trim());
			} catch (IllegalArgumentException ignored) {
			}
		}

		AsiakkaanTila valittuTila = null;
		if (tila != null && !tila.isBlank()) {
			try {
				valittuTila = AsiakkaanTila.valueOf(tila.trim());
			} catch (IllegalArgumentException ignored) {
			}
		}

		// Haetaan max 50 osumaa aakkosjärjestyksessä koko tietokannasta yli
		// sivutusrajojen
		org.springframework.data.domain.Pageable maxOsumat = org.springframework.data.domain.PageRequest.of(0, 50,
				org.springframework.data.domain.Sort.by(org.springframework.data.domain.Sort.Direction.ASC, "nimi"));

		org.springframework.data.domain.Page<fi.sotemindit.astori.model.Asiakas> tulokset = asiakasRepository.haeSuodattimilla(
				istuntoTunnus, valittuTila, valittuAlue, haku.trim(), maxOsumat);

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

	@Transactional
	@PostMapping("/palvelu/muokkaa/{id}")
	public String muokkaaMyytyaPalvelua(@PathVariable Long id, @RequestParam java.math.BigDecimal maara,
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
