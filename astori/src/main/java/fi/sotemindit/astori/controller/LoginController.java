package fi.sotemindit.astori.controller;

import java.util.Optional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.PathVariable;

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

    // 4. REITTI: UUDEN KÄYTTÄJÄN LUONTI ROOLIVALINNALLA (Vain pääkäyttäjälle)
    @PostMapping("/admin/luo-kayttaja")
    public String luoUusiKayttaja(HttpSession session,
                                  @RequestParam String kayttajatunnus,
                                  @RequestParam String salasana,
                                  @RequestParam String etunimi,
                                  @RequestParam String sukunimi,
                                  @RequestParam String sahkoposti,
                                  @RequestParam String puhelin,
                                  @RequestParam String rooli) { // Vastaanotetaan rooli lomakkeelta
        
        String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
        if (istuntoTunnus == null) return "redirect:/login";

        // Varmistetaan tietoturva: vain ADMIN saa luoda tilejä
        Kayttaja nykyinenKayttaja = kayttajaRepository.findByKayttajatunnus(istuntoTunnus)
                .orElseThrow(() -> new IllegalArgumentException("Käyttäjää ei löydy"));
        if (!"ADMIN".equals(nykyinenKayttaja.getRooli())) {
            return "redirect:/?error=access_denied";
        }

        // Kryptataan uuden käyttäjän salasana ennen tallennusta
        String kryptattuSalasana = passwordEncoder.encode(salasana);

        Kayttaja uusiKayttaja = new Kayttaja(kayttajatunnus, kryptattuSalasana, etunimi, sukunimi, sahkoposti, puhelin);
        uusiKayttaja.setRooli(rooli); // Asetetaan valittu rooli (USER tai ADMIN)

        kayttajaRepository.save(uusiKayttaja);
        return "redirect:/asetukset?success=user_created"; // Palataan asetuksiin
    }

    // 5. REITTI: KÄYTTÄJÄN MUOKKAUS SISÄLTÄEN ROOLIN (Vain pääkäyttäjälle)
    @PostMapping("/admin/muokkaa-kayttajaa/{id}")
    public String muokkaaKayttajaa(HttpSession session,
                                   @PathVariable Long id,
                                   @RequestParam String etunimi,
                                   @RequestParam String sukunimi,
                                   @RequestParam String sahkoposti,
                                   @RequestParam String puhelin,
                                   @RequestParam String rooli) {
        
        String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
        if (istuntoTunnus == null) return "redirect:/login";

        // Varmistetaan tietoturva
        Kayttaja nykyinenKayttaja = kayttajaRepository.findByKayttajatunnus(istuntoTunnus)
                .orElseThrow(() -> new IllegalArgumentException("Käyttäjää ei löydy"));
        if (!"ADMIN".equals(nykyinenKayttaja.getRooli())) {
            return "redirect:/?error=access_denied";
        }

        // Haetaan muokattava käyttäjä
        Kayttaja muokattava = kayttajaRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Muokattavaa käyttäjää ei löydy ID: " + id));

        // Päivitetään tiedot
        muokattava.setEtunimi(etunimi);
        muokattava.setSukunimi(sukunimi);
        muokattava.setSahkoposti(sahkoposti);
        muokattava.setPuhelin(puhelin);
        muokattava.setRooli(rooli); // Päivitetään rooli

        kayttajaRepository.save(muokattava);
        return "redirect:/asetukset?success=user_updated";
    }
}
