package fi.sotemindit.astori.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import fi.sotemindit.astori.model.Muistiinpano;

@Repository
public interface MuistiinpanoRepository extends JpaRepository<Muistiinpano, Long> {
	
	// Hakee tietyn käyttäjän yleiset muistiinpanot aikajärjestyksessä (uusimmat ensin)
	List<Muistiinpano> findByKayttajatunnusOrderByLuontiaikaDesc(String kayttajatunnus);
}
