package fi.sotemindit.astori.repository;

import fi.sotemindit.astori.model.Palveluyksikko; // 💡 Pieni y-kirjain
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PalveluyksikkoRepository extends JpaRepository<Palveluyksikko, Long> {
    java.util.List<Palveluyksikko> findByAsiakasId(Long asiakasId);
}