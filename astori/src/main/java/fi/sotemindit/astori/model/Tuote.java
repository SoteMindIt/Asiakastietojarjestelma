package fi.sotemindit.astori.model;

import jakarta.persistence.*;
import java.math.BigDecimal;

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
    private BigDecimal hinta; // Rekisterin oletushinta

    public Tuote() {}

    public Tuote(String nimi, String kuvaus, BigDecimal hinta) {
        this.nimi = nimi;
        this.kuvaus = kuvaus;
        this.hinta = hinta;
    }

    // Getterit ja Setterit
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNimi() { return nimi; }
    public void setNimi(String nimi) { this.nimi = nimi; }
    public String getKuvaus() { return kuvaus; }
    public void setKuvaus(String kuvaus) { this.kuvaus = kuvaus; }
    public BigDecimal getHinta() { return hinta; }
    public void setHinta(BigDecimal hinta) { this.hinta = hinta; }
}
