package fi.sotemindit.astori.model;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "asiakkaat") // Määrittää tietokantataulun nimeksi "asiakkaat"
public class Asiakas {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) // Automaattisesti kasvava ID (Serial)
    private Long id;

    private String nimi;
    private String sahkoposti;
    private String puhelin;
    
    @jakarta.persistence.ManyToOne
    @jakarta.persistence.JoinColumn(name = "kayttaja_id", nullable = true) // nullable=true sallii vanhat asiakkaat ilman käyttäjää aluksi
    private Kayttaja kayttaja;

    // Tyhjä konstruktori (pakollinen JPA:ta varten)
    public Asiakas() {
    }

    // Konstruktori helpottamaan uusien asiakkaiden luontia
    public Asiakas(String nimi, String sahkoposti, String puhelin) {
        this.nimi = nimi;
        this.sahkoposti = sahkoposti;
        this.puhelin = puhelin;
    }

    // Getterit ja Setterit (Eclipse osaa luoda nämä myös automaattisesti Source -> Generate Getters and Setters)
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getNimi() {
        return nimi;
    }

    public void setNimi(String nimi) {
        this.nimi = nimi;
    }

    public String getSahkoposti() {
        return sahkoposti;
    }

    public void setSahkoposti(String sahkoposti) {
        this.sahkoposti = sahkoposti;
    }

    public String getPuhelin() {
        return puhelin;
    }

    public void setPuhelin(String puhelin) {
        this.puhelin = puhelin;
    }
    public Kayttaja getKayttaja() {
        return kayttaja;
    }

    public void setKayttaja(Kayttaja kayttaja) {
        this.kayttaja = kayttaja;
    }
}