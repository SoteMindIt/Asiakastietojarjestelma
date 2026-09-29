package fi.sotemindit.astori.repository;

import fi.sotemindit.astori.model.Asiakas;
import fi.sotemindit.astori.model.AsiakasAjo;
import java.time.LocalDate;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface AsiakasAjoRepository extends JpaRepository<AsiakasAjo, Long> {

	@Query("SELECT a FROM AsiakasAjo a WHERE a.asiakas.kayttaja.kayttajatunnus = :tunnus "
			+ "AND a.paivamaara BETWEEN :alku AND :loppu "
			+ "AND (:asiakasId IS NULL OR a.asiakas.id = :asiakasId) "
			+ "ORDER BY a.paivamaara DESC, a.id DESC")
	List<AsiakasAjo> haeAjot(@Param("tunnus") String tunnus, @Param("alku") LocalDate alku,
			@Param("loppu") LocalDate loppu, @Param("asiakasId") Long asiakasId);

	@Query("SELECT DISTINCT a.asiakas FROM AsiakasAjo a "
			+ "WHERE a.asiakas.kayttaja.kayttajatunnus = :tunnus ORDER BY a.asiakas.nimi")
	List<Asiakas> haeAsiakkaatJoillaAjoja(@Param("tunnus") String tunnus);
}