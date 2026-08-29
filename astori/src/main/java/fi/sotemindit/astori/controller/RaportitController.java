package fi.sotemindit.astori.controller;

import java.util.List;
import jakarta.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import fi.sotemindit.astori.model.Loki;
import fi.sotemindit.astori.repository.LokiRepository;
import fi.sotemindit.astori.repository.AsiakasRepository;

@Controller
public class RaportitController {

	@Autowired
	private LokiRepository lokiRepository;

	@Autowired
	private AsiakasRepository asiakasRepository;

	// 1. RAPORTTISIVU: Listaa järjestelmän yleiset raportit ja auditoitavan käyttölokin
	@GetMapping("/raportit")
	public String naytaRaportit(HttpSession session, Model model) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		// Haetaan tilastotietoja raporttisivun yhteenvetokortteja varten
		long asiakkaatYhteensa = asiakasRepository.count();
		List<Loki> lokirivit = lokiRepository.findAllByOrderByAikaleimaDesc();

		// Viedään tiedot raportit.jsp-sivulle
		model.addAttribute("asiakkaatYhteensa", asiakkaatYhteensa);
		model.addAttribute("lokirivit", lokirivit);

		return "raportit";
	}
}
