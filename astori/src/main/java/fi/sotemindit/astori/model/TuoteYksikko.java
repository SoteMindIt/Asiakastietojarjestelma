package fi.sotemindit.astori.model;

public enum TuoteYksikko {
    KPL("kpl"), 
    TUNTI("tunti"), 
    KK("kk"), 
    PV("päivä"),
    KM("kilometriä"); 

    private final String lyhenne;

    TuoteYksikko(String lyhenne) {
        this.lyhenne = lyhenne;
    }

    public String getLyhenne() {
        return lyhenne;
    }
}

