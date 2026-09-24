package fi.sotemindit.astori.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "muistiinpanot")
public class Muistiinpano {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@Column(columnDefinition = "TEXT", nullable = false)
	private String teksti;

	@Column(nullable = false)
	private LocalDateTime luontiaika;

	@Column(nullable = false)
	private String kayttajatunnus;

	// Konstruktorit
	public Muistiinpano() {
	}

	public Muistiinpano(String teksti, String kayttajatunnus) {
		this.teksti = teksti;
		this.luontiaika = LocalDateTime.now();
		this.kayttajatunnus = kayttajatunnus;
	}

	// Getterit ja Setterit
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getTeksti() {
		return teksti;
	}

	public void setTeksti(String teksti) {
		this.teksti = teksti;
	}

	public LocalDateTime getLuontiaika() {
		return luontiaika;
	}

	public void setLuontiaika(LocalDateTime luontiaika) {
		this.luontiaika = luontiaika;
	}

	public String getKayttajatunnus() {
		return kayttajatunnus;
	}

	public void setKayttajatunnus(String kayttajatunnus) {
		this.kayttajatunnus = kayttajatunnus;
	}
}
