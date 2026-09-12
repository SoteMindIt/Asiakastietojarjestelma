package fi.sotemindit.astori.controller;

import jakarta.servlet.http.HttpSession;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;

import fi.sotemindit.astori.model.Loki;
import fi.sotemindit.astori.repository.LokiRepository;
import fi.sotemindit.astori.repository.AsiakasRepository;

@Controller
public class RaportitController {

	@Autowired
	private LokiRepository lokiRepository;

	@Autowired
	private AsiakasRepository asiakasRepository;

	// RAPORTTISIVU: Listaa järjestelmän yleiset raportit ja auditoitavan
	// käyttölokin sivutettuna (100 riviä / sivu) hakuaikavälillä
	@GetMapping("/raportit")
	public String naytaRaportit(
			HttpSession session, 
			@RequestParam(value = "sivu", defaultValue = "0") int sivu,
			@RequestParam(value = "alkuPvm", required = false) String alkuPvmStr,
			@RequestParam(value = "loppuPvm", required = false) String loppuPvmStr,
			Model model) {

		// 1. Istuntotarkistus: Varmistetaan, että käyttäjä on kirjautunut sisään
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		// 2. Sivutuskonfiguraatio: Pyydetään 100 riviä kerrallaan
		Pageable pageable = PageRequest.of(sivu, 100);
		Page<Loki> lokiSivu;
		long lokirivejaYhteensa;

		// 3. Aikavälihaku tai yleishaku ehtojen mukaan
		if (alkuPvmStr != null && !alkuPvmStr.trim().isEmpty() && loppuPvmStr != null && !loppuPvmStr.trim().isEmpty()) {
			// Muutetaan String -> LocalDate (esim "2026-03-15")
			LocalDate alkuPvm = LocalDate.parse(alkuPvmStr);
			LocalDate loppuPvm = LocalDate.parse(loppuPvmStr);

			// Laajennetaan LocalDate kattamaan koko vuorokausi (alku klo 00:00:00 ja loppu klo 23:59:59)
			LocalDateTime alkuAika = alkuPvm.atStartOfDay();
			LocalDateTime loppuAika = loppuPvm.atTime(LocalTime.MAX);

			lokiSivu = lokiRepository.findByAikaleimaBetweenOrderByAikaleimaDesc(alkuAika, loppuAika, pageable);
			lokirivejaYhteensa = lokiSivu.getTotalElements(); // Palauttaa suoraan kyseisen haun kokonaisrivimäärän
		} else {
			// Jos hakuehtoja ei ole, haetaan kaikki kuten ennenkin
			lokiSivu = lokiRepository.findAllByOrderByAikaleimaDesc(pageable);
			lokirivejaYhteensa = lokiRepository.count();
		}

		// Haetaan asiakkaiden kokonaismäärä tilastokorttia varten
		long asiakkaatYhteensa = asiakasRepository.count();

		// 4. Datan vieminen raportit.jsp-sivulle
		model.addAttribute("asiakkaatYhteensa", asiakkaatYhteensa);
		model.addAttribute("lokirivit", lokiSivu.getContent()); // Vain kyseisen sivun 100 riviä
		model.addAttribute("nykyinenSivu", sivu);
		model.addAttribute("kokonaissivut", lokiSivu.getTotalPages());
		model.addAttribute("lokirivejaYhteensa", lokirivejaYhteensa);
		
		// Lähetetään arvot takaisin sivulle, jotta ne jäävät input-kenttiin näkyviin haun jälkeen
		model.addAttribute("alkuPvm", alkuPvmStr);
		model.addAttribute("loppuPvm", loppuPvmStr);

		return "raportit";
	}
}
