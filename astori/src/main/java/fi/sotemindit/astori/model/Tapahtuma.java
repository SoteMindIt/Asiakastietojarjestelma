package fi.sotemindit.astori.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "tapahtumat")
public class Tapahtuma {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String otsikko;

    private String kuvaus;

    @Column(nullable = false)
    private LocalDateTime ajankohta;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TapahtumaTyyppi tyyppi = TapahtumaTyyppi.TAPAAMINEN;

    @ManyToOne
    @JoinColumn(name = "asiakas_id", nullable = false)
    private Asiakas asiakas;

    public Tapahtuma() {}

    public Tapahtuma(String otsikko, String kuvaus, LocalDateTime ajankohta, TapahtumaTyyppi tyyppi, Asiakas asiakas) {
        this.otsikko = otsikko;
        this.kuvaus = kuvaus;
        this.ajankohta = ajankohta;
        this.tyyppi = tyyppi;
        this.asiakas = asiakas;
    }

    // Getterit ja Setterit
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getOtsikko() { return otsikko; }
    public void setOtsikko(String otsikko) { this.otsikko = otsikko; }
    public String getKuvaus() { return kuvaus; }
    public void setKuvaus(String kuvaus) { this.kuvaus = kuvaus; }
    public LocalDateTime getAjankohta() { return ajankohta; }
    public void setAjankohta(LocalDateTime ajankohta) { this.ajankohta = ajankohta; }
    public TapahtumaTyyppi getTyyppi() { return tyyppi; }
    public void setTyyppi(TapahtumaTyyppi tyyppi) { this.tyyppi = tyyppi; }
    public Asiakas getAsiakas() { return asiakas; }
    public void setAsiakas(Asiakas asiakas) { this.asiakas = asiakas; }
}
