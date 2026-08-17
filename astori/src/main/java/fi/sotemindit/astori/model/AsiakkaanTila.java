package fi.sotemindit.astori.model;

public enum AsiakkaanTila {
    PROSPEKTI("Prospekti (Potentiaalinen)"),
    KONTAKTOITU("Kontaktoitu / Keskustelussa"),
    TARJOUS_JATETTY("Tarjous jätetty"),
    AKTIIVINEN("Aktiivinen asiakas"),
    PAATTYNYT("Yhteistyö päättynyt");

    private final String nayttorivi;

    private AsiakkaanTila(String nayttorivi) {
        this.nayttorivi = nayttorivi;
    }

    public String getNayttorivi() {
        return nayttorivi;
    }
}
