# AI_CONTEXT: Astori (Asiakastietojärjestelmä)
Tämä muistio sisältää sovelluksen arkkitehtuurin, muuttujanerot, reitit ja tietokantarakenteet. Tämän tiedon avulla tekoäly pysyy täysin synkronoituna koodipohjan kanssa eikä tee arkkitehtuuria rikkovia muutosehdotuksia.

- **Tekniikka:** Java 17, Spring Boot 4.1.0, Maven (war-pakkaus)
- **Tietokanta:** PostgreSQL (tietokanta: `asiakastiedot`) + Spring Data JPA (`ddl-auto=update`)
- **Käyttöliittymä:** JSP (sijainti: `/WEB-INF/jsp/`)
- **Lisäkirjastot:** Spring Security Crypto/Web, OpenPDF 1.3.40 (raportointi), FullCalendar 6

---

## ⚙️ 1. Konfiguraatiot ja Perusrakenne

### pom.xml (Maven)
- Riippuvuudet: `spring-boot-starter-web`, `spring-boot-starter-data-jpa`, `postgresql`, `spring-security-crypto`, `openpdf` (versio 1.3.40), `tomcat-embed-jasper` ja `jakarta.servlet.jsp.jstl` (JSP/JSTL-tuki Spring Boot 3/4:ssä).

### application.properties
- Tietokantayhteys: `jdbc:postgresql://localhost:5432/asiakastiedot` (tunnus: `postgres`, salasana: `admin`).
- JPA-asetukset: Dialekti `PostgreSQLDialect`, `ddl-auto=update`, `show-sql=true`.
- MVC-asetukset: Prefiksi `/WEB-INF/jsp/` ja suffiksi `.jsp`.

---

## 🏛️ 2. Tietomallit (Entities / Models)

### Asiakas.java
- Kentät: `Long id` (Identity), `String nimi` (nullable=false), `String puhelin`, `String sahkoposti`, `String katuosoite`, `String postinumero`, `String postitoimipaikka`, `String kotisivu`, `String yTunnus` (length=9).
- Tila: `@Enumerated(EnumType.STRING) AsiakkaanTila tila` (Oletus: `PROSPEKTI`).
- Relaatiot: `@ManyToOne`, `@JoinColumn(name = "kayttaja_id") Kayttaja kayttaja`.

### AsiakkaanTila.java (Enum)
- Arvot: `PROSPEKTI` ("Prospekti (Potentiaalinen)"), `KONTAKTOITU` ("Kontaktoitu / Keskustelussa"), `TARJOUS_JATETTY` ("Tarjous jätetty"), `AKTIIVINEN` ("Aktiivinen asiakas"), `PAATTYNYT` ("Yhteistyö päättynyt").
- Metodit: `getNayttorivi()`.

### Kayttaja.java
- Kentät: `Long id` (Identity), `String kayttajatunnus` (unique=true, nullable=false), `String salasana` (nullable=false), `String rooli` (nullable=false, oletus: `"USER"`), `String etunimi`, `String sukunimi`, `String sahkoposti`, `String puhelin`.
- Relaatiot: `@OneToMany(mappedBy = "kayttaja") List<Asiakas> asiakkaat`.

### Tuote.java
- Kentät: `Long id` (Identity), `String nimi` (nullable=false), `String kuvaus`, `BigDecimal hinta` (nullable=false).
- Yksikkö: `@Enumerated(EnumType.STRING) TuoteYksikko yksikko` (Oletus: `KPL`).

### TuoteYksikko.java (Enum)
- Arvot: `KPL` ("kpl"), `TUNTI` ("tunti"), `KK` ("kk"), `PV` ("päivä").
- Metodit: `getLyhenne()`.

### AsiakasTuote.java
- Kentät: `Long id` (Identity), `BigDecimal myyntihinta` (nullable=false), `Integer maara` (nullable=false, oletus: 1), `LocalDate ostopaivamaara` (nullable=false), `LocalDateTime myyntiaika` (Oletus: `now()`).
- Relaatiot: `@ManyToOne @JoinColumn(name = "asiakas_id") Asiakas asiakas`, `@ManyToOne @JoinColumn(name = "tuote_id") Tuote tuote`.
- Metodit: `getKokonaishinta()` (palauttaa `myyntihinta * maara`).

