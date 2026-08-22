package fi.sotemindit.astori.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "loki")
public class Loki {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private LocalDateTime aikaleima;

    @Column(nullable = false)
    private String kayttajatunnus;

    @Column(nullable = false)
    private String toiminto; // esim. "KATSELU", "LISÄYS", "MUOKKAUS", "POISTO"

    @Column(columnDefinition = "TEXT")
    private String kuvaus; // Tarkempi tieto, esim. "Katseltu asiakkaan Juho Ström (ID: 12) profiilia"

    // Tyhjä konstruktori JPA:ta varten
    public Loki() {}

    // Kätevä konstruktori käyttöä varten
    public Loki(String kayttajatunnus, String toiminto, String kuvaus) {
        this.aikaleima = LocalDateTime.now();
        this.kayttajatunnus = kayttajatunnus;
        this.toiminto = toiminto;
        this.kuvaus = kuvaus;
    }

    // Getterit ja Setterit
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public LocalDateTime getAikaleima() { return aikaleima; }
    public void setAikaleima(LocalDateTime aikaleima) { this.aikaleima = aikaleima; }
    public String getKayttajatunnus() { return kayttajatunnus; }
    public void setKayttajatunnus(String kayttajatunnus) { this.kayttajatunnus = kayttajatunnus; }
    public String getToiminto() { return toiminto; }
    public void setToiminto(String toiminto) { this.toiminto = toiminto; }
    public String getKuvaus() { return kuvaus; }
    public void setKuvaus(String kuvaus) { this.kuvaus = kuvaus; }
}
