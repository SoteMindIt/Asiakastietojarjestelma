package fi.sotemindit.astori.controller;

import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import fi.sotemindit.astori.model.Muistiinpano;
import fi.sotemindit.astori.repository.MuistiinpanoRepository;

@Controller
public class MuistiinpanoController {

	@Autowired
	private MuistiinpanoRepository muistiinpanoRepository;

	// 🔌 UUSI: Ottaa vastaan etusivun pikalomakkeen yleisen muistiinpanon ja tallentaa sen
	@PostMapping("/lisaa-muistiinpano")
	public String lisaaMuistiinpano(@RequestParam("teksti") String teksti, HttpSession session) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		if (teksti != null && !teksti.trim().isEmpty()) {
			Muistiinpano mp = new Muistiinpano(teksti.trim(), istuntoTunnus);
			muistiinpanoRepository.save(mp);
		}

		return "redirect:/"; // Palautetaan käyttäjä suoraan takaisin etusivulle
	}
}
