package fi.sotemindit.astori.model;

import jakarta.persistence.*;

@Entity
@Table(name = "tapahtuma_tyypit")
public class TapahtumaTyyppi {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String nimi; // Selkokielinen nimi, esim. "Etäkokous", "Puhelu"

    public TapahtumaTyyppi() {}

    public TapahtumaTyyppi(String nimi) {
        this.nimi = nimi;
    }

    // Getterit ja Setterit
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNimi() { return nimi; }
    public void setNimi(String nimi) { this.nimi = nimi; }
    
    // Jätetään tämä väliaikaisesti, jos jokin JSP-sivu kutsuu vielä vanhaa nimeä
    public String getNayttorivi() { return nimi; } 
}
