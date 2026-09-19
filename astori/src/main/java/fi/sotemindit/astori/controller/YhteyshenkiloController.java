package fi.sotemindit.astori.controller;

import fi.sotemindit.astori.model.Asiakas;
import fi.sotemindit.astori.model.Loki;
import fi.sotemindit.astori.model.Palveluyksikko;
import fi.sotemindit.astori.model.Yhteyshenkilo;
import fi.sotemindit.astori.repository.AsiakasRepository;
import fi.sotemindit.astori.repository.LokiRepository;
import fi.sotemindit.astori.repository.PalveluyksikkoRepository;
import fi.sotemindit.astori.repository.YhteyshenkiloRepository;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class YhteyshenkiloController {

	@Autowired
	private YhteyshenkiloRepository yhteyshenkiloRepository;

	@Autowired
	private AsiakasRepository asiakasRepository;

	@Autowired
	private PalveluyksikkoRepository palveluyksikkoRepository;

	@Autowired
	private LokiRepository lokiRepository;

	// Siirretty AsiakasControllerista: Yleisen yhteyshenkilön lisäys
	@PostMapping("/asiakas/{asiakasId}/lisaa-yhteyshenkilo")
	public String lisaaYhteyshenkilo(HttpSession session, @PathVariable Long asiakasId,
			@RequestParam String nimi, @RequestParam String rooli, @RequestParam String sahkoposti,
			@RequestParam String puhelin,
			@RequestParam(value = "palveluyksikkoId", required = false) Long palveluyksikkoId) {

		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}
		Asiakas asiakas = asiakasRepository.findById(asiakasId)
				.orElseThrow(() -> new IllegalArgumentException("Asiakasta ei löytynyt"));

		Yhteyshenkilo uusiHenkilo;

		if (palveluyksikkoId != null && palveluyksikkoId > 0) {
			Palveluyksikko py = palveluyksikkoRepository.findById(palveluyksikkoId)
					.orElseThrow(() -> new IllegalArgumentException("Palveluyksikköä ei löytynyt ID:llä: " + palveluyksikkoId));
			uusiHenkilo = new Yhteyshenkilo(nimi, rooli, sahkoposti, puhelin, asiakas, py);
		} else {
			uusiHenkilo = new Yhteyshenkilo(nimi, rooli, sahkoposti, puhelin, asiakas);
		}

		yhteyshenkiloRepository.save(uusiHenkilo);
		
		lokiRepository.save(new Loki(istuntoTunnus, "LISÄYS",
				"Lisätty yhteyshenkilö: " + nimi + " asiakkaalle: " + asiakas.getNimi()));

		return "redirect:/asiakas/" + asiakasId;
	}

	// 🔌 KORJATTU REITTI: Päivittää tiedot JA kytkee dynaamisen palveluyksikkömuutoksen
	@PostMapping("/yhteyshenkilo/muokkaa/{id}")
	public String muokkaaYhteyshenkilo(@PathVariable Long id, @RequestParam String nimi, @RequestParam String rooli,
			@RequestParam String sahkoposti, @RequestParam String puhelin, @RequestParam Long asiakasId,
			@RequestParam(value = "palveluyksikkoId", required = false) Long palveluyksikkoId,
			HttpSession session) {

		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		Yhteyshenkilo yh = yhteyshenkiloRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Yhteyshenkilöä ei löytynyt ID-numerolla: " + id));

		yh.setNimi(nimi);
		yh.setRooli(rooli);
		yh.setSahkoposti(sahkoposti);
		yh.setPuhelin(puhelin);

		// 🔌 Päivitetään palveluyksikkörelaatio lomakevalinnan perusteella
		if (palveluyksikkoId != null && palveluyksikkoId > 0) {
			Palveluyksikko py = palveluyksikkoRepository.findById(palveluyksikkoId)
					.orElseThrow(() -> new IllegalArgumentException("Palveluyksikköä ei löytynyt ID:llä: " + palveluyksikkoId));
			yh.setPalveluyksikko(py);
		} else {
			yh.setPalveluyksikko(null); // Valittiin tyhjä -> katkaistaan suhde yksikköön, siirtyy organisaatiotasolle
		}

		yhteyshenkiloRepository.save(yh);

		lokiRepository.save(new Loki(istuntoTunnus, "MUOKKAUS",
				"Muokattu yhteyshenkilön tietoja ja toimipistesidosta: " + nimi + " (ID: " + id + ") asiakkaalle ID: " + asiakasId));

		return "redirect:/asiakas/" + asiakasId;
	}
}
