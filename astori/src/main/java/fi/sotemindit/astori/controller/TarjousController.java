package fi.sotemindit.astori.controller;

import java.util.List;
import java.time.LocalDate;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.transaction.annotation.Transactional;

import fi.sotemindit.astori.model.Asiakas;
import fi.sotemindit.astori.model.Tarjous;
import fi.sotemindit.astori.model.TarjousRivi;
import fi.sotemindit.astori.model.Tuote;
import fi.sotemindit.astori.repository.AsiakasRepository;
import fi.sotemindit.astori.repository.TarjousRepository;
import fi.sotemindit.astori.repository.TuoteRepository;

@Controller
public class TarjousController {

	@Autowired
	private AsiakasRepository asiakasRepository;

	@Autowired
	private TarjousRepository tarjousRepository;

	@Autowired
	private TuoteRepository tuoteRepository;

	// 1. Avaa tarjoushallinnan ja -laskennan sivun (tarjoukset.jsp)
	@Transactional
	@GetMapping("/asiakas/{asiakasId}/tarjoukset")
	public String naytaTarjouslaskenta(@PathVariable Long asiakasId, Model model,
			jakarta.servlet.http.HttpSession session) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		Asiakas asiakas = asiakasRepository.findById(asiakasId)
				.orElseThrow(() -> new IllegalArgumentException("Asiakasta ei löytynyt ID-numerolla: " + asiakasId));

		List<Tarjous> tarjoukset = tarjousRepository.findByAsiakasId(asiakasId);
		List<Tuote> tuoteLista = tuoteRepository.findAll();

		model.addAttribute("asiakas", asiakas);
		model.addAttribute("tarjoukset", tarjoukset);
		
		// 💡 KORJAUS: Muutettu kaikkiTuotteet -> tuoteLista, jotta se täsmää dynaamisen tarjoukset.jsp -pudotusvalikon kanssa
		model.addAttribute("tuoteLista", tuoteLista);

