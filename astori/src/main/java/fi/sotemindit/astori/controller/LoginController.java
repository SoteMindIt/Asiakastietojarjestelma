package fi.sotemindit.astori.controller;

import java.util.Optional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import fi.sotemindit.astori.model.Kayttaja;
import fi.sotemindit.astori.repository.KayttajaRepository;
import jakarta.servlet.http.HttpSession;

@Controller
public class LoginController {

    @Autowired
    private KayttajaRepository kayttajaRepository;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    // 1. REITTI: Näyttää uuden tyylikkään kirjautumissivun
    @GetMapping("/login")
    public String naytaKirjautuminen() {
        return "login"; // Avaa login.jsp
    }
    // 2. REITTI: Ottaa vastaan lomakkeen tunnuksen ja salasanan ja tarkistaa ne BCryptillä
    @PostMapping("/login")
    public String kirjauduSissaan(@RequestParam String username, 
                                  @RequestParam String password, 
                                  HttpSession session) {
        
        Optional<Kayttaja> kayttajaHaku = kayttajaRepository.findByKayttajatunnus(username);

        // Tarkistetaan löytyykö käyttäjä ja täsmääkö kryptattu salasana
        if (kayttajaHaku.isPresent() && passwordEncoder.matches(password, kayttajaHaku.get().getSalasana())) {
            // Tallennetaan istuntoon tieto kirjautuneesta käyttäjästä
            session.setAttribute("kirjautunutKayttaja", username);
            return "redirect:/"; // Ohjataan onnistuneen kirjautumisen jälkeen etusivulle
        }

        // Jos tunnus tai salasana on väärin, palataan kirjautumissivulle virhe-parametrilla
        return "redirect:/login?error=true";
    }

    // 3. REITTI: Kirjaa käyttäjän ulos ja tuhoaa istunnon
    @GetMapping("/logout")
    public String kirjaaUlos(HttpSession session) {
        session.invalidate(); // Tyhjennetään istunto
        return "redirect:/login?logout=true";
    }
}
