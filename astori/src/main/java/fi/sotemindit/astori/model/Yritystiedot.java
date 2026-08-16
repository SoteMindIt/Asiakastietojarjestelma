package fi.sotemindit.astori.model;

import jakarta.persistence.*;

@Entity
@Table(name = "yritystiedot")
public class Yritystiedot {

    @Id
    private Long id = 1L; // Kiinteä ID, jotta rivejä on aina tasan yksi

    private String nimi;
    private String yTunnus;
    private String sahkoposti;
    private String puhelin;
    private String osoite;
    private String iban;
    private String bic;

    public Yritystiedot() {}

    public Yritystiedot(String nimi, String yTunnus, String sahkoposti, String puhelin, String osoite, String iban, String bic) {
        this.nimi = nimi;
        this.yTunnus = yTunnus;
        this.sahkoposti = sahkoposti;
        this.puhelin = puhelin;
        this.osoite = osoite;
        this.iban = iban;
        this.bic = bic;
    }

    // Getterit ja setterit
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNimi() { return nimi; }
    public void setNimi(String nimi) { this.nimi = nimi; }
    public String getyTunnus() { return yTunnus; }
    public void setyTunnus(String yTunnus) { this.yTunnus = yTunnus; }
    public String getSahkoposti() { return sahkoposti; }
    public void setSahkoposti(String sahkoposti) { this.sahkoposti = sahkoposti; }
    public String getPuhelin() { return puhelin; }
    public void setPuhelin(String puhelin) { this.puhelin = puhelin; }
    public String getOsoite() { return osoite; }
    public void setOsoite(String osoite) { this.osoite = osoite; }
    public String getIban() { return iban; }
    public void setIban(String iban) { this.iban = iban; }
    public String getBic() { return bic; }
    public void setBic(String bic) { this.bic = bic; }
}
