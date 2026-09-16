package fi.sotemindit.astori.controller;

import fi.sotemindit.astori.model.Kirjaus;
import fi.sotemindit.astori.model.Loki;
import fi.sotemindit.astori.model.Asiakas;
import fi.sotemindit.astori.repository.KirjausRepository;
import fi.sotemindit.astori.repository.LokiRepository;
import fi.sotemindit.astori.repository.AsiakasRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import jakarta.servlet.http.HttpSession;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Optional;

@Controller
public class KirjausController {

    @Autowired
    private KirjausRepository kirjausRepository;

    @Autowired
    private AsiakasRepository asiakasRepository;

    @Autowired
    private LokiRepository lokiRepository;

    // 1. TALLENNA UUSI LOKIMERKINTÄ / SOVITTU ASIA
    @Transactional
    @PostMapping("/asiakas/{asiakasId}/lisaa-kirjaus")
    public String lisaaKirjaus(@PathVariable Long asiakasId, 
                               @RequestParam String teksti,
                               @RequestParam(value = "tarkea", defaultValue = "false") boolean tarkea,
                               @RequestParam(value = "linkitettavaId", required = false) Long linkitettavaId,
                               HttpSession session) {

        String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
        if (istuntoTunnus == null) {
            return "redirect:/login";
        }

        Asiakas asiakas = asiakasRepository.findById(asiakasId)
                .orElseThrow(() -> new IllegalArgumentException("Asiakasta ei löytynyt ID-numerolla: " + asiakasId));

        Kirjaus uusiKirjaus = new Kirjaus();
        uusiKirjaus.setAsiakas(asiakas);
        uusiKirjaus.setTeksti(teksti);
        uusiKirjaus.setTarkea(tarkea);
        uusiKirjaus.setLuontiaika(LocalDateTime.now());

        // Tallennetaan ensin, jotta saadaan ID
        uusiKirjaus = kirjausRepository.save(uusiKirjaus);

        // Hoitaa Jira-tyylisen linkityksen
        if (linkitettavaId != null) {
            Optional<Kirjaus> linkitettavaOpt = kirjausRepository.findById(linkitettavaId);
            if (linkitettavaOpt.isPresent()) {
                Kirjaus vanhaKirjaus = linkitettavaOpt.get();
                uusiKirjaus.linkitäKirjaukseen(vanhaKirjaus);
                
                kirjausRepository.save(uusiKirjaus);
                kirjausRepository.save(vanhaKirjaus);
            }
        }

        String lokiViesti = "Lisätty uusi " + (tarkea ? "TÄRKEÄ " : "") + "lokimerkintä asiakkaalle: " 
                + asiakas.getNimi() + " (ID: " + asiakasId + ").";
        if (linkitettavaId != null) {
            lokiViesti += " Merkintä linkitetty aiemmin sovittuun asiaan (ID: " + linkitettavaId + ").";
        }
        lokiRepository.save(new Loki(istuntoTunnus, "LISÄYS", lokiViesti));

        return "redirect:/asiakas/" + asiakasId;
    }

    // 2. MUOKKAA LOKIMERKINTÄÄ
    @Transactional
    @PostMapping("/kirjaus/muokkaa/{id}")
    public String muokkaaKirjausta(@PathVariable Long id, 
                                   @RequestParam String teksti, 
                                   @RequestParam Long asiakasId,
                                   @RequestParam(value = "linkitettavaId", required = false) Long linkitettavaId,
                                   HttpSession session) {
        
        String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
        if (istuntoTunnus == null) {
            return "redirect:/login";
        }

        Kirjaus kirjaus = kirjausRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Merkintää ei löytynyt ID-numerolla: " + id));

        kirjaus.setTeksti(teksti);

        // Jos valittiin uusi kohde, lisätään se muiden jatkoksi (haitari säilyy)
        if (linkitettavaId != null) {
            Optional<Kirjaus> linkitettavaOpt = kirjausRepository.findById(linkitettavaId);
            if (linkitettavaOpt.isPresent()) {
                Kirjaus uusiLinkki = linkitettavaOpt.get();
                if (!kirjaus.getLinkitetytKirjaukset().contains(uusiLinkki)) {
                    kirjaus.linkitäKirjaukseen(uusiLinkki);
                    kirjausRepository.save(uusiLinkki);
                }
            }
        }

        kirjausRepository.save(kirjaus);

        String lokiViesti = "Muokattu lokimerkintää (ID: " + id + ") asiakkaalla (ID: " + asiakasId + ").";
        lokiRepository.save(new Loki(istuntoTunnus, "MUOKKAUS", lokiViesti));

        return "redirect:/asiakas/" + asiakasId;
    }

    // 3. 🔗 UUSI: POISTA KYTKENTÄ / LINKITYS KAHDEN KIRJAUKSEN VÄLILTÄ
    @Transactional
    @PostMapping("/kirjaus/{id}/poista-linkki/{linkkiId}")
    public String poistaKirjausLinkki(@PathVariable Long id, 
                                      @PathVariable Long linkkiId,
                                      @RequestParam Long asiakasId,
                                      HttpSession session) {
        
        String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
        if (istuntoTunnus == null) {
            return "redirect:/login";
        }

        Optional<Kirjaus> kirjausOpt = kirjausRepository.findById(id);
        Optional<Kirjaus> linkkiOpt = kirjausRepository.findById(linkkiId);

        if (kirjausOpt.isPresent() && linkkiOpt.isPresent()) {
            Kirjaus kirjaus = kirjausOpt.get();
            Kirjaus linkitetty = linkkiOpt.get();

            kirjaus.getLinkitetytKirjaukset().remove(linkitetty);
            linkitetty.getLinkitetytKirjaukset().remove(kirjaus);

            kirjausRepository.save(kirjaus);
            kirjausRepository.save(linkitetty);

            String lokiViesti = "Poistettu linkitys kirjauksen (ID: " + id + ") ja kirjauksen (ID: " + linkkiId + ") väliltä.";
            lokiRepository.save(new Loki(istuntoTunnus, "MUOKKAUS", lokiViesti));
		}

        return "redirect:/asiakas/" + asiakasId;
    }
}
