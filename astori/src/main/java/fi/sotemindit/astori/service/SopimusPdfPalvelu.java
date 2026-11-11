package fi.sotemindit.astori.service;

import java.awt.Color;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Service;

import com.lowagie.text.Document;
import com.lowagie.text.DocumentException;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.Chunk;
import com.lowagie.text.Phrase;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Rectangle;
import com.lowagie.text.pdf.ColumnText;
import com.lowagie.text.pdf.PdfAnnotation;
import com.lowagie.text.pdf.BaseFont;
import com.lowagie.text.pdf.PdfBorderDictionary;
import com.lowagie.text.pdf.PdfContentByte;
import com.lowagie.text.pdf.PdfFormField;
import com.lowagie.text.pdf.PdfReader;
import com.lowagie.text.pdf.PdfWriter;
import com.lowagie.text.pdf.TextField;
import com.lowagie.text.pdf.draw.LineSeparator;
import com.lowagie.text.pdf.parser.PdfTextExtractor;

@Service
public class SopimusPdfPalvelu {

	private static final String POHJAN_POLKU = "templates/Palvelusopimus_pohja.pdf";
	private static final DateTimeFormatter SUOMALAINEN_PAIVAMAARA = DateTimeFormatter.ofPattern("dd.MM.yyyy");
	private static final Pattern TAYTTAMATON_KOHTA = Pattern.compile("\\[[^\\]]+\\]");

	private final Resource sopimuspohja;

	public SopimusPdfPalvelu() {
		this(new ClassPathResource(POHJAN_POLKU));
	}

	SopimusPdfPalvelu(Resource sopimuspohja) {
		this.sopimuspohja = sopimuspohja;
	}

	public byte[] luoSopimusPdf(SopimusTiedot tiedot) throws IOException, DocumentException {
		List<String> sivut = new ArrayList<>();
		Rectangle sivunKoko;

		try (InputStream pohja = sopimuspohja.getInputStream()) {
			PdfReader lukija = new PdfReader(pohja);
			try {
				sivunKoko = lukija.getPageSize(1);
				PdfTextExtractor tekstinpoimija = new PdfTextExtractor(lukija);
				for (int sivu = 1; sivu <= lukija.getNumberOfPages(); sivu++) {
					sivut.add(tekstinpoimija.getTextFromPage(sivu));
				}
			} finally {
				lukija.close();
			}
		}

		String[] taydennetytSivut = taydennaPohja(String.join("\f", sivut), tiedot).split("\f", -1);
		try (ByteArrayOutputStream tuloste = new ByteArrayOutputStream()) {
			Document dokumentti = new Document(sivunKoko, 100, 100, 72, 72);
			PdfWriter kirjoittaja = PdfWriter.getInstance(dokumentti, tuloste);
			dokumentti.open();

			BaseFont perusfontti = BaseFont.createFont(BaseFont.HELVETICA, BaseFont.WINANSI,
					BaseFont.NOT_EMBEDDED);
			Font tekstifontti = new Font(perusfontti, 10.5f);
			Font otsikkofontti = new Font(perusfontti, 12, Font.BOLD);
			Font paafontti = new Font(perusfontti, 16, Font.BOLD);

			for (int sivu = 0; sivu < taydennetytSivut.length; sivu++) {
				if (sivu > 0) {
					dokumentti.newPage();
				}
				if (sivu == taydennetytSivut.length - 1) {
					lisaaAllekirjoitussivu(kirjoittaja, sivunKoko, tiedot, perusfontti);
				} else {
					lisaaSivu(dokumentti, taydennetytSivut[sivu], tekstifontti, otsikkofontti, paafontti);
				}
			}

			dokumentti.close();
			return tuloste.toByteArray();
		}
	}

