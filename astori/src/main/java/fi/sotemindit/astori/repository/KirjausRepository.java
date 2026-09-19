package fi.sotemindit.astori.repository;

import fi.sotemindit.astori.model.Kirjaus;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.repository.query.Param;

import java.util.List;

import java.time.LocalDateTime;

@Repository
public interface KirjausRepository extends JpaRepository<Kirjaus, Long> {
    
    // Valmis metodi, jolla voidaan hakea kaikki tietyn asiakkaan kirjaukset aikajärjestyksessä
    List<Kirjaus> findByAsiakasIdOrderByLuontiaikaDesc(Long asiakasId);
    // Hakee kaikki järjestelmän kirjaukset tietyltä aikaväliltä sivutettuna (uusin ensin)
    Page<Kirjaus> findByLuontiaikaBetweenOrderByLuontiaikaDesc(LocalDateTime alku, LocalDateTime loppu, Pageable pageable);
    
    //Hakee kaikki käyttäjän asiakkaiden TÄRKEÄT kirjaukset valitulta ajanjaksolta järjestettynä uusimman mukaan
    @Query("SELECT k FROM Kirjaus k WHERE k.asiakas.kayttaja.kayttajatunnus = :tunnus " +
           "AND k.tarkea = true " +
           "AND k.luontiaika >= :alkuAika AND k.luontiaika <= :loppuAika " +
           "ORDER BY k.luontiaika DESC")
    List<Kirjaus> findTarkeatKirjauksetAjanjaksolta(
            @Param("tunnus") String tunnus, 
            @Param("alkuAika") LocalDateTime alkuAika, 
            @Param("loppuAika") LocalDateTime loppuAika);
    
}
