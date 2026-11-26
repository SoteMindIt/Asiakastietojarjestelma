package fi.sotemindit.astori.controller;

import fi.sotemindit.astori.model.Kirjaustyyppi;
import fi.sotemindit.astori.model.Kirjaus;
import fi.sotemindit.astori.repository.KirjausRepository;
import fi.sotemindit.astori.repository.KirjaustyyppiRepository;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class KirjaustyyppiController {

	@Autowired
	private KirjaustyyppiRepository kirjaustyyppiRepository;

	@Autowired
	private KirjausRepository kirjausRepository;

	/**
	 * 🔌 1. UUDEN KIRJAUSTYYPIN LISÄYS
	 * Ottaa vastaan lomakkeelta tyypin nimen ja valitun tunnusvärin.
	 */
	@PostMapping("/asetukset/lisaa-kirjaustyyppi")
	public String lisaaKirjaustyyppi(@RequestParam("nimi") String nimi, @RequestParam("vari") String vari,
			HttpSession session) {

		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		Kirjaustyyppi uusiTyyppi = new Kirjaustyyppi();
		uusiTyyppi.setNimi(nimi.trim());
		uusiTyyppi.setVari(vari);

		kirjaustyyppiRepository.save(uusiTyyppi);
		
		// Palataan asetuksiin ja viedään onnistumis-URL-parametri välilehden tunnistusta varten
		return "redirect:/asetukset?success=kirjaustyyppi_created";
	}

	/**
	 * 🔌 2. OLEMASSA OLEVAN KIRJAUSTYYPIN MUOKKAUS
	 * Päivittää dynaamisen tyypin nimen ja badge-värin.
	 */
	@PostMapping("/asetukset/muokkaa-kirjaustyyppia/{id}")
	public String muokkaaKirjaustyyppia(@PathVariable Long id, @RequestParam("nimi") String uusiNimi,
			@RequestParam("vari") String vari, HttpSession session) {

		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		Kirjaustyyppi tyyppi = kirjaustyyppiRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Kirjaustyyppiä ei löytynyt ID-numerolla: " + id));

		tyyppi.setNimi(uusiNimi.trim());
		tyyppi.setVari(vari);

		kirjaustyyppiRepository.save(tyyppi);
		
		return "redirect:/asetukset?success=kirjaustyyppi_updated";
	}

	@Transactional
	@PostMapping("/asetukset/poista-kirjaustyyppi/{id}")
	public String poistaKirjaustyyppi(@PathVariable Long id, HttpSession session) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		Kirjaustyyppi tyyppi = kirjaustyyppiRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Kirjaustyyppiä ei löytynyt ID-numerolla: " + id));
		List<Kirjaus> kirjaukset = kirjausRepository.findByKirjaustyyppi_Id(id);
		kirjaukset.forEach(kirjaus -> kirjaus.setKirjaustyyppi(null));
		kirjausRepository.saveAll(kirjaukset);
		kirjausRepository.flush();
		kirjaustyyppiRepository.delete(tyyppi);

		return "redirect:/asetukset?success=kirjaustyyppi_deleted";
	}
}
