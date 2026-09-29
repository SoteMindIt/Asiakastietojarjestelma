package fi.sotemindit.astori.model;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

import org.junit.jupiter.api.Test;

class AsiakkaanTilaTest {

    @Test
    void shouldReturnExpectedDisplayValueForProspekti() {
        assertEquals("Prospekti (Potentiaalinen)", AsiakkaanTila.PROSPEKTI.getNayttorivi());
    }

    @Test
    void shouldReturnExpectedDisplayValueForActiveCustomer() {
        assertEquals("Aktiivinen asiakas", AsiakkaanTila.AKTIIVINEN.getNayttorivi());
    }

    @Test
    void shouldReturnExpectedDisplayValueForEndedCollaboration() {
        assertEquals("Yhteistyö päättynyt", AsiakkaanTila.PAATTYNYT.getNayttorivi());
    }

    @Test
    void shouldHaveNonNullDisplayTextForEachStatus() {
        for (AsiakkaanTila tila : AsiakkaanTila.values()) {
            assertNotNull(tila.getNayttorivi());
        }
    }
}
