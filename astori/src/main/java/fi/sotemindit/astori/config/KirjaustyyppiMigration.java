package fi.sotemindit.astori.config;

import fi.sotemindit.astori.model.Kirjaus;
import fi.sotemindit.astori.model.Kirjaustyyppi;
import fi.sotemindit.astori.repository.KirjausRepository;
import fi.sotemindit.astori.repository.KirjaustyyppiRepository;
import java.util.Arrays;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
public class KirjaustyyppiMigration implements ApplicationRunner {

    @Autowired
    private KirjaustyyppiRepository kirjaustyyppiRepository;

    @Autowired
    private KirjausRepository kirjausRepository;

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        Kirjaustyyppi oletusTyyppi = haeYleinenTyyppi();
        if (oletusTyyppi == null) {
            return;
        }

        List<Kirjaus> ilmanTyyppia = kirjausRepository.findAll().stream()
                .filter(kirjaus -> kirjaus.getKirjaustyyppi() == null)
                .toList();

        for (Kirjaus kirjaus : ilmanTyyppia) {
            kirjaus.setKirjaustyyppi(oletusTyyppi);
            kirjausRepository.save(kirjaus);
        }
    }

    private Kirjaustyyppi haeYleinenTyyppi() {
        List<String> nimet = Arrays.asList("Yleinen", "Yleinen merkintä", "Normaali", "Normaali merkintä");

        for (String nimi : nimet) {
            var tyyppi = kirjaustyyppiRepository.findByNimiIgnoreCase(nimi);
            if (tyyppi.isPresent()) {
                return tyyppi.get();
            }
        }

        Kirjaustyyppi uusiTyyppi = new Kirjaustyyppi();
        uusiTyyppi.setNimi("Yleinen");
        uusiTyyppi.setVari("#6c757d");
        return kirjaustyyppiRepository.save(uusiTyyppi);
    }
}
