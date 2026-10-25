package fi.sotemindit.astori.model;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

import java.math.BigDecimal;
import java.util.List;
import org.junit.jupiter.api.Test;

class AsiakasAjoTest {

	@Test
	void kilometritLasketaanMatkamittarinLukemienErotuksena() {
		AsiakasAjo ajo = new AsiakasAjo();
		ajo.setAlkumatkamittari(new BigDecimal("12540.5"));
		ajo.setLoppumatkamittari(new BigDecimal("12568.0"));

		assertEquals(new BigDecimal("27.5"), ajo.getKilometrit());
	}

	@Test
	void ajolleVoiAsettaaUseitaAsiakkaitaTaiEiYhtaanAsiakasta() {
		Asiakas firstCustomer = asiakas(1L);
		Asiakas secondCustomer = asiakas(2L);
		AsiakasAjo ajo = new AsiakasAjo();

		ajo.setAsiakkaat(List.of(firstCustomer, secondCustomer));

		assertEquals(List.of(firstCustomer, secondCustomer), ajo.getAsiakkaat());
		assertEquals(firstCustomer, ajo.getAsiakas());

		ajo.setAsiakkaat(List.of());

		assertEquals(List.of(), ajo.getAsiakkaat());
		assertNull(ajo.getAsiakas());
	}

	@Test
	void vanhanAsiakaskiinnityksenAsiakasNakyYhaAsiakkaissa() {
		Asiakas customer = asiakas(1L);
		AsiakasAjo ajo = new AsiakasAjo();
		ajo.setAsiakas(customer);

		assertEquals(List.of(customer), ajo.getAsiakkaat());
	}

	private Asiakas asiakas(Long id) {
		Asiakas asiakas = new Asiakas();
		asiakas.setId(id);
		return asiakas;
	}
}