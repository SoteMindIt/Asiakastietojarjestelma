package fi.sotemindit.astori.model;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "asiakkaat")
public class Asiakas {

	@Id
	@GeneratedValue(strategy = jakarta.persistence.GenerationType.IDENTITY)
	private Long id;

	private String nimi;
	private String sahkoposti;
	private String puhelin;

	// UUSI REKISTERI: Tila
	@jakarta.persistence.Enumerated(jakarta.persistence.EnumType.STRING)
	private AsiakkaanTila tila = AsiakkaanTila.PROSPEKTI;

	// KORJATTU JA ENERGINEN KÄYTTÄJÄRELAATIO:
	@jakarta.persistence.ManyToOne
	@jakarta.persistence.JoinColumn(name = "kayttaja_id", nullable = true)
	private Kayttaja kayttaja;
	
    @jakarta.persistence.OneToMany(mappedBy = "asiakas", cascade = jakarta.persistence.CascadeType.ALL, orphanRemoval = true)
    private java.util.List<Tapahtuma> tapahtumat;


	// CASCADE-OMINAISUUDET POISTOA VARTEN:
	@jakarta.persistence.OneToMany(mappedBy = "asiakas", cascade = jakarta.persistence.CascadeType.ALL, orphanRemoval = true)
	private java.util.List<Yhteyshenkilo> yhteyshenkilot;

	@jakarta.persistence.OneToMany(mappedBy = "asiakas", cascade = jakarta.persistence.CascadeType.ALL, orphanRemoval = true)
	private java.util.List<Kirjaus> kirjaukset;

	@jakarta.persistence.OneToMany(mappedBy = "asiakas", cascade = jakarta.persistence.CascadeType.ALL, orphanRemoval = true)
	private java.util.List<AsiakasTuote> ostetutTuotteet;

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
