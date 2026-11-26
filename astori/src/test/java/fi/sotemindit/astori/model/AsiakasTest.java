package fi.sotemindit.astori.model;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.util.List;
import org.junit.jupiter.api.Test;

class AsiakasTest {

	@Test
	void potilastietojarjestelmaOnOletuksenaEiTiedossa() {
		Asiakas asiakas = new Asiakas();

		assertEquals(List.of(Potilastietojarjestelma.EI_TIEDOSSA),
				asiakas.getPotilastietojarjestelmat());
	}

	@Test
	void potilastietojarjestelmaanVoiValitaUseitaVaihtoehtoja() {
		Asiakas asiakas = new Asiakas();
		asiakas.setPotilastietojarjestelmat(List.of(
				Potilastietojarjestelma.HILKKA,
				Potilastietojarjestelma.APOTTI));

		assertEquals(List.of(Potilastietojarjestelma.HILKKA, Potilastietojarjestelma.APOTTI),
				asiakas.getPotilastietojarjestelmat());
	}

	@Test
	void tyhjaValintaPalautuuEiTiedossaVaihtoehdoksi() {
		Asiakas asiakas = new Asiakas();
		asiakas.setPotilastietojarjestelmat(List.of());

		assertEquals(List.of(Potilastietojarjestelma.EI_TIEDOSSA),
				asiakas.getPotilastietojarjestelmat());
	}

	@Test
	void eiTiedossaPoistuuKunTodellinenJarjestelmaValitaan() {
		Asiakas asiakas = new Asiakas();
		asiakas.setPotilastietojarjestelmat(List.of(
				Potilastietojarjestelma.EI_TIEDOSSA,
				Potilastietojarjestelma.NURSEBUDDY));

		assertEquals(List.of(Potilastietojarjestelma.NURSEBUDDY),
				asiakas.getPotilastietojarjestelmat());
	}
}
