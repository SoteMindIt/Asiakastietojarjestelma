package fi.sotemindit.astori.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import fi.sotemindit.astori.model.Asiakas;

public interface AsiakasRepository extends JpaRepository<Asiakas, Long> {

	// 1. Haetaan tietyn käyttäjän asiakkaat sivutettuna (Ilman hakua)
	Page<Asiakas> findByKayttajaKayttajatunnus(String kayttajatunnus, Pageable pageable);

	// 2. Haetaan tietyn käyttäjän asiakkaat hakuominaisuudella ja sivutuksella
	// Tämä etsii nimen, sähköpostin, puhelimen tai Y-tunnuksen perusteella (case-insensitive)
	@Query("SELECT a FROM Asiakas a WHERE a.kayttaja.kayttajatunnus = :tunnus AND " +
	       "(LOWER(a.nimi) LIKE LOWER(CONCAT('%', :haku, '%')) OR " +
	       " LOWER(a.sahkoposti) LIKE LOWER(CONCAT('%', :haku, '%')) OR " +
	       " LOWER(a.puhelin) LIKE LOWER(CONCAT('%', :haku, '%')) OR " +
	       " LOWER(a.yTunnus) LIKE LOWER(CONCAT('%', :haku, '%')))")
	Page<Asiakas> findByKayttajaKayttajatunnusAndHaku(
			@Param("tunnus") String tunnus, 
			@Param("haku") String haku, 
			Pageable pageable);
}