		return "tarjoukset";
	}
	// 2. Vastaanottaa dynaamiset tarjousrivit ja laskee summat tietokantaan
	@Transactional
	@PostMapping("/asiakkaat/{asiakasId}/tarjoukset/tallenna")
	public String tallennaTarjous(@PathVariable("asiakasId") Long asiakasId, @RequestParam String tarjousNumero,
			@RequestParam String voimassaoloPvm, @RequestParam(required = false) String lisatiedot,
			@RequestParam("tuote[]") List<String> tuotteet, 
			@RequestParam("maara[]") List<java.math.BigDecimal> maarat, 
			@RequestParam("hinta[]") List<java.math.BigDecimal> hinnat, 
			@RequestParam("alv[]") List<java.math.BigDecimal> alvProsentit, 
			jakarta.servlet.http.HttpSession session,
			org.springframework.web.servlet.mvc.support.RedirectAttributes redirectAttributes) {

		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		if (tarjousRepository.existsByTarjousNumero(tarjousNumero)) {
			redirectAttributes.addFlashAttribute("virheViesti",
					"Tarjousnumero '" + tarjousNumero + "' on jo käytössä! Valitse toinen numero.");
			return "redirect:/asiakas/" + asiakasId + "/tarjoukset";
		}

		Asiakas asiakas = asiakasRepository.findById(asiakasId)
				.orElseThrow(() -> new IllegalArgumentException("Asiakasta ei löytynyt ID-numerolla: " + asiakasId));

		Tarjous tarjous = new Tarjous();
		tarjous.setAsiakas(asiakas);
		tarjous.setTarjousNumero(tarjousNumero);
		tarjous.setPvm(LocalDate.now());
		tarjous.setVoimassaoloPvm(LocalDate.parse(voimassaoloPvm));
		tarjous.setLisatiedot(lisatiedot);

		java.math.BigDecimal kokonaisVeroton = java.math.BigDecimal.ZERO;
		java.math.BigDecimal kokonaisAlv = java.math.BigDecimal.ZERO;

		for (int i = 0; i < tuotteet.size(); i++) {
			String tuoteNimi = tuotteet.get(i);
			
			java.math.BigDecimal bdMaara = maarat.get(i) != null ? maarat.get(i) : java.math.BigDecimal.ZERO;
			java.math.BigDecimal bdHinta = hinnat.get(i) != null ? hinnat.get(i) : java.math.BigDecimal.ZERO;
			java.math.BigDecimal bdAlvProsentti = alvProsentit.get(i) != null ? alvProsentit.get(i) : java.math.BigDecimal.ZERO;

			// Rivin veroton hinta = määrä * hinta
			java.math.BigDecimal riviVeroton = bdMaara.multiply(bdHinta);
			
			// Rivin ALV = riviVeroton * (alvProsentti / 100)
			java.math.BigDecimal riviAlv = riviVeroton.multiply(bdAlvProsentti)
					.divide(java.math.BigDecimal.valueOf(100.0), 2, java.math.RoundingMode.HALF_UP);

			kokonaisVeroton = kokonaisVeroton.add(riviVeroton);
			kokonaisAlv = kokonaisAlv.add(riviAlv);

			TarjousRivi rivi = new TarjousRivi(tuoteNimi, bdMaara, bdHinta, bdAlvProsentti, tarjous);
			tarjous.getRivit().add(rivi);
		}

		tarjous.setVerotonYhteensa(kokonaisVeroton);
		tarjous.setAlvYhteensa(kokonaisAlv);
		tarjous.setVerollinenYhteensa(kokonaisVeroton.add(kokonaisAlv));

		tarjousRepository.save(tarjous);

		return "redirect:/asiakas/" + asiakasId + "/tarjoukset";
	}

	// 3. Generoi ja lataa tarjous PDF-muodossa
	@Transactional
	@GetMapping("/tarjous/{tarjousId}/lataa-pdf")
	public void lataaTarjousPdf(@PathVariable Long tarjousId, jakarta.servlet.http.HttpServletResponse response,
			jakarta.servlet.http.HttpSession session) throws java.io.IOException {

		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			response.sendRedirect("/login");
			return;
		}

		Tarjous tarjous = tarjousRepository.findById(tarjousId)
				.orElseThrow(() -> new IllegalArgumentException("Tarjousta ei löytynyt ID-numerolla: " + tarjousId));
		java.time.format.DateTimeFormatter suomiPvm = java.time.format.DateTimeFormatter.ofPattern("dd.MM.yyyy");
		Asiakas asiakas = tarjous.getAsiakas();

		response.setContentType("application/pdf");
		response.setHeader("Content-Disposition",
				"attachment; filename=\"Tarjous_" + tarjous.getTarjousNumero() + ".pdf\"");

		com.lowagie.text.Document document = new com.lowagie.text.Document(com.lowagie.text.PageSize.A4, 50, 50, 50,
				50);
		com.lowagie.text.pdf.PdfWriter.getInstance(document, response.getOutputStream());

		document.open();

		com.lowagie.text.Font otsikkoFontti = com.lowagie.text.FontFactory
				.getFont(com.lowagie.text.FontFactory.HELVETICA_BOLD, 22);
		com.lowagie.text.Font alaOtsikkoFontti = com.lowagie.text.FontFactory
				.getFont(com.lowagie.text.FontFactory.HELVETICA_BOLD, 12);
		com.lowagie.text.Font tekstiFontti = com.lowagie.text.FontFactory
				.getFont(com.lowagie.text.FontFactory.HELVETICA, 10);
		com.lowagie.text.Font lihavoituTeksti = com.lowagie.text.FontFactory
				.getFont(com.lowagie.text.FontFactory.HELVETICA_BOLD, 10);

		// A. DOKUMENTIN OTSIKKO
		com.lowagie.text.Paragraph otsikko = new com.lowagie.text.Paragraph("TARJOUS", otsikkoFontti);
		otsikko.setAlignment(com.lowagie.text.Element.ALIGN_LEFT);
		otsikko.setSpacingAfter(20);
		document.add(otsikko);

		// B. METATIEDOT (Päivämäärät ja tarjousnumero)
		com.lowagie.text.pdf.PdfPTable metaTaulu = new com.lowagie.text.pdf.PdfPTable(2);
		metaTaulu.setWidthPercentage(100);
		metaTaulu.setSpacingAfter(20);

		com.lowagie.text.pdf.PdfPCell cell1 = new com.lowagie.text.pdf.PdfPCell(
				new com.lowagie.text.Paragraph("Tarjousnumero: " + tarjous.getTarjousNumero(), tekstiFontti));
		cell1.setBorder(com.lowagie.text.pdf.PdfPCell.NO_BORDER);
		metaTaulu.addCell(cell1);

		com.lowagie.text.pdf.PdfPCell cell2 = new com.lowagie.text.pdf.PdfPCell(
				new com.lowagie.text.Paragraph("Päivämäärä: " + tarjous.getPvm().format(suomiPvm), tekstiFontti));
		cell2.setBorder(com.lowagie.text.pdf.PdfPCell.NO_BORDER);
		metaTaulu.addCell(cell2);

		com.lowagie.text.pdf.PdfPCell cell3 = new com.lowagie.text.pdf.PdfPCell(new com.lowagie.text.Paragraph(
				"Voimassaolo: " + tarjous.getVoimassaoloPvm().format(suomiPvm), tekstiFontti));
		cell3.setBorder(com.lowagie.text.pdf.PdfPCell.NO_BORDER);
		metaTaulu.addCell(cell3);

		com.lowagie.text.pdf.PdfPCell cell4 = new com.lowagie.text.pdf.PdfPCell(
				new com.lowagie.text.Paragraph("", tekstiFontti));
		cell4.setBorder(com.lowagie.text.pdf.PdfPCell.NO_BORDER);
		metaTaulu.addCell(cell4);

		document.add(metaTaulu);

		// C. ASIAKKAAN TIEDOT
		document.add(new com.lowagie.text.Paragraph("Asiakas:", alaOtsikkoFontti));
		com.lowagie.text.Paragraph asiakasTiedot = new com.lowagie.text.Paragraph(
				asiakas.getNimi() + "\n" + (asiakas.getSahkoposti() != null ? asiakas.getSahkoposti() : "") + "\n"
						+ (asiakas.getPuhelin() != null ? asiakas.getPuhelin() : ""),
				tekstiFontti);
		asiakasTiedot.setSpacingAfter(30);
		document.add(asiakasTiedot);

		if (tarjous.getLisatiedot() != null && !tarjous.getLisatiedot().trim().isEmpty()) {
			document.add(new com.lowagie.text.Paragraph("Lisätiedot ja ehdot:", alaOtsikkoFontti));
			com.lowagie.text.Paragraph pLisatiedot = new com.lowagie.text.Paragraph(tarjous.getLisatiedot(),
					tekstiFontti);
			pLisatiedot.setSpacingAfter(20);
			document.add(pLisatiedot);
		}
		// 4. TARJOUSRIVIT TAULUKKONA
		document.add(new com.lowagie.text.Paragraph("Tarjouksen sisältö:", alaOtsikkoFontti));
		com.lowagie.text.Paragraph vali = new com.lowagie.text.Paragraph(" ");
		vali.setSpacingAfter(5);
		document.add(vali);

		com.lowagie.text.pdf.PdfPTable riviTaulu = new com.lowagie.text.pdf.PdfPTable(5);
		riviTaulu.setWidthPercentage(100);
		riviTaulu.setSpacingAfter(20);
		riviTaulu.setWidths(new float[] { 4.0f, 1.2f, 1.6f, 1.2f, 2.0f });

		String[] otsikot = { "Tuote / Kuvaus", "Määrä", "Yksikköhinta", "ALV %", "Yhteensä (alv)" };
		for (String otsikkoTeksti : otsikot) {
			com.lowagie.text.pdf.PdfPCell solu = new com.lowagie.text.pdf.PdfPCell(
					new com.lowagie.text.Paragraph(otsikkoTeksti, lihavoituTeksti));
			solu.setBackgroundColor(java.awt.Color.LIGHT_GRAY);
			solu.setPadding(6);
			solu.setHorizontalAlignment(com.lowagie.text.Element.ALIGN_CENTER);
			riviTaulu.addCell(solu);
		}

		for (fi.sotemindit.astori.model.TarjousRivi r : tarjous.getRivit()) {
			java.math.BigDecimal maara = r.getMaara() != null ? r.getMaara() : java.math.BigDecimal.ZERO;
			java.math.BigDecimal hinta = r.getYksikkohinta() != null ? r.getYksikkohinta() : java.math.BigDecimal.ZERO;
			java.math.BigDecimal alv = r.getAlvProsentti() != null ? r.getAlvProsentti() : java.math.BigDecimal.ZERO;
			
			java.math.BigDecimal riviVeroton = maara.multiply(hinta);
			java.math.BigDecimal alvKerroin = java.math.BigDecimal.ONE.add(
					alv.divide(java.math.BigDecimal.valueOf(100.0), 4, java.math.RoundingMode.HALF_UP)
			);
			java.math.BigDecimal riviVerollinen = riviVeroton.multiply(alvKerroin)
					.setScale(2, java.math.RoundingMode.HALF_UP);

			com.lowagie.text.pdf.PdfPCell solu1 = new com.lowagie.text.pdf.PdfPCell(
					new com.lowagie.text.Paragraph(r.getTuotteenNimi(), tekstiFontti));
			solu1.setPadding(6);
			riviTaulu.addCell(solu1);

			com.lowagie.text.pdf.PdfPCell solu2 = new com.lowagie.text.pdf.PdfPCell(
					new com.lowagie.text.Paragraph(String.format("%.2f", maara), tekstiFontti));
			solu2.setHorizontalAlignment(com.lowagie.text.Element.ALIGN_CENTER);
			solu2.setPadding(6);
			riviTaulu.addCell(solu2);

			com.lowagie.text.pdf.PdfPCell solu3 = new com.lowagie.text.pdf.PdfPCell(
					new com.lowagie.text.Paragraph(String.format("%.2f €", hinta), tekstiFontti));
			solu3.setHorizontalAlignment(com.lowagie.text.Element.ALIGN_RIGHT);
			solu3.setPadding(6);
			riviTaulu.addCell(solu3);

			com.lowagie.text.pdf.PdfPCell solu4 = new com.lowagie.text.pdf.PdfPCell(
					new com.lowagie.text.Paragraph(String.format("%.1f %%", alv), tekstiFontti));
			solu4.setHorizontalAlignment(com.lowagie.text.Element.ALIGN_CENTER);
			solu4.setPadding(6);
			riviTaulu.addCell(solu4);

			com.lowagie.text.pdf.PdfPCell solu5 = new com.lowagie.text.pdf.PdfPCell(
					new com.lowagie.text.Paragraph(String.format("%.2f €", riviVerollinen), tekstiFontti));
			solu5.setHorizontalAlignment(com.lowagie.text.Element.ALIGN_RIGHT);
			solu5.setPadding(6);
			riviTaulu.addCell(solu5);
		}
		document.add(riviTaulu);

		// 5. YHTEENVETOLAATIKKO
		com.lowagie.text.pdf.PdfPTable summaTaulu = new com.lowagie.text.pdf.PdfPTable(2);
		summaTaulu.setWidthPercentage(40);
		summaTaulu.setHorizontalAlignment(com.lowagie.text.Element.ALIGN_RIGHT);
		summaTaulu.setSpacingAfter(30);

		com.lowagie.text.pdf.PdfPCell lblVeroton = new com.lowagie.text.pdf.PdfPCell(
				new com.lowagie.text.Paragraph("Veroton yhteensä:", tekstiFontti));
		lblVeroton.setBorder(com.lowagie.text.pdf.PdfPCell.NO_BORDER);
		summaTaulu.addCell(lblVeroton);

		com.lowagie.text.pdf.PdfPCell sv = new com.lowagie.text.pdf.PdfPCell(new com.lowagie.text.Paragraph(
				String.format("%.2f €", tarjous.getVerotonYhteensa()), tekstiFontti));
		sv.setHorizontalAlignment(com.lowagie.text.Element.ALIGN_RIGHT);
		sv.setBorder(com.lowagie.text.pdf.PdfPCell.NO_BORDER);
		summaTaulu.addCell(sv);

		com.lowagie.text.pdf.PdfPCell lblAlv = new com.lowagie.text.pdf.PdfPCell(
				new com.lowagie.text.Paragraph("ALV yhteensä:", tekstiFontti));
		lblAlv.setBorder(com.lowagie.text.pdf.PdfPCell.NO_BORDER);
		summaTaulu.addCell(lblAlv);

		com.lowagie.text.pdf.PdfPCell sa = new com.lowagie.text.pdf.PdfPCell(
				new com.lowagie.text.Paragraph(String.format("%.2f €", tarjous.getAlvYhteensa()), tekstiFontti));
		sa.setHorizontalAlignment(com.lowagie.text.Element.ALIGN_RIGHT);
		sa.setBorder(com.lowagie.text.pdf.PdfPCell.NO_BORDER);
		summaTaulu.addCell(sa);

		com.lowagie.text.pdf.PdfPCell lblLoppusumma = new com.lowagie.text.pdf.PdfPCell(
				new com.lowagie.text.Paragraph("Loppusumma:", lihavoituTeksti));
		lblLoppusumma.setBorder(com.lowagie.text.pdf.PdfPCell.BOTTOM);
		summaTaulu.addCell(lblLoppusumma);

		com.lowagie.text.pdf.PdfPCell sll = new com.lowagie.text.pdf.PdfPCell(new com.lowagie.text.Paragraph(
				String.format("%.2f €", tarjous.getVerollinenYhteensa()), lihavoituTeksti));
		sll.setHorizontalAlignment(com.lowagie.text.Element.ALIGN_RIGHT);
		sll.setBorder(com.lowagie.text.pdf.PdfPCell.BOTTOM);
		summaTaulu.addCell(sll);

		document.add(summaTaulu);
		
		document.close();
	}

	// 4. Poistaa tarjouksen ID-numeron perusteella ja ohjaa takaisin asiakkaan sivulle
	@Transactional
	@PostMapping("/tarjous/{tarjousId}/poista")
	public String poistaTarjous(@PathVariable Long tarjousId, jakarta.servlet.http.HttpSession session) {
		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		Tarjous tarjous = tarjousRepository.findById(tarjousId)
				.orElseThrow(() -> new IllegalArgumentException("Tarjousta ei löytynyt ID-numerolla: " + tarjousId));

		Long asiakasId = tarjous.getAsiakas().getId();
		tarjousRepository.delete(tarjous);

		return "redirect:/asiakas/" + asiakasId + "/tarjoukset";
	}
}
