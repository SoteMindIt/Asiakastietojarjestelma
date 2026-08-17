package fi.sotemindit.astori.model;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "tarjoukset")
public class Tarjous {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@Column(name = "tarjous_numero", nullable = false)
	private String tarjousNumero;
	private LocalDate pvm;
	private LocalDate voimassaoloPvm;
	private Double verotonYhteensa;
	private Double alvYhteensa;
	private Double verollinenYhteensa;

	@ManyToOne
	@JoinColumn(name = "asiakas_id", nullable = false)
	private Asiakas asiakas;

	@OneToMany(mappedBy = "tarjous", cascade = CascadeType.ALL, orphanRemoval = true)
	private List<TarjousRivi> rivit = new ArrayList<>();

	@Column(name = "lisatiedot", columnDefinition = "TEXT")
	private String lisatiedot;

	public Tarjous() {
	}

	public void lisaaRivi(TarjousRivi rivi) {
		this.rivit.add(rivi);
		rivi.setTarjous(this);
	}

	// Getterit ja Setterit
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getTarjousNumero() {
		return tarjousNumero;
	}

	public void setTarjousNumero(String tarjousNumero) {
		this.tarjousNumero = tarjousNumero;
	}

	public LocalDate getPvm() {
		return pvm;
	}

	public void setPvm(LocalDate pvm) {
		this.pvm = pvm;
	}

	public LocalDate getVoimassaoloPvm() {
		return voimassaoloPvm;
	}

	public void setVoimassaoloPvm(LocalDate voimassaoloPvm) {
		this.voimassaoloPvm = voimassaoloPvm;
	}

	public Double getVerotonYhteensa() {
		return verotonYhteensa;
	}

	public void setVerotonYhteensa(Double verotonYhteensa) {
		this.verotonYhteensa = verotonYhteensa;
	}

	public Double getAlvYhteensa() {
		return alvYhteensa;
	}

	public void setAlvYhteensa(Double alvYhteensa) {
		this.alvYhteensa = alvYhteensa;
	}

	public Double getVerollinenYhteensa() {
		return verollinenYhteensa;
	}

	public void setVerollinenYhteensa(Double verollinenYhteensa) {
		this.verollinenYhteensa = verollinenYhteensa;
	}

	public Asiakas getAsiakas() {
		return asiakas;
	}

	public void setAsiakas(Asiakas asiakas) {
		this.asiakas = asiakas;
	}

	public List<TarjousRivi> getRivit() {
		return rivit;
	}

	public void setRivit(List<TarjousRivi> rivit) {
		this.rivit = rivit;
	}

	public String getLisatiedot() {
		return lisatiedot;
	}

	public void setLisatiedot(String lisatiedot) {
		this.lisatiedot = lisatiedot;
	}
}
