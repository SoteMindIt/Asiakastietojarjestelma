package fi.sotemindit.astori.controller;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import fi.sotemindit.astori.model.Asiakas;
import fi.sotemindit.astori.model.Kirjaus;
import fi.sotemindit.astori.model.Kirjaustyyppi;
import fi.sotemindit.astori.repository.AsiakasRepository;
import fi.sotemindit.astori.repository.KirjausRepository;
import fi.sotemindit.astori.repository.KirjaustyyppiRepository;
import fi.sotemindit.astori.repository.LokiRepository;
import jakarta.servlet.http.HttpSession;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@ExtendWith(MockitoExtension.class)
class KirjausControllerTest {

	@Mock
	private KirjausRepository kirjausRepository;

	@Mock
	private AsiakasRepository asiakasRepository;

	@Mock
	private LokiRepository lokiRepository;

	@Mock
	private KirjaustyyppiRepository kirjaustyyppiRepository;

	@Mock
	private HttpSession session;

	@Mock
	private RedirectAttributes redirectAttributes;

	private KirjausController controller;
	private Asiakas asiakas;
	private Kirjaustyyppi kirjaustyyppi;

	@BeforeEach
	void setUp() {
		controller = new KirjausController();
		ReflectionTestUtils.setField(controller, "kirjausRepository", kirjausRepository);
		ReflectionTestUtils.setField(controller, "asiakasRepository", asiakasRepository);
		ReflectionTestUtils.setField(controller, "lokiRepository", lokiRepository);
		ReflectionTestUtils.setField(controller, "kirjaustyyppiRepository", kirjaustyyppiRepository);
		when(session.getAttribute("kirjautunutKayttaja")).thenReturn("kayttaja");

		asiakas = new Asiakas();
		asiakas.setId(7L);
		asiakas.setNimi("Asiakas Oy");
		kirjaustyyppi = new Kirjaustyyppi("Sovittu asia", "#123456");
		kirjaustyyppi.setId(3L);
		when(asiakasRepository.findById(7L)).thenReturn(Optional.of(asiakas));
		when(kirjaustyyppiRepository.findById(3L)).thenReturn(Optional.of(kirjaustyyppi));
		when(kirjausRepository.save(any(Kirjaus.class)))
				.thenAnswer(invocation -> invocation.getArgument(0));
	}

	@Test
	void savesHistoricalEventDateWithoutTime() {
		LocalDate tapahtumaPaivamaara = LocalDate.of(2026, 11, 20);

		String result = controller.lisaaKirjaus(7L, "Takautuva merkintä", tapahtumaPaivamaara,
				false, null, 3L, session, redirectAttributes);

		assertEquals("redirect:/asiakas/7", result);
		ArgumentCaptor<Kirjaus> kirjausCaptor = ArgumentCaptor.forClass(Kirjaus.class);
		verify(kirjausRepository).save(kirjausCaptor.capture());
		assertEquals(LocalDateTime.of(2026, 11, 20, 0, 0), kirjausCaptor.getValue().getLuontiaika());
	}
}
