package fi.sotemindit.astori.controller;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import fi.sotemindit.astori.model.Tapahtuma;
import fi.sotemindit.astori.model.Tarjous;
import fi.sotemindit.astori.repository.AsiakasRepository;
import fi.sotemindit.astori.repository.MuistiinpanoRepository;
import fi.sotemindit.astori.repository.TapahtumaRepository;
import fi.sotemindit.astori.repository.TapahtumaTyyppiRepository;
import fi.sotemindit.astori.repository.TarjousRepository;
import jakarta.servlet.http.HttpSession;
import java.time.LocalDateTime;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.ui.ExtendedModelMap;

@ExtendWith(MockitoExtension.class)
class DashboardControllerTest {

	@Mock
	private AsiakasRepository asiakasRepository;

	@Mock
	private TapahtumaRepository tapahtumaRepository;

	@Mock
	private TarjousRepository tarjousRepository;

	@Mock
	private TapahtumaTyyppiRepository tapahtumaTyyppiRepository;

	@Mock
	private MuistiinpanoRepository muistiinpanoRepository;

	@Mock
	private HttpSession session;

	private DashboardController controller;

	@BeforeEach
	void setUp() {
		controller = new DashboardController();
		ReflectionTestUtils.setField(controller, "asiakasRepository", asiakasRepository);
		ReflectionTestUtils.setField(controller, "tapahtumaRepository", tapahtumaRepository);
		ReflectionTestUtils.setField(controller, "tarjousRepository", tarjousRepository);
		ReflectionTestUtils.setField(controller, "tapahtumaTyyppiRepository", tapahtumaTyyppiRepository);
		ReflectionTestUtils.setField(controller, "muistiinpanoRepository", muistiinpanoRepository);
		when(session.getAttribute("kirjautunutKayttaja")).thenReturn("admin");
	}

	@Test
	void requestsFiveUpcomingEventsForRequestedPage() {
		List<Tapahtuma> tapahtumat = List.of(new Tapahtuma());
		List<Tarjous> tarjoukset = List.of(new Tarjous(), new Tarjous());
		when(tarjousRepository.findAvoimetKayttajalle(eq("admin"), any()))
				.thenReturn(tarjoukset);
		when(tarjousRepository.countAvoimetKayttajalle(eq("admin"), any()))
				.thenReturn((long) tarjoukset.size());
		when(tapahtumaRepository.findByKayttajaKayttajatunnusAndAjankohtaBetweenOrderByAjankohtaAsc(
				eq("admin"), any(LocalDateTime.class), any(LocalDateTime.class), eq(PageRequest.of(1, 5))))
				.thenReturn(new PageImpl<>(tapahtumat, PageRequest.of(1, 5), 11));

		ExtendedModelMap model = new ExtendedModelMap();
		String view = controller.naytaEtusivu(session, model, 1);

		assertEquals("dashboard", view);
		assertEquals(tapahtumat, model.get("tulevatTapahtumat"));
		assertEquals(tarjoukset, model.get("avoimetTarjoukset"));
		assertEquals(2L, model.get("tarjouksetLaskuri"));
		assertEquals(1, model.get("tapahtumaSivu"));
		assertEquals(3, model.get("tapahtumaSivuja"));

		ArgumentCaptor<LocalDateTime> alku = ArgumentCaptor.forClass(LocalDateTime.class);
		ArgumentCaptor<LocalDateTime> loppu = ArgumentCaptor.forClass(LocalDateTime.class);
		ArgumentCaptor<PageRequest> pageable = ArgumentCaptor.forClass(PageRequest.class);
		verify(tapahtumaRepository).findByKayttajaKayttajatunnusAndAjankohtaBetweenOrderByAjankohtaAsc(
				eq("admin"), alku.capture(), loppu.capture(), pageable.capture());
		assertEquals(30, java.time.Duration.between(alku.getValue(), loppu.getValue()).toDays());
		assertEquals(5, pageable.getValue().getPageSize());
		assertEquals(1, pageable.getValue().getPageNumber());
	}
}
