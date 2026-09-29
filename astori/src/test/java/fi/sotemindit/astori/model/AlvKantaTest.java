package fi.sotemindit.astori.model;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

import java.math.BigDecimal;
import org.junit.jupiter.api.Test;

class AlvKantaTest {

    @Test
    void shouldReturnExpectedProsenttiStringForGeneralRate() {
        assertEquals("25.5", AlvKanta.ALV_25_5.getProsenttiStr());
    }

    @Test
    void shouldReturnExpectedDisplayTextForGeneralRate() {
        assertEquals("25,5 % (Yleinen verokanta)", AlvKanta.ALV_25_5.getNayttorivi());
    }

    @Test
    void shouldReturnBigDecimalForGeneralRate() {
        BigDecimal expected = new BigDecimal("25.5");
        assertEquals(expected, AlvKanta.ALV_25_5.getProsentti());
    }

    @Test
    void shouldReturnNonNullValuesForAllEnumEntries() {
        for (AlvKanta kanta : AlvKanta.values()) {
            assertNotNull(kanta.getProsenttiStr());
            assertNotNull(kanta.getNayttorivi());
            assertNotNull(kanta.getProsentti());
        }
    }
}