	private String taydennaPohja(String teksti, SopimusTiedot tiedot) {
		String taydennetty = teksti;
		taydennetty = poistaPohjanAllekirjoituskentat(taydennetty);
		taydennetty = poistaOsio(taydennetty, "4. Lisätyöt", "5. Sopimuksen voimassaolo ja irtisanominen");
		for (Map.Entry<String, String> otsikko : Map.of(
				"5. Sopimuksen voimassaolo ja irtisanominen", "4. Sopimuksen voimassaolo ja irtisanominen",
				"6. Salassapito", "5. Salassapito",
				"7. Vastuunrajoitus", "6. Vastuunrajoitus",
				"8. Erimielisyyksien ratkaiseminen", "7. Erimielisyyksien ratkaiseminen",
				"9. Allekirjoitukset", "8. Allekirjoitukset").entrySet()) {
			taydennetty = taydennaOtsikko(taydennetty, otsikko.getKey(), otsikko.getValue());
		}
		taydennetty = korvaaOsionSisalto(taydennetty, "3. Palvelun hinta ja maksuehdot",
				"4. Sopimuksen voimassaolo ja irtisanominen", tiedot.hintaJaMaksuehdot());
		taydennetty = korvaaOsionSisalto(taydennetty, "2. Sopimuksen kohde ja sisältö",
				"3. Palvelun hinta ja maksuehdot", tiedot.sopimuksenKohdeJaSisalto());
		taydennetty = korvaaPakollinen(taydennetty, "[Yrityksesi Nimi / Toiminimi]",
				tiedot.palveluntarjoajanNimi());
		taydennetty = korvaaPakollinen(taydennetty, "[Y-tunnuksesi]", tiedot.palveluntarjoajanYTunnus());
		taydennetty = korvaaPakollinen(taydennetty, "[Osoitteesi]", tiedot.palveluntarjoajanOsoite());
		taydennetty = korvaaPakollinen(taydennetty, "[Asiakasyrityksen Nimi]", tiedot.asiakkaanNimi());
		taydennetty = korvaaPakollinen(taydennetty, "[Asiakkaan Y-tunnus]", tiedot.asiakkaanYTunnus());
		taydennetty = korvaaPakollinen(taydennetty, "[Asiakkaan osoite]", tiedot.asiakkaanOsoite());
		taydennetty = korvaaPakollinen(taydennetty, "[Päivämäärä]",
				tiedot.aloituspaiva().format(SUOMALAINEN_PAIVAMAARA));
		taydennetty = korvaaAllekirjoitustapa(taydennetty, tiedot.sahkoinenAllekirjoitus());

		var tayttamaton = TAYTTAMATON_KOHTA.matcher(taydennetty);
		if (tayttamaton.find()) {
			throw new IllegalStateException("Sopimuspohjaan jäi täyttämätön kohta: " + tayttamaton.group());
		}
		return taydennetty;
	}

	private String poistaPohjanAllekirjoituskentat(String teksti) {
		int allekirjoitustenAlku = teksti.indexOf("Paikka ja aika:");
		if (allekirjoitustenAlku < 0) {
			throw new IllegalStateException("Sopimuspohjasta ei löytynyt allekirjoitussivun paikkamerkintää.");
		}
		return teksti.substring(0, allekirjoitustenAlku);
	}

	private String korvaaOsionSisalto(String teksti, String otsikko, String seuraavaOtsikko, String sisalto) {
		var alku = Pattern.compile(Pattern.quote(otsikko).replace(" ", "\\E\\s+\\Q")).matcher(teksti);
		var loppu = Pattern.compile(Pattern.quote(seuraavaOtsikko).replace(" ", "\\E\\s+\\Q")).matcher(teksti);
		if (!alku.find() || !loppu.find() || alku.end() > loppu.start()) {
			throw new IllegalStateException("Sopimuspohjasta ei löytynyt osiota otsikoiden '" + otsikko
					+ "' ja '" + seuraavaOtsikko + "' välistä.");
		}
		boolean sisaltaaSivunvaihdon = teksti.substring(alku.end(), loppu.start()).contains("\f");
		String sivunvaihto = sisaltaaSivunvaihdon ? "\n\f\n" : "\n";
		return teksti.substring(0, alku.end()) + "\n" + sisalto.trim() + sivunvaihto
				+ teksti.substring(loppu.start());
	}

	private String poistaOsio(String teksti, String otsikko, String seuraavaOtsikko) {
		var alku = Pattern.compile(Pattern.quote(otsikko).replace(" ", "\\E\\s+\\Q")).matcher(teksti);
		var loppu = Pattern.compile(Pattern.quote(seuraavaOtsikko).replace(" ", "\\E\\s+\\Q")).matcher(teksti);
		if (!alku.find() || !loppu.find() || alku.start() > loppu.start()) {
			throw new IllegalStateException("Sopimuspohjasta ei löytynyt poistettavaa osiota: " + otsikko);
		}
		int rivinAlku = Math.max(teksti.lastIndexOf('\n', alku.start()), teksti.lastIndexOf('\f', alku.start())) + 1;
		return teksti.substring(0, rivinAlku) + teksti.substring(loppu.start());
	}

	private String taydennaOtsikko(String teksti, String vanhaOtsikko, String uusiOtsikko) {
		var osuma = Pattern.compile(Pattern.quote(vanhaOtsikko).replace(" ", "\\E\\s+\\Q")).matcher(teksti);
		if (!osuma.find()) {
			throw new IllegalStateException("Sopimuspohjasta ei löytynyt otsikkoa: " + vanhaOtsikko);
		}
		return teksti.substring(0, osuma.start()) + uusiOtsikko + teksti.substring(osuma.end());
	}

