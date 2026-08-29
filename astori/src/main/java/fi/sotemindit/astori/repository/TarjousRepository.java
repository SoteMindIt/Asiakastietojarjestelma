package fi.sotemindit.astori.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import fi.sotemindit.astori.model.Tarjous;

public interface TarjousRepository extends JpaRepository<Tarjous, Long> {

	//KORJATTU LASKURI: Etenee polkua Tarjous -> Asiakas -> Käyttäjä -> Tunnus
	@Query("SELECT COUNT(t) FROM Tarjous t WHERE t.asiakas.kayttaja.kayttajatunnus = :tunnus")
	long countByAsiakasKayttajaKayttajatunnus(@Param("tunnus") String tunnus);
	java.util.List<Tarjous> findByAsiakasId(Long asiakasId);
	boolean existsByTarjousNumero(String tarjousNumero);
}
