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
