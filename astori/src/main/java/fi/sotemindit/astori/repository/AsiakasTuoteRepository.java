package fi.sotemindit.astori.repository;

import fi.sotemindit.astori.model.AsiakasTuote;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface AsiakasTuoteRepository extends JpaRepository<AsiakasTuote, Long> {
    List<AsiakasTuote> findByAsiakasId(Long asiakasId);
}
