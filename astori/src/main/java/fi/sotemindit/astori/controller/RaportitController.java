package fi.sotemindit.astori.controller;

import jakarta.servlet.http.HttpSession;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.temporal.TemporalAdjusters;
import java.math.BigDecimal;
import java.util.List;

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
import fi.sotemindit.astori.model.AsiakasAjo;
import fi.sotemindit.astori.model.Kirjaus;
import fi.sotemindit.astori.model.AsiakasTuote;
import fi.sotemindit.astori.model.Kirjaustyyppi; 
import fi.sotemindit.astori.repository.LokiRepository;
import fi.sotemindit.astori.repository.AsiakasRepository;
import fi.sotemindit.astori.repository.KirjausRepository;
import fi.sotemindit.astori.repository.KirjaustyyppiRepository;
import fi.sotemindit.astori.repository.AsiakasTuoteRepository;
import fi.sotemindit.astori.repository.AsiakasAjoRepository;

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

	@Autowired
	private AsiakasAjoRepository asiakasAjoRepository;

	@GetMapping("/raportit")
	public String naytaRaportit(HttpSession session, @RequestParam(value = "sivu", defaultValue = "0") int sivu,
			@RequestParam(value = "kSivu", defaultValue = "0") int kirjausSivu,
			@RequestParam(value = "alkuPvm", required = false) String alkuPvmStr,
			@RequestParam(value = "loppuPvm", required = false) String loppuPvmStr,
			@RequestParam(value = "tyyppi", required = false) Long tyyppiId,
			@RequestParam(value = "ajoAlku", required = false) String ajoAlkuStr,
			@RequestParam(value = "ajoLoppu", required = false) String ajoLoppuStr,
			@RequestParam(value = "ajoAsiakas", required = false) Long ajoAsiakasId, Model model) {

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
		Page<Kirjaus> haetutKirjauksetSivu = kirjausRepository.findAsiakasKirjauksetAjanjaksolta(istuntoTunnus,
				alkuAika, loppuAika, tyyppiId, kirjausPageable);

		if (tyyppiId != null) {
			model.addAttribute("valittuTyyppiId", tyyppiId);
		}

		List<AsiakasTuote> myyntirivit = asiakasTuoteRepository.findMyyntiAjanjaksolta(istuntoTunnus, alkuPvm,
				loppuPvm);

		LocalDate ajoAlku = ajoAlkuStr != null && !ajoAlkuStr.isBlank() ? LocalDate.parse(ajoAlkuStr)
				: LocalDate.now().with(TemporalAdjusters.firstDayOfMonth());
		LocalDate ajoLoppu = ajoLoppuStr != null && !ajoLoppuStr.isBlank() ? LocalDate.parse(ajoLoppuStr)
				: LocalDate.now().with(TemporalAdjusters.lastDayOfMonth());
		List<AsiakasAjo> asiakasAjot = ajoAlku.isAfter(ajoLoppu) ? List.of()
				: asiakasAjoRepository.haeAjot(istuntoTunnus, ajoAlku, ajoLoppu, ajoAsiakasId);
		BigDecimal ajojenKilometrit = asiakasAjot.stream().map(AsiakasAjo::getKilometrit)
				.reduce(BigDecimal.ZERO, BigDecimal::add);

		BigDecimal kokonaisVeroton = BigDecimal.ZERO;
		BigDecimal kokonaisAlv = BigDecimal.ZERO;
		BigDecimal kokonaisVerollinen = BigDecimal.ZERO;

		for (AsiakasTuote at : myyntirivit) {
			kokonaisVeroton = kokonaisVeroton.add(at.getKokonaishinta());
			kokonaisAlv = kokonaisAlv.add(at.getAlvOsuus());
			kokonaisVerollinen = kokonaisVerollinen.add(at.getVerollinenKokonaishinta());
		}

		List<Kirjaus> tarkeatKirjaukset = kirjausRepository.findTarkeatKirjauksetAjanjaksolta(istuntoTunnus, alkuAika,
				loppuAika);

		model.addAttribute("kirjaustyypit", kirjaustyyppiRepository.findAll());
		model.addAttribute("tarkeatKirjaukset", tarkeatKirjaukset);
		model.addAttribute("asiakkaatYhteensa", asiakasRepository.count());
		model.addAttribute("kirjausRivit", haetutKirjauksetSivu.getContent());

		model.addAttribute("myyntirivit", myyntirivit);
		model.addAttribute("asiakasAjot", asiakasAjot);
		model.addAttribute("omatAsiakkaat", asiakasRepository.findAllByKayttajaKayttajatunnusOrderByNimiAsc(istuntoTunnus));
		model.addAttribute("ajojenKilometrit", ajojenKilometrit);
		model.addAttribute("ajoAlku", ajoAlku);
		model.addAttribute("ajoLoppu", ajoLoppu);
		model.addAttribute("valittuAjoAsiakas", ajoAsiakasId);
		model.addAttribute("tanaan", LocalDate.now());
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
