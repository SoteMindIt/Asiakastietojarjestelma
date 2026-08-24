package fi.sotemindit.astori.repository;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import fi.sotemindit.astori.model.Tapahtuma;

@Repository
public interface TapahtumaRepository extends JpaRepository<Tapahtuma, Long> {
    
    // TÄMÄ TOIMII: Nimi on siisti, ja @Query hoitaa relaation linkityksen taustalla
    @Query("SELECT t FROM Tapahtuma t WHERE t.kayttaja.kayttajatunnus = :tunnus")
    List<Tapahtuma> findByKayttajatunnus(String kayttajatunnus);
    // UUSI METODI ETUSIVUA VARTEN: hakee käyttäjän tulevat tapahtumat aikajärjestyksessä
    List<Tapahtuma> findByKayttajaKayttajatunnusAndAjankohtaAfterOrderByAjankohtaAsc(String kayttajatunnus, java.time.LocalDateTime nyt);

}
