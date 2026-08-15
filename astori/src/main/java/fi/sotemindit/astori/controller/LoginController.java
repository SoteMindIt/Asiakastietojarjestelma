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

    // 5. KIRJAUDU ULOS
    @GetMapping("/logout")
    public String kirjauduUlos(HttpSession session) {
        session.invalidate(); // Tyhjennetään istunto ja poistetaan kirjautumistieto
        return "redirect:/login";
    }
}
