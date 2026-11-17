package fi.sotemindit.astori.repository;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.transaction.annotation.Transactional;

import fi.sotemindit.astori.model.Asiakas;
import fi.sotemindit.astori.model.Kayttaja;

@SpringBootTest
class AsiakasRepositoryTest {

	@Autowired
	private AsiakasRepository asiakasRepository;

	@Autowired
	private KayttajaRepository kayttajaRepository;

	@Test
	@Transactional
	void filtersByEitherOrBothCompanyTypes() {
		String tunnus = "company-type-test-" + UUID.randomUUID();
		Kayttaja kayttaja = kayttajaRepository.save(new Kayttaja(tunnus, "password-hash",
				"Testi", "Käyttäjä", "test@example.com", "0401234567"));

		tallennaAsiakas(kayttaja, "Ei tyyppiä", false, false);
		tallennaAsiakas(kayttaja, "Kotihoito", true, false);
		tallennaAsiakas(kayttaja, "Asumispalvelut", false, true);
		tallennaAsiakas(kayttaja, "Molemmat", true, true);

		assertEquals(Set.of("Ei tyyppiä", "Kotihoito", "Asumispalvelut", "Molemmat"),
				haeNimet(tunnus, false, false));
		assertEquals(Set.of("Kotihoito", "Molemmat"), haeNimet(tunnus, true, false));
		assertEquals(Set.of("Asumispalvelut", "Molemmat"), haeNimet(tunnus, false, true));
		assertEquals(Set.of("Kotihoito", "Asumispalvelut", "Molemmat"), haeNimet(tunnus, true, true));
	}

	private void tallennaAsiakas(Kayttaja kayttaja, String nimi, boolean kotihoito, boolean asumispalvelut) {
		Asiakas asiakas = new Asiakas();
		asiakas.setNimi(nimi);
		asiakas.setKayttaja(kayttaja);
		asiakas.setKotihoitoyritys(kotihoito);
		asiakas.setAsumispalveluyritys(asumispalvelut);
		asiakasRepository.save(asiakas);
	}

	private Set<String> haeNimet(String tunnus, boolean kotihoito, boolean asumispalvelut) {
		Page<Asiakas> asiakkaat = asiakasRepository.haeSuodattimilla(
				tunnus, null, null, kotihoito, asumispalvelut, "", PageRequest.of(0, 20));
		return asiakkaat.getContent().stream().map(Asiakas::getNimi).collect(Collectors.toSet());
	}
}
