package fi.sotemindit.astori.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import fi.sotemindit.astori.model.Asiakas;
import fi.sotemindit.astori.model.Hyvinvointialue;

public interface AsiakasRepository extends JpaRepository<Asiakas, Long> {

	// 1. Haetaan käyttäjän asiakkaat sivutettuna ilman rajauksia
	Page<Asiakas> findByKayttajaKayttajatunnus(String kayttajatunnus, Pageable pageable);

	// 2. 🔗 UUSI: Hakee tietyn käyttäjän asiakkaat pelkän hyvinvointialueen perusteella sivutettuna
	Page<Asiakas> findByKayttajaKayttajatunnusAndHyvinvointialue(String kayttajatunnus, Hyvinvointialue hyvinvointialue, Pageable pageable);

	// 3. Hakutoiminto viidelle kentälle (Vapaa tekstihaku ilman aluerajausta)
	@Query("SELECT a FROM Asiakas a WHERE a.kayttaja.kayttajatunnus = :tunnus AND " +
		       "(LOWER(a.nimi) LIKE LOWER(CONCAT('%', :haku, '%')) OR " +
		       "LOWER(a.sahkoposti) LIKE LOWER(CONCAT('%', :haku, '%')) OR " +
		       "LOWER(a.puhelin) LIKE LOWER(CONCAT('%', :haku, '%')) OR " +
		       "LOWER(a.yTunnus) LIKE LOWER(CONCAT('%', :haku, '%')) OR " +
		       "LOWER(a.hyvinvointialue) LIKE LOWER(CONCAT('%', :haku, '%')))")
	Page<Asiakas> findByKayttajaKayttajatunnusAndHaku(
			@Param("tunnus") String tunnus, 
			@Param("haku") String haku, 
			Pageable pageable);

	// 4. 🔗 UUSI YHDISTELMÄHAKU: Hakee vapaalla hakusanalla JA rajatulla hyvinvointialueella sivutettuna
	@Query("SELECT a FROM Asiakas a WHERE a.kayttaja.kayttajatunnus = :tunnus AND a.hyvinvointialue = :hyvinvointialue AND " +
		       "(LOWER(a.nimi) LIKE LOWER(CONCAT('%', :haku, '%')) OR " +
		       "LOWER(a.sahkoposti) LIKE LOWER(CONCAT('%', :haku, '%')) OR " +
		       "LOWER(a.puhelin) LIKE LOWER(CONCAT('%', :haku, '%')) OR " +
		       "LOWER(a.yTunnus) LIKE LOWER(CONCAT('%', :haku, '%')))")
	Page<Asiakas> findByKayttajaKayttajatunnusAndHyvinvointialueAndHaku(
			@Param("tunnus") String tunnus, 
			@Param("hyvinvointialue") Hyvinvointialue hyvinvointialue,
			@Param("haku") String haku, 
			Pageable pageable);

	// 5. 📈 KORJATTU LASKURI: Käyttää Javan luokkarakennetta, toimii satavarmasti ilman SQL-ongelmia
	@Query("SELECT COUNT(a) FROM Asiakas a WHERE a.kayttaja.kayttajatunnus = :tunnus")
	long countByKayttajaKayttajatunnus(@Param("tunnus") String tunnus);
}
