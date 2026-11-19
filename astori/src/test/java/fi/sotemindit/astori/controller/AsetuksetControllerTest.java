package fi.sotemindit.astori.controller;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertSame;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import fi.sotemindit.astori.model.Kayttaja;
import fi.sotemindit.astori.model.Asiakas;
import fi.sotemindit.astori.model.AsiakasAjo;
import fi.sotemindit.astori.model.Tapahtuma;
import fi.sotemindit.astori.repository.AsiakasRepository;
import fi.sotemindit.astori.repository.AsiakasAjoRepository;
import fi.sotemindit.astori.repository.KayttajaRepository;
import fi.sotemindit.astori.repository.TapahtumaRepository;
import jakarta.servlet.http.HttpSession;

@ExtendWith(MockitoExtension.class)
class AsetuksetControllerTest {

	@Mock
	private KayttajaRepository kayttajaRepository;

	@Mock
	private AsiakasRepository asiakasRepository;

	@Mock
	private AsiakasAjoRepository asiakasAjoRepository;

	@Mock
	private TapahtumaRepository tapahtumaRepository;

	@Mock
	private BCryptPasswordEncoder passwordEncoder;

	@Mock
	private HttpSession session;

	private AsetuksetController controller;

	@BeforeEach
	void setUp() {
		controller = new AsetuksetController();
		ReflectionTestUtils.setField(controller, "kayttajaRepository", kayttajaRepository);
		ReflectionTestUtils.setField(controller, "asiakasRepository", asiakasRepository);
		ReflectionTestUtils.setField(controller, "asiakasAjoRepository", asiakasAjoRepository);
		ReflectionTestUtils.setField(controller, "tapahtumaRepository", tapahtumaRepository);
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

	@Test
	void savesAllowedTimeoutForCurrentUserAndAppliesItToCurrentSession() {
		Kayttaja admin = kayttaja(1L, "admin", "ADMIN");
		when(kayttajaRepository.findByKayttajatunnus("admin")).thenReturn(Optional.of(admin));

		String result = controller.tallennaIstunnonAikakatkaisu(session, 60);

		assertEquals("redirect:/asetukset?success=session_timeout_updated", result);
		assertEquals(60, admin.getIstunnonAikakatkaisuMinuutteina());
		verify(kayttajaRepository).save(admin);
		verify(session).setMaxInactiveInterval(3600);
	}

	@Test
	void rejectsTimeoutOutsideAllowedOptions() {
		String result = controller.tallennaIstunnonAikakatkaisu(session, 120);

		assertEquals("redirect:/asetukset?virhe=istunnon_aikakatkaisu", result);
		verify(kayttajaRepository, never()).save(org.mockito.ArgumentMatchers.any());
		verify(session, never()).setMaxInactiveInterval(org.mockito.ArgumentMatchers.anyInt());
	}

	@Test
	void deletesUserAndTransfersRelatedRecordsToCurrentAdmin() {
		Kayttaja admin = kayttaja(1L, "admin", "ADMIN");
		Kayttaja userToDelete = kayttaja(2L, "employee", "USER");
		Asiakas asiakas = new Asiakas();
		Tapahtuma tapahtuma = new Tapahtuma();
		AsiakasAjo ajo = new AsiakasAjo();

		when(kayttajaRepository.findByKayttajatunnus("admin")).thenReturn(Optional.of(admin));
		when(kayttajaRepository.findById(2L)).thenReturn(Optional.of(userToDelete));
		when(asiakasRepository.findAllByKayttaja(userToDelete)).thenReturn(List.of(asiakas));
		when(tapahtumaRepository.findAllByKayttaja(userToDelete)).thenReturn(List.of(tapahtuma));
		when(asiakasAjoRepository.findAllByLuoja(userToDelete)).thenReturn(List.of(ajo));

		String result = controller.poistaKayttaja(session, 2L);

		assertEquals("redirect:/asetukset?success=user_deleted", result);
		assertSame(admin, asiakas.getKayttaja());
		assertSame(admin, tapahtuma.getKayttaja());
		assertSame(admin, ajo.getLuoja());
		verify(asiakasRepository).saveAll(List.of(asiakas));
		verify(tapahtumaRepository).saveAll(List.of(tapahtuma));
		verify(asiakasAjoRepository).saveAll(List.of(ajo));
		verify(kayttajaRepository).delete(userToDelete);
	}

	@Test
	void preventsDeletingCurrentUser() {
		Kayttaja admin = kayttaja(1L, "admin", "ADMIN");
		when(kayttajaRepository.findByKayttajatunnus("admin")).thenReturn(Optional.of(admin));
		when(kayttajaRepository.findById(1L)).thenReturn(Optional.of(admin));

		String result = controller.poistaKayttaja(session, 1L);

		assertEquals("redirect:/asetukset?virhe=oma_kayttaja", result);
		verify(kayttajaRepository, never()).delete(admin);
	}

	@Test
	void preventsDeletingLastAdmin() {
		Kayttaja admin = kayttaja(1L, "admin", "ADMIN");
		Kayttaja otherAdmin = kayttaja(2L, "other-admin", "ADMIN");
		when(kayttajaRepository.findByKayttajatunnus("admin")).thenReturn(Optional.of(admin));
		when(kayttajaRepository.findById(2L)).thenReturn(Optional.of(otherAdmin));
		when(kayttajaRepository.countByRooli("ADMIN")).thenReturn(1L);

		String result = controller.poistaKayttaja(session, 2L);

		assertEquals("redirect:/asetukset?virhe=viimeinen_paakayttaja", result);
		verify(kayttajaRepository, never()).delete(otherAdmin);
	}

	@Test
	void rejectsUserDeletionByNonAdmin() {
		Kayttaja user = kayttaja(1L, "admin", "USER");
		when(kayttajaRepository.findByKayttajatunnus("admin")).thenReturn(Optional.of(user));

		String result = controller.poistaKayttaja(session, 2L);

		assertEquals("redirect:/?error=access_denied", result);
		verify(kayttajaRepository, never()).findById(2L);
		verify(kayttajaRepository, never()).delete(org.mockito.ArgumentMatchers.any());
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
