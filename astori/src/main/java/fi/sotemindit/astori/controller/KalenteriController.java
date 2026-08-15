package fi.sotemindit.astori.controller;

import java.time.LocalDateTime;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import fi.sotemindit.astori.model.Tapahtuma;
import fi.sotemindit.astori.model.TapahtumaTyyppi;
import fi.sotemindit.astori.repository.AsiakasRepository;
import fi.sotemindit.astori.repository.TapahtumaRepository;
import jakarta.servlet.http.HttpSession;

@Controller
public class KalenteriController {

	@Autowired
	private TapahtumaRepository tapahtumaRepository;

	@Autowired
	private AsiakasRepository asiakasRepository;

	// 1. REITTI: Näyttää kalenterisivun
	@GetMapping("/kalenteri")
	public String naytaKalenteri(HttpSession session, Model model) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		// Viedään sivulle asiakkaat uuden varauksen pudotusvalikkoa varten
		model.addAttribute("asiakkaat", asiakasRepository.findAll());
		// Viedään tapahtumatyypit (PUHELU, TAPAAMINEN jne.)
		model.addAttribute("tyypit", TapahtumaTyyppi.values());
		// Haetaan kaikki tapahtumat kalenteriruudukkoon tulostettavaksi
		model.addAttribute("tapahtumat", tapahtumaRepository.findAll());

		return "kalenteri"; // Avaa kalenteri.jsp
	}

	// 2. REITTI: Tallentaa uuden kalenterimerkinnän
	@PostMapping("/kalenteri/lisaa")
	public String lisaaKalenteriTapahtuma(@RequestParam String otsikko, @RequestParam String kuvaus,
			@RequestParam String ajankohtaStr, // Otetaan vastaan tekstinä lomakkeelta
			@RequestParam TapahtumaTyyppi tyyppi, @RequestParam Long asiakasId, HttpSession session) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		// Muunnetaan HTML5-lomakkeen datetime-local merkkijono Javan
		// LocalDateTime-muotoon
		LocalDateTime ajankohta = LocalDateTime.parse(ajankohtaStr);

		fi.sotemindit.astori.model.Asiakas asiakas = asiakasRepository.findById(asiakasId)
				.orElseThrow(() -> new IllegalArgumentException("Asiakasta ei löytynyt"));

		Tapahtuma uusiTapahtuma = new Tapahtuma(otsikko, kuvaus, ajankohta, tyyppi, asiakas);
		tapahtumaRepository.save(uusiTapahtuma);

		return "redirect:/kalenteri"; // Palataan takaisin kalenterinäkymään
	}

}
