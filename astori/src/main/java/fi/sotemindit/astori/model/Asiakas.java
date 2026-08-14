package fi.sotemindit.astori.model;

import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "asiakkaat")
public class Asiakas {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nimi;
    private String sahkoposti;
    private String puhelin;
    
    // UUSI KENTTÄ: Tallentaa tilan tietokantaan tekstimuodossa (String)
    @Enumerated(EnumType.STRING)
    private AsiakkaanTila tila = AsiakkaanTila.PROSPEKTI; // Oletuksena uusi asiakas on Prospekti

    @jakarta.persistence.ManyToOne
    @jakarta.persistence.JoinColumn(name = "kayttaja_id", nullable = true)
    private Kayttaja kayttaja;

    public Asiakas() {
    }

    // Päivitetty konstruktori ottamaan vastaan myös tilan
    public Asiakas(String nimi, String sahkoposti, String puhelin, AsiakkaanTila tila) {
        this.nimi = nimi;
        this.sahkoposti = sahkoposti;
        this.puhelin = puhelin;
        this.tila = tila;
    }

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

    // UUDET GETTERIT JA SETTERIT TILALLE
    public AsiakkaanTila getTila() {
        return tila;
    }

    public void setTila(AsiakkaanTila tila) {
        this.tila = tila;
    }

    public Kayttaja getKayttaja() {
        return kayttaja;
    }

    public void setKayttaja(Kayttaja kayttaja) {
        this.kayttaja = kayttaja;
    }
}
