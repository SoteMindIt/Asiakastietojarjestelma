package fi.sotemindit.astori.repository;

import fi.sotemindit.astori.model.Yhteistyotaho;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface YhteistyotahoRepository extends JpaRepository<Yhteistyotaho, Long> {
	List<Yhteistyotaho> findAllByOrderByNimiAsc();
}