### Tarjoukset ja Tarjousrivit
- `Tarjous.java`: `Long id`, `String tarjousNumero` (unique=true, nullable=false), `LocalDate pvm`, `LocalDate voimassaoloPvm`, `BigDecimal verotonYhteensa`, `BigDecimal alvYhteensa`, `BigDecimal verollinenYhteensa`, `String lisatiedot` (TEXT). `@ManyToOne` kytkös `Asiakas`-malliin. `@OneToMany(cascade = CascadeType.ALL, orphanRemoval = true)` suhde `TarjousRivi`-listaan.
- `TarjousRivi.java`: `Long id`, `String tuotteenNimi`, `BigDecimal maara`, `BigDecimal yksikkohinta`, `BigDecimal alvProsentti`. `@ManyToOne` kytkös `Tarjous`-malliin.

### Yritystiedot.java
- Kentät: `Long id` (Kiinteä `1L`), `String nimi`, `String yTunnus`, `String sahkoposti`, `String puhelin`, `String osoite`, `String iban`, `String bic`. Käytetään globaalina tarjouspohjan asetuksena.

### Kalenteritapahtumat ja Aputaulut
- `Tapahtuma.java`: `Long id`, `String otsikko` (nullable=false), `String kuvaus`, `LocalDateTime ajankohta` (nullable=false), `@Enumerated(EnumType.STRING) TapahtumaTyyppi tyyppi`. `@ManyToOne` kytkennät `Asiakas`- ja `Kayttaja`-malleihin.
- `TapahtumaTyyppi.java` (Enum): `PUHELU` ("Puhelu"), `TAPAAMINEN` ("Tapaaminen"), `ETAKOKOUS` ("Etäkokous"), `MUU` ("Muu tehtävä"). `getNayttorivi()`.
- `Yhteyshenkilo.java`: Asiakkaan yhteyshenkilöt. `Long id`, `String nimi`, `String rooli`, `String sahkoposti`, `String puhelin`. `@ManyToOne @JoinColumn(name = "asiakas_id", nullable = false)` kytkös `Asiakas`-malliin.
- `Kirjaus.java`: Asiakkaan lokimerkinnät. `Long id`, `String teksti`, `LocalDateTime luontiaika`. `@ManyToOne` kytkös `Asiakas`-malliin.
- `Loki.java`: Audit Trail -järjestelmäloki. `Long id`, `LocalDateTime aikaleima`, `String kayttajatunnus`, `String toiminto` (KATSELU, LISÄYS, MUOKKAUS, POISTO), `String kuvaus` (TEXT).
- `Liitetiedosto.java`: `Long id`, `String tiedostonNimi`, `String kuvaus`, `byte[] data` (columnDefinition = "bytea"), `LocalDateTime latausaika`. `@ManyToOne` kytkös `Asiakas`-malliin.

---

## 🔌 3. Repository-rajapinnat (Repositories)

### AsiakasRepository.java
- `Page<Asiakas> findByKayttajaKayttajatunnus(String kayttajatunnus, Pageable pageable)`
- `Page<Asiakas> findByKayttajaKayttajatunnusAndHaku(@Param("tunnus") String tunnus, @Param("haku") String haku, Pageable pageable)` -> JPQL-haku (`LOWER`) nimestä, sähköpostista, puhelimesta ja Y-tunnuksesta.
- `long countByKayttajaKayttajatunnus(@Param("tunnus") String tunnus)` -> `COUNT(a)` dashboardille.

### AsiakasTuoteRepository.java
- `List<AsiakasTuote> findByAsiakasId(Long asiakasId)` -> Palauttaa tietyn asiakkaan palveluostot.

### KayttajaRepository.java
- `Optional<Kayttaja> findByKayttajatunnus(String kayttajatunnus)` -> Autentikointiin ja tietojen lataukseen.

### KirjausRepository.java
- `List<Kirjaus> findByAsiakasIdOrderByLuontiaikaDesc(Long asiakasId)` -> Muistiinpanot aikajärjestyksessä.

### LiitetiedostoRepository.java
- `List<Liitetiedosto> findByAsiakasIdOrderByLatausaikaDesc(Long asiakasId)` -> Dokumentit profiilinäkymään.

### LokiRepository.java
- `List<Loki> findAllByOrderByAikaleimaDesc()` -> Järjestelmäloki Audit Trailiin (uusimmasta vanhimpaan).

### TapahtumaRepository.java
- `List<Tapahtuma> findByKayttajaKayttajatunnusAndAjankohtaAfterOrderByAjankohtaAsc(@Param("tunnus") String tunnus, @Param("nyt") LocalDateTime nyt)` -> Tulevat tapahtumat etusivun koosteeseen.
- `long countByKayttajaKayttajatunnusAndAjankohtaBetween(@Param("tunnus") String tunnus, @Param("alku") LocalDateTime alku, @Param("loppu") LocalDateTime loppu)` -> Päivän agenda työpöydän korttiin.
- `List<Tapahtuma> findByKayttajatunnus(@Param("tunnus") String tunnus)` -> Kalenterisivun tapahtumalataus.

