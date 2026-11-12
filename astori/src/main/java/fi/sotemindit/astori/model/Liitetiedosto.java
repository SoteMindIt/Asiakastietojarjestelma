package fi.sotemindit.astori.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "liitetiedostot")
public class Liitetiedosto {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@Column(nullable = false)
	private String tiedostonNimi;

	private String kuvaus;

    @jakarta.persistence.Column(name = "data", columnDefinition = "bytea", nullable = false)
    private byte[] data;

	@Column(columnDefinition = "TEXT")
	private String sopimusTiedot;

	private String palveluntarjoajanNimi;
	private String palveluntarjoajanYTunnus;
	private String palveluntarjoajanOsoite;
	private String asiakkaanNimi;
	private String asiakkaanYTunnus;
	private String asiakkaanOsoite;

	@Column(columnDefinition = "TEXT")
	private String sopimuksenKohdeJaSisalto;

	@Column(columnDefinition = "TEXT")
	private String hintaJaMaksuehdot;

	private java.time.LocalDate sopimuksenAloituspaiva;
	private String palveluntarjoajanEdustaja;
	private String asiakkaanEdustaja;
	private Boolean sahkoinenAllekirjoitus;

	private LocalDateTime latausaika = LocalDateTime.now();

	@ManyToOne
	@JoinColumn(name = "asiakas_id", nullable = false)
	private Asiakas asiakas;

	public Liitetiedosto() {
	}

	public Liitetiedosto(String tiedostonNimi, String kuvaus, byte[] data, Asiakas asiakas) {
		this.tiedostonNimi = tiedostonNimi;
		this.kuvaus = kuvaus;
		this.data = data;
		this.asiakas = asiakas;
	}

	// Getterit ja Setterit
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getTiedostonNimi() {
		return tiedostonNimi;
	}

	public void setTiedostonNimi(String tiedostonNimi) {
		this.tiedostonNimi = tiedostonNimi;
	}

	public String getKuvaus() {
		return kuvaus;
	}

	public void setKuvaus(String kuvaus) {
		this.kuvaus = kuvaus;
	}

	public byte[] getData() {
		return data;
	}

	public void setData(byte[] data) {
		this.data = data;
	}

	public String getSopimusTiedot() {
		return sopimusTiedot;
	}

	public void setSopimusTiedot(String sopimusTiedot) {
		this.sopimusTiedot = sopimusTiedot;
	}

	public String getPalveluntarjoajanNimi() { return palveluntarjoajanNimi; }
	public void setPalveluntarjoajanNimi(String nimi) { this.palveluntarjoajanNimi = nimi; }
	public String getPalveluntarjoajanYTunnus() { return palveluntarjoajanYTunnus; }
	public void setPalveluntarjoajanYTunnus(String tunnus) { this.palveluntarjoajanYTunnus = tunnus; }
	public String getPalveluntarjoajanOsoite() { return palveluntarjoajanOsoite; }
	public void setPalveluntarjoajanOsoite(String osoite) { this.palveluntarjoajanOsoite = osoite; }
	public String getAsiakkaanNimi() { return asiakkaanNimi; }
	public void setAsiakkaanNimi(String nimi) { this.asiakkaanNimi = nimi; }
	public String getAsiakkaanYTunnus() { return asiakkaanYTunnus; }
	public void setAsiakkaanYTunnus(String tunnus) { this.asiakkaanYTunnus = tunnus; }
	public String getAsiakkaanOsoite() { return asiakkaanOsoite; }
	public void setAsiakkaanOsoite(String osoite) { this.asiakkaanOsoite = osoite; }
	public String getSopimuksenKohdeJaSisalto() { return sopimuksenKohdeJaSisalto; }
	public void setSopimuksenKohdeJaSisalto(String sisalto) { this.sopimuksenKohdeJaSisalto = sisalto; }
	public String getHintaJaMaksuehdot() { return hintaJaMaksuehdot; }
	public void setHintaJaMaksuehdot(String ehdot) { this.hintaJaMaksuehdot = ehdot; }
	public java.time.LocalDate getSopimuksenAloituspaiva() { return sopimuksenAloituspaiva; }
	public void setSopimuksenAloituspaiva(java.time.LocalDate paiva) { this.sopimuksenAloituspaiva = paiva; }
	public String getPalveluntarjoajanEdustaja() { return palveluntarjoajanEdustaja; }
	public void setPalveluntarjoajanEdustaja(String edustaja) { this.palveluntarjoajanEdustaja = edustaja; }
	public String getAsiakkaanEdustaja() { return asiakkaanEdustaja; }
	public void setAsiakkaanEdustaja(String edustaja) { this.asiakkaanEdustaja = edustaja; }
	public Boolean getSahkoinenAllekirjoitus() { return sahkoinenAllekirjoitus; }
	public void setSahkoinenAllekirjoitus(Boolean sahkoinen) { this.sahkoinenAllekirjoitus = sahkoinen; }

	public boolean hasSopimustiedot() {
		return palveluntarjoajanNimi != null;
	}

	public LocalDateTime getLatausaika() {
		return latausaika;
	}

	public void setLatausaika(LocalDateTime latausaika) {
		this.latausaika = latausaika;
	}

	public Asiakas getAsiakas() {
		return asiakas;
	}

	public void setAsiakas(Asiakas asiakas) {
		this.asiakas = asiakas;
	}
}
