package fi.sotemindit.astori.repository;

import fi.sotemindit.astori.model.Asiakas;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List; // TÄRKEÄ: Varmista tämä import!

@Repository
public interface AsiakasRepository extends JpaRepository<Asiakas, Long> {
    
    // Lisää tämä rivi, jos kontrollerisi käyttää käyttäjäkohtaista hakua:
    List<Asiakas> findByKayttajaKayttajatunnus(String kayttajatunnus);
}
