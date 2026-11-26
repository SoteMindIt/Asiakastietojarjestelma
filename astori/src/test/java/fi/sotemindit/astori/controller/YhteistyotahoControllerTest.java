package fi.sotemindit.astori.controller;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import fi.sotemindit.astori.model.Loki;
import fi.sotemindit.astori.model.Yhteistyotaho;
import fi.sotemindit.astori.repository.LokiRepository;
import fi.sotemindit.astori.repository.YhteistyotahoRepository;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

@ExtendWith(MockitoExtension.class)
class YhteistyotahoControllerTest {

	@Mock
	private YhteistyotahoRepository yhteistyotahoRepository;

	@Mock
	private LokiRepository lokiRepository;

	@Mock
	private HttpSession session;

	private YhteistyotahoController controller;

	@BeforeEach
	void setUp() {
		controller = new YhteistyotahoController();
		ReflectionTestUtils.setField(controller, "yhteistyotahoRepository", yhteistyotahoRepository);
		ReflectionTestUtils.setField(controller, "lokiRepository", lokiRepository);
		when(session.getAttribute("kirjautunutKayttaja")).thenReturn("kayttaja");
	}

	@Test
	void savesSharedPartnerAndItsContactDetails() {
		String result = controller.lisaaYhteistyotaho(" Sote Oy ", " 040 123 4567 ",
				" info@sote.fi ", " Palveluntuottaja ", " Alueellinen kumppani ", session);

		assertEquals("redirect:/yhteistyotahot?success=created", result);
		ArgumentCaptor<Yhteistyotaho> yhteistyotahoCaptor = ArgumentCaptor.forClass(Yhteistyotaho.class);
		verify(yhteistyotahoRepository).save(yhteistyotahoCaptor.capture());
		Yhteistyotaho tallennettu = yhteistyotahoCaptor.getValue();
		assertEquals("Sote Oy", tallennettu.getNimi());
		assertEquals("040 123 4567", tallennettu.getPuhelin());
		assertEquals("info@sote.fi", tallennettu.getSahkoposti());
		assertEquals("Palveluntuottaja", tallennettu.getRooli());
		assertEquals("Alueellinen kumppani", tallennettu.getSelite());
		verify(lokiRepository).save(any(Loki.class));
	}

	@Test
	void allowsOptionalFieldsToBeEmpty() {
		String result = controller.lisaaYhteistyotaho("Kumppani", "", "", "", "", session);

		assertEquals("redirect:/yhteistyotahot?success=created", result);
		ArgumentCaptor<Yhteistyotaho> yhteistyotahoCaptor = ArgumentCaptor.forClass(Yhteistyotaho.class);
		verify(yhteistyotahoRepository).save(yhteistyotahoCaptor.capture());
		Yhteistyotaho tallennettu = yhteistyotahoCaptor.getValue();
		assertNull(tallennettu.getPuhelin());
		assertNull(tallennettu.getSahkoposti());
		assertNull(tallennettu.getRooli());
		assertNull(tallennettu.getSelite());
	}
}
