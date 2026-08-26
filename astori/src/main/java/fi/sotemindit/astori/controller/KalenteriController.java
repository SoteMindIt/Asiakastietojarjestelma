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

	// 1. REITTI: Näyttää kalenterin
	@GetMapping("/kalenteri")
	public String naytaKalenteri(HttpSession session, Model model) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		Kayttaja nykyinenKayttaja = kayttajaRepository.findByKayttajatunnus(istuntoTunnus)
				.orElseThrow(() -> new IllegalArgumentException("Käyttäjää ei löytynyt"));

		model.addAttribute("asiakkaat", asiakasRepository.findAll());
		model.addAttribute("tyypit", TapahtumaTyyppi.values());

		List<Tapahtuma> tapahtumat;

		if ("ADMIN".equals(nykyinenKayttaja.getRooli())) {
			tapahtumat = tapahtumaRepository.findAll();
			lokiRepository.save(
					new Loki(istuntoTunnus, "KATSELU", "Pääkäyttäjä avasi kaikkien työntekijöiden kalenterinäkymän."));
		} else {
			tapahtumat = tapahtumaRepository.findByKayttajatunnus(istuntoTunnus);
		}

		model.addAttribute("tapahtumat", tapahtumat);
		return "kalenteri";
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
		model.addAttribute("asiakkaat", asiakasRepository.findAll()); // Tarvitaan, jos asiakasta halutaan vaihtaa
																		// muokatessa
		model.addAttribute("tyypit", TapahtumaTyyppi.values()); // Tarvitaan tyypin vaihtoon

		return "muokkaa-tapahtumaa";
	}

	// 💾 3. REITTI: Vastaanottaa muokkauslomakkeen tiedot (sekä etusivulta että
	// kalenterista) ja ohjaa oikealle sivulle
	@PostMapping("/kalenteri/paivita/{id}")
	public String paivitaTapahtuma(@PathVariable Long id, @RequestParam String otsikko, @RequestParam String kuvaus,
			@RequestParam String ajankohtaStr, @RequestParam TapahtumaTyyppi tyyppi,
			@RequestParam(value = "asiakasId", required = false) Long asiakasId,
			@RequestParam(value = "lahde", required = false) String lahde, // Tunnistaa mistä ikkuna avattiin
			HttpSession session) {

		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		Tapahtuma tapahtuma = tapahtumaRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Tapahtumaa ei löytynyt id-numerolla: " + id));

		// Päivitetään tiedot olioon
		tapahtuma.setOtsikko(otsikko);
		tapahtuma.setKuvaus(kuvaus);
		tapahtuma.setAjankohta(LocalDateTime.parse(ajankohtaStr));
		tapahtuma.setTyyppi(tyyppi);

		// Käsitellään vapaaehtoinen asiakasliitos
		if (asiakasId != null) {
			fi.sotemindit.astori.model.Asiakas asiakas = asiakasRepository.findById(asiakasId)
					.orElseThrow(() -> new IllegalArgumentException("Asiakasta ei löytynyt"));
			tapahtuma.setAsiakas(asiakas);
		} else {
			tapahtuma.setAsiakas(null);
		}

		tapahtumaRepository.save(tapahtuma);

		// Lisätään lokimerkintä muokkauksesta
		lokiRepository.save(new Loki(istuntoTunnus, "MUOKKAUS",
				"Muokattu kalenteritapahtumaa ID: " + id + " (Otsikko: " + otsikko + ")"));

		// JOUSTAVA PALUU: Jos muokkaus tehtiin kalenterisivulta, palataan sinne. Muuten
		// etusivulle.
		if ("kalenteri".equals(lahde)) {
			return "redirect:/kalenteri";
		}
		return "redirect:/";
	}

	// 📅 4. REITTI: Tallentaa uuden kalenterimerkinnän (KORJATTU ASIAKAS ID -VIRHE)
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

	// 5. REITTI: Poistaa kalenteritapahtuman taulukkolistoista (käyttää
	// RequestParamia)
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

	// 🗑️ 6. REITTI: Poistaa kalenteritapahtuman suoraan modal-ponnahdusikkunasta
	// käsin (Käyttää PathVariablea)
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