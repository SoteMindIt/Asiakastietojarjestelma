package fi.sotemindit.astori.model;

public enum TapahtumaTyyppi {
    PUHELU("Puhelu"),
    TAPAAMINEN("Tapaaminen"),
    KOULUTUS("Koulutus"),
    ETAPALAVERI("Etäpalaveri"),
    ETAKOULUTUS("Etäkoulutus"),
    MUU("Muu tehtävä");

    private final String nayttorivi;

    TapahtumaTyyppi(String nayttorivi) {
        this.nayttorivi = nayttorivi;
    }

    public String getNayttorivi() {
        return nayttorivi;
    }
}