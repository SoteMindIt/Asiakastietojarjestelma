package fi.sotemindit.astori.controller;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.when;

import fi.sotemindit.astori.model.AsiakasTuote;
import fi.sotemindit.astori.model.AlvKanta;
import fi.sotemindit.astori.model.Tuote;
import fi.sotemindit.astori.model.TuoteYksikko;
import fi.sotemindit.astori.repository.AsiakasAjoRepository;
import fi.sotemindit.astori.repository.AsiakasRepository;
import fi.sotemindit.astori.repository.AsiakasTuoteRepository;
import fi.sotemindit.astori.repository.KirjausRepository;
import fi.sotemindit.astori.repository.KirjaustyyppiRepository;
import fi.sotemindit.astori.repository.LokiRepository;
import jakarta.servlet.http.HttpSession;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.ui.ExtendedModelMap;

@ExtendWith(MockitoExtension.class)
class RaportitControllerTest {

	@Mock
	private KirjaustyyppiRepository kirjaustyyppiRepository;

	@Mock
	private LokiRepository lokiRepository;

	@Mock
	private AsiakasRepository asiakasRepository;

	@Mock
	private KirjausRepository kirjausRepository;

	@Mock
	private AsiakasTuoteRepository asiakasTuoteRepository;

	@Mock
	private AsiakasAjoRepository asiakasAjoRepository;

	@Mock
	private HttpSession session;

	private RaportitController controller;

	@BeforeEach
	void setUp() {
		controller = new RaportitController();
		ReflectionTestUtils.setField(controller, "kirjaustyyppiRepository", kirjaustyyppiRepository);
		ReflectionTestUtils.setField(controller, "lokiRepository", lokiRepository);
		ReflectionTestUtils.setField(controller, "asiakasRepository", asiakasRepository);
		ReflectionTestUtils.setField(controller, "kirjausRepository", kirjausRepository);
		ReflectionTestUtils.setField(controller, "asiakasTuoteRepository", asiakasTuoteRepository);
		ReflectionTestUtils.setField(controller, "asiakasAjoRepository", asiakasAjoRepository);
		when(session.getAttribute("kirjautunutKayttaja")).thenReturn("admin");
	}

	@Test
	void verollinenYhteissummaSisaltaaMyosNollaverokannanMyynnit() {
		LocalDate alku = LocalDate.of(2026, 9, 1);
		LocalDate loppu = LocalDate.of(2026, 10, 31);
		Tuote verotonTuote = new Tuote("Kilometrikorvaus", null, new BigDecimal("86.07"), TuoteYksikko.KM,
				AlvKanta.ALV_0);
		AsiakasTuote verotonMyynti = new AsiakasTuote(null, verotonTuote, new BigDecimal("86.07"), BigDecimal.ONE);
		when(lokiRepository.findByAikaleimaBetweenOrderByAikaleimaDesc(
				eq(alku.atStartOfDay()), eq(loppu.atTime(23, 59, 59, 999999999)), any()))
				.thenReturn(Page.empty());
		when(kirjausRepository.findAsiakasKirjauksetAjanjaksolta(
				eq("admin"),
				eq(alku.atStartOfDay()),
				eq(loppu.atTime(23, 59, 59, 999999999)),
				isNull(),
				any())).thenReturn(Page.empty());
		when(asiakasTuoteRepository.findMyyntiAjanjaksolta("admin", alku, loppu))
				.thenReturn(List.of(verotonMyynti));

		ExtendedModelMap model = new ExtendedModelMap();
		String view = controller.naytaRaportit(session, 0, 0, alku.toString(), loppu.toString(),
				null, null, null, null, model);

		assertEquals("raportit", view);
		assertEquals(new BigDecimal("86.07"), model.get("kokonaisVeroton"));
		assertEquals(new BigDecimal("0.00"), model.get("kokonaisAlv"));
		assertEquals(new BigDecimal("86.07"), model.get("kokonaisVerollinen"));
	}
}
