package fi.sotemindit.astori.controller;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import fi.sotemindit.astori.model.Asiakas;
import fi.sotemindit.astori.model.Kayttaja;
import fi.sotemindit.astori.model.Liitetiedosto;
import fi.sotemindit.astori.repository.AsiakasRepository;
import fi.sotemindit.astori.repository.LiitetiedostoRepository;
import fi.sotemindit.astori.repository.LokiRepository;
import jakarta.servlet.http.HttpSession;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.web.multipart.MultipartFile;

@ExtendWith(MockitoExtension.class)
class AsiakasLiitetiedostoControllerTest {

	private static final long ENIMMAISKOKO = 50L * 1024 * 1024;

	@Mock
	private AsiakasRepository asiakasRepository;

	@Mock
	private LiitetiedostoRepository liitetiedostoRepository;

	@Mock
	private LokiRepository lokiRepository;

	@Mock
	private HttpSession session;

	@Mock
	private RedirectAttributes redirectAttributes;

	private AsiakasController controller;
	private Asiakas asiakas;

	@BeforeEach
	void setUp() {
		controller = new AsiakasController();
		ReflectionTestUtils.setField(controller, "asiakasRepository", asiakasRepository);
		ReflectionTestUtils.setField(controller, "liitetiedostoRepository", liitetiedostoRepository);
		ReflectionTestUtils.setField(controller, "lokiRepository", lokiRepository);
		when(session.getAttribute("kirjautunutKayttaja")).thenReturn("kayttaja");

		Kayttaja kayttaja = new Kayttaja();
		kayttaja.setKayttajatunnus("kayttaja");
		asiakas = new Asiakas();
		asiakas.setId(7L);
		asiakas.setNimi("Asiakas Oy");
		asiakas.setKayttaja(kayttaja);
		when(asiakasRepository.findById(7L)).thenReturn(Optional.of(asiakas));
	}

	@Test
	void savesUploadWithSafeFilenameAndCustomerAssociation() throws Exception {
		MockMultipartFile file = new MockMultipartFile("tiedosto", "C:\\upload\\raportti.pdf",
				"application/pdf", new byte[] { 1, 2, 3 });

		String result = controller.lisaaAsiakasliite(7L, file, session, redirectAttributes);

		assertEquals("redirect:/asiakas/7", result);
		ArgumentCaptor<Liitetiedosto> liiteCaptor = ArgumentCaptor.forClass(Liitetiedosto.class);
		verify(liitetiedostoRepository).save(liiteCaptor.capture());
		assertEquals("raportti.pdf", liiteCaptor.getValue().getTiedostonNimi());
		assertEquals("ASIAKASLIITE", liiteCaptor.getValue().getKuvaus());
		assertEquals(asiakas, liiteCaptor.getValue().getAsiakas());
		assertEquals(3, liiteCaptor.getValue().getData().length);
	}

	@Test
	void acceptsFileAt50MbLimit() throws Exception {
		MultipartFile file = mock(MultipartFile.class);
		when(file.isEmpty()).thenReturn(false);
		when(file.getSize()).thenReturn(ENIMMAISKOKO);
		when(file.getOriginalFilename()).thenReturn("raportti.pdf");
		when(file.getBytes()).thenReturn(new byte[] { 1 });

		controller.lisaaAsiakasliite(7L, file, session, redirectAttributes);

		verify(liitetiedostoRepository).save(any(Liitetiedosto.class));
	}

	@Test
	void rejectsFileLargerThan50Mb() throws Exception {
		MultipartFile file = mock(MultipartFile.class);
		when(file.isEmpty()).thenReturn(false);
		when(file.getSize()).thenReturn(ENIMMAISKOKO + 1);

		String result = controller.lisaaAsiakasliite(7L, file, session, redirectAttributes);

		assertEquals("redirect:/asiakas/7", result);
		verify(redirectAttributes).addFlashAttribute("virhe", "Liitetiedoston enimmäiskoko on 50 Mt.");
		verify(liitetiedostoRepository, never()).save(any(Liitetiedosto.class));
	}
}
