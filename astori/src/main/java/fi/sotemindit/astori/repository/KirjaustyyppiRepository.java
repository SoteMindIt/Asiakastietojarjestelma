package fi.sotemindit.astori.repository;

import fi.sotemindit.astori.model.Kirjaustyyppi;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface KirjaustyyppiRepository extends JpaRepository<Kirjaustyyppi, Long> {
    Optional<Kirjaustyyppi> findByNimiIgnoreCase(String nimi);
}
