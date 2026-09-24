package fi.sotemindit.astori.controller;

import fi.sotemindit.astori.model.Kayttaja;
import fi.sotemindit.astori.model.Tuote;
import fi.sotemindit.astori.model.TuoteYksikko;
import fi.sotemindit.astori.model.AlvKanta;
import fi.sotemindit.astori.model.Yritystiedot;
import fi.sotemindit.astori.repository.KayttajaRepository;
import fi.sotemindit.astori.repository.KirjaustyyppiRepository;
import fi.sotemindit.astori.repository.TuoteRepository;
import fi.sotemindit.astori.model.TapahtumaTyyppi;
import fi.sotemindit.astori.repository.TapahtumaTyyppiRepository;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

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

	@Autowired
	private TapahtumaTyyppiRepository tapahtumaTyyppiRepository;
	
	@Autowired
	private KirjaustyyppiRepository kirjaustyyppiRepository;

	// 1. REITTI: Näyttää järjestelmän asetussivun ja lataa kaikki tarvittavat tiedot
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

		// Tuotteiden yksiköt. Esim. Km, kpl, tuntia jne
		model.addAttribute("yksikot", TuoteYksikko.values());

		// Viedään kaikki ALV-kannat JSP-sivua varten
		model.addAttribute("alvKannat", AlvKanta.values());
		// Viedään kaikki tapahtumatyypit
		model.addAttribute("kaikkiTapahtumaTyypit", tapahtumaTyyppiRepository.findAll());
		
		// Viedään kirjaustyypit asetussivulle
		model.addAttribute("kaikkiKirjaustyypit", kirjaustyyppiRepository.findAll());

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

	// 4. REITTI: Tallenna oman yrityksen tiedot tarjouspohjaa varten
	@PostMapping("/asetukset/tallenna-yritys")
	public String tallennaYrityksenTiedot(HttpSession session, @RequestParam String nimi, @RequestParam String yTunnus,
			@RequestParam(required = false) String sahkoposti, @RequestParam(required = false) String puhelin,
			@RequestParam(required = false) String osoite, @RequestParam(required = false) String iban,
			@RequestParam(required = false) String bic) {

		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		Yritystiedot yritys = yritystiedotRepository.findById(1L).orElse(new Yritystiedot());

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

	// 5. REITTI: Generoi PostgreSQL-tietokannan varmuuskopiot .sql tiedostona
	@GetMapping("/asetukset/varmuuskopio")
	public void otaVarmuuskopio(HttpSession session, HttpServletResponse response) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
			return;
		}

		try {
			String dbName = "asiakastiedot";
			String dbUser = "postgres";
			String dbPassword = "admin";

			ProcessBuilder pb = new ProcessBuilder("E:\\Program Files\\PostgreSQL\\18\\bin\\pg_dump.exe", "-U", dbUser,
					"-h", "localhost", "-p", "5432", "-F", "p", dbName);

			pb.environment().put("PGPASSWORD", dbPassword);
			Process prosessi = pb.start();

			String tiedostonimi = "astori_varmuuskopio_" + System.currentTimeMillis() + ".sql";
			response.setContentType("application/sql");
			response.setCharacterEncoding("UTF-8");
			response.setHeader("Content-Disposition", "attachment; filename=\"" + tiedostonimi + "\"");

			try (java.io.InputStream in = prosessi.getInputStream();
					java.io.OutputStream out = response.getOutputStream()) {

				byte[] puskuri = new byte[8192];
				int luetutTavut;
				while ((luetutTavut = in.read(puskuri)) != -1) {
					out.write(puskuri, 0, luetutTavut);
				}
				out.flush();
			}

			int exitCode = prosessi.waitFor();
			if (exitCode != 0) {
				System.err.println("pg_dump päättyi virhekoodiin: " + exitCode);
			}

		} catch (Exception e) {
			e.printStackTrace();
			response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
		}
	}

	// 6. REITTI: Kalenterin dynaamisten tapahtumatyyppien luonti
	@PostMapping("/asetukset/lisaa-tyyppi")
	public String lisaaTapahtumaTyyppi(@RequestParam("nimi") String nimi, @RequestParam("vari") String vari) {

		TapahtumaTyyppi uusiTyyppi = new TapahtumaTyyppi();
		uusiTyyppi.setNimi(nimi);
		uusiTyyppi.setVari(vari);

		tapahtumaTyyppiRepository.save(uusiTyyppi);
		return "redirect:/asetukset";
	}

	// 7. REITTI: Kalenterin dynaamisten tapahtumatyyppien muokkaus
	@PostMapping("/asetukset/muokkaa-typpia/{id}")
	public String muokkaaTapahtumaTyyppi(@PathVariable Long id, @RequestParam("nimi") String uusiNimi,
			@RequestParam("vari") String vari) {

		TapahtumaTyyppi tyyppi = tapahtumaTyyppiRepository.findById(id).orElse(null);
		if (tyyppi != null) {
			tyyppi.setNimi(uusiNimi);
			tyyppi.setVari(vari);
			tapahtumaTyyppiRepository.save(tyyppi);
		}
		return "redirect:/asetukset";
	}
}
