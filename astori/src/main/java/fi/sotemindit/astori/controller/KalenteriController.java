package fi.sotemindit.astori.controller;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.PathVariable;

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
	private LokiRepository lokiRepository;

	
	//Näyttää kalenterin ja suorittaa dynaamisen haun suodattimilla
	@GetMapping("/kalenteri")
	public String naytaKalenteri(
			@RequestParam(required = false) Long asiakasId,
			@RequestParam(required = false) String tyyppiStr,
			@RequestParam(required = false) String alkuStr,
			@RequestParam(required = false) String loppuStr,
			jakarta.servlet.http.HttpSession session, 
			org.springframework.ui.Model model) {
		
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		// 1. Muunnetaan lomakkeen merkkijonot Javan tyypeiksi turvallisesti
		fi.sotemindit.astori.model.TapahtumaTyyppi tyyppi = null;
		if (tyyppiStr != null && !tyyppiStr.trim().isEmpty()) {
			try {
				tyyppi = fi.sotemindit.astori.model.TapahtumaTyyppi.valueOf(tyyppiStr);
			} catch (IllegalArgumentException e) { /* Ohitetaan virheellinen tyyppi */ }
		}

		java.time.LocalDateTime alkuPvm = null;
		if (alkuStr != null && !alkuStr.trim().isEmpty()) {
			alkuPvm = java.time.LocalDate.parse(alkuStr).atStartOfDay(); // Hakupäivän alusta klo 00:00
		}

		java.time.LocalDateTime loppuPvm = null;
		if (loppuStr != null && !loppuStr.trim().isEmpty()) {
			loppuPvm = java.time.LocalDate.parse(loppuStr).atTime(23, 59, 59); // Hakupäivän loppuun klo 23:59
		}

		// 2. Haetaan suodatetut tapahtumat suoraan tietokannasta dynaamisella kyselyllä
		List<fi.sotemindit.astori.model.Tapahtuma> tapahtumat = tapahtumaRepository.haeKalenteriSuodattimilla(
				istuntoTunnus, asiakasId, tyyppi, alkuPvm, loppuPvm
		);
		model.addAttribute("tapahtumat", tapahtumat);

		// 3. Viedään myös kaikki dynaamiset asiakkaat ja tyypit hakulomakkeen pudotusvalikoita varten
		model.addAttribute("kaikkiAsiakkaat", asiakasRepository.findAll()); // Tarvitaan valikkoon
		model.addAttribute("tapahtumaTyypit", fi.sotemindit.astori.model.TapahtumaTyyppi.values());

		// 4. Laitetaan tehdyt valinnat takaisin modeliin, jotta ne jäävät lomakkeeseen näkyviin haun jälkeen!
		model.addAttribute("valittuAsiakasId", asiakasId);
		model.addAttribute("valittuTyyppi", tyyppiStr);
		model.addAttribute("valittuAlku", alkuStr);
		model.addAttribute("valittuLoppu", loppuStr);

		return "kalenteri"; // Avaa kalenteri.jsp
	}

	// 📅 2. REITTI: Avaa kalenteritapahtuman muokkaussivun
	@GetMapping("/kalenteri/muokkaa/{id}")
	public String naytaTapahtumanMuokkaus(@PathVariable Long id, Model model, HttpSession session) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		Tapahtuma tapahtuma = tapahtumaRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Tapahtumaa ei löytynyt ID-numerolla: " + id));

		model.addAttribute("tapahtuma", tapahtuma);
		model.addAttribute("asiakkaat", asiakasRepository.findAll());
		model.addAttribute("tyypit", TapahtumaTyyppi.values());

		return "muokkaa-tapahtumaa";
	}

	// 💾 3. REITTI: Vastaanottaa muokkauslomakkeen tiedot ja ohjaa oikealle sivulle
	@PostMapping("/kalenteri/paivita/{id}")
	public String paivitaTapahtuma(@PathVariable Long id, @RequestParam String otsikko, @RequestParam String kuvaus,
			@RequestParam String ajankohtaStr, @RequestParam TapahtumaTyyppi tyyppi,
			@RequestParam(value = "asiakasId", required = false) Long asiakasId,
			@RequestParam(value = "lahde", required = false) String lahde,
			HttpSession session) {

		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		Tapahtuma tapahtuma = tapahtumaRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Tapahtumaa ei löytynyt id-numerolla: " + id));

		tapahtuma.setOtsikko(otsikko);
		tapahtuma.setKuvaus(kuvaus);
		tapahtuma.setAjankohta(LocalDateTime.parse(ajankohtaStr));
		tapahtuma.setTyyppi(tyyppi);

		if (asiakasId != null) {
			fi.sotemindit.astori.model.Asiakas asiakas = asiakasRepository.findById(asiakasId)
					.orElseThrow(() -> new IllegalArgumentException("Asiakasta ei löytynyt"));
			tapahtuma.setAsiakas(asiakas);
		} else {
			tapahtuma.setAsiakas(null);
		}

		tapahtumaRepository.save(tapahtuma);

		lokiRepository.save(new Loki(istuntoTunnus, "MUOKKAUS",
				"Muokattu kalenteritapahtumaa ID: " + id + " (Otsikko: " + otsikko + ")"));

		if ("kalenteri".equals(lahde)) {
			return "redirect:/kalenteri";
		}
		return "redirect:/";
	}

	// 📅 4. REITTI: Tallentaa uuden kalenterimerkinnän
	@PostMapping("/kalenteri/lisaa")
	public String lisaaKalenteriTapahtuma(@RequestParam String otsikko, @RequestParam String kuvaus,
			@RequestParam String ajankohtaStr, @RequestParam TapahtumaTyyppi tyyppi,
			@RequestParam(value = "asiakasId", required = false) Long asiakasId, HttpSession session) {

		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		LocalDateTime ajankohta = LocalDateTime.parse(ajankohtaStr);
		Kayttaja nykyinenKayttaja = kayttajaRepository.findByKayttajatunnus(istuntoTunnus)
				.orElseThrow(() -> new IllegalArgumentException("Käyttäjää ei löytynyt"));

		Tapahtuma uusiTapahtuma = new Tapahtuma();
		uusiTapahtuma.setOtsikko(otsikko);
		uusiTapahtuma.setKuvaus(kuvaus);
		uusiTapahtuma.setAjankohta(ajankohta);
		uusiTapahtuma.setTyyppi(tyyppi);
		uusiTapahtuma.setKayttaja(nykyinenKayttaja);

		if (asiakasId != null) {
			fi.sotemindit.astori.model.Asiakas asiakas = asiakasRepository.findById(asiakasId)
					.orElseThrow(() -> new IllegalArgumentException("Asiakasta ei löytynyt"));
			uusiTapahtuma.setAsiakas(asiakas);
			lokiRepository.save(new Loki(istuntoTunnus, "LISÄYS",
					"Luotu uusi kalenteritapahtuma: '" + otsikko + "' asiakkaalle ID: " + asiakasId));
		} else {
			uusiTapahtuma.setAsiakas(null);
			lokiRepository.save(new Loki(istuntoTunnus, "LISÄYS",
					"Luotu yleinen kalenteritapahtuma ilman asiakasta: '" + otsikko + "'"));
		}

		tapahtumaRepository.save(uusiTapahtuma);
		return "redirect:/kalenteri";
	}

	// 5. REITTI: Poistaa kalenteritapahtuman taulukkolistoista
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

		boolean onOmistaja = tapahtuma.getKayttaja().getKayttajatunnus().equals(istuntoTunnus);
		boolean onAdmin = "ADMIN".equals(nykyinenKayttaja.getRooli());

		if (!onOmistaja && !onAdmin) {
			throw new SecurityException("Sinulla ei ole oikeutta poistaa tämän käyttäjän tapahtumia!");
		}

		tapahtumaRepository.delete(tapahtuma);
		lokiRepository.save(new Loki(istuntoTunnus, "POISTO",
				"Poistettu kalenteritapahtuma ID: " + tapahtumaId + " (Otsikko: " + tapahtuma.getOtsikko() + ")"));

		return "redirect:/kalenteri";
	}

	// 🗑️ 6. REITTI: Poistaa kalenteritapahtuman suoraan modal-ponnahdusikkunasta käsin
	@PostMapping("/kalenteri/poista-suoraan/{id}")
	public String poistaSuoraanModali(
			@PathVariable Long id, 
			@RequestParam(value = "lahde", required = false) String lahde, 
			HttpSession session) {
		
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}
		
		tapahtumaRepository.deleteById(id);
		lokiRepository.save(new Loki(istuntoTunnus, "POISTO", "Poistettu kalenteritapahtuma suoraan modalista ID: " + id));
		
		if ("kalenteri".equals(lahde)) {
			return "redirect:/kalenteri";
		}
		return "redirect:/";
	}
}
