package fi.sotemindit.astori.model;

import jakarta.persistence.*;

@Entity
@Table(name = "palveluyksikot")
public class Palveluyksikko {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String nimi;

    private String katuosoite;
    private String postinumero;
    private String postitoimipaikka;
    private String puhelin;
    private String sahkoposti;
    
    @Column(columnDefinition = "TEXT")
    private String kuvaus;

    // 💡 LISÄTTY: Palveluyksiköllä voi olla oma, pääyksiköstä eroava hyvinvointialueensa
    @Enumerated(EnumType.STRING)
    private Hyvinvointialue hyvinvointialue;

    // Relaatio: Palveluyksikkö kuuluu aina tiettyyn pääasiakkaaseen (toimintayksikköön)
    @ManyToOne
    @JoinColumn(name = "asiakas_id", nullable = false)
    private Asiakas asiakas;

    public Palveluyksikko() {}

    public Palveluyksikko(String nimi, String katuosoite, String postinumero, String postitoimipaikka, 
                          String puhelin, String sahkoposti, String kuvaus, Hyvinvointialue hyvinvointialue, Asiakas asiakas
                          ) {
        this.nimi = nimi;
        this.katuosoite = katuosoite;
        this.postinumero = postinumero;
        this.postitoimipaikka = postitoimipaikka;
        this.puhelin = puhelin;
        this.sahkoposti = sahkoposti;
        this.kuvaus = kuvaus;
        this.hyvinvointialue = hyvinvointialue;
        this.asiakas = asiakas;
        
    }

    // Getterit ja Setterit
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNimi() { return nimi; }
    public void setNimi(String nimi) { this.nimi = nimi; }
    public String getKatuosoite() { return katuosoite; }
    public void setKatuosoite(String katuosoite) { this.katuosoite = katuosoite; }
    public String getPostinumero() { return postinumero; }
    public void setPostinumero(String postinumero) { this.postinumero = postinumero; }
    public String getPostitoimipaikka() { return postitoimipaikka; }
    public void setPostitoimipaikka(String postitoimipaikka) { this.postitoimipaikka = postitoimipaikka; }
    public String getPuhelin() { return puhelin; }
    public void setPuhelin(String puhelin) { this.puhelin = puhelin; }
    public String getSahkoposti() { return sahkoposti; }
    public void setSahkoposti(String sahkoposti) { this.sahkoposti = sahkoposti; }
    public String getKuvaus() { return kuvaus; }
    public void setKuvaus(String kuvaus) { this.kuvaus = kuvaus; }
    public Hyvinvointialue getHyvinvointialue() { return hyvinvointialue; }
    public void setHyvinvointialue(Hyvinvointialue hyvinvointialue) { this.hyvinvointialue = hyvinvointialue; }
    public Asiakas getAsiakas() { return asiakas; }
    public void setAsiakas(Asiakas asiakas) { this.asiakas = asiakas; }
    
}
