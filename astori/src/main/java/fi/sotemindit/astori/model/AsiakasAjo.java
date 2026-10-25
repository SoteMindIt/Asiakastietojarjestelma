package fi.sotemindit.astori.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "asiakasajot")
public class AsiakasAjo {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@ManyToOne
	@JoinColumn(name = "asiakas_id")
	private Asiakas asiakas;

	@ManyToMany
	@JoinTable(name = "asiakasajo_asiakkaat",
			joinColumns = @JoinColumn(name = "ajo_id"),
			inverseJoinColumns = @JoinColumn(name = "asiakas_id"))
	private List<Asiakas> asiakkaat = new ArrayList<>();

	@ManyToOne
	@JoinColumn(name = "luoja_id")
	private Kayttaja luoja;

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

	public Long getId() {
		return id;
	}

	public Asiakas getAsiakas() {
		return asiakas;
	}

	public void setAsiakas(Asiakas asiakas) {
		this.asiakas = asiakas;
	}

	public List<Asiakas> getAsiakkaat() {
		List<Asiakas> kaikkiAsiakkaat = new ArrayList<>(asiakkaat);
		if (asiakas != null && kaikkiAsiakkaat.stream()
				.noneMatch(linkitetty -> samaAsiakas(linkitetty, asiakas))) {
			kaikkiAsiakkaat.add(0, asiakas);
		}
		return kaikkiAsiakkaat;
	}

	public void setAsiakkaat(List<Asiakas> asiakkaat) {
		this.asiakkaat.clear();
		if (asiakkaat != null) {
			for (Asiakas valittuAsiakas : asiakkaat) {
				if (this.asiakkaat.stream()
						.noneMatch(linkitetty -> samaAsiakas(linkitetty, valittuAsiakas))) {
					this.asiakkaat.add(valittuAsiakas);
				}
			}
		}
		this.asiakas = this.asiakkaat.isEmpty() ? null : this.asiakkaat.get(0);
	}

	private boolean samaAsiakas(Asiakas ensimmainen, Asiakas toinen) {
		return ensimmainen == toinen || (ensimmainen.getId() != null && ensimmainen.getId().equals(toinen.getId()));
	}

	public Kayttaja getLuoja() {
		return luoja;
	}

	public void setLuoja(Kayttaja luoja) {
		this.luoja = luoja;
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

	public BigDecimal getKilometrit() {
		if (alkumatkamittari == null || loppumatkamittari == null) {
			return BigDecimal.ZERO;
		}
		return loppumatkamittari.subtract(alkumatkamittari);
	}
}