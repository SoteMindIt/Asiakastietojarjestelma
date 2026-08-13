package fi.sotemindit.astori.repository;

import fi.sotemindit.astori.model.Asiakas;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AsiakasRepository extends JpaRepository<Asiakas, Long> {
    // Tänne ei tarvitse kirjoittaa omia metodeja.
    // JpaRepository tuo automaattisesti mukanaan valmiit metodit:
    // save() (tallennus/päivitys), findAll() (haku), deleteById() (poisto) jne.
}
