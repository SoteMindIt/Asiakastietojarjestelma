package fi.sotemindit.astori.controller;

import fi.sotemindit.astori.model.Asiakas;
import fi.sotemindit.astori.model.Tarjous;
import fi.sotemindit.astori.model.TarjousRivi;
import fi.sotemindit.astori.model.Tuote; // UUSI IMPORT
import fi.sotemindit.astori.repository.AsiakasRepository;
import fi.sotemindit.astori.repository.TarjousRepository;
import fi.sotemindit.astori.repository.TuoteRepository; // UUSI IMPORT
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
@RequestMapping("/asiakkaat/{asiakasId}/tarjoukset")
public class TarjousController {

    private final TarjousRepository tarjousRepository;
    private final AsiakasRepository asiakasRepository;
    private final TuoteRepository tuoteRepository; // UUSI RIIPPUVUUS

    // Päivitetty konstruktori ottamaan vastaan myös TuoteRepositoryn
    public TarjousController(TarjousRepository tarjousRepository, 
                             AsiakasRepository asiakasRepository, 
                             TuoteRepository tuoteRepository) {
        this.tarjousRepository = tarjousRepository;
        this.asiakasRepository = asiakasRepository;
        this.tuoteRepository = tuoteRepository;
    }

    // 1. Näytetään asiakkaan tarjoukset ja lomake uuden luomiseen (PÄIVITETTY)
    @GetMapping
    public String naytaTarjoukset(@PathVariable Long asiakasId, Model model) {
        Asiakas asiakas = asiakasRepository.findById(asiakasId)
                .orElseThrow(() -> new IllegalArgumentException("Asiakasta ei löydy: " + asiakasId));
        
        List<Tuote> tuotteet = tuoteRepository.findAll(); // HAETAAN TUOTTEET REKISTERISTÄ
        
        model.addAttribute("asiakas", asiakas);
        model.addAttribute("tarjoukset", tarjousRepository.findByAsiakasId(asiakasId));
        model.addAttribute("kaikkiTuotteet", tuotteet); // VIEDÄÄN TUOTELISTA JSP-SIVULLE
        
        Tarjous uusiTarjous = new Tarjous();
        uusiTarjous.setAsiakas(asiakas);
        model.addAttribute("uusiTarjous", uusiTarjous);
        
        return "tarjoukset";
    }

    // 2. Vastaanotetaan lomake ja tallennetaan tarjous riveineen
    @PostMapping("/tallenna")
    public String tallennaTarjous(@PathVariable Long asiakasId, 
                                  @ModelAttribute Tarjous uusiTarjous,
                                  @RequestParam("tuote[]") String[] tuotteet,
                                  @RequestParam("maara[]") double[] maarat,
                                  @RequestParam("hinta[]") double[] hinnat,
                                  @RequestParam("alv[]") double[] alvProsentit) {
        
        Asiakas asiakas = asiakasRepository.findById(asiakasId)
                .orElseThrow(() -> new IllegalArgumentException("Asiakasta ei löydy: " + asiakasId));
        
        uusiTarjous.setAsiakas(asiakas);

        for (int i = 0; i < tuotteet.length; i++) {
            if (tuotteet[i] != null && !tuotteet[i].trim().isEmpty()) {
                TarjousRivi rivi = new TarjousRivi();
                rivi.setTuoteNimi(tuotteet[i]);
                rivi.setMaara(maarat[i]);
                rivi.setYksikkohinta(hinnat[i]);
                rivi.setAlvProsentti(alvProsentit[i]);
                
                uusiTarjous.lisaaRivi(rivi);
            }
        }

        tarjousRepository.save(uusiTarjous);
        return "redirect:/asiakkaat/" + asiakasId + "/tarjoukset";
    }
}
