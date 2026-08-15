package fi.sotemindit.astori.repository;

import fi.sotemindit.astori.model.Tapahtuma;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface TapahtumaRepository extends JpaRepository<Tapahtuma, Long> {
    // Haetaan asiakkaan tapaamiset niin, että lähin ajankohta on ensimmäisenä
    List<Tapahtuma> findByAsiakasIdOrderByAjankohtaAsc(Long asiakasId);
}
