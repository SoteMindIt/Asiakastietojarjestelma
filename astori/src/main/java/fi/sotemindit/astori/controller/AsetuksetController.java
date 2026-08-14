package fi.sotemindit.astori.controller;

import java.math.BigDecimal;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import fi.sotemindit.astori.model.Tuote;
import fi.sotemindit.astori.model.TuoteYksikko;
import fi.sotemindit.astori.repository.TuoteRepository;
import jakarta.servlet.http.HttpSession;

@Controller
public class AsetuksetController {

    @Autowired
    private TuoteRepository tuoteRepository;

    // Näytetään asetussivu, jossa listataan tuotteet
    @GetMapping("/asetukset")
    public String naytaAsetukset(HttpSession session, Model model) {
        String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
        if (istuntoTunnus == null) {
            return "redirect:/login";
        }

        List<Tuote> tuotteet = tuoteRepository.findAll();
        model.addAttribute("tuotteet", tuotteet);
        return "asetukset"; // Etsii asetukset.jsp -näkymää
    }

    // Lisätään uusi tuote asetuksista käsin yksikön kanssa
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
}
