package fi.sotemindit.astori.controller;

import java.math.BigDecimal;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import fi.sotemindit.astori.model.Tuote;
import fi.sotemindit.astori.model.TuoteYksikko;
import fi.sotemindit.astori.model.Kayttaja;
import fi.sotemindit.astori.repository.TuoteRepository;
import fi.sotemindit.astori.repository.KayttajaRepository;
import jakarta.servlet.http.HttpSession;

@Controller
public class AsetuksetController {

    @Autowired
    private TuoteRepository tuoteRepository;

    @Autowired
    private KayttajaRepository kayttajaRepository;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    // 1. REITTI: Näyttää asetussivun ja listaa tuotteet sekä käyttäjät
    @GetMapping("/asetukset")
    public String naytaAsetukset(HttpSession session, Model model) {
        String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
        if (istuntoTunnus == null) {
            return "redirect:/login";
        }
        
        List<Tuote> tuotteet = tuoteRepository.findAll();
        List<Kayttaja> kayttajat = kayttajaRepository.findAll(); // Haetaan käyttäjälista
        
        model.addAttribute("tuotteet", tuotteet);
        model.addAttribute("kayttajat", kayttajat);
        
        return "asetukset"; // Avaa asetukset.jsp
    }

    // 2. REITTI: Näyttää tuotteen lisäyslomakkeen omalla sivullaan
    @GetMapping("/asetukset/uusi")
    public String naytaLisaaTuoteSivu(HttpSession session) {
        String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
        if (istuntoTunnus == null) {
            return "redirect:/login";
        }
        return "lisaa-tuote";
    }

    // 3. REITTI: Ottaa vastaan tuotteen tiedot ja tallentaa ne
    @PostMapping("/asetukset/lisaa-tuote")
    public String lisaaTuote(HttpSession session,
                             @RequestParam String nimi,
                             @RequestParam String kuvaus,
                             @RequestParam BigDecimal hinta,
                             @RequestParam TuoteYksikko yksikko) {
        String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
        if (istuntoTunnus == null) {
            return "redirect:/login";
        }

        Tuote uusiTuote = new Tuote(nimi, kuvaus, hinta, yksikko);
        tuoteRepository.save(uusiTuote);

        return "redirect:/asetukset";
    }

    // 4. REITTI: Ottaa vastaan uuden käyttäjän tiedot ja tallentaa ne turvallisesti
    @PostMapping("/asetukset/lisaa-kayttaja")
    public String lisaaKayttaja(HttpSession session,
                                @RequestParam String tunnus,
                                @RequestParam String salasana,
                                @RequestParam String etunimi,
                                @RequestParam String sukunimi,
                                @RequestParam String sahkoposti,
                                @RequestParam String puhelin,
                                Model model) {
        String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
        if (istuntoTunnus == null) {
            return "redirect:/login";
        }

        // Varmistetaan, ettei tunnus ole jo varattu
        if (kayttajaRepository.findByKayttajatunnus(tunnus).isPresent()) {
            return "redirect:/asetukset?virhe=tunnus_varattu";
        }

        // Kryptataan salasana ennen tallennusta
        String suojattuSalasana = passwordEncoder.encode(salasana);
        
        Kayttaja uusiKayttaja = new Kayttaja(tunnus, suojattuSalasana, etunimi, sukunimi, sahkoposti, puhelin);
        kayttajaRepository.save(uusiKayttaja);

        return "redirect:/asetukset";
    }
}
