package fi.sotemindit.astori.repository;

import fi.sotemindit.astori.model.Loki;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import java.time.LocalDateTime;

@Repository
public interface LokiRepository extends JpaRepository<Loki, Long> {
    
    // Pääkäyttäjää varten: haetaan kaikki lokitapahtumat uusimmasta vanhimpaan
    List<Loki> findAllByOrderByAikaleimaDesc();
    
    // Laskuri tietyn aikavälin riveille tilastokorttia varten
   // long countByAikaleimaBetween(LocalDateTime alku, LocalDateTime loppu);
    
   //Spring Data rakentaa tästä automaattisesti sivutetun SQL-aikavälihaun
    Page<Loki> findByAikaleimaBetweenOrderByAikaleimaDesc(LocalDateTime alku, LocalDateTime loppu, Pageable pageable);
    
    //Spring Data rakentaa tästä automaattisesti sivutetun SQL-haun
    Page<Loki> findAllByOrderByAikaleimaDesc(Pageable pageable);
}
