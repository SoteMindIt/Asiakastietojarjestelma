package fi.sotemindit.astori.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import fi.sotemindit.astori.model.Asiakas;
import fi.sotemindit.astori.model.AsiakkaanTila;
import fi.sotemindit.astori.model.Hyvinvointialue;
import fi.sotemindit.astori.model.Kayttaja;
import java.util.List;

public interface AsiakasRepository extends JpaRepository<Asiakas, Long> {

	List<Asiakas> findAllByKayttajaKayttajatunnusOrderByNimiAsc(String kayttajatunnus);
	List<Asiakas> findAllByKayttaja(Kayttaja kayttaja);

	// 1. Haetaan käyttäjän asiakkaat sivutettuna ilman rajauksia
	Page<Asiakas> findByKayttajaKayttajatunnus(String kayttajatunnus, Pageable pageable);

	// 📈 LASKURI: Käyttää Javan luokkarakennetta, toimii satavarmasti
	@Query("SELECT COUNT(a) FROM Asiakas a WHERE a.kayttaja.kayttajatunnus = :tunnus")
	long countByKayttajaKayttajatunnus(@Param("tunnus") String tunnus);

	@Query("SELECT DISTINCT a FROM Asiakas a LEFT JOIN a.hyvinvointialueet ha WHERE a.kayttaja.kayttajatunnus = :tunnus " +
			"AND (:tila IS NULL OR a.tila = :tila) " +
			"AND (:hyvinvointialue IS NULL OR ha = :hyvinvointialue OR a.vanhaHyvinvointialue = :hyvinvointialue) " +
			"AND ((:kotihoito = false AND :asumispalvelu = false) " +
			"OR (:kotihoito = true AND a.kotihoitoyritys = true) " +
			"OR (:asumispalvelu = true AND a.asumispalveluyritys = true)) " +
			"AND (:haku = '' OR " +
			"LOWER(a.nimi) LIKE LOWER(CONCAT('%', :haku, '%')) OR " +
			"LOWER(a.sahkoposti) LIKE LOWER(CONCAT('%', :haku, '%')) OR " +
			"LOWER(a.puhelin) LIKE LOWER(CONCAT('%', :haku, '%')) OR " +
			"LOWER(a.yTunnus) LIKE LOWER(CONCAT('%', :haku, '%')))")
	Page<Asiakas> haeSuodattimilla(
			@Param("tunnus") String tunnus,
			@Param("tila") AsiakkaanTila tila,
			@Param("hyvinvointialue") Hyvinvointialue hyvinvointialue,
			@Param("kotihoito") boolean kotihoito,
			@Param("asumispalvelu") boolean asumispalvelu,
			@Param("haku") String haku,
			Pageable pageable);
}
