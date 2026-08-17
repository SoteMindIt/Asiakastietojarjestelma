package fi.sotemindit.astori.model;

import jakarta.persistence.*;

@Entity
@Table(name = "tarjous_rivit")
public class TarjousRivi {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	private String tuotteenNimi;
	private Double maara;
	private Double yksikkohinta;
	private Double alvProsentti;

	@ManyToOne
	@JoinColumn(name = "tarjous_id", nullable = false)
	private Tarjous tarjous;

	public TarjousRivi() {}

	public TarjousRivi(String tuotteenNimi, Double maara, Double yksikkohinta, Double alvProsentti, Tarjous tarjous) {
		this.tuotteenNimi = tuotteenNimi;
		this.maara = maara;
		this.yksikkohinta = yksikkohinta;
		this.alvProsentti = alvProsentti;
		this.tarjous = tarjous;
	}

	// Getterit ja Setterit
	public Long getId() { return id; }
	public void setId(Long id) { this.id = id; }
	public String getTuotteenNimi() { return tuotteenNimi; }
	public void setTuotteenNimi(String tuotteenNimi) { this.tuotteenNimi = tuotteenNimi; }
	public Double getMaara() { return maara; }
	public void setMaara(Double maara) { this.maara = maara; }
	public Double getYksikkohinta() { return yksikkohinta; }
	public void setYksikkohinta(Double yksikkohinta) { this.yksikkohinta = yksikkohinta; }
	public Double getAlvProsentti() { return alvProsentti; }
	public void setAlvProsentti(Double alvProsentti) { this.alvProsentti = alvProsentti; }
	public Tarjous getTarjous() { return tarjous; }
	public void setTarjous(Tarjous tarjous) { this.tarjous = tarjous; }
}
