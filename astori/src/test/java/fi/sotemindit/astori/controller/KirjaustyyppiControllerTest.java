package fi.sotemindit.astori.controller;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.mockito.Mockito.inOrder;
import static org.mockito.Mockito.when;

import fi.sotemindit.astori.model.Kirjaus;
import fi.sotemindit.astori.model.Kirjaustyyppi;
import fi.sotemindit.astori.repository.KirjausRepository;
import fi.sotemindit.astori.repository.KirjaustyyppiRepository;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InOrder;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

@ExtendWith(MockitoExtension.class)
class KirjaustyyppiControllerTest {

	@Mock
	private KirjaustyyppiRepository kirjaustyyppiRepository;

	@Mock
	private KirjausRepository kirjausRepository;

	@Mock
	private HttpSession session;

	private KirjaustyyppiController controller;

	@BeforeEach
	void setUp() {
		controller = new KirjaustyyppiController();
		ReflectionTestUtils.setField(controller, "kirjaustyyppiRepository", kirjaustyyppiRepository);
		ReflectionTestUtils.setField(controller, "kirjausRepository", kirjausRepository);
		when(session.getAttribute("kirjautunutKayttaja")).thenReturn("kayttaja");
	}

	@Test
	void deletingUsedTypeKeepsEntriesAndClearsTheirTypeBeforeDeleting() {
		Kirjaustyyppi tyyppi = new Kirjaustyyppi("Vanha tyyppi", "#123456");
		tyyppi.setId(5L);
		Kirjaus kirjaus = new Kirjaus();
		kirjaus.setKirjaustyyppi(tyyppi);
		when(kirjaustyyppiRepository.findById(5L)).thenReturn(Optional.of(tyyppi));
		when(kirjausRepository.findByKirjaustyyppi_Id(5L)).thenReturn(List.of(kirjaus));

		String result = controller.poistaKirjaustyyppi(5L, session);

		assertEquals("redirect:/asetukset?success=kirjaustyyppi_deleted", result);
		assertNull(kirjaus.getKirjaustyyppi());
		InOrder inOrder = inOrder(kirjausRepository, kirjaustyyppiRepository);
		inOrder.verify(kirjausRepository).saveAll(List.of(kirjaus));
		inOrder.verify(kirjausRepository).flush();
		inOrder.verify(kirjaustyyppiRepository).delete(tyyppi);
	}
}
