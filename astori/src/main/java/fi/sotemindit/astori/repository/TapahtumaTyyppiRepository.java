package fi.sotemindit.astori.repository;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import fi.sotemindit.astori.model.TapahtumaTyyppi;

public interface TapahtumaTyyppiRepository extends JpaRepository<TapahtumaTyyppi, Long> {
    Optional<TapahtumaTyyppi> findByNimiIgnoreCase(String nimi);
}
