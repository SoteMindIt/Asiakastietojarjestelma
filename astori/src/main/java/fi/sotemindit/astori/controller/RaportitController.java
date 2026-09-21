package fi.sotemindit.astori.controller;

import jakarta.servlet.http.HttpSession;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.temporal.TemporalAdjusters;
import java.math.BigDecimal;
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
import fi.sotemindit.astori.model.AsiakasTuote;
import fi.sotemindit.astori.model.Kirjaustyyppi; 
import fi.sotemindit.astori.repository.LokiRepository;
import fi.sotemindit.astori.repository.AsiakasRepository;
import fi.sotemindit.astori.repository.KirjausRepository;
import fi.sotemindit.astori.repository.KirjaustyyppiRepository;
import fi.sotemindit.astori.repository.AsiakasTuoteRepository;

@Controller
public class RaportitController {

	@Autowired
	private KirjaustyyppiRepository kirjaustyyppiRepository;

	@Autowired
	private LokiRepository lokiRepository;

	@Autowired
	private AsiakasRepository asiakasRepository;

	@Autowired
	private KirjausRepository kirjausRepository;

	@Autowired
	private AsiakasTuoteRepository asiakasTuoteRepository;

	@GetMapping("/raportit")
	public String naytaRaportit(HttpSession session, @RequestParam(value = "sivu", defaultValue = "0") int sivu,
			@RequestParam(value = "kSivu", defaultValue = "0") int kirjausSivu,
			@RequestParam(value = "alkuPvm", required = false) String alkuPvmStr,
			@RequestParam(value = "loppuPvm", required = false) String loppuPvmStr,
			@RequestParam(value = "tyyppi", required = false) Long tyyppiId, Model model) {

		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		LocalDate alkuPvm;
		LocalDate loppuPvm;
		boolean kaytossaOletusKuluvaKk = false;

		if (alkuPvmStr != null && !alkuPvmStr.trim().isEmpty() && loppuPvmStr != null
				&& !loppuPvmStr.trim().isEmpty()) {
			alkuPvm = LocalDate.parse(alkuPvmStr);
			loppuPvm = LocalDate.parse(loppuPvmStr);
		} else {
			LocalDate tanaan = LocalDate.now();
			alkuPvm = tanaan.with(TemporalAdjusters.firstDayOfMonth());
			loppuPvm = tanaan.with(TemporalAdjusters.lastDayOfMonth());

			alkuPvmStr = alkuPvm.toString();
			loppuPvmStr = loppuPvm.toString();
			kaytossaOletusKuluvaKk = true;
		}

		LocalDateTime alkuAika = alkuPvm.atStartOfDay();
		LocalDateTime loppuAika = loppuPvm.atTime(LocalTime.MAX);

		Pageable lokiPageable = PageRequest.of(sivu, 100);
		Page<Loki> lokiSivu = lokiRepository.findByAikaleimaBetweenOrderByAikaleimaDesc(alkuAika, loppuAika,
				lokiPageable);

		Pageable kirjausPageable = PageRequest.of(kirjausSivu, 20);
		Page<Kirjaus> haetutKirjauksetSivu = kirjausRepository.findByLuontiaikaBetweenOrderByLuontiaikaDesc(alkuAika,
				loppuAika, kirjausPageable);

		Map<Long, List<Kirjaus>> kirjauksetKartta = haetutKirjauksetSivu.getContent().stream()
				.collect(Collectors.groupingBy(k -> k.getAsiakas().getId()));

		List<Asiakas> hatariAsiakkaat = new java.util.ArrayList<>();

		if (tyyppiId != null) {
			List<Kirjaus> kaikkiTietynTyypinKirjaukset = kirjausRepository.findAll().stream()
					.filter(k -> k.getKirjaustyyppi() != null && k.getKirjaustyyppi().getId().equals(tyyppiId))
					.collect(Collectors.toList());

			for (Kirjaus k : kaikkiTietynTyypinKirjaukset) {
				Asiakas a = k.getAsiakas();
				if (a != null && a.getKayttaja() != null && istuntoTunnus.equals(a.getKayttaja().getKayttajatunnus())) {
					if (!hatariAsiakkaat.contains(a)) {
						hatariAsiakkaat.add(a);
					}
				}
			}
			model.addAttribute("valittuTyyppiId", tyyppiId);
		} else {
			hatariAsiakkaat = asiakasRepository.findAll().stream()
					.filter(a -> a.getKayttaja() != null && istuntoTunnus.equals(a.getKayttaja().getKayttajatunnus()))
					.collect(Collectors.toList());
		}

		List<AsiakasTuote> myyntirivit = asiakasTuoteRepository.findMyyntiAjanjaksolta(istuntoTunnus, alkuPvm,
				loppuPvm);

		BigDecimal kokonaisVeroton = BigDecimal.ZERO;
		BigDecimal kokonaisAlv = BigDecimal.ZERO;
		BigDecimal kokonaisVerollinen = BigDecimal.ZERO;

		for (AsiakasTuote at : myyntirivit) {
			kokonaisVeroton = kokonaisVeroton.add(at.getKokonaishinta());
			kokonaisAlv = kokonaisAlv.add(at.getAlvOsuus());

			if (at.getAlvKanta() != null && at.getAlvKanta().getProsentti().compareTo(java.math.BigDecimal.ZERO) > 0) {
				kokonaisVerollinen = kokonaisVerollinen.add(at.getVerollinenKokonaishinta());
			}
		}

		List<Kirjaus> tarkeatKirjaukset = kirjausRepository.findTarkeatKirjauksetAjanjaksolta(istuntoTunnus, alkuAika,
				loppuAika);

		model.addAttribute("kirjaustyypit", kirjaustyyppiRepository.findAll());
		model.addAttribute("tarkeatKirjaukset", tarkeatKirjaukset);
		model.addAttribute("asiakkaatYhteensa", asiakasRepository.count());
		model.addAttribute("haitariAsiakkaat", hatariAsiakkaat);
		model.addAttribute("kirjauksetKartta", kirjauksetKartta);

		model.addAttribute("myyntirivit", myyntirivit);
		model.addAttribute("kokonaisVeroton", kokonaisVeroton);
		model.addAttribute("kokonaisAlv", kokonaisAlv);
		model.addAttribute("kokonaisVerollinen", kokonaisVerollinen);
		model.addAttribute("kaytossaOletusKuluvaKk", kaytossaOletusKuluvaKk);

		model.addAttribute("lokirivit", lokiSivu.getContent());
		model.addAttribute("nykyinenSivu", sivu);
		model.addAttribute("kokonaissivut", lokiSivu.getTotalPages());
		model.addAttribute("lokirivejaYhteensa", lokiSivu.getTotalElements());

		model.addAttribute("nykyinenKirjausSivu", kirjausSivu);
		model.addAttribute("kirjausKokonaissivut", haetutKirjauksetSivu.getTotalPages());
		model.addAttribute("kirjauksiaYhteensa", haetutKirjauksetSivu.getTotalElements());

		model.addAttribute("alkuPvm", alkuPvmStr);
		model.addAttribute("loppuPvm", loppuPvmStr);

		return "raportit";
	}
}