	private String korvaaPakollinen(String teksti, String kohta, String arvo) {
		String kuvio = Pattern.quote(kohta).replace(" ", "\\E\\s+\\Q");
		var osuma = Pattern.compile(kuvio).matcher(teksti);
		if (!osuma.find()) {
			throw new IllegalStateException("Sopimuspohjasta ei löytynyt täydennettävää kohtaa: " + kohta);
		}
		return osuma.replaceAll(java.util.regex.Matcher.quoteReplacement(arvo == null ? "" : arvo.trim()));
	}

	private String korvaaAllekirjoitustapa(String teksti, boolean sahkoinenAllekirjoitus) {
		String allekirjoitusvaihtoehto = "\\[tai:\\s*Sopimus allekirjoitetaan sähköisesti\\]";
		var vaihtoehto = Pattern.compile(allekirjoitusvaihtoehto).matcher(teksti);
		if (!vaihtoehto.find()) {
			throw new IllegalStateException("Sopimuspohjasta ei löytynyt allekirjoitustavan valintaa.");
		}
		if (sahkoinenAllekirjoitus) {
			String paperinenLause = "Tätä sopimusta on tehty kaksi samanlaista kappaletta, yksi kummallekin\\s+"
					+ "osapuolelle\\s*" + allekirjoitusvaihtoehto + "\\.";
			return Pattern.compile(paperinenLause).matcher(teksti)
					.replaceAll(java.util.regex.Matcher.quoteReplacement("Sopimus allekirjoitetaan sähköisesti."));
		}
		return Pattern.compile("\\s*" + allekirjoitusvaihtoehto).matcher(teksti).replaceAll("");
	}

	private void lisaaSivu(Document dokumentti, String teksti, Font tekstifontti, Font otsikkofontti,
			Font paafontti) throws DocumentException {
		for (String rivi : teksti.split("\\R")) {
			String siistitty = rivi.trim();
			if (siistitty.isEmpty()) {
				Paragraph tyhjaRivi = new Paragraph(" ", tekstifontti);
				tyhjaRivi.setLeading(6);
				dokumentti.add(tyhjaRivi);
				continue;
			}

			Paragraph kappale;
			if (siistitty.equalsIgnoreCase("PALVELUSOPIMUS")) {
				kappale = new Paragraph(siistitty, paafontti);
				kappale.setAlignment(Paragraph.ALIGN_CENTER);
				kappale.setSpacingAfter(12);
				kappale.setLeading(21);
			} else if (siistitty.matches("^\\d+\\.\\s+.*")) {
				kappale = new Paragraph(siistitty, otsikkofontti);
				kappale.setSpacingBefore(18);
				kappale.setSpacingAfter(0);
				kappale.setLeading(15);
			} else if (siistitty.equals("Palveluntarjoaja:") || siistitty.equals("Asiakas:")) {
				kappale = new Paragraph(siistitty, otsikkofontti);
				kappale.setSpacingBefore(5);
				kappale.setSpacingAfter(3);
				kappale.setLeading(15);
			} else {
				kappale = new Paragraph(siistitty, tekstifontti);
				kappale.setLeading(14);
			}
			dokumentti.add(kappale);
			if (siistitty.matches("^\\d+\\.\\s+.*")) {
				Paragraph alleviivaus = new Paragraph(
						new Chunk(new LineSeparator(0.6f, 100, new Color(205, 210, 216), Element.ALIGN_CENTER, 0)));
				alleviivaus.setSpacingAfter(6);
				dokumentti.add(alleviivaus);
			}
		}
	}

	private void lisaaAllekirjoitussivu(PdfWriter kirjoittaja, Rectangle sivunKoko, SopimusTiedot tiedot,
			BaseFont perusfontti) throws IOException, DocumentException {
		float vasen = 72;
		float oikea = sivunKoko.getWidth() - 72;
		float leveys = oikea - vasen;
		PdfContentByte sisalto = kirjoittaja.getDirectContent();
		Font otsikko = new Font(perusfontti, 16, Font.BOLD);
		Font leipateksti = new Font(perusfontti, 11);
		Font kentanOtsikko = new Font(perusfontti, 9);

		lisaaTeksti(sisalto, "Allekirjoitukset", otsikko, vasen, sivunKoko.getHeight() - 75);
		lisaaAllekirjoittaja(sisalto, kirjoittaja, perusfontti, leipateksti, kentanOtsikko,
				"Palveluntarjoajan edustaja", tiedot.palveluntarjoajanEdustaja(),
				tiedot.palveluntarjoajanNimi(), "palveluntarjoaja", vasen, leveys,
				sivunKoko.getHeight() - 125);
		lisaaAllekirjoittaja(sisalto, kirjoittaja, perusfontti, leipateksti, kentanOtsikko,
				"Asiakkaan edustaja", tiedot.asiakkaanEdustaja(), tiedot.asiakkaanNimi(),
				"asiakas", vasen, leveys, sivunKoko.getHeight() - 410);
	}

