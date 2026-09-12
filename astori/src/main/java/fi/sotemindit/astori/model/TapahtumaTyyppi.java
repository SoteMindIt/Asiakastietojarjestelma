package fi.sotemindit.astori.model;

import jakarta.persistence.*;

@Entity
@Table(name = "tapahtuma_tyypit")
public class TapahtumaTyyppi {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@Column(nullable = false, unique = true)
	private String nimi;

	//Tallentaa värin HEX-koodin (Oletus: Bootstrap-sininen)
	@Column(nullable = false, columnDefinition = "VARCHAR(255) DEFAULT '#0d6efd'")
	private String vari = "#0d6efd";

	public TapahtumaTyyppi() {
	}

	public TapahtumaTyyppi(String nimi, String vari) {
		this.nimi = nimi;
		this.vari = vari;
	}

	// --- GETTERIT JA SETTERIT ---
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

	public String getVari() {
		return vari;
	}

	public void setVari(String vari) {
		this.vari = vari;
	}
}
