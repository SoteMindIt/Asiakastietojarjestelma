package fi.sotemindit.astori.model;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.math.BigDecimal;
import org.junit.jupiter.api.Test;

class AsiakasTuoteTest {

	@Test
	void verotonKilometrikuluSailyyVerottomanaKunSeLisataanAsiakkaalle() {
		Tuote kilometrikulu = new Tuote(
				"Kilometrikorvaus",
				null,
				new BigDecimal("0.57"),
				TuoteYksikko.KM,
				AlvKanta.ALV_0);

		AsiakasTuote myynti = new AsiakasTuote(
				null,
				kilometrikulu,
				new BigDecimal("0.57"),
				new BigDecimal("10"));

		assertEquals(AlvKanta.ALV_0, myynti.getAlvKanta());
		assertEquals(new BigDecimal("0.00"), myynti.getAlvOsuus());
		assertEquals(new BigDecimal("5.70"), myynti.getVerollinenKokonaishinta());
	}

	@Test
	void asiakaskohtainenHintaEiMuutaTuotteenAlkuperaisHintaa() {
		Tuote tuote = new Tuote(
				"Palvelu",
				null,
				new BigDecimal("100.00"),
				TuoteYksikko.TUNTI,
				AlvKanta.ALV_25_5);

		AsiakasTuote myynti = new AsiakasTuote(
				null,
				tuote,
				new BigDecimal("85.00"),
				BigDecimal.ONE);

		assertEquals(new BigDecimal("85.00"), myynti.getMyyntihinta());
		assertEquals(new BigDecimal("100.00"), tuote.getHinta());
		assertEquals(new BigDecimal("21.68"), myynti.getAlvOsuus());
		assertEquals(new BigDecimal("106.68"), myynti.getVerollinenKokonaishinta());
	}
}
