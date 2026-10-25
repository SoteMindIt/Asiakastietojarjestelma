package fi.sotemindit.astori.repository;

import fi.sotemindit.astori.model.AsiakasAjo;
import java.time.LocalDate;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface AsiakasAjoRepository extends JpaRepository<AsiakasAjo, Long> {

	@Query("SELECT DISTINCT a FROM AsiakasAjo a "
			+ "LEFT JOIN a.asiakkaat linkitettyAsiakas "
			+ "LEFT JOIN a.luoja luoja "
			+ "LEFT JOIN a.asiakas vanhaAsiakas "
			+ "LEFT JOIN vanhaAsiakas.kayttaja vanhaOmistaja "
			+ "LEFT JOIN linkitettyAsiakas.kayttaja linkitetynAsiakkaanOmistaja "
			+ "WHERE (luoja.kayttajatunnus = :tunnus OR vanhaOmistaja.kayttajatunnus = :tunnus "
			+ "OR linkitetynAsiakkaanOmistaja.kayttajatunnus = :tunnus) "
			+ "AND a.paivamaara BETWEEN :alku AND :loppu "
			+ "AND (:asiakasId IS NULL OR vanhaAsiakas.id = :asiakasId OR linkitettyAsiakas.id = :asiakasId) "
			+ "ORDER BY a.paivamaara DESC, a.id DESC")
	List<AsiakasAjo> haeAjot(@Param("tunnus") String tunnus, @Param("alku") LocalDate alku,
			@Param("loppu") LocalDate loppu, @Param("asiakasId") Long asiakasId);
}