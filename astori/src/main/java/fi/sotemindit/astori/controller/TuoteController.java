package fi.sotemindit.astori.controller;

import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import fi.sotemindit.astori.model.Tuote;
import fi.sotemindit.astori.model.TuoteYksikko;
import fi.sotemindit.astori.model.AlvKanta;
import fi.sotemindit.astori.repository.TuoteRepository;

@Controller
@RequestMapping("/asetukset")
public class TuoteController {

	@Autowired
	private TuoteRepository tuoteRepository;

	// 1. LISÄÄ UUSI TUOTE / PALVELU TUOTEREKISTERIIN
	@PostMapping("/lisaa-tuote")
	public String lisaaTuote(@RequestParam String nimi,
							 @RequestParam String kuvaus,
							 @RequestParam java.math.BigDecimal hinta,
							 @RequestParam String yksikko,
							 @RequestParam String alvKanta,
							 HttpSession session) {

		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		try {
			Tuote uusiTuote = new Tuote();
			uusiTuote.setNimi(nimi != null ? nimi.trim() : "");
			uusiTuote.setKuvaus(kuvaus != null ? kuvaus.trim() : "");
			uusiTuote.setHinta(hinta);
			uusiTuote.setYksikko(TuoteYksikko.valueOf(yksikko));
			uusiTuote.setAlvKanta(AlvKanta.valueOf(alvKanta));

			tuoteRepository.save(uusiTuote);
			return "redirect:/asetukset?success=product_created";
		} catch (Exception e) {
			return "redirect:/asetukset?virhe=product_failed";
		}
	}

	// 2. INLINE-MUOKKAA OLEMASSA OLEVAA TUOTETTA
	@PostMapping("/muokkaa-tuotetta/{id}")
	public String muokkaaTuotetta(@PathVariable Long id,
								  @RequestParam String nimi,
								  @RequestParam String kuvaus,
								  @RequestParam java.math.BigDecimal hinta,
								  @RequestParam String yksikko,
								  @RequestParam String alvKanta,
								  HttpSession session) {

		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		try {
			Tuote tuote = tuoteRepository.findById(id)
					.orElseThrow(() -> new IllegalArgumentException("Tuotetta ei löytynyt ID-numerolla: " + id));

			tuote.setNimi(nimi != null ? nimi.trim() : "");
			tuote.setKuvaus(kuvaus != null ? kuvaus.trim() : "");
			tuote.setHinta(hinta);
			tuote.setYksikko(TuoteYksikko.valueOf(yksikko));
			tuote.setAlvKanta(AlvKanta.valueOf(alvKanta));

			tuoteRepository.save(tuote);
			return "redirect:/asetukset?success=product_updated";
		} catch (Exception e) {
			return "redirect:/asetukset?virhe=product_edit_failed";
		}
	}
}
