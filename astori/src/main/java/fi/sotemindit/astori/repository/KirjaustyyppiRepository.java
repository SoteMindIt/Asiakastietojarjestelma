package fi.sotemindit.astori.repository;

import fi.sotemindit.astori.model.Kirjaustyyppi;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface KirjaustyyppiRepository extends JpaRepository<Kirjaustyyppi, Long> {
    // Valmiit CRUD-metodit löytyvät perinnän kautta automaattisesti
}
