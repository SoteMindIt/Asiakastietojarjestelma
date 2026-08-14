package fi.sotemindit.astori.model;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "asiakas_tuotteet")
public class AsiakasTuote {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "asiakas_id", nullable = false)
    private Asiakas asiakas;

    @ManyToOne
    @JoinColumn(name = "tuote_id", nullable = false)
    private Tuote tuote;

    @Column(nullable = false)
    private BigDecimal myyntihinta; // Yksikköhinta myyntihetkellä

    @Column(nullable = false)
    private Integer maara = 1; // UUSI KENTTÄ: Myyty määrä (oletus 1)

    private LocalDateTime myyntiaika = LocalDateTime.now();

    public AsiakasTuote() {}

    public AsiakasTuote(Asiakas asiakas, Tuote tuote, BigDecimal myyntihinta, Integer maara) {
        this.asiakas = asiakas;
        this.tuote = tuote;
        this.myyntihinta = myyntihinta;
        this.maara = maara;
    }

    // Apu-metodi laskemaan rivin kokonaishinnan (Hinta x Määrä) raportteja varten
    public BigDecimal getKokonaishinta() {
        return this.myyntihinta.multiply(new BigDecimal(this.maara));
    }

    // Getterit ja Setterit
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Asiakas getAsiakas() { return asiakas; }
    public void setAsiakas(Asiakas asiakas) { this.asiakas = asiakas; }
    public Tuote getTuote() { return tuote; }
    public void setTuote(Tuote tuote) { this.tuote = tuote; }
    public BigDecimal getMyyntihinta() { return myyntihinta; }
    public void setMyyntihinta(BigDecimal myyntihinta) { this.myyntihinta = myyntihinta; }
    public Integer getMaara() { return maara; }
    public void setMaara(Integer maara) { this.maara = maara; }
    public LocalDateTime getMyyntiaika() { return myyntiaika; }
    public void setMyyntiaika(LocalDateTime myyntiaika) { this.myyntiaika = myyntiaika; }
}
