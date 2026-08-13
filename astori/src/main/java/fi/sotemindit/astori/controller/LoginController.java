package fi.sotemindit.astori.controller;

import fi.sotemindit.astori.model.Kayttaja;
import fi.sotemindit.astori.repository.KayttajaRepository;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Optional;

@Controller
public class LoginController {

    @Autowired
    private KayttajaRepository kayttajaRepository;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    // 1. NÄYTÄ KIRJAUTUMISSIVU
    @GetMapping("/login")
    public String naytaLogin() {
        return "login"; // Etsii login.jsp-sivua
    }

    // 2. KÄSITTELE KIRJAUTUMINEN
    @PostMapping("/login")
    public String kirjauduSisaan(@RequestParam String tunnus, 
                                 @RequestParam String salasana, 
                                 HttpSession session, 
                                 Model model) {
        // Etsitään käyttäjää tietokannasta tunnuksen perusteella
        Optional<Kayttaja> oK = kayttajaRepository.findByKayttajatunnus(tunnus);
        
        // Jos käyttäjä löytyy ja salasana täsmää kryptattuun versioon
        if (oK.isPresent() && passwordEncoder.matches(salasana, oK.get().getSalasana())) {
            // Tallennetaan käyttäjätunnus istuntoon (session) merkiksi kirjautumisesta
            session.setAttribute("kirjautunutKayttaja", tunnus);
            return "redirect:/"; // Kirjautuminen onnistui -> siirrytään pääsivulle
        }
        
        // Jos kirjautuminen epäonnistui, näytetään virheilmoitus sivulla
        model.addAttribute("virhe", "Väärä käyttäjätunnus tai salasana!");
        return "login";
    }

    // 3. NÄYTÄ REKISTERÖINTISIVU
    @GetMapping("/rekisteroidy")
    public String naytaRekisterointi() {
        return "rekisterointi"; // Etsii rekisterointi.jsp-sivua
    }

    // 4. KÄSITTELE REKISTERÖINTI (Uuden käyttäjän luonti)
    @PostMapping("/rekisteroidy")
    public String luoKayttaja(@RequestParam String tunnus, 
                              @RequestParam String salasana,
                              @RequestParam String etunimi,
                              @RequestParam String sukunimi,
                              @RequestParam String sahkoposti,
                              @RequestParam String puhelin, // UUSI PARAMETRI
                              Model model) {
        
        if (kayttajaRepository.findByKayttajatunnus(tunnus).isPresent()) {
            model.addAttribute("virhe", "Käyttäjätunnus on jo varattu!");
            return "rekisterointi";
        }
        
        // Kryptataan (suojataan) salasana ennen tietokantaan tallentamista
        String suojattuSalasana = passwordEncoder.encode(salasana);
        
        // Luodaan uusi käyttäjä kaikilla tiedoilla
        Kayttaja uusiKayttaja = new Kayttaja(tunnus, suojattuSalasana, etunimi, sukunimi, sahkoposti, puhelin);
        kayttajaRepository.save(uusiKayttaja);
        
        return "redirect:/login";
         
        
    }

    // 5. KIRJAUDU ULOS
    @GetMapping("/logout")
    public String kirjauduUlos(HttpSession session) {
        session.invalidate(); // Tyhjennetään istunto ja poistetaan kirjautumistieto
        return "redirect:/login";
    }
}
