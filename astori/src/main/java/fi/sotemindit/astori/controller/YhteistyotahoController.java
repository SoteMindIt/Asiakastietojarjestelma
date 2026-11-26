package fi.sotemindit.astori.controller;

import fi.sotemindit.astori.model.Loki;
import fi.sotemindit.astori.model.Yhteistyotaho;
import fi.sotemindit.astori.repository.LokiRepository;
import fi.sotemindit.astori.repository.YhteistyotahoRepository;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class YhteistyotahoController {

	@Autowired
	private YhteistyotahoRepository yhteistyotahoRepository;

	@Autowired
	private LokiRepository lokiRepository;

	@GetMapping("/yhteistyotahot")
	public String listaaYhteistyotahot(HttpSession session, Model model) {
		if (session.getAttribute("kirjautunutKayttaja") == null) {
			return "redirect:/login";
		}

		List<Yhteistyotaho> yhteistyotahot = yhteistyotahoRepository.findAllByOrderByNimiAsc();
		model.addAttribute("yhteistyotahot", yhteistyotahot);
		return "yhteistyotahot";
	}

	@PostMapping("/yhteistyotahot/lisaa")
	public String lisaaYhteistyotaho(@RequestParam String nimi,
			@RequestParam(required = false, defaultValue = "") String puhelin,
			@RequestParam(required = false, defaultValue = "") String sahkoposti,
			@RequestParam(required = false, defaultValue = "") String rooli,
			@RequestParam(required = false, defaultValue = "") String selite,
			HttpSession session) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}
		if (nimi == null || nimi.isBlank()) {
			return "redirect:/yhteistyotahot?error=nimi";
		}

		Yhteistyotaho yhteistyotaho = new Yhteistyotaho();
		yhteistyotaho.setNimi(nimi.trim());
		yhteistyotaho.setPuhelin(normalisoiValinnainen(puhelin));
		yhteistyotaho.setSahkoposti(normalisoiValinnainen(sahkoposti));
		yhteistyotaho.setRooli(normalisoiValinnainen(rooli));
		yhteistyotaho.setSelite(normalisoiValinnainen(selite));
		yhteistyotahoRepository.save(yhteistyotaho);
		lokiRepository.save(new Loki(istuntoTunnus, "LISÄYS",
				"Lisätty yhteistyötaho '" + yhteistyotaho.getNimi() + "'."));

		return "redirect:/yhteistyotahot?success=created";
	}

	private String normalisoiValinnainen(String arvo) {
		return arvo == null || arvo.isBlank() ? null : arvo.trim();
	}
}