	private void lisaaAllekirjoittaja(PdfContentByte sisalto, PdfWriter kirjoittaja, BaseFont perusfontti,
			Font leipateksti, Font kentanOtsikko, String rooli, String nimi, String yritys, String kenttaprefiksi,
			float vasen, float leveys, float yla) throws IOException, DocumentException {
		lisaaTeksti(sisalto, rooli + ":", leipateksti, vasen, yla);
		ColumnText osapuolenTiedot = new ColumnText(sisalto);
		osapuolenTiedot.setSimpleColumn(vasen, yla - 66, vasen + leveys, yla - 18, 11, Element.ALIGN_LEFT);
		osapuolenTiedot.addText(new Phrase(nimi + ", " + yritys, new Font(perusfontti, 9.5f)));
		osapuolenTiedot.go();

		float allekirjoituksenYla = yla - 87;
		float allekirjoituksenAla = allekirjoituksenYla - 38;
		lisaaTeksti(sisalto, "Allekirjoitus", kentanOtsikko, vasen, allekirjoituksenYla + 5);
		PdfFormField allekirjoituskentta = PdfFormField.createSignature(kirjoittaja);
		allekirjoituskentta.setFieldName(kenttaprefiksi + "Allekirjoitus");
		allekirjoituskentta.setWidget(new Rectangle(vasen, allekirjoituksenAla, vasen + leveys,
				allekirjoituksenYla), PdfAnnotation.HIGHLIGHT_OUTLINE);
		allekirjoituskentta.setBorderStyle(new PdfBorderDictionary(1, PdfBorderDictionary.STYLE_SOLID));
		allekirjoituskentta.setMKBorderColor(Color.GRAY);
		kirjoittaja.addAnnotation(allekirjoituskentta);

		float tietoOtsikonY = allekirjoituksenAla - 18;
		float tietokenttienY = tietoOtsikonY - 30;
		float vali = 8;
		float paikkaleveys = leveys * 0.48f;
		float paivaysleveys = leveys * 0.30f;
		float aikaX = vasen + paikkaleveys + vali + paivaysleveys + vali;
		lisaaTeksti(sisalto, "Paikka", kentanOtsikko, vasen, tietoOtsikonY);
		lisaaTeksti(sisalto, "Päivämäärä", kentanOtsikko, vasen + paikkaleveys + vali,
				tietoOtsikonY);
		lisaaTeksti(sisalto, "Kellonaika", kentanOtsikko, aikaX, tietoOtsikonY);
		lisaaTekstikentta(kirjoittaja, perusfontti, kenttaprefiksi + "Paikka",
				new Rectangle(vasen, tietokenttienY, vasen + paikkaleveys, tietokenttienY + 22));
		lisaaTekstikentta(kirjoittaja, perusfontti, kenttaprefiksi + "Paivamaara",
				new Rectangle(vasen + paikkaleveys + vali, tietokenttienY,
						vasen + paikkaleveys + vali + paivaysleveys, tietokenttienY + 22));
		lisaaTekstikentta(kirjoittaja, perusfontti, kenttaprefiksi + "Kellonaika",
				new Rectangle(aikaX, tietokenttienY, vasen + leveys, tietokenttienY + 22));
	}

	private void lisaaTekstikentta(PdfWriter kirjoittaja, BaseFont perusfontti, String nimi, Rectangle rajaus)
			throws IOException, DocumentException {
		TextField tekstikentta = new TextField(kirjoittaja, rajaus, nimi);
		tekstikentta.setFont(perusfontti);
		tekstikentta.setFontSize(10);
		tekstikentta.setBorderColor(Color.GRAY);
		tekstikentta.setBorderWidth(1);
		kirjoittaja.addAnnotation(tekstikentta.getTextField());
	}

	private void lisaaTeksti(PdfContentByte sisalto, String teksti, Font fontti, float x, float y)
			throws DocumentException {
		ColumnText.showTextAligned(sisalto, Element.ALIGN_LEFT, new Phrase(teksti, fontti), x, y, 0);
	}

	public record SopimusTiedot(String palveluntarjoajanNimi, String palveluntarjoajanYTunnus,
			String palveluntarjoajanOsoite, String asiakkaanNimi, String asiakkaanYTunnus, String asiakkaanOsoite,
			String sopimuksenKohdeJaSisalto, String hintaJaMaksuehdot, java.time.LocalDate aloituspaiva,
			String palveluntarjoajanEdustaja, String asiakkaanEdustaja, boolean sahkoinenAllekirjoitus) {
	}
}
