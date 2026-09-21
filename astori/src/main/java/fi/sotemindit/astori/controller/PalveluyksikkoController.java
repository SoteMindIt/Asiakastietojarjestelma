package fi.sotemindit.astori.controller;

import fi.sotemindit.astori.model.Asiakas;
import fi.sotemindit.astori.model.Hyvinvointialue;
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
public class PalveluyksikkoController {

	@Autowired
	private PalveluyksikkoRepository palveluyksikkoRepository;

	@Autowired
	private AsiakasRepository asiakasRepository;

	@Autowired
	private YhteyshenkiloRepository yhteyshenkiloRepository;

	@Autowired
	private LokiRepository lokiRepository;

	/**
	 * 🔌 1. PALVELUYKSIKÖN LISÄYS
	 * Tallentaa uuden palveluyksikön Y-tunnuksineen ja kytkee sen pääasiakkaaseen.
	 */
	@PostMapping("/asiakas/{asiakasId}/lisaa-palveluyksikko")
	public String lisaaPalveluyksikko(@PathVariable Long asiakasId, @RequestParam String nimi,
			@RequestParam(required = false) String yTunnus, // 🔌 UUSI PARAMETRI LOMAKKEELTA
			@RequestParam(required = false) String katuosoite, @RequestParam(required = false) String postinumero,
			@RequestParam(required = false) String postitoimipaikka, @RequestParam(required = false) String puhelin,
			@RequestParam(required = false) String sahkoposti, @RequestParam(required = false) String kuvaus,
			@RequestParam(required = false) Hyvinvointialue hyvinvointialue,
			@RequestParam(required = false) String yhNimi, @RequestParam(required = false) String yhRooli,
			@RequestParam(required = false) String yhSahkoposti, @RequestParam(required = false) String yhPuhelin,
			HttpSession session) {

		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		Asiakas asiakas = asiakasRepository.findById(asiakasId)
				.orElseThrow(() -> new IllegalArgumentException("Asiakasta ei löytynyt ID-numerolla: " + asiakasId));

		// 1. Luodaan palveluyksikkö ja asetetaan sille uusi Y-tunnus
		Palveluyksikko uusiYksikko = new Palveluyksikko(nimi, katuosoite, postinumero, postitoimipaikka, 
				puhelin, sahkoposti, kuvaus, hyvinvointialue, asiakas);
		
		uusiYksikko.setyTunnus(yTunnus); // 🔌 Tallennetaan toimipistekohtainen Y-tunnus
		palveluyksikkoRepository.save(uusiYksikko);

		// 2. Jos lomakkeella annettiin inline-yhteyshenkilö, luodaan ja liitetään se tähän yksikköön
		if (yhNimi != null && !yhNimi.trim().isEmpty()) {
			Yhteyshenkilo vastuuhenkilo = new Yhteyshenkilo(yhNimi.trim(), yhRooli != null ? yhRooli.trim() : "",
					yhSahkoposti != null ? yhSahkoposti.trim() : "", yhPuhelin != null ? yhPuhelin.trim() : "", 
					asiakas, uusiYksikko);
			yhteyshenkiloRepository.save(vastuuhenkilo);
		}

		String lokiKuvaus = "Lisätty uusi palveluyksikkö '" + nimi + "' (Y-tunnus: " + (yTunnus != null ? yTunnus : "-") + ") asiakkaalle '" + asiakas.getNimi() + "'.";
		lokiRepository.save(new Loki(istuntoTunnus, "LISÄYS", lokiKuvaus));

		return "redirect:/asiakas/" + asiakasId;
	}

	/**
	 * 🔌 2. PALVELUYKSIKÖN MUOKKAUS
	 * Muokkaa palveluyksikköä, sen omaa Y-tunnusta sekä sen inline-vastuuhenkilöä.
	 */
	@PostMapping("/palveluyksikko/muokkaa/{id}")
	public String muokkaaPalveluyksikkaa(@PathVariable Long id, @RequestParam String nimi,
			@RequestParam(required = false) String yTunnus, // 🔌 UUSI PARAMETRI LOMAKKEELTA
			@RequestParam(required = false) String katuosoite, @RequestParam(required = false) String postinumero,
			@RequestParam(required = false) String postitoimipaikka, @RequestParam(required = false) String puhelin,
			@RequestParam(required = false) String sahkoposti, @RequestParam(required = false) String kuvaus,
			@RequestParam(required = false) Hyvinvointialue hyvinvointialue,
			@RequestParam(required = false) Long yhId, @RequestParam(required = false) String yhNimi,
			@RequestParam(required = false) String yhRooli, @RequestParam(required = false) String yhSahkoposti,
			@RequestParam(required = false) String yhPuhelin, @RequestParam Long asiakasId,
			HttpSession session) {

		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		Palveluyksikko py = palveluyksikkoRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Palveluyksikköä ei löytynyt ID:llä: " + id));

		// Päivitetään palveluyksikön tiedot ja uusi Y-tunnus
		py.setNimi(nimi);
		py.setyTunnus(yTunnus); // 🔌 Päivitetään toimipistekohtainen Y-tunnus
		py.setKatuosoite(katuosoite);
		py.setPostinumero(postinumero);
		py.setPostitoimipaikka(postitoimipaikka);
		py.setPuhelin(puhelin);
		py.setSahkoposti(sahkoposti);
		py.setKuvaus(kuvaus);
		py.setHyvinvointialue(hyvinvointialue);
		palveluyksikkoRepository.save(py);

		// Päivitetään tai luodaan inline-yhteyshenkilö toimipisteelle
		Asiakas asiakas = asiakasRepository.findById(asiakasId).orElse(null);
		if (yhNimi != null && !yhNimi.trim().isEmpty()) {
			Yhteyshenkilo yh;
			if (yhId != null) {
				yh = yhteyshenkiloRepository.findById(yhId).orElse(new Yhteyshenkilo());
			} else {
				yh = new Yhteyshenkilo();
				yh.setAsiakas(asiakas);
				yh.setPalveluyksikko(py);
			}
			yh.setNimi(yhNimi.trim());
			yh.setRooli(yhRooli != null ? yhRooli.trim() : "");
			yh.setSahkoposti(yhSahkoposti != null ? yhSahkoposti.trim() : "");
			yh.setPuhelin(yhPuhelin != null ? yhPuhelin.trim() : "");
			yhteyshenkiloRepository.save(yh);
		}

		String lokiKuvaus = "Muokattu palveluyksikön '" + nimi + "' (ID: " + id + ") tietoja asiakkaalle ID: " + asiakasId;
		lokiRepository.save(new Loki(istuntoTunnus, "MUOKKAUS", lokiKuvaus));

		return "redirect:/asiakas/" + asiakasId;
	}
}

