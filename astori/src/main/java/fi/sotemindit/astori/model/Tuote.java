package fi.sotemindit.astori.model;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.math.RoundingMode;

@Entity
@Table(name = "tuotteet")
public class Tuote {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String nimi;

    private String kuvaus;

    @Column(nullable = false)
    private BigDecimal hinta;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TuoteYksikko yksikko = TuoteYksikko.KPL;

    // UUSI KENTTÄ: Kytketty luomaamme AlvKanta-enumiin
    @Enumerated(EnumType.STRING)
    @Column(name = "alv_kanta", nullable = false)
    private AlvKanta alvKanta = AlvKanta.ALV_25_5;

    public Tuote() {}

    // Alkuperäinen konstruktori (asettaa oletuksena 25.5 % ALV:n)
    public Tuote(String nimi, String kuvaus, BigDecimal hinta, TuoteYksikko yksikko) {
        this.nimi = nimi;
        this.kuvaus = kuvaus;
        this.hinta = hinta;
        this.yksikko = yksikko;
        this.alvKanta = AlvKanta.ALV_25_5;
    }

    // Uusi konstruktori, jolla ALV-kannan voi määrittää suoraan tuotetta luodessa
    public Tuote(String nimi, String kuvaus, BigDecimal hinta, TuoteYksikko yksikko, AlvKanta alvKanta) {
        this.nimi = nimi;
        this.kuvaus = kuvaus;
        this.hinta = hinta;
        this.yksikko = yksikko;
        this.alvKanta = alvKanta;
    }

    // APUMETODI: Laskee tuotteen verollisen hinnan tämän tuotteen ALV-kannan mukaan
    public BigDecimal getVerollinenHinta() {
        if (hinta == null) return BigDecimal.ZERO;
        BigDecimal prosentti = alvKanta.getProsentti();
        // Kerroin = 1 + (prosentti / 100) -> esim. 1 + 0.255 = 1.255
        BigDecimal kerroin = BigDecimal.ONE.add(prosentti.divide(new BigDecimal("100"), 4, RoundingMode.HALF_UP));
        return hinta.multiply(kerroin).setScale(2, RoundingMode.HALF_UP);
    }

    // Getterit ja setterit
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNimi() { return nimi; }
    public void setNimi(String nimi) { this.nimi = nimi; }
    public String getKuvaus() { return kuvaus; }
    public void setKuvaus(String kuvaus) { this.kuvaus = kuvaus; }
    public BigDecimal getHinta() { return hinta; }
    public void setHinta(BigDecimal hinta) { this.hinta = hinta; }
    public TuoteYksikko getYksikko() { return yksikko; }
    public void setYksikko(TuoteYksikko yksikko) { this.yksikko = yksikko; }
    
    public AlvKanta getAlvKanta() { return alvKanta; }
    public void setAlvKanta(AlvKanta alvKanta) { this.alvKanta = alvKanta; }
}
