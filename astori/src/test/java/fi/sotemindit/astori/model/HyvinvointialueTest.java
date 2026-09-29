package fi.sotemindit.astori.model;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

import org.junit.jupiter.api.Test;

class HyvinvointialueTest {

    @Test
    void shouldReturnExpectedNameForHelsinki() {
        assertEquals("Helsinki", Hyvinvointialue.HELSINKI.getNimi());
    }

    @Test
    void shouldReturnExpectedNameForItauusimaa() {
        assertEquals("Itä-Uusimaa", Hyvinvointialue.ITA_UUSIMAA.getNimi());
    }

    @Test
    void shouldReturnExpectedNameForLapland() {
        assertEquals("Lappi", Hyvinvointialue.LAPPI.getNimi());
    }

    @Test
    void shouldHaveNonNullNameForEveryArea() {
        for (Hyvinvointialue alue : Hyvinvointialue.values()) {
            assertNotNull(alue.getNimi());
        }
    }
}
