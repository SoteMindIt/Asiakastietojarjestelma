package fi.sotemindit.astori.repository;

import fi.sotemindit.astori.model.Asiakas;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AsiakasRepository extends JpaRepository<Asiakas, Long> {
    
    // Muutettu palauttamaan Page ja ottamaan vastaan Pageable-parametri
    Page<Asiakas> findByKayttajaKayttajatunnus(String kayttajatunnus, Pageable pageable);
}
