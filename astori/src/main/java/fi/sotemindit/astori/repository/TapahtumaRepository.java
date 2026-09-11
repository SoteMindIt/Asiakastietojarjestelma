package fi.sotemindit.astori.repository;

import java.util.List;
import java.time.LocalDateTime;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import fi.sotemindit.astori.model.Tapahtuma;
import fi.sotemindit.astori.model.TapahtumaTyyppi;

public interface TapahtumaRepository extends JpaRepository<Tapahtuma, Long> {

	// 💡 VIIMEISTELTY DYNAAMINEN HAKUMETOLI KALENTERILLE (Oliotuki korjattu)
	@Query("SELECT t FROM Tapahtuma t WHERE "
			+ "(:kayttajatunnus IS NULL OR t.kayttaja.kayttajatunnus = :kayttajatunnus) AND "
			+ "(:asiakasId IS NULL OR t.asiakas.id = :asiakasId) AND " + "(:tyyppi IS NULL OR t.tyyppi = :tyyppi) AND " // Puhdas
																														// oliotason
																														// NULL-tarkistus
			+ "(CAST(:alkuPvm AS localdatetime) IS NULL OR t.ajankohta >= :alkuPvm) AND "
			+ "(CAST(:loppuPvm AS localdatetime) IS NULL OR t.ajankohta <= :loppuPvm) " + "ORDER BY t.ajankohta ASC")
	List<Tapahtuma> haeKalenteriSuodattimilla(@Param("kayttajatunnus") String kayttajatunnus,
			@Param("asiakasId") Long asiakasId, @Param("tyyppi") TapahtumaTyyppi tyyppi,
			@Param("alkuPvm") LocalDateTime alkuPvm, @Param("loppuPvm") LocalDateTime loppuPvm);

	// 🔍 1. Haetaan tulevat tapahtumat aikajärjestyksessä etusivun koosteeseen
	@Query("SELECT t FROM Tapahtuma t WHERE t.kayttaja.kayttajatunnus = :tunnus AND t.ajankohta > :nyt ORDER BY t.ajankohta ASC")
	List<Tapahtuma> findByKayttajaKayttajatunnusAndAjankohtaAfterOrderByAjankohtaAsc(@Param("tunnus") String tunnus,
			@Param("nyt") LocalDateTime nyt);

	// 📈 2. Lasketaan tämän päivän tehtävien määrä etusivun dashboard-korttiin
	@Query("SELECT COUNT(t) FROM Tapahtuma t WHERE t.kayttaja.kayttajatunnus = :tunnus AND t.ajankohta BETWEEN :alku AND :loppu")
	long countByKayttajaKayttajatunnusAndAjankohtaBetween(@Param("tunnus") String tunnus,
			@Param("alku") LocalDateTime alku, @Param("loppu") LocalDateTime loppu);

	// 📅 3. Kalenterisivun haku
	@Query("SELECT t FROM Tapahtuma t WHERE t.kayttaja.kayttajatunnus = :tunnus")
	List<Tapahtuma> findByKayttajatunnus(@Param("tunnus") String tunnus);
}
