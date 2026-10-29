package fi.sotemindit.astori.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import fi.sotemindit.astori.model.Tarjous;
import java.time.LocalDate;
import java.util.List;

public interface TarjousRepository extends JpaRepository<Tarjous, Long> {

	//KORJATTU LASKURI: Etenee polkua Tarjous -> Asiakas -> Käyttäjä -> Tunnus
	@Query("SELECT COUNT(t) FROM Tarjous t WHERE t.asiakas.kayttaja.kayttajatunnus = :tunnus")
	long countByAsiakasKayttajaKayttajatunnus(@Param("tunnus") String tunnus);

	@Query("SELECT t FROM Tarjous t WHERE t.asiakas.kayttaja.kayttajatunnus = :tunnus "
			+ "AND t.voimassaoloPvm >= :paiva ORDER BY t.voimassaoloPvm ASC, t.pvm DESC")
	List<Tarjous> findAvoimetKayttajalle(@Param("tunnus") String tunnus, @Param("paiva") LocalDate paiva);

	@Query("SELECT COUNT(t) FROM Tarjous t WHERE t.asiakas.kayttaja.kayttajatunnus = :tunnus "
			+ "AND t.voimassaoloPvm >= :paiva")
	long countAvoimetKayttajalle(@Param("tunnus") String tunnus, @Param("paiva") LocalDate paiva);

	java.util.List<Tarjous> findByAsiakasId(Long asiakasId);
	boolean existsByTarjousNumero(String tarjousNumero);
	boolean existsByTarjousNumeroAndIdNot(String tarjousNumero, Long id);
}