### TarjousRepository.java
- `long countByAsiakasKayttajaKayttajatunnus(@Param("tunnus") String tunnus)` -> Tarjouslaskurin kokonaissumma työpöydälle relaation yli kulkeen.
- `List<Tarjous> findByAsiakasId(Long asiakasId)` -> Asiakkaan vanhat tarjoukset.
- `boolean existsByTarjousNumero(String tarjousNumero)` -> Estää duplikaatit tarjousnumeroissa.

### TuoteRepository.java
- `JpaRepository<Tuote, Long>` -> Standardit CRUD-operaatiot tuoterekisterille.

### YhteyshenkiloRepository.java
- `List<Yhteyshenkilo> findByAsiakasId(Long asiakasId)` -> Hakee kaikki asiakkaaseen sidotut kontaktit.

### YritystiedotRepository.java
- `JpaRepository<Yritystiedot, Long>` -> Standardit CRUD-operaatiot globaalille yritystietoriville (ID 1L).

---

## 🎮 4. Backend-kontrollerit (Controllers & Routes)

- **`AsiakasController.java`**: Hoitaa dashboardin, dynaamiset laskurit, asiakaslistauksen (10 kpl sivutus), asiakasprofiilin (`@Transactional` ja `KATSELU`-lokitus), sekä asiakkaan, lokien, myyntien ja yhteyshenkilöiden hallinnan.
- **`TarjousController.java`**: Vastaanottaa dynaamiset tarjousrivit. Laskee summat `BigDecimal`-luokalla (25.5 % ALV-tuki). Generoi PDF-tulosteet OpenPDF-kirjastolla suoraan response-virtaan.
- **`AsetuksetController.java`**: Työntekijöiden luonnit BCrypt-salauksella (Vain `ADMIN`), työntekijätietojen päivitykset ja tuoterekisterin dynaamiset lisäykset/muokkaukset.
- **`KalenteriController.java`**: Ohjaa FullCalendar-näkymiä (ADMIN näkee kaikki, USER vain omat). Hoitaa tuplaklikkausvaraukset, joustavat paluuosoitteet (`lahde`) ja modal-poistot.
- **`LoginController.java`**: Istuntopohjainen kirjautuminen (`session.setAttribute`), `passwordEncoder.matches()`-todennus ja uloskirjautuminen istunnon nollauksella.
- **`RaportitController.java`**: Välittää kokonaisasiakasmäärät ja Audit Trail -lokit (`findAllByOrderByAikaleimaDesc()`) uusimmasta vanhimpaan järjestyksessä.

---

## 💻 5. Käyttöliittymäkerros (JSP-näkymät)

Kaikki sivut käyttävät dynaamista kontekstipolkua `${pageContext.request.contextPath}` ja paikallisia Bootstrap-resursseja.

- **`login.jsp`** & **`rekisterointi.jsp`**: Kirjautumisportti ja erillinen uuden työntekijän rekisteröitymislomake.
- **`dashboard.jsp`** & **`asiakkaat.jsp`**: Työpöytä laskureilla ja kalenterikoosteella sekä asiakasrekisteri sivutuksella, hakuominaisuudella ja osoite/Y-tunnus-lomakkeella.
- **`asiakasprofiili.jsp`**: Kolmesarakkeinen profiilinäkymä (yhteyshenkilöt, muistiinpanot, palveluostot summalaskureilla ja tarjoukset). Pudotusvalikot hyödyntävät suoraan enumin `${tilaVaihtoehto.nayttorivi}`-metodia.
- **`tarjoukset.jsp`**: Tarjouslaskentasivu. Listaa vanhat tarjoukset (PDF-lataus ja poisto). Sisältää dynaamisen JavaScript-taulukon rivien monistamiseen (`cloneNode`). Synkronoituna kontrollerin `${tuoteLista}`-muuttujan kanssa. Sisältää valmiina uuden **25.5 % ALV**-verokannan.
- **`asetukset.jsp`** & **`lisaa-tuote.jsp`**: Tuoterekisteri dynaamisilla muokkausmodaalelle, varmuuskopiointipainike, yritystietolomake ja työntekijöiden hallinta.
- **`kalenteri.jsp`**: FullCalendar 6 -kuukausinäkymä dynaamisella `datalist`-asiakashaulla ja automaattisella piilokenttä-ID-muunnoksella. Sukunimen katkaisu suojattu `null`-arvoilta.
