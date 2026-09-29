package fi.sotemindit.astori.config;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.Test;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

class SecurityConfigTest {

    @Test
    void passwordEncoderShouldReturnBeanInstance() {
        SecurityConfig config = new SecurityConfig();

        BCryptPasswordEncoder encoder = config.passwordEncoder();

        assertNotNull(encoder);
        assertTrue(encoder.matches("secret", encoder.encode("secret")));
    }
}
