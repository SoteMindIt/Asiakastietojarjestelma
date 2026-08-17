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
		model.addAttribute("kaikkiTuotteet", tuoteLista);

		return "tarjoukset";
	}

	// 2. Vastaanottaa dynaamiset tarjousrivit ja laskee summat tietokantaan
	@Transactional
	@PostMapping("/asiakkaat/{asiakasId}/tarjoukset/tallenna")
	public String tallennaTarjous(@PathVariable Long asiakasId, @RequestParam String tarjousNumero,
			@RequestParam String voimassaoloPvm, @RequestParam(required = false) String lisatiedot,
			@RequestParam("tuote[]") List<String> tuotteet, @RequestParam("maara[]") List<Double> maarat,
			@RequestParam("hinta[]") List<Double> hinnat, @RequestParam("alv[]") List<Double> alvProsentit,
			jakarta.servlet.http.HttpSession session) {

		String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
		if (istuntoTunnus == null) {
			return "redirect:/login";
		}

		Asiakas asiakas = asiakasRepository.findById(asiakasId)
				.orElseThrow(() -> new IllegalArgumentException("Asiakasta ei löytynyt ID-numerolla: " + asiakasId));

		Tarjous tarjous = new Tarjous();
		tarjous.setAsiakas(asiakas);
		tarjous.setTarjousNumero(tarjousNumero);
		tarjous.setPvm(LocalDate.now());
		tarjous.setVoimassaoloPvm(LocalDate.parse(voimassaoloPvm));
		tarjous.setLisatiedot(lisatiedot);

		double kokonaisVeroton = 0.0;
		double kokonaisAlv = 0.0;

		for (int i = 0; i < tuotteet.size(); i++) {
			String tuoteNimi = tuotteet.get(i);
			double maara = maarat.get(i) != null ? maarat.get(i) : 0.0;
			double hinta = hinnat.get(i) != null ? hinnat.get(i) : 0.0;
			double alv = alvProsentit.get(i) != null ? alvProsentit.get(i) : 0.0;

			double riviVeroton = maara * hinta;
			double riviAlv = riviVeroton * (alv / 100.0);

			kokonaisVeroton += riviVeroton;
			kokonaisAlv += riviAlv;

			TarjousRivi rivi = new TarjousRivi(tuoteNimi, maara, hinta, alv, tarjous);
			tarjous.getRivit().add(rivi);
		}

		tarjous.setVerotonYhteensa(kokonaisVeroton);
		tarjous.setAlvYhteensa(kokonaisAlv);
		tarjous.setVerollinenYhteensa(kokonaisVeroton + kokonaisAlv);

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

		// 1. DOKUMENTIN OTSIKKO
		com.lowagie.text.Paragraph otsikko = new com.lowagie.text.Paragraph("TARJOUS", otsikkoFontti);
		otsikko.setAlignment(com.lowagie.text.Element.ALIGN_LEFT);
		otsikko.setSpacingAfter(20);
		document.add(otsikko);

		// 2. METATIEDOT (Päivämäärät ja tarjousnumero)
		com.lowagie.text.pdf.PdfPTable metaTaulu = new com.lowagie.text.pdf.PdfPTable(2);
		metaTaulu.setWidthPercentage(100);
		metaTaulu.setSpacingAfter(20);

		com.lowagie.text.pdf.PdfPCell cell1 = new com.lowagie.text.pdf.PdfPCell(
				new com.lowagie.text.Paragraph("Tarjousnumero: " + tarjous.getTarjousNumero(), tekstiFontti));
		cell1.setBorder(com.lowagie.text.pdf.PdfPCell.NO_BORDER);
		metaTaulu.addCell(cell1);

		// Päivitetty suomalaisella muotoilulla:
		com.lowagie.text.pdf.PdfPCell cell2 = new com.lowagie.text.pdf.PdfPCell(
				new com.lowagie.text.Paragraph("Päivämäärä: " + tarjous.getPvm().format(suomiPvm), tekstiFontti));
		cell2.setBorder(com.lowagie.text.pdf.PdfPCell.NO_BORDER);
		metaTaulu.addCell(cell2);

		// Päivitetty suomalaisella muotoilulla:
		com.lowagie.text.pdf.PdfPCell cell3 = new com.lowagie.text.pdf.PdfPCell(new com.lowagie.text.Paragraph(
				"Voimassaolo: " + tarjous.getVoimassaoloPvm().format(suomiPvm), tekstiFontti));
		cell3.setBorder(com.lowagie.text.pdf.PdfPCell.NO_BORDER);
		metaTaulu.addCell(cell3);

		com.lowagie.text.pdf.PdfPCell cell4 = new com.lowagie.text.pdf.PdfPCell(
				new com.lowagie.text.Paragraph("", tekstiFontti));
		cell4.setBorder(com.lowagie.text.pdf.PdfPCell.NO_BORDER);
		metaTaulu.addCell(cell4);

		document.add(metaTaulu);

		// 3. ASIAKKAAN TIEDOT
		document.add(new com.lowagie.text.Paragraph("Asiakas:", alaOtsikkoFontti));
		com.lowagie.text.Paragraph asiakasTiedot = new com.lowagie.text.Paragraph(
				asiakas.getNimi() + "\n" + (asiakas.getSahkoposti() != null ? asiakas.getSahkoposti() : "") + "\n"
						+ (asiakas.getPuhelin() != null ? asiakas.getPuhelin() : ""),
				tekstiFontti);
		asiakasTiedot.setSpacingAfter(30);
		document.add(asiakasTiedot);

		// TULOSTETAAN LISÄTIEDOT JOS NIITÄ ON KIRJOITETTU
		if (tarjous.getLisatiedot() != null && !tarjous.getLisatiedot().trim().isEmpty()) {
			document.add(new com.lowagie.text.Paragraph("Lisätiedot ja ehdot:", alaOtsikkoFontti));
			com.lowagie.text.Paragraph pLisatiedot = new com.lowagie.text.Paragraph(tarjous.getLisatiedot(),
					tekstiFontti);
			pLisatiedot.setSpacingAfter(20);
			document.add(pLisatiedot);

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
				double maara = r.getMaara() != null ? r.getMaara() : 0.0;
				double hinta = r.getYksikkohinta() != null ? r.getYksikkohinta() : 0.0;
				double alv = r.getAlvProsentti() != null ? r.getAlvProsentti() : 0.0;
				double riviVerollinen = (maara * hinta) * (1 + (alv / 100.0));

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
	}
}
