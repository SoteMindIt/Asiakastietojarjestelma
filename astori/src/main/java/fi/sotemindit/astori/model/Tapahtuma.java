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
	
	private LocalDateTime loppuaika;
	
	@Column(nullable = false)
	private LocalDateTime ajankohta;
	
	@ManyToOne
	@JoinColumn(name = "tyyppi_id", nullable = false)
	private TapahtumaTyyppi tyyppi;
	
	@ManyToOne
	@JoinColumn(name = "asiakas_id", nullable = true)
	private Asiakas asiakas;
	
	@ManyToOne
	@JoinColumn(name = "kayttaja_id", nullable = false)
	private Kayttaja kayttaja;

	public Tapahtuma() {
	}// PÄIVITETTY KONSTRUKTORI: Sisältää nyt myös loppuajan siistejä lennosta
		// tehtyjä luonteja varten

	public Tapahtuma(String otsikko, String kuvaus, LocalDateTime ajankohta, LocalDateTime loppuaika,
			TapahtumaTyyppi tyyppi, Asiakas asiakas, Kayttaja kayttaja) {
		this.otsikko = otsikko;
		this.kuvaus = kuvaus;
		this.ajankohta = ajankohta;
		this.loppuaika = loppuaika;
		this.tyyppi = tyyppi;
		this.asiakas = asiakas;
		this.kayttaja = kayttaja;
	}// Getterit ja Setterit

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getOtsikko() {
		return otsikko;
	}

	public void setOtsikko(String otsikko) {
		this.otsikko = otsikko;
	}

	public String getKuvaus() {
		return kuvaus;
	}

	public void setKuvaus(String kuvaus) {
		this.kuvaus = kuvaus;
	}

	public LocalDateTime getLoppuaika() {
		return loppuaika;
	}

	public void setLoppuaika(LocalDateTime loppuaika) {
		this.loppuaika = loppuaika;
	}

	public LocalDateTime getAjankohta() {
		return ajankohta;
	}

	public void setAjankohta(LocalDateTime ajankohta) {
		this.ajankohta = ajankohta;
	}

	public TapahtumaTyyppi getTyyppi() {
		return tyyppi;
	}

	public void setTyyppi(TapahtumaTyyppi tyyppi) {
		this.tyyppi = tyyppi;
	}

	public Asiakas getAsiakas() {
		return asiakas;
	}

	public void setAsiakas(Asiakas asiakas) {
		this.asiakas = asiakas;
	}

	public Kayttaja getKayttaja() {
		return kayttaja;
	}

	public void setKayttaja(Kayttaja kayttaja) {
		this.kayttaja = kayttaja;
	}
}