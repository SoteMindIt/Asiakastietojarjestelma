package fi.sotemindit.astori.model;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.math.RoundingMode;

@Entity
@Table(name = "tarjous_rivit")
public class TarjousRivi {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	private String tuotteenNimi;
	private java.math.BigDecimal maara;
	private java.math.BigDecimal yksikkohinta;
	private java.math.BigDecimal alvProsentti;

	@ManyToOne
	@JoinColumn(name = "tarjous_id", nullable = false)
	private Tarjous tarjous;

	public TarjousRivi() {}

	public TarjousRivi(String tuotteenNimi, java.math.BigDecimal maara, java.math.BigDecimal yksikkohinta, java.math.BigDecimal alvProsentti, Tarjous tarjous) {
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
	public java.math.BigDecimal getMaara() { return maara; }
	public void setMaara(java.math.BigDecimal maara) { this.maara = maara; }
	public java.math.BigDecimal getYksikkohinta() { return yksikkohinta; }
	public void setYksikkohinta(java.math.BigDecimal yksikkohinta) { this.yksikkohinta = yksikkohinta; }
	public java.math.BigDecimal getAlvProsentti() { return alvProsentti; }
	public void setAlvProsentti(java.math.BigDecimal alvProsentti) { this.alvProsentti = alvProsentti; }
	public Tarjous getTarjous() { return tarjous; }
	public void setTarjous(Tarjous tarjous) { this.tarjous = tarjous; }

	public BigDecimal getVerotonYhteensa() {
		if (maara == null || yksikkohinta == null) {
			return BigDecimal.ZERO.setScale(2);
		}
		return maara.multiply(yksikkohinta);
	}

	public BigDecimal getAlvOsuus() {
		if (alvProsentti == null) {
			return BigDecimal.ZERO.setScale(2);
		}
		return getVerotonYhteensa().multiply(alvProsentti)
				.divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);
	}

	public BigDecimal getVerollinenYhteensa() {
		return getVerotonYhteensa().add(getAlvOsuus()).setScale(2, RoundingMode.HALF_UP);
	}
}
