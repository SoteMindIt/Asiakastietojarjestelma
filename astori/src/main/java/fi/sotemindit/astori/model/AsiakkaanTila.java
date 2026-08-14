package fi.sotemindit.astori.model;


public enum AsiakkaanTila {
    PROSPEKTI("Prospekti"),
    KONTAKTOITU("Kontaktoitu"),
    KAUPPA("Kauppa"),
    EI_KAUPPAA("Ei kauppaa");

    private final String nayttorivi;

    AsiakkaanTila(String nayttorivi) {
        this.nayttorivi = nayttorivi;
    }

    public String getNayttorivi() {
        return nayttorivi;
    }
}
