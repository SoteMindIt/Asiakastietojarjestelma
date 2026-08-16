package fi.sotemindit.astori.repository;

import fi.sotemindit.astori.model.Yritystiedot;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface YritystiedotRepository extends JpaRepository<Yritystiedot, Long> {
}
