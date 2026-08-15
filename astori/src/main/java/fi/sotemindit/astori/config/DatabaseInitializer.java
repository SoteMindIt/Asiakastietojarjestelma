package fi.sotemindit.astori.config;

import java.util.Optional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Component;

import fi.sotemindit.astori.model.Kayttaja;
import fi.sotemindit.astori.repository.KayttajaRepository;

@Component
public class DatabaseInitializer implements CommandLineRunner {

    @Autowired
    private KayttajaRepository kayttajaRepository;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        // Tarkistetaan, onko admin-käyttäjä jo olemassa tietokannassa
        Optional<Kayttaja> adminHaku = kayttajaRepository.findByKayttajatunnus("admin");
        
        if (adminHaku.isEmpty()) {
            // Jos adminia ei löydy, luodaan se dynaamisesti oletussalasanalla "admin1!"
            String suojattuSalasana = passwordEncoder.encode("admin1!");
            
            Kayttaja admin = new Kayttaja(
                "admin", 
                suojattuSalasana, 
                "Järjestelmän", 
                "Ylläpitäjä", 
                "admin@astori.fi", 
                "0400000000"
            );
            
            kayttajaRepository.save(admin);
            System.out.println(">>> Oletuskäyttäjä admin luotu onnistuneesti tietokantaan! <<<");
        }
    }
}
