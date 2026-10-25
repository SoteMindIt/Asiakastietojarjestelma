package fi.sotemindit.astori.controller;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import fi.sotemindit.astori.model.Asiakas;
import fi.sotemindit.astori.model.AsiakasAjo;
import fi.sotemindit.astori.model.Kayttaja;
import fi.sotemindit.astori.repository.AsiakasAjoRepository;
import fi.sotemindit.astori.repository.AsiakasRepository;
import fi.sotemindit.astori.repository.KayttajaRepository;
import fi.sotemindit.astori.repository.LokiRepository;
import jakarta.servlet.http.HttpSession;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

@ExtendWith(MockitoExtension.class)
class AsiakasAjoControllerTest {

	@Mock
	private AsiakasAjoRepository asiakasAjoRepository;

	@Mock
	private AsiakasRepository asiakasRepository;

	@Mock
	private KayttajaRepository kayttajaRepository;

	@Mock
	private LokiRepository lokiRepository;

	@Mock
	private HttpSession session;

	private AsiakasAjoController controller;

	@BeforeEach
	void setUp() {
		controller = new AsiakasAjoController();
		ReflectionTestUtils.setField(controller, "asiakasAjoRepository", asiakasAjoRepository);
		ReflectionTestUtils.setField(controller, "asiakasRepository", asiakasRepository);
		ReflectionTestUtils.setField(controller, "kayttajaRepository", kayttajaRepository);
		ReflectionTestUtils.setField(controller, "lokiRepository", lokiRepository);
		when(session.getAttribute("kirjautunutKayttaja")).thenReturn("admin");
		Kayttaja kayttaja = new Kayttaja();
		kayttaja.setKayttajatunnus("admin");
		when(kayttajaRepository.findByKayttajatunnus("admin")).thenReturn(Optional.of(kayttaja));
	}

	@Test
	void allowsSavingTripWithoutCustomer() {
		String result = controller.lisaaAjo(null, LocalDate.of(2026, 10, 25), "Helsinki", "Espoo",
				"Asiakaskäynnit", new BigDecimal("12000"), new BigDecimal("12025"), false, session);

		assertEquals("redirect:/raportit?tab=ajotSisalto&ajoAlku=2026-10-25&ajoLoppu=2026-10-25", result);
		ArgumentCaptor<AsiakasAjo> ajoCaptor = ArgumentCaptor.forClass(AsiakasAjo.class);
		verify(asiakasAjoRepository).save(ajoCaptor.capture());
		assertNull(ajoCaptor.getValue().getAsiakas());
		assertEquals("admin", ajoCaptor.getValue().getLuoja().getKayttajatunnus());
		assertEquals(List.of(), ajoCaptor.getValue().getAsiakkaat());
	}

	@Test
	void storesSeveralSelectedCustomersOnOneTrip() {
		Asiakas firstCustomer = asiakas(1L, "Ensimmäinen");
		Asiakas secondCustomer = asiakas(2L, "Toinen");
		when(asiakasRepository.findAllById(List.of(1L, 2L))).thenReturn(List.of(firstCustomer, secondCustomer));

		controller.lisaaAjo(List.of(1L, 2L), LocalDate.of(2026, 10, 25), "Helsinki", "Espoo",
				"Asiakaskäynnit", new BigDecimal("12000"), new BigDecimal("12025"), false, session);

		ArgumentCaptor<AsiakasAjo> ajoCaptor = ArgumentCaptor.forClass(AsiakasAjo.class);
		verify(asiakasAjoRepository).save(ajoCaptor.capture());
		assertEquals(List.of(firstCustomer, secondCustomer), ajoCaptor.getValue().getAsiakkaat());
		assertEquals(new BigDecimal("25"), ajoCaptor.getValue().getKilometrit());
	}

	private Asiakas asiakas(Long id, String nimi) {
		Kayttaja kayttaja = new Kayttaja();
		kayttaja.setKayttajatunnus("admin");
		Asiakas asiakas = new Asiakas();
		asiakas.setId(id);
		asiakas.setNimi(nimi);
		asiakas.setKayttaja(kayttaja);
		return asiakas;
	}
}
