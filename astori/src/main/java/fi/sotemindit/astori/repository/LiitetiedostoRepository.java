package fi.sotemindit.astori.repository;

import fi.sotemindit.astori.model.Liitetiedosto;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface LiitetiedostoRepository extends JpaRepository<Liitetiedosto, Long> {
    List<Liitetiedosto> findByAsiakasIdOrderByLatausaikaDesc(Long asiakasId);
}
