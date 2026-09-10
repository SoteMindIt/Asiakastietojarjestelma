package fi.sotemindit.astori.model;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;

@Entity
@Table(name = "asiakas_tuotteet")
public class AsiakasTuote {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@ManyToOne
	@JoinColumn(name = "asiakas_id", nullable = false)
	private Asiakas asiakas;

	@ManyToOne
	@JoinColumn(name = "tuote_id", nullable = false)
	private Tuote tuote;

	@Column(nullable = false)
	private BigDecimal myyntihinta; // Yksikköhinta myyntihetkellä

	@Column(nullable = false)
	private Integer maara = 1; // Myyty määrä (oletus 1)

	// Kytketään luomasi AlvKanta-enum tietokantaan merkkijonona. Oletus: ALV_25_5
	@Enumerated(EnumType.STRING)
	@Column(name = "alv_kanta", nullable = false)
	private AlvKanta alvKanta = AlvKanta.ALV_25_5;

	@Column(name = "ostopaivamaara", nullable = false)
	private java.time.LocalDate ostopaivamaara;

	private LocalDateTime myyntiaika = LocalDateTime.now();

	public AsiakasTuote() {
	}

	public AsiakasTuote(Asiakas asiakas, Tuote tuote, BigDecimal myyntihinta, Integer maara) {
		this.asiakas = asiakas;
		this.tuote = tuote;
		this.myyntihinta = myyntihinta;
		this.maara = maara;
		this.ostopaivamaara = java.time.LocalDate.now();
		this.alvKanta = AlvKanta.ALV_25_5; // Asetetaan oletus arvo myös konstruktoriin
	}

	// Alkuperäinen apumetodi palauttaa verottoman yhteishinnan
	public BigDecimal getKokonaishinta() {
		if (this.myyntihinta == null || this.maara == null) return BigDecimal.ZERO;
		return this.myyntihinta.multiply(new BigDecimal(this.maara)).setScale(2, RoundingMode.HALF_UP);
	}

	// --- LASKENTAMETODIT ENUM-POHJAiselle ALVILLESelle ---

	/**
	 * Laskee pelkän ALV:n osuuden euroina käyttäen enumin BigDecimal-prosenttia
	 */
	public BigDecimal getAlvOsuus() {
		if (this.alvKanta == null) return BigDecimal.ZERO;
		
		BigDecimal verotonYhteensa = getKokonaishinta();
		BigDecimal satanen = new BigDecimal("100");
		
		// Haetaan prosentti enumista (esim. 25.5) ja jaetaan se sadalla
		BigDecimal kerroin = this.alvKanta.getProsentti().divide(satanen, 4, RoundingMode.HALF_UP);
		
		return verotonYhteensa.multiply(kerroin).setScale(2, RoundingMode.HALF_UP);
	}

	/**
	 * Laskee lopullisen verollisen kokonaishinnan (Veroton + ALV)
	 */
	public BigDecimal getVerollinenKokonaishinta() {
		return getKokonaishinta().add(getAlvOsuus()).setScale(2, RoundingMode.HALF_UP);
	}

	// --- GETTERIT JA SETTERIT ---
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Asiakas getAsiakas() {
		return asiakas;
	}

	public void setAsiakas(Asiakas asiakas) {
		this.asiakas = asiakas;
	}

	public Tuote getTuote() {
		return tuote;
	}

	public void setTuote(Tuote tuote) {
		this.tuote = tuote;
	}

	public BigDecimal getMyyntihinta() {
		return myyntihinta;
	}

	public void setMyyntihinta(BigDecimal myyntihinta) {
		this.myyntihinta = myyntihinta;
	}

	public Integer getMaara() {
		return maara;
	}

	public void setMaara(Integer maara) {
		this.maara = maara;
	}

	public AlvKanta getAlvKanta() {
		return alvKanta;
	}

	public void setAlvKanta(AlvKanta alvKanta) {
		this.alvKanta = alvKanta;
	}

	public LocalDateTime getMyyntiaika() {
		return myyntiaika;
	}

	public void setMyyntiaika(LocalDateTime myyntiaika) {
		this.myyntiaika = myyntiaika;
	}

	public java.time.LocalDate getOstopaivamaara() {
		return ostopaivamaara;
	}

	public void setOstopaivamaara(java.time.LocalDate ostopaivamaara) {
		this.ostopaivamaara = ostopaivamaara;
	}
}
