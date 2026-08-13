package fi.sotemindit.astori.repository;

import fi.sotemindit.astori.model.Kirjaus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface KirjausRepository extends JpaRepository<Kirjaus, Long> {
    
    // Valmis metodi, jolla voidaan hakea kaikki tietyn asiakkaan kirjaukset aikajärjestyksessä
    List<Kirjaus> findByAsiakasIdOrderByLuontiaikaDesc(Long asiakasId);
}
