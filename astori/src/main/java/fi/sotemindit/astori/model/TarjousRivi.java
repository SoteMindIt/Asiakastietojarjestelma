package fi.sotemindit.astori.model;

import jakarta.persistence.*;

@Entity
@Table(name = "tarjous_rivit")
public class TarjousRivi {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String tuoteNimi;
    private double maara;
    private double yksikkohinta;
    private double alvProsentti; // esim. 25.5 tai 10.0

    @ManyToOne
    @JoinColumn(name = "tarjous_id", nullable = false)
    private Tarjous tarjous;

    public TarjousRivi() {}

    // RIVILASKENTA: Veroton hinta yhteensä (määrä * hinta)
    public double getVerotonSumma() {
        return this.maara * this.yksikkohinta;
    }

    // RIVILASKENTA: Verollinen hinta yhteensä
    public double getVerollinenSumma() {
        return getVerotonSumma() * (1 + (this.alvProsentti / 100.0));
    }

    // Getterit ja setterit
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getTuoteNimi() { return tuoteNimi; }
    public void setTuoteNimi(String tuoteNimi) { this.tuoteNimi = tuoteNimi; }
    public double getMaara() { return maara; }
    public void setMaara(double maara) { this.maara = maara; }
    public double getYksikkohinta() { return yksikkohinta; }
    public void setYksikkohinta(double yksikkohinta) { this.yksikkohinta = yksikkohinta; }
    public double getAlvProsentti() { return alvProsentti; }
    public void setAlvProsentti(double alvProsentti) { this.alvProsentti = alvProsentti; }
    public Tarjous getTarjous() { return tarjous; }
    public void setTarjous(Tarjous tarjous) { this.tarjous = tarjous; }
}
