package fi.sotemindit.astori.model;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.math.BigDecimal;
import org.junit.jupiter.api.Test;

class AsiakasAjoTest {

	@Test
	void kilometritLasketaanMatkamittarinLukemienErotuksena() {
		AsiakasAjo ajo = new AsiakasAjo();
		ajo.setAlkumatkamittari(new BigDecimal("12540.5"));
		ajo.setLoppumatkamittari(new BigDecimal("12568.0"));

		assertEquals(new BigDecimal("27.5"), ajo.getKilometrit());
	}
}