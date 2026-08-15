package fi.sotemindit.astori.model;

public enum TapahtumaTyyppi {
    PUHELU("Puhelu"),
    TAPAAMINEN("Tapaaminen"),
    ETAKOKOUS("Etäkokous"),
    MUU("Muu tehtävä");

    private final String nayttorivi;

    TapahtumaTyyppi(String nayttorivi) {
        this.nayttorivi = nayttorivi;
    }

    public String getNayttorivi() {
        return nayttorivi;
    }
}