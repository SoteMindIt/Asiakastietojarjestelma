package fi.sotemindit.astori.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import java.time.LocalDate;
import java.util.List;
import fi.sotemindit.astori.model.Tapahtuma;
import fi.sotemindit.astori.model.Tarjous;
import fi.sotemindit.astori.model.TapahtumaTyyppi;
import fi.sotemindit.astori.repository.AsiakasRepository;
import fi.sotemindit.astori.repository.TapahtumaRepository;
import fi.sotemindit.astori.repository.TarjousRepository;
import fi.sotemindit.astori.repository.TapahtumaTyyppiRepository;
import jakarta.servlet.http.HttpSession;

@Controller
public class DashboardController {

	@Autowired
	private AsiakasRepository asiakasRepository;

	@Autowired
	private TapahtumaRepository tapahtumaRepository;

	@Autowired
	private TarjousRepository tarjousRepository;

	@Autowired
	private TapahtumaTyyppiRepository tapahtumaTyyppiRepository;

	@Autowired
	private fi.sotemindit.astori.repository.MuistiinpanoRepository muistiinpanoRepository;

	@GetMapping("/")
	public String naytaEtusivu(HttpSession session, Model model,
			@RequestParam(value = "tapahtumaSivu", defaultValue = "0") int tapahtumaSivu) {
		// 1. Istuntotarkistus tietoturvaa varten
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		// 2. Haetaan laskuritietorivit dashboard-kortteja varten
		long asiakkaatLaskuri = asiakasRepository.count();
		LocalDate tanaan = LocalDate.now(java.time.ZoneId.of("Europe/Helsinki"));
		List<Tarjous> avoimetTarjoukset = tarjousRepository.findAvoimetKayttajalle(istuntoTunnus, tanaan);
		long tarjouksetLaskuri = tarjousRepository.countAvoimetKayttajalle(istuntoTunnus, tanaan);
		// long tehtavatLaskuri = tapahtumaRepository.count();

		java.time.ZoneId suomenAika = java.time.ZoneId.of("Europe/Helsinki");
		java.time.LocalDateTime tamanPaivanAlku = java.time.LocalDate.now(suomenAika).atStartOfDay();
		java.time.LocalDateTime tamanPaivanLoppu = java.time.LocalDate.now(suomenAika).atTime(23, 59, 59);

		long tehtavatLaskuri = tapahtumaRepository.countByKayttajaKayttajatunnusAndAjankohtaBetween(istuntoTunnus,
				tamanPaivanAlku, tamanPaivanLoppu);

		// 3. Haetaan tulevat kalenterimerkinnät etusivun koosteeseen
		java.time.LocalDateTime nyt = java.time.LocalDateTime.now();
		java.time.LocalDateTime tapahtumaRajauksenLoppu = nyt.plusDays(30);
		Pageable tapahtumaPageable = PageRequest.of(Math.max(0, tapahtumaSivu), 5);
		Page<Tapahtuma> tulevatTapahtumat = tapahtumaRepository
				.findByKayttajaKayttajatunnusAndAjankohtaBetweenOrderByAjankohtaAsc(istuntoTunnus, nyt,
						tapahtumaRajauksenLoppu, tapahtumaPageable);

		// 4. Viedään laskurit ja tapahtumat näkymälle
		model.addAttribute("asiakkaatLaskuri", asiakkaatLaskuri);
		model.addAttribute("tarjouksetLaskuri", tarjouksetLaskuri);
		model.addAttribute("avoimetTarjoukset", avoimetTarjoukset);
		model.addAttribute("tehtavatLaskuri", tehtavatLaskuri);
		model.addAttribute("tulevatTapahtumat", tulevatTapahtumat.getContent());
		model.addAttribute("tapahtumaSivu", tapahtumaPageable.getPageNumber());
		model.addAttribute("tapahtumaSivuja", tulevatTapahtumat.getTotalPages());

		// 5.Viedään dynaamiset listat täsmälleen samoilla nimillä kuin dashboard.jsp:n
		// modal-ikkuna niitä odottaa
		model.addAttribute("kaikkiAsiakkaat", asiakasRepository.findAll()); // JSP odottaa: kaikkiAsiakkaat
		model.addAttribute("tapahtumaTyypit", tapahtumaTyyppiRepository.findAll()); // JSP odottaa: tapahtumaTyypit

		// 6.Haetaan kirjautuneen työntekijän yleiset muistiinpanot etusivulle
		model.addAttribute("yleisetMuistiinpanot",
				muistiinpanoRepository.findByKayttajatunnusOrderByLuontiaikaDesc(istuntoTunnus));

		return "dashboard"; // Avaa dashboard.jsp
	}
}
