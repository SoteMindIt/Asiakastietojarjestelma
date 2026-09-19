package fi.sotemindit.astori.controller;

import jakarta.servlet.http.HttpSession;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.temporal.TemporalAdjusters; // 🔗 UUSI: Kuukauden dynaamiseen rajaukseen
import java.math.BigDecimal; // 📊 UUSI: Sentintarkkaan myyntilaskentaan
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;

import fi.sotemindit.astori.model.Loki;
import fi.sotemindit.astori.model.Asiakas;
import fi.sotemindit.astori.model.Kirjaus;
import fi.sotemindit.astori.model.AsiakasTuote; // 🔗 UUSI
import fi.sotemindit.astori.repository.LokiRepository;
import fi.sotemindit.astori.repository.AsiakasRepository;
import fi.sotemindit.astori.repository.KirjausRepository;
import fi.sotemindit.astori.repository.AsiakasTuoteRepository; // 🔗 UUSI

@Controller
public class RaportitController {

	@Autowired
	private LokiRepository lokiRepository;

	@Autowired
	private AsiakasRepository asiakasRepository;

	@Autowired
	private KirjausRepository kirjausRepository;

	@Autowired
	private AsiakasTuoteRepository asiakasTuoteRepository; // 🔗 UUSI

	@GetMapping("/raportit")
	public String naytaRaportit(HttpSession session, @RequestParam(value = "sivu", defaultValue = "0") int sivu,
			@RequestParam(value = "kSivu", defaultValue = "0") int kirjausSivu,
			@RequestParam(value = "alkuPvm", required = false) String alkuPvmStr,
			@RequestParam(value = "loppuPvm", required = false) String loppuPvmStr, Model model) {

		// 1. Istuntotarkistus
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		// Asetetaan dynaamiset aikavälit
		LocalDate alkuPvm;
		LocalDate loppuPvm;
		boolean kaytossaOletusKuluvaKk = false;

		if (alkuPvmStr != null && !alkuPvmStr.trim().isEmpty() && loppuPvmStr != null
				&& !loppuPvmStr.trim().isEmpty()) {
			alkuPvm = LocalDate.parse(alkuPvmStr);
			loppuPvm = LocalDate.parse(loppuPvmStr);
		} else {
			// 💡 DYNAAMINEN KORJAUS: Katsotaan kuluva kuukausi palvelimen tämän hetken
			// päivämäärästä!
			LocalDate tanaan = LocalDate.now();
			alkuPvm = tanaan.with(TemporalAdjusters.firstDayOfMonth()); // Kuukauden 1. päivä
			loppuPvm = tanaan.with(TemporalAdjusters.lastDayOfMonth()); // Kuukauden viimeinen päivä

			alkuPvmStr = alkuPvm.toString();
			loppuPvmStr = loppuPvm.toString();
			kaytossaOletusKuluvaKk = true;
		}

		// Muunnetaan LocalDateTime-muotoon Audittia ja Kirjauksia varten
		LocalDateTime alkuAika = alkuPvm.atStartOfDay();
		LocalDateTime loppuAika = loppuPvm.atTime(LocalTime.MAX);

		// 2. HAETAAN KÄYTTÖLOKI (Audit Trail) - 100 riviä
		Pageable lokiPageable = PageRequest.of(sivu, 100);
		Page<Loki> lokiSivu = lokiRepository.findByAikaleimaBetweenOrderByAikaleimaDesc(alkuAika, loppuAika,
				lokiPageable);

		// 3. HAETAAN ASIAKASKIRJAUKSET - 20 riviä per sivu
		Pageable kirjausPageable = PageRequest.of(kirjausSivu, 20);
		Page<Kirjaus> haetutKirjauksetSivu = kirjausRepository.findByLuontiaikaBetweenOrderByLuontiaikaDesc(alkuAika,
				loppuAika, kirjausPageable);

		Map<Long, List<Kirjaus>> kirjauksetKartta = haetutKirjauksetSivu.getContent().stream()
				.collect(Collectors.groupingBy(k -> k.getAsiakas().getId()));

		List<Asiakas> kaikkiAsiakkaat = asiakasRepository.findAll();

		// 📊 4. UUSI MYYNTIRAPORTTILOGIIKKA (AsiakasTuote)
		List<AsiakasTuote> myyntirivit = asiakasTuoteRepository.findMyyntiAjanjaksolta(istuntoTunnus, alkuPvm,
				loppuPvm);

		// 📊 PÄIVITETTY MYYNTIRAPORTTILOGIIKKA (Erotetaan 0% korvaukset verollisesta
		// yhteissummasta)
		BigDecimal kokonaisVeroton = BigDecimal.ZERO;
		BigDecimal kokonaisAlv = BigDecimal.ZERO;
		BigDecimal kokonaisVerollinen = BigDecimal.ZERO;

		for (AsiakasTuote at : myyntirivit) {
			// Kaikki rivit kerryttävät aina yleistä verotonta liikevaihtoa
			kokonaisVeroton = kokonaisVeroton.add(at.getKokonaishinta());
			kokonaisAlv = kokonaisAlv.add(at.getAlvOsuus());

			// 💡 KORJAUS: Jos ALV on 0% (esim. KM-korvaus), sitä EI lasketa mukaan
			// verollisen myynnin pottiin
			if (at.getAlvKanta() != null && at.getAlvKanta().getProsentti().compareTo(java.math.BigDecimal.ZERO) > 0) {
				kokonaisVerollinen = kokonaisVerollinen.add(at.getVerollinenKokonaishinta());
			}
		}

		// 5. DATAN REKISTERÖINTI JSP-SIVULLE
		
		//Haetaan kaikki tärkeäksi merkityt asiakaskirjaukset valitulta ajanjaksolta
		List<Kirjaus> tarkeatKirjaukset = kirjausRepository.findTarkeatKirjauksetAjanjaksolta(istuntoTunnus, alkuAika, loppuAika);

		// Tärkeät kirjaukset -muuttuja JSP-sivulle
		model.addAttribute("tarkeatKirjaukset", tarkeatKirjaukset);

		model.addAttribute("asiakkaatYhteensa", asiakasRepository.count());
		model.addAttribute("haitariAsiakkaat", kaikkiAsiakkaat);
		model.addAttribute("kirjauksetKartta", kirjauksetKartta);

		// Myyntiraportin muuttujat
		model.addAttribute("myyntirivit", myyntirivit);
		model.addAttribute("kokonaisVeroton", kokonaisVeroton);
		model.addAttribute("kokonaisAlv", kokonaisAlv);
		model.addAttribute("kokonaisVerollinen", kokonaisVerollinen);
		model.addAttribute("kaytossaOletusKuluvaKk", kaytossaOletusKuluvaKk);

		// Audit Trail -sivutusmuuttujat
		model.addAttribute("lokirivit", lokiSivu.getContent());
		model.addAttribute("nykyinenSivu", sivu);
		model.addAttribute("kokonaissivut", lokiSivu.getTotalPages());
		model.addAttribute("lokirivejaYhteensa", lokiSivu.getTotalElements());

		// Kirjaushaitari -sivutusmuuttujat
		model.addAttribute("nykyinenKirjausSivu", kirjausSivu);
		model.addAttribute("kirjausKokonaissivut", haetutKirjauksetSivu.getTotalPages());
		model.addAttribute("kirjauksiaYhteensa", haetutKirjauksetSivu.getTotalElements());

		model.addAttribute("alkuPvm", alkuPvmStr);
		model.addAttribute("loppuPvm", loppuPvmStr);

		return "raportit";
	}
}
