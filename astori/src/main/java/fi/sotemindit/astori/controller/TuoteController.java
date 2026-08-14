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
import fi.sotemindit.astori.repository.TuoteRepository;
import jakarta.servlet.http.HttpSession;

@Controller
public class TuoteController {

    @Autowired
    private TuoteRepository tuoteRepository;

    // 1. LISTAA TUOTTEET: Näyttää tuoterekisterin pääsivun
    @GetMapping("/tuotteet")
    public String listaaTuotteet(HttpSession session, Model model) {
        String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
        if (istuntoTunnus == null) {
            return "redirect:/login"; // Pakotetaan kirjautumaan sisään tietoturvan vuoksi
        }

        List<Tuote> tuotteet = tuoteRepository.findAll();
        model.addAttribute("tuotteet", tuotteet);
        return "tuotteet"; // Etsii tuotteet.jsp -näkymää
    }

    // 2. LISÄÄ TUOTE: Tallentaa uuden tuotteen tai palvelun hintoineen
    @PostMapping("/lisaa-tuote")
    public String lisaaTuote(HttpSession session,
                             @RequestParam String nimi,
                             @RequestParam String kuvaus,
                             @RequestParam BigDecimal hinta) {
        String istuntoTunnus = (String) session.getAttribute("kirjautunutKayttaja");
        if (istuntoTunnus == null) {
            return "redirect:/login";
        }

        Tuote uusiTuote = new Tuote(nimi, kuvaus, hinta);
        tuoteRepository.save(uusiTuote);

        return "redirect:/tuotteet"; // Palataan takaisin tuotelistaussivulle
    }
}

