package fi.sotemindit.astori.model;


public enum Hyvinvointialue {
    HELSINKI("Helsinki"),
    ITA_UUSIMAA("Itä-Uusimaa"),
    KESKI_UUSIMAA("Keski-Uusimaa"),
    LANSI_UUSIMAA("Länsi-Uusimaa"),
    VANTAA_KERAVA("Vantaa ja Kerava"),
    VARSINAIS_SUOMI("Varsinais-Suomi"),
    SATAKUNTA("Satakunta"),
    KANTA_HAME("Kanta-Häme"),
    PIRKANMAA("Pirkanmaa"),
    PAIJAT_HAME("Päijät-Häme"),
    KYMENLAAKSO("Kymenlaakso"),
    ETELA_KARJALA("Etelä-Karjala"),
    ETELA_SAVO("Etelä-Savo"),
    POHJOIS_SAVO("Pohjois-Savo"),
    POHJOIS_KARJALA("Pohjois-Karjala"),
    KESKI_SUOMI("Keski-Suomi"),
    ETELA_POHJANMAA("Etelä-Pohjanmaa"),
    POHJANMAA("Pohjanmaa"),
    KESKI_POHJANMAA("Keski-Pohjanmaa"),
    POHJOIS_POHJANMAA("Pohjois-Pohjanmaa"),
    KAINUU("Kainuu"),
    LAPPI("Lappi");

    private final String nimi;

    Hyvinvointialue(String nimi) {
        this.nimi = nimi;
    }

    public String getNimi() {
        return nimi;
    }
}