package fi.sotemindit.astori.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import fi.sotemindit.astori.model.Asiakas;
import fi.sotemindit.astori.model.AsiakkaanTila;
import fi.sotemindit.astori.model.Hyvinvointialue;
import java.util.List;

public interface AsiakasRepository extends JpaRepository<Asiakas, Long> {

	List<Asiakas> findAllByKayttajaKayttajatunnusOrderByNimiAsc(String kayttajatunnus);

	// 1. Haetaan käyttäjän asiakkaat sivutettuna ilman rajauksia
	Page<Asiakas> findByKayttajaKayttajatunnus(String kayttajatunnus, Pageable pageable);

	// 2. Hakee tietyn käyttäjän asiakkaat pelkän hyvinvointialueen perusteella sivutettuna
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

	// 4. YHDISTELMÄHAKU: Hakee vapaalla hakusanalla JA rajatulla hyvinvointialueella sivutettuna
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

	// 📈 LASKURI: Käyttää Javan luokkarakennetta, toimii satavarmasti
	@Query("SELECT COUNT(a) FROM Asiakas a WHERE a.kayttaja.kayttajatunnus = :tunnus")
	long countByKayttajaKayttajatunnus(@Param("tunnus") String tunnus);

	@Query("SELECT DISTINCT a FROM Asiakas a WHERE a.kayttaja.kayttajatunnus = :tunnus " +
			"AND (:tila IS NULL OR a.tila = :tila) " +
			"AND (:hyvinvointialue IS NULL OR a.hyvinvointialue = :hyvinvointialue) " +
			"AND (:haku = '' OR " +
			"LOWER(a.nimi) LIKE LOWER(CONCAT('%', :haku, '%')) OR " +
			"LOWER(a.sahkoposti) LIKE LOWER(CONCAT('%', :haku, '%')) OR " +
			"LOWER(a.puhelin) LIKE LOWER(CONCAT('%', :haku, '%')) OR " +
			"LOWER(a.yTunnus) LIKE LOWER(CONCAT('%', :haku, '%')))")
	Page<Asiakas> haeSuodattimilla(
			@Param("tunnus") String tunnus,
			@Param("tila") AsiakkaanTila tila,
			@Param("hyvinvointialue") Hyvinvointialue hyvinvointialue,
			@Param("haku") String haku,
			Pageable pageable);
}
