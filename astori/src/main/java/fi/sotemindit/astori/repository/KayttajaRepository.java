package fi.sotemindit.astori.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import fi.sotemindit.astori.model.Kayttaja;

@Repository
public interface KayttajaRepository extends JpaRepository<Kayttaja, Long> {
    
    // Tämän metodin avulla Spring hakee käyttäjän automaattisesti tietokannasta tunnuksen perusteella
    Optional<Kayttaja> findByKayttajatunnus(String kayttajatunnus);
}
