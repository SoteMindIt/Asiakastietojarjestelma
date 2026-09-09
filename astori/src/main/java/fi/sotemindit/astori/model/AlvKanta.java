package fi.sotemindit.astori.model;

public enum AlvKanta {
    ALV_25_5("25.5", "25,5 % (Yleinen verokanta)"),
    ALV_14("14.0", "14 % (Elintarvikkeet ja ravintolat)"),
    ALV_10("10.0", "10 % (Kirjat, lääkkeet, majoitus)"),
    ALV_0("0.0", "0 % (Veroton / Käänteinen ALV)");

    private final String prosenttiStr;
    private final String nayttorivi;

    private AlvKanta(String prosenttiStr, String nayttorivi) {
        this.prosenttiStr = prosenttiStr;
        this.nayttorivi = nayttorivi;
    }

    public String getProsenttiStr() {
        return prosenttiStr;
    }

    public String getNayttorivi() {
        return nayttorivi;
    }

    // Hyödyllinen apumetodi BigDecimal-muunnosta varten laskennoissa
    public java.math.BigDecimal getProsentti() {
        return new java.math.BigDecimal(prosenttiStr);
    }
}
