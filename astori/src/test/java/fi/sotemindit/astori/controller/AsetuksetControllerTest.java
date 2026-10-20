package fi.sotemindit.astori.controller;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import fi.sotemindit.astori.model.Kayttaja;
import fi.sotemindit.astori.repository.KayttajaRepository;
import jakarta.servlet.http.HttpSession;

@ExtendWith(MockitoExtension.class)
class AsetuksetControllerTest {

	@Mock
	private KayttajaRepository kayttajaRepository;

	@Mock
	private BCryptPasswordEncoder passwordEncoder;

	@Mock
	private HttpSession session;

	private AsetuksetController controller;

	@BeforeEach
	void setUp() {
		controller = new AsetuksetController();
		ReflectionTestUtils.setField(controller, "kayttajaRepository", kayttajaRepository);
		ReflectionTestUtils.setField(controller, "passwordEncoder", passwordEncoder);
		when(session.getAttribute("kirjautunutKayttaja")).thenReturn("admin");
	}

	@Test
	void rejectsUsernameAlreadyOwnedByAnotherUser() {
		Kayttaja admin = kayttaja(1L, "admin", "ADMIN");
		Kayttaja otherUser = kayttaja(2L, "existing", "USER");
		Kayttaja userToEdit = kayttaja(3L, "old-name", "USER");
		when(kayttajaRepository.findByKayttajatunnus("admin")).thenReturn(Optional.of(admin));
		when(kayttajaRepository.findById(3L)).thenReturn(Optional.of(userToEdit));
		when(kayttajaRepository.findByKayttajatunnus("existing")).thenReturn(Optional.of(otherUser));

		String result = controller.muokkaaKayttajaa(session, 3L, "existing", "", "Etunimi", "Sukunimi",
				"user@example.com", "0401234567", "USER");

		assertEquals("redirect:/asetukset?virhe=tunnus_varattu", result);
		verify(kayttajaRepository, never()).save(userToEdit);
	}

	@Test
	void changesUsernameAndEncodesPasswordAndKeepsOwnSessionInSync() {
		Kayttaja admin = kayttaja(1L, "admin", "ADMIN");
		when(kayttajaRepository.findByKayttajatunnus("admin")).thenReturn(Optional.of(admin));
		when(kayttajaRepository.findById(1L)).thenReturn(Optional.of(admin));
		when(passwordEncoder.encode("new-password")).thenReturn("encoded-password");

		String result = controller.muokkaaKayttajaa(session, 1L, "new-admin", "new-password", "Admin", "User",
				"admin@example.com", "0401234567", "ADMIN");

		assertEquals("redirect:/asetukset?success=user_updated", result);
		assertEquals("new-admin", admin.getKayttajatunnus());
		assertEquals("encoded-password", admin.getSalasana());
		verify(kayttajaRepository).save(admin);
		verify(session).setAttribute("kirjautunutKayttaja", "new-admin");
	}

	@Test
	void keepsExistingPasswordWhenPasswordFieldIsEmpty() {
		Kayttaja admin = kayttaja(1L, "admin", "ADMIN");
		when(kayttajaRepository.findByKayttajatunnus("admin")).thenReturn(Optional.of(admin));
		when(kayttajaRepository.findById(1L)).thenReturn(Optional.of(admin));

		controller.muokkaaKayttajaa(session, 1L, "admin", "", "Admin", "User", "admin@example.com",
				"0401234567", "ADMIN");

		assertEquals("old-password-hash", admin.getSalasana());
		verify(passwordEncoder, never()).encode("");
	}

	private Kayttaja kayttaja(Long id, String tunnus, String rooli) {
		Kayttaja kayttaja = new Kayttaja();
		kayttaja.setId(id);
		kayttaja.setKayttajatunnus(tunnus);
		kayttaja.setSalasana("old-password-hash");
		kayttaja.setRooli(rooli);
		return kayttaja;
	}
}
