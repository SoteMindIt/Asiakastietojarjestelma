package fi.sotemindit.astori.repository;

import java.util.List;
import java.time.LocalDateTime;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
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

	// 🔍 Haetaan etusivulle vain seuraavan 30 vuorokauden tapahtumat.
	@Query("SELECT t FROM Tapahtuma t WHERE t.kayttaja.kayttajatunnus = :kayttajatunnus "
			+ "AND t.ajankohta > :alku AND t.ajankohta <= :loppu ORDER BY t.ajankohta ASC")
	Page<Tapahtuma> findByKayttajaKayttajatunnusAndAjankohtaBetweenOrderByAjankohtaAsc(
			@Param("kayttajatunnus") String kayttajatunnus, @Param("alku") LocalDateTime alku,
			@Param("loppu") LocalDateTime loppu, Pageable pageable);

	// 📈 2. Lasketaan tämän päivän tehtävien määrä etusivun dashboard-korttiin
	@Query("SELECT COUNT(t) FROM Tapahtuma t WHERE t.kayttaja.kayttajatunnus = :tunnus AND t.ajankohta BETWEEN :alku AND :loppu")
	long countByKayttajaKayttajatunnusAndAjankohtaBetween(@Param("tunnus") String tunnus,
			@Param("alku") LocalDateTime alku, @Param("loppu") LocalDateTime loppu);

	// 📅 3. Kalenterisivun haku
	@Query("SELECT t FROM Tapahtuma t WHERE t.kayttaja.kayttajatunnus = :tunnus")
	List<Tapahtuma> findByKayttajatunnus(@Param("tunnus") String tunnus);
}
