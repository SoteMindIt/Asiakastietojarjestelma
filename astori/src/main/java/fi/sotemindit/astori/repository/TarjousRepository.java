package fi.sotemindit.astori.repository;

import fi.sotemindit.astori.model.Tarjous;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface TarjousRepository extends JpaRepository<Tarjous, Long> {
    // Haetaan tietyn asiakkaan kaikki tarjoukset
    List<Tarjous> findByAsiakasId(Long asiakasId);
    
    // UUSI: Tarkistaa löytyykö tarjousnumero jo tietokannasta
    boolean existsByTarjousNumero(String tarjousNumero);
}
