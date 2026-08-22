package fi.sotemindit.astori.repository;

import fi.sotemindit.astori.model.Loki;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface LokiRepository extends JpaRepository<Loki, Long> {
    
    // Pääkäyttäjää varten: haetaan kaikki lokitapahtumat uusimmasta vanhimpaan
    List<Loki> findAllByOrderByAikaleimaDesc();
}
