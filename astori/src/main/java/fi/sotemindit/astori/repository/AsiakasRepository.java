package fi.sotemindit.astori.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import fi.sotemindit.astori.model.Asiakas;

public interface AsiakasRepository extends JpaRepository<Asiakas, Long> {

	// Haetaan käyttäjän asiakkaat sivutettuna
	Page<Asiakas> findByKayttajaKayttajatunnus(String kayttajatunnus, Pageable pageable);

	
	
	// Hakutoiminto neljälle kentälle
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

	// 📈 KORJATTU LASKURI: Käyttää Javan luokkarakennetta (Asiakas isolla), toimii satavarmasti ilman SQL-ongelmia
	@Query("SELECT COUNT(a) FROM Asiakas a WHERE a.kayttaja.kayttajatunnus = :tunnus")
	long countByKayttajaKayttajatunnus(@Param("tunnus") String tunnus);
}
