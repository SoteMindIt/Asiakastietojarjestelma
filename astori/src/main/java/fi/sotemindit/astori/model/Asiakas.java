package fi.sotemindit.astori.model;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Column;
import jakarta.persistence.Enumerated;
import jakarta.persistence.EnumType;
import jakarta.persistence.OneToMany;
import jakarta.persistence.CascadeType;

@Entity
@Table(name = "asiakkaat")
public class Asiakas {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@Column(nullable = false)
	private String nimi;

	private String puhelin;
	private String sahkoposti;
	private String katuosoite;
	private String postinumero;
	private String postitoimipaikka;
	private String kotisivu;

	@Enumerated(EnumType.STRING)
	private Hyvinvointialue hyvinvointialue;

	@Enumerated(EnumType.STRING)
	@Column(nullable = false)
	private AsiakkaanTila tila = AsiakkaanTila.PROSPEKTI;

	@jakarta.persistence.ManyToOne
	@jakarta.persistence.JoinColumn(name = "kayttaja_id")
	private Kayttaja kayttaja;

	@Column(name = "y_tunnus", length = 9)
	private String yTunnus;

	@jakarta.persistence.Column(columnDefinition = "TEXT")
	private String kuvaus;

	// 🛰️ UUTTA: Geokoodauksen koordinaatit kilometrihakua varten
	private Double leveysaste; // Latitude
	private Double pituusaste; // Longitude

	// ==================== RELAATIOT (Sisältävät automaattisen siivouksen poistoissa) ====================

	@OneToMany(mappedBy = "asiakas", cascade = CascadeType.ALL, orphanRemoval = true)
	private java.util.List<Palveluyksikko> palveluyksikot = new java.util.ArrayList<>();

	@OneToMany(mappedBy = "asiakas", cascade = CascadeType.ALL, orphanRemoval = true)
	private java.util.List<Yhteyshenkilo> yhteyshenkilot = new java.util.ArrayList<>();

	@OneToMany(mappedBy = "asiakas", cascade = CascadeType.ALL, orphanRemoval = true)
	private java.util.List<Kirjaus> kirjaukset = new java.util.ArrayList<>();

	@OneToMany(mappedBy = "asiakas", cascade = CascadeType.ALL, orphanRemoval = true)
	private java.util.List<Tarjous> tarjoukset = new java.util.ArrayList<>();


	// Tyhjä konstruktori JPA:ta varten
	public Asiakas() {
	}

	// Konstruktori helpottamaan olioiden luontia kehityksessä
	public Asiakas(String nimi, String puhelin, String sahkoposti, String katuosoite, String postinumero,
			String postitoimipaikka, String kotisivu, AsiakkaanTila tila, String yTunnus, String kuvaus,
			Hyvinvointialue hyvinvointialue) {
		this.nimi = nimi;
		this.puhelin = puhelin;
		this.sahkoposti = sahkoposti;
		this.katuosoite = katuosoite;
		this.postinumero = postinumero;
		this.postitoimipaikka = postitoimipaikka;
		this.kotisivu = kotisivu;
		this.tila = tila != null ? tila : AsiakkaanTila.PROSPEKTI;
		this.yTunnus = yTunnus;
		this.kuvaus = kuvaus;
		this.hyvinvointialue = hyvinvointialue;
	}

	// Getterit ja Setterit
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

	public String getPuhelin() {
		return puhelin;
	}

	public void setPuhelin(String puhelin) {
		this.puhelin = puhelin;
	}

	public String getSahkoposti() {
		return sahkoposti;
	}

	public void setSahkoposti(String sahkoposti) {
		this.sahkoposti = sahkoposti;
	}

	public String getKatuosoite() {
		return katuosoite;
	}

	public void setKatuosoite(String katuosoite) {
		this.katuosoite = katuosoite;
	}

	public String getPostinumero() {
		return postinumero;
	}

	public void setPostinumero(String postinumero) {
		this.postinumero = postinumero;
	}

	public String getPostitoimipaikka() {
		return postitoimipaikka;
	}

	public void setPostitoimipaikka(String postitoimipaikka) {
		this.postitoimipaikka = postitoimipaikka;
	}

	public String getKotisivu() {
		return kotisivu;
	}

	public void setKotisivu(String kotisivu) {
		this.kotisivu = kotisivu;
	}

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

	public String getyTunnus() {
		return this.yTunnus;
	}

	public void setyTunnus(String yTunnus) {
		this.yTunnus = yTunnus;
	}

	public String getKuvaus() {
		return this.kuvaus;
	}

	public void setKuvaus(String kuvaus) {
		this.kuvaus = kuvaus;
	}

	public Hyvinvointialue getHyvinvointialue() {
		return hyvinvointialue;
	}

	public void setHyvinvointialue(Hyvinvointialue hyvinvointialue) {
		this.hyvinvointialue = hyvinvointialue;
	}

	// 🛰️ UUDET GETTERIT JA SETTERIT KOORDINAATEILLE
	public Double getLeveysaste() {
		return leveysaste;
	}

	public void setLeveysaste(Double leveysaste) {
		this.leveysaste = leveysaste;
	}

	public Double getPituusaste() {
		return pituusaste;
	}

	public void setPituusaste(Double pituusaste) {
		this.pituusaste = pituusaste;
	}

	// RELAATIOIDEN GETTERIT JA SETTERIT
	public java.util.List<Palveluyksikko> getPalveluyksikot() {
		return palveluyksikot;
	}

	public void setPalveluyksikot(java.util.List<Palveluyksikko> palveluyksikot) {
		this.palveluyksikot = palveluyksikot;
	}

	public java.util.List<Yhteyshenkilo> getYhteyshenkilot() {
		return yhteyshenkilot;
	}

	public void setYhteyshenkilot(java.util.List<Yhteyshenkilo> yhteyshenkilot) {
		this.yhteyshenkilot = yhteyshenkilot;
	}

	public java.util.List<Kirjaus> getKirjaukset() {
		return kirjaukset;
	}

	public void setKirjaukset(java.util.List<Kirjaus> kirjaukset) {
		this.kirjaukset = kirjaukset;
	}

	public java.util.List<Tarjous> getTarjoukset() {
		return tarjoukset;
	}

	public void setTarjoukset(java.util.List<Tarjous> tarjoukset) {
		this.tarjoukset = tarjoukset;
	}
}
