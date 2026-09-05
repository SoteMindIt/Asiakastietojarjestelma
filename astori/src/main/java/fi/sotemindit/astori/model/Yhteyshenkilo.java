package fi.sotemindit.astori.model;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import fi.sotemindit.astori.model.Palveluyksikko;

@Entity
@Table(name = "yhteyshenkilot")
public class Yhteyshenkilo {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	private String nimi;
	private String rooli;
	private String sahkoposti;
	private String puhelin;

	// Relaatio: Monta yhteyshenkilöä voi kuulua yhdelle asiakkaalle
	@ManyToOne
	@JoinColumn(name = "asiakas_id", nullable = false)
	private Asiakas asiakas;

	// Relaatio: Monta yhteyshenkilöä voi kuulua yhdelle palveluyksikölle
	@ManyToOne
	@JoinColumn(name = "palveluyksikko_id", nullable = true)
	private Palveluyksikko palveluyksikko;

	public Yhteyshenkilo() {
	}

	 // 1. KORJATTU 5-ARGUMENTTINEN KONSTRUKTORI: Vastaa täsmälleen kontrollerin kutsua
    public Yhteyshenkilo(String nimi, String rooli, String sahkoposti, String puhelin, Asiakas asiakas) {
        this.nimi = nimi;
        this.rooli = rooli;
        this.sahkoposti = sahkoposti;
        this.puhelin = puhelin;
        this.asiakas = asiakas;
        this.palveluyksikko = null; // Yleinen organisaatiotason kontakti
    }

    // 2. KORJATTU 6-ARGUMENTTINEN KONSTRUKTORI: Mukana myös palveluyksikkö
    public Yhteyshenkilo(String nimi, String rooli, String sahkoposti, String puhelin, Asiakas asiakas, Palveluyksikko palveluyksikko) {
        this.nimi = nimi;
        this.rooli = rooli;
        this.sahkoposti = sahkoposti;
        this.puhelin = puhelin;
        this.asiakas = asiakas;
        this.palveluyksikko = palveluyksikko;
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

	public String getRooli() {
		return rooli;
	}

	public void setRooli(String rooli) {
		this.rooli = rooli;
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

	public Asiakas getAsiakas() {
		return asiakas;
	}

	public void setAsiakas(Asiakas asiakas) {
		this.asiakas = asiakas;
	}

	public Palveluyksikko getPalveluyksikko() {
		return palveluyksikko;
	}

	public void setPalveluyksikko(Palveluyksikko palveluyksikko) {
		this.palveluyksikko = palveluyksikko;
	}
}