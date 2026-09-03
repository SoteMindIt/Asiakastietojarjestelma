package fi.sotemindit.astori.model;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Column;
import jakarta.persistence.Enumerated;
import jakarta.persistence.EnumType;

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

	// UUSI: Asiakkaan tila tallennetaan tietokantaan tekstimuodossa (esim.
	// 'PROSPEKTI')
	@Enumerated(EnumType.STRING)
	@Column(nullable = false)
	private AsiakkaanTila tila = AsiakkaanTila.PROSPEKTI; // Oletuksena uusi asiakas on Prospekti

	// Lisää tämä muiden muuttujien joukkoon (esim. tilan alapuolelle)
	@jakarta.persistence.ManyToOne
	@jakarta.persistence.JoinColumn(name = "kayttaja_id")
	private Kayttaja kayttaja;

	@Column(name = "y_tunnus", length = 9) // Suomalainen Y-tunnus on aina 9 merkkiä (esim. 1234567-8)
	private String yTunnus;

	@jakarta.persistence.Column(columnDefinition = "TEXT") // 💡 LISÄTTY: Sallii rajattoman määrän tekstiä tietokantaan
	private String kuvaus;

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
		// Jos lomakkeelta tulisi tyhjä arvo, se asettuu turvallisesti nulliksi
		this.hyvinvointialue = hyvinvointialue;
	}
}
