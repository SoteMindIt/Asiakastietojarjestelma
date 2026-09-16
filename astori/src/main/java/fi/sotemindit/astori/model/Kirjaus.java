package fi.sotemindit.astori.model;

import java.util.List;
import java.util.ArrayList;
import java.time.LocalDateTime;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.Table;
import jakarta.persistence.Column;


@Entity
@Table(name = "kirjaukset")
public class Kirjaus {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@Column(columnDefinition = "TEXT", nullable = false)
	private String teksti;
	private LocalDateTime luontiaika;

	// Kirjauksen voi merkitä tärkeäksi ja niitä voi hakea erikseen.
	@Column(name = "tarkea", nullable = false)
	private boolean tarkea = false;
	
	//Kirjaus pystytään kytkemään tarvittaessa toisiin kirjauksiin. Asiakkaan omiin tai toisen asiakkaan kirjauksiin.
	@ManyToMany
	@JoinTable(
	    name = "kirjaus_linkitykset",
	    joinColumns = @JoinColumn(name = "kirjaus_id"),
	    inverseJoinColumns = @JoinColumn(name = "linkitetty_kirjaus_id")
	)
	private List<Kirjaus> linkitetytKirjaukset = new ArrayList<>();


	// Relaatio: Monta kirjausta voi liittyä yhdelle asiakkaalle
	@ManyToOne
	@JoinColumn(name = "asiakas_id", nullable = false)
	private Asiakas asiakas;

	public Kirjaus() {
	}
	
	public Kirjaus(String teksti, Asiakas asiakas) {
		this.teksti = teksti;
		this.asiakas = asiakas;
		this.luontiaika = LocalDateTime.now(); // Asettaa automaattisesti nykyisen ajan
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

	public Asiakas getAsiakas() {
		return asiakas;
	}

	public void setAsiakas(Asiakas asiakas) {
		this.asiakas = asiakas;
	}

	public boolean isTarkea() {
		return tarkea;
	}

	public void setTarkea(boolean tarkea) {
		this.tarkea = tarkea;
	}
	
	public List<Kirjaus> getLinkitetytKirjaukset() {
		return linkitetytKirjaukset;
	}

	public void setLinkitetytKirjaukset(List<Kirjaus> linkitetytKirjaukset) {
		this.linkitetytKirjaukset = linkitetytKirjaukset;
	}
	
	public void linkitäKirjaukseen(Kirjaus toinenKirjaus) {
	    if (!this.linkitetytKirjaukset.contains(toinenKirjaus)) {
	        this.linkitetytKirjaukset.add(toinenKirjaus);
	    }
	    if (!toinenKirjaus.getLinkitetytKirjaukset().contains(this)) {
	        toinenKirjaus.getLinkitetytKirjaukset().add(this);
	    }
	}


}
