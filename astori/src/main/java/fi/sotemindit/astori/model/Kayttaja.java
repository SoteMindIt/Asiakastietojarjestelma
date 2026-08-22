package fi.sotemindit.astori.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import java.util.List;
import java.util.ArrayList;

@Entity
@Table(name = "kayttajat")
public class Kayttaja {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@Column(unique = true, nullable = false)
	private String kayttajatunnus;

	@Column(nullable = false)
	private String salasana;

	@Column(nullable = false)
	private String rooli = "USER";

	private String etunimi;
	private String sukunimi;
	private String sahkoposti;
	private String puhelin; // UUSI KENTTÄ

	@OneToMany(mappedBy = "kayttaja")
	private List<Asiakas> asiakkaat = new ArrayList<>();

	public Kayttaja() {
		this.rooli = "USER";
	}

	// Päivitetty konstruktori sisältäen puhelinnumeron
	public Kayttaja(String kayttajatunnus, String salasana, String etunimi, String sukunimi, String sahkoposti,
			String puhelin) {
		this.kayttajatunnus = kayttajatunnus;
		this.salasana = salasana;
		this.etunimi = etunimi;
		this.sukunimi = sukunimi;
		this.sahkoposti = sahkoposti;
		this.puhelin = puhelin;
		this.rooli = "USER";
	}

	// Getterit ja Setterit
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getKayttajatunnus() {
		return kayttajatunnus;
	}

	public void setKayttajatunnus(String kayttajatunnus) {
		this.kayttajatunnus = kayttajatunnus;
	}

	public String getSalasana() {
		return salasana;
	}

	public void setSalasana(String salasana) {
		this.salasana = salasana;
	}

	public String getEtunimi() {
		return etunimi;
	}

	public void setEtunimi(String etunimi) {
		this.etunimi = etunimi;
	}

	public String getSukunimi() {
		return sukunimi;
	}

	public void setSukunimi(String sukunimi) {
		this.sukunimi = sukunimi;
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

	public List<Asiakas> getAsiakkaat() {
		return asiakkaat;
	}

	public void setAsiakkaat(List<Asiakas> asiakkaat) {
		this.asiakkaat = asiakkaat;
	}

	public String getRooli() {
		return rooli;
	}

	
	public void setRooli(String rooli) {
		this.rooli = rooli;
	}
}