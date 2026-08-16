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

    private String tarjousNumero;
    private LocalDate pvm = LocalDate.now();
    private LocalDate voimassaoloPvm;

    @ManyToOne
    @JoinColumn(name = "asiakas_id", nullable = false)
    private Asiakas asiakas;

    @OneToMany(mappedBy = "tarjous", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<TarjousRivi> rivit = new ArrayList<>();

    public Tarjous() {}

    // LASKENTALOGIIKKA: Laskee kaikkien rivien verottoman summan
    public double getVerotonYhteensa() {
        return rivit.stream().mapToDouble(TarjousRivi::getVerotonSumma).sum();
    }

    // LASKENTALOGIIKKA: Laskee kaikkien rivien verollisen loppusumman
    public double getVerollinenYhteensa() {
        return rivit.stream().mapToDouble(TarjousRivi::getVerollinenSumma).sum();
    }

    // LASKENTALOGIIKKA: Laskee ALV-osuuden kokonaismäärän
    public double getAlvYhteensa() {
        return getVerollinenYhteensa() - getVerotonYhteensa();
    }

    // Apumetodi rivien hallintaan
    public void lisaaRivi(TarjousRivi rivi) {
        rivit.add(rivi);
        rivi.setTarjous(this);
    }

    // Getterit ja setterit
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getTarjousNumero() { return tarjousNumero; }
    public void setTarjousNumero(String tarjousNumero) { this.tarjousNumero = tarjousNumero; }
    public LocalDate getPvm() { return pvm; }
    public void setPvm(LocalDate pvm) { this.pvm = pvm; }
    public LocalDate getVoimassaoloPvm() { return voimassaoloPvm; }
    public void setVoimassaoloPvm(LocalDate voimassaoloPvm) { this.voimassaoloPvm = voimassaoloPvm; }
    public Asiakas getAsiakas() { return asiakas; }
    public void setAsiakas(Asiakas asiakas) { this.asiakas = asiakas; }
    public List<TarjousRivi> getRivit() { return rivit; }
    public void setRivit(List<TarjousRivi> rivit) { this.rivit = rivit; }
}

