package fi.sotemindit.astori.repository;

import fi.sotemindit.astori.model.Kirjaus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import java.time.LocalDateTime;

@Repository
public interface KirjausRepository extends JpaRepository<Kirjaus, Long> {
    
    // Valmis metodi, jolla voidaan hakea kaikki tietyn asiakkaan kirjaukset aikajärjestyksessä
    List<Kirjaus> findByAsiakasIdOrderByLuontiaikaDesc(Long asiakasId);
    // Hakee kaikki järjestelmän kirjaukset tietyltä aikaväliltä sivutettuna (uusin ensin)
    Page<Kirjaus> findByLuontiaikaBetweenOrderByLuontiaikaDesc(LocalDateTime alku, LocalDateTime loppu, Pageable pageable);
}
