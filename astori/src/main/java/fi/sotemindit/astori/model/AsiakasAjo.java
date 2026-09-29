package fi.sotemindit.astori.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "asiakasajot")
public class AsiakasAjo {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@ManyToOne(optional = false)
	@JoinColumn(name = "asiakas_id", nullable = false)
	private Asiakas asiakas;

	@Column(nullable = false)
	private LocalDate paivamaara;

	@Column(nullable = false, length = 200)
	private String lahtopaikka;

	@Column(nullable = false, length = 200)
	private String kohde;

	@Column(nullable = false, columnDefinition = "TEXT")
	private String tarkoitus;

	@Column(name = "edestakainen", nullable = false, columnDefinition = "boolean default false")
	private boolean edestakainen;

	@Column(name = "alkumatkamittari", precision = 12, scale = 2, nullable = false)
	private BigDecimal alkumatkamittari;

	@Column(name = "loppumatkamittari", precision = 12, scale = 2, nullable = false)
	private BigDecimal loppumatkamittari;

	@Column(name = "laskuviite", length = 100)
	private String laskuviite;

	public Long getId() {
		return id;
	}

	public Asiakas getAsiakas() {
		return asiakas;
	}

	public void setAsiakas(Asiakas asiakas) {
		this.asiakas = asiakas;
	}

	public LocalDate getPaivamaara() {
		return paivamaara;
	}

	public void setPaivamaara(LocalDate paivamaara) {
		this.paivamaara = paivamaara;
	}

	public String getLahtopaikka() {
		return lahtopaikka;
	}

	public void setLahtopaikka(String lahtopaikka) {
		this.lahtopaikka = lahtopaikka;
	}

	public String getKohde() {
		return kohde;
	}

	public void setKohde(String kohde) {
		this.kohde = kohde;
	}

	public String getTarkoitus() {
		return tarkoitus;
	}

	public void setTarkoitus(String tarkoitus) {
		this.tarkoitus = tarkoitus;
	}

	public boolean isEdestakainen() {
		return edestakainen;
	}

	public void setEdestakainen(boolean edestakainen) {
		this.edestakainen = edestakainen;
	}

	public BigDecimal getAlkumatkamittari() {
		return alkumatkamittari;
	}

	public void setAlkumatkamittari(BigDecimal alkumatkamittari) {
		this.alkumatkamittari = alkumatkamittari;
	}

	public BigDecimal getLoppumatkamittari() {
		return loppumatkamittari;
	}

	public void setLoppumatkamittari(BigDecimal loppumatkamittari) {
		this.loppumatkamittari = loppumatkamittari;
	}

	public String getLaskuviite() {
		return laskuviite;
	}

	public void setLaskuviite(String laskuviite) {
		this.laskuviite = laskuviite;
	}

	public BigDecimal getKilometrit() {
		if (alkumatkamittari == null || loppumatkamittari == null) {
			return BigDecimal.ZERO;
		}
		return loppumatkamittari.subtract(alkumatkamittari);
	}
}