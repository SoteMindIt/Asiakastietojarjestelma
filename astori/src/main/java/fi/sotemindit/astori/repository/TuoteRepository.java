package fi.sotemindit.astori.repository;

import fi.sotemindit.astori.model.Tuote;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TuoteRepository extends JpaRepository<Tuote, Long> {}