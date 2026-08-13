package fi.sotemindit.astori.repository;

import fi.sotemindit.astori.model.Yhteyshenkilo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface YhteyshenkiloRepository extends JpaRepository<Yhteyshenkilo, Long> {
    
    // Valmis metodi, jolla voidaan hakea kaikki tietyn asiakkaan yhteyshenkilöt
    List<Yhteyshenkilo> findByAsiakasId(Long asiakasId);
}
