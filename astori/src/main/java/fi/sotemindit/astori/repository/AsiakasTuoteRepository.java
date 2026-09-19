package fi.sotemindit.astori.repository;

import fi.sotemindit.astori.model.AsiakasTuote;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.data.repository.query.Param;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
import java.time.LocalDate;

@Repository
public interface AsiakasTuoteRepository extends JpaRepository<AsiakasTuote, Long> {
    List<AsiakasTuote> findByAsiakasId(Long asiakasId);
    
    // 📊 UUSI: Hakee kaikki kirjautuneen käyttäjän asiakkaiden tuoteostokset valitulta ajanjaksolta
    @Query("SELECT at FROM AsiakasTuote at WHERE at.asiakas.kayttaja.kayttajatunnus = :tunnus " +
           "AND at.ostopaivamaara >= :alkuPvm AND at.ostopaivamaara <= :loppuPvm " +
           "ORDER BY at.ostopaivamaara DESC")
    List<AsiakasTuote> findMyyntiAjanjaksolta(
            @Param("tunnus") String tunnus, 
            @Param("alkuPvm") LocalDate alkuPvm, 
            @Param("loppuPvm") LocalDate loppuPvm);
    
    
}
