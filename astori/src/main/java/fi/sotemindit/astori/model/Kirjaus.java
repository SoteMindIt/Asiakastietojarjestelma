package fi.sotemindit.astori.model;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import jakarta.persistence.Column;

@Entity
@Table(name = "kirjaukset")
public class Kirjaus {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String teksti;
    private LocalDateTime luontiaika;

    // Relaatio: Monta kirjausta voi liittyä yhdelle asiakkaalle
    @ManyToOne
    @JoinColumn(name = "asiakas_id", nullable = false)
    private Asiakas asiakas;

    public Kirjaus() {}

    public Kirjaus(String teksti, Asiakas asiakas) {
        this.teksti = teksti;
        this.asiakas = asiakas;
        this.luontiaika = LocalDateTime.now(); // Asettaa automaattisesti nykyisen ajan
    }

    // Getterit ja Setterit
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getTeksti() { return teksti; }
    public void setTeksti(String teksti) { this.teksti = teksti; }
    public LocalDateTime getLuontiaika() { return luontiaika; }
    public void setLuontiaika(LocalDateTime luontiaika) { this.luontiaika = luontiaika; }
    public Asiakas getAsiakas() { return asiakas; }
    public void setAsiakas(Asiakas asiakas) { this.asiakas = asiakas; }
}
