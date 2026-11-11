package fi.sotemindit.astori.controller;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.test.util.ReflectionTestUtils;

import fi.sotemindit.astori.model.Kayttaja;
import fi.sotemindit.astori.repository.KayttajaRepository;
import jakarta.servlet.http.HttpSession;

@ExtendWith(MockitoExtension.class)
class LoginControllerTest {

	@Mock
	private KayttajaRepository kayttajaRepository;

	@Mock
	private BCryptPasswordEncoder passwordEncoder;

	@Mock
	private HttpSession session;

	private LoginController controller;

	@BeforeEach
	void setUp() {
		controller = new LoginController();
		ReflectionTestUtils.setField(controller, "kayttajaRepository", kayttajaRepository);
		ReflectionTestUtils.setField(controller, "passwordEncoder", passwordEncoder);
	}

	@Test
	void appliesSavedTimeoutWhenUserLogsIn() {
		Kayttaja kayttaja = new Kayttaja();
		kayttaja.setKayttajatunnus("user");
		kayttaja.setSalasana("password-hash");
		kayttaja.setIstunnonAikakatkaisuMinuutteina(60);
		when(kayttajaRepository.findByKayttajatunnus("user")).thenReturn(Optional.of(kayttaja));
		when(passwordEncoder.matches("password", "password-hash")).thenReturn(true);

		String result = controller.kirjauduSissaan("user", "password", session);

		assertEquals("redirect:/", result);
		verify(session).setMaxInactiveInterval(3600);
		verify(session).setAttribute("kirjautunutKayttaja", "user");
	}

	@Test
	void defaultsExistingUsersToThirtyMinutes() {
		Kayttaja kayttaja = new Kayttaja();
		kayttaja.setSalasana("password-hash");
		when(kayttajaRepository.findByKayttajatunnus("user")).thenReturn(Optional.of(kayttaja));
		when(passwordEncoder.matches("password", "password-hash")).thenReturn(true);

		controller.kirjauduSissaan("user", "password", session);

		verify(session).setMaxInactiveInterval(1800);
	}
}
