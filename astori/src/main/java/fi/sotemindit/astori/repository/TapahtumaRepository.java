package fi.sotemindit.astori.repository;

import java.util.List;
import java.time.LocalDateTime;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import fi.sotemindit.astori.model.Tapahtuma;

public interface TapahtumaRepository extends JpaRepository<Tapahtuma, Long> {

	// 🔍 1. Haetaan tulevat tapahtumat aikajärjestyksessä etusivun koosteeseen (KORJATTU PÄIVITETYLLÄ KYSELYLLÄ)
	@Query("SELECT t FROM Tapahtuma t WHERE t.kayttaja.kayttajatunnus = :tunnus AND t.ajankohta > :nyt ORDER BY t.ajankohta ASC")
	List<Tapahtuma> findByKayttajaKayttajatunnusAndAjankohtaAfterOrderByAjankohtaAsc(
			@Param("tunnus") String tunnus, 
			@Param("nyt") LocalDateTime nyt);

	// 📈 2. Lasketaan tämän päivän tehtävien määrä etusivun dashboard-korttiin (KORJATTU PÄIVITETYLLÄ KYSELYLLÄ)
	@Query("SELECT COUNT(t) FROM Tapahtuma t WHERE t.kayttaja.kayttajatunnus = :tunnus AND t.ajankohta BETWEEN :alku AND :loppu")
	long countByKayttajaKayttajatunnusAndAjankohtaBetween(
			@Param("tunnus") String tunnus, 
			@Param("alku") LocalDateTime alku, 
			@Param("loppu") LocalDateTime loppu);

	// 📅 3. Kalenterisivun haku (Varmistetaan että tämäkin toimii ilman nimitulkintavirheitä)
	@Query("SELECT t FROM Tapahtuma t WHERE t.kayttaja.kayttajatunnus = :tunnus")
	List<Tapahtuma> findByKayttajatunnus(@Param("tunnus") String tunnus);
}
