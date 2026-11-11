package fi.sotemindit.astori.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.io.IOException;
import java.time.LocalDate;

import org.junit.jupiter.api.Test;

import com.lowagie.text.DocumentException;
import com.lowagie.text.pdf.PdfReader;
import com.lowagie.text.pdf.AcroFields;
import com.lowagie.text.pdf.parser.PdfTextExtractor;

class SopimusPdfPalveluTest {

	private final SopimusPdfPalvelu palvelu = new SopimusPdfPalvelu();

	@Test
	void tayttaaPohjanTiedotJaSailyttaaPohjanKiinteatEhdot() throws IOException, DocumentException {
		String pdfTeksti = puraTeksti(palvelu.luoSopimusPdf(tiedot(false,
				"Kirjanpidon kuukausittainen tarkistus.\nAsiakirjojen käsittely etäyhteydellä.",
				"Kuukausihinta 150 euroa.\nMaksuehto 14 päivää netto.")));

		assertTrue(pdfTeksti.contains("Palveluntarjoaja Oy"));
		assertTrue(pdfTeksti.contains("Testiasiakas Oy"));
		assertTrue(pdfTeksti.contains("Testiedustaja"));
		assertTrue(pdfTeksti.contains("Kirjanpidon kuukausittainen tarkistus."));
		assertTrue(pdfTeksti.contains("Asiakirjojen käsittely etäyhteydellä."));
		assertTrue(pdfTeksti.contains("Kuukausihinta 150 euroa."));
		assertTrue(pdfTeksti.contains("Maksuehto 14 päivää netto."));
		assertTrue(pdfTeksti.contains("4. Sopimuksen voimassaolo ja irtisanominen"));
		assertFalse(pdfTeksti.contains("5. Sopimuksen voimassaolo ja irtisanominen"));
		assertFalse(pdfTeksti.contains("Lisätyöt"));
		assertFalse(pdfTeksti.contains("Enintään kolme"));
		assertTrue(pdfTeksti.contains("yksi kummallekin osapuolelle."));
		assertTrue(pdfTeksti.contains("Palveluntarjoajan edustaja"));
		assertTrue(pdfTeksti.contains("Oma Nimi, Palveluntarjoaja Oy"));
		assertTrue(pdfTeksti.contains("Asiakkaan edustaja"));
		assertTrue(pdfTeksti.contains("Testiedustaja, Testiasiakas Oy"));
		assertTrue(pdfTeksti.contains("Paikka"));
		assertTrue(pdfTeksti.contains("Päivämäärä"));
		assertTrue(pdfTeksti.contains("Kellonaika"));
		assertFalse(pdfTeksti.contains("["));
		assertEquals(8, lomakekenttienLukumaara(
				palvelu.luoSopimusPdf(tiedot(false, "Palvelu.", "Hinta."))));
	}

	@Test
	void kayttaaValitutEnnakkomaksuJaSahkoisenAllekirjoituksenVaihtoehdot()
			throws IOException, DocumentException {
		String pdfTeksti = puraTeksti(palvelu.luoSopimusPdf(tiedot(true,
				"IT-tuki asiakkaan tarpeiden mukaan.", "Laskutus kuukausittain etukäteen.")));

		assertTrue(pdfTeksti.contains("IT-tuki asiakkaan tarpeiden mukaan."));
		assertTrue(pdfTeksti.contains("Laskutus kuukausittain etukäteen."));
		assertTrue(pdfTeksti.contains("Sopimus allekirjoitetaan sähköisesti."));
		assertFalse(pdfTeksti.contains("["));
		assertEquals(8, lomakekenttienLukumaara(
				palvelu.luoSopimusPdf(tiedot(true, "Palvelu.", "Hinta."))));
	}

	private SopimusPdfPalvelu.SopimusTiedot tiedot(boolean sahkoinen, String kohdeJaSisalto, String hintaJaMaksuehdot) {
		return new SopimusPdfPalvelu.SopimusTiedot("Palveluntarjoaja Oy", "1234567-8", "Testikatu 1, Helsinki",
				"Testiasiakas Oy", "8765432-1", "Asiakaskatu 2, Turku", kohdeJaSisalto, hintaJaMaksuehdot,
				LocalDate.of(2026, 11, 11), "Oma Nimi", "Testiedustaja", sahkoinen);
	}

	private int lomakekenttienLukumaara(byte[] pdf) throws IOException {
		PdfReader reader = new PdfReader(pdf);
		try {
			AcroFields kentat = reader.getAcroFields();
			assertEquals(AcroFields.FIELD_TYPE_SIGNATURE, kentat.getFieldType("palveluntarjoajaAllekirjoitus"));
			assertEquals(AcroFields.FIELD_TYPE_SIGNATURE, kentat.getFieldType("asiakasAllekirjoitus"));
			assertEquals(AcroFields.FIELD_TYPE_TEXT, kentat.getFieldType("palveluntarjoajaPaikka"));
			assertEquals(AcroFields.FIELD_TYPE_TEXT, kentat.getFieldType("palveluntarjoajaPaivamaara"));
			assertEquals(AcroFields.FIELD_TYPE_TEXT, kentat.getFieldType("palveluntarjoajaKellonaika"));
			assertEquals(AcroFields.FIELD_TYPE_TEXT, kentat.getFieldType("asiakasPaikka"));
			assertEquals(AcroFields.FIELD_TYPE_TEXT, kentat.getFieldType("asiakasPaivamaara"));
			assertEquals(AcroFields.FIELD_TYPE_TEXT, kentat.getFieldType("asiakasKellonaika"));
			return kentat.getFields().size();
		} finally {
			reader.close();
		}
	}

	private String puraTeksti(byte[] pdf) throws IOException {
		PdfReader reader = new PdfReader(pdf);
		try {
			assertEquals(3, reader.getNumberOfPages());
			PdfTextExtractor extractor = new PdfTextExtractor(reader);
			StringBuilder teksti = new StringBuilder();
			for (int sivu = 1; sivu <= reader.getNumberOfPages(); sivu++) {
				teksti.append(extractor.getTextFromPage(sivu)).append('\n');
			}
			return teksti.toString().replaceAll("\\s+", " ");
		} finally {
			reader.close();
		}
	}
}
