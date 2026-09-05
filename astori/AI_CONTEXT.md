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
- MVC-asetukset: Prefiksi `/WEB-INF/jsp/` and suffiksi `.jsp`.

---

## 🏛️ 2. Tietomallit (Entities / Models)

### Asiakas.java
- Kentät: Long id (Identity), String nimi (nullable=false), String puhelin, String sahkoposti, String katuosoite, String postinumero, String postitoimipaikka, String kotisivu, String yTunnus (length=9).
- Tila: @Enumerated(EnumType.STRING) AsiakkaanTila tila (Oletus: PROSPEKTI).
- Hyvinvointialue: @Enumerated(EnumType.STRING) Hyvinvointialue hyvinvointialue (Kytketty dynaamiseen enumiin).
- Relaatiot: 
  - `@ManyToOne @JoinColumn(name = "kayttaja_id") Kayttaja kayttaja`
  - `@OneToMany(mappedBy = "asiakas", cascade = CascadeType.ALL, orphanRemoval = true) List<Palveluyksikko> palveluyksikot` (Dynaaminen lista toimintayksikön alaisuudessa olevista palveluyksiköistä).
- Konstruktori: public Asiakas(String nimi, String puhelin, String sahkoposti, String katuosoite, String postinumero, String postitoimipaikka, String kotisivu, AsiakkaanTila tila, String yTunnus, String kuvaus, Hyvinvointialue hyvinvointialue) -> 11 argumentin standardikonstruktori.

### AsiakkaanTila.java (Enum)
- Arvot: `PROSPEKTI`, `KONTAKTOITU`, `TARJOUS_JATETTY`, `AKTIIVINEN`, `PAATTYNYT`.

### Hyvinvointialue.java (Enum)
- Arvot: 21 virallista hyvinvointialuetta (esim. `HELSINKI`, `LANSI_UUSIMAA`) + `getNimi()`-metodi selkokieliselle suomenkieliselle tulostukselle.

### Palveluyksikko.java (Uusi)
- Kentät: `Long id` (Identity), `String nimi` (nullable=false), `String katuosoite`, `String postinumero`, `String postitoimipaikka`, `String puhelin`, `String sahkoposti`, `String kuvaus` (columnDefinition = "TEXT").
- Hyvinvointialue: `@Enumerated(EnumType.STRING) Hyvinvointialue hyvinvointialue` (Yksikön oma mahdollinen hyvinvointialue).
- Relaatiot:
  - `@ManyToOne @JoinColumn(name = "asiakas_id", nullable = false) Asiakas asiakas` (Kytkös päätoimintayksikköön/emoyhtiöön).
  - `@OneToMany(mappedBy = "palveluyksikko", cascade = CascadeType.ALL, orphanRemoval = true) List<Yhteyshenkilo> yhteyshenkilot` (Yksikön omat nimetyt vastuuhenkilöt).

### Yhteyshenkilo.java
- Kentät: `Long id`, `String nimi`, `String rooli`, `String sahkoposti`, `String puhelin`.
- Relaatiot:
  - `@ManyToOne @JoinColumn(name = "asiakas_id", nullable = false) Asiakas asiakas` (Emo-organisaatiolinkitys).
  - `@ManyToOne @JoinColumn(name = "palveluyksikko_id", nullable = true) Palveluyksikko palveluyksikko` (Joustava linkitys tiettyyn alayksikköön. Jos `null`, henkilö on yleinen organisaatiotason kontakti).

### Kayttaja.java
- Kentät: `Long id`, `String kayttajatunnus`, `String salasana`, `String rooli`. `@OneToMany` suhde `Asiakas`-listaan.

### Tuote.java
- Kentät: `Long id`, `String nimi`, `String kuvaus`, `BigDecimal hinta`. `@Enumerated(EnumType.STRING) TuoteYksikko yksikko`. `tuotteet_yksikko_check` sallii arvot: 'KPL', 'TUNTI', 'KK', 'PV', 'KM'.

### TuoteYksikko.java (Enum)
- Arvot: `KPL`, `TUNTI`, `KK`, `PV`, `KM` (km matkakorvauksille). `getLyhenne()`.

### AsiakasTuote.java
- `@ManyToOne` kytkökset `Asiakas` ja `Tuote`. Myyntitiedot ja `getKokonaishinta()`.

### Kirjaus.java
- Kentät: `Long id`, `String teksti` (columnDefinition = "TEXT" pitkiä muistiinpanoja varten), `LocalDateTime luontiaika`. `@ManyToOne` kytkös `Asiakas`-malliin.

### Tarjoukset, Järjestelmäloki ja Liitteet
- `Tarjous.java`, `TarjousRivi.java`, `Yritystiedot.java` (ID 1L), `Loki.java` (Audit Trail), `Tapahtuma.java` (Kalenteri), `Liitetiedosto.java`.
---

## 🔌 3. Repository-rajapinnat (Repositories)

### AsiakasRepository.java
- Page<Asiakas> findByKayttajaKayttajatunnus(String kayttajatunnus, Pageable pageable)
- Page<Asiakas> findByKayttajaKayttajatunnusAndHaku(@Param("tunnus") String tunnus, @Param("haku") String haku, Pageable pageable)

### PalveluyksikkoRepository.java (Uusi)
- `List<Palveluyksikko> findByAsiakasId(Long asiakasId)` -> Hakee tietyn pääasiakkaan kaikki palveluyksiköt ja toimipisteet.

### YhteyshenkiloRepository.java
- `List<Yhteyshenkilo> findByAsiakasId(Long asiakasId)` -> Alkuperäinen listaus hakee kaikki asiakkaaseen sidotut kontaktit.

### Muut rajapinnat
- `AsiakasTuoteRepository`, `KayttajaRepository`, `KirjausRepository`, `LiitetiedostoRepository`, `LokiRepository` (Audit Trail), `TapahtumaRepository`, `TarjousRepository`, `TuoteRepository`, `YritystiedotRepository`.

---

## 🎮 4. Backend-kontrollerit (Controllers & Routes)

- **`AsiakasController.java`**: 
  - Hoitaa dashboardin reaaliaikaiset laskurit, asiakaslistauksen ja asiakasprofiilin (`KATSELU`-lokitus). 
  - Hoitaa yhteyshenkilöiden (`/yhteyshenkilo/muokkaa/{id}`), lokien (`/kirjaus/muokkaa/{id}`) ja ostettujen palveluiden muokkausreitit (`/palvelu/muokkaa/{id}`).
  - **Uusi reitti:** `/asiakas/{asiakasId}/lisaa-palveluyksikko` (POST) ottaa vastaan uuden palveluyksikön osoite- ja yhteystiedot sekä dynaamisen `Hyvinvointialue`-enumin ja tallentaa ne kantaan sidottuna pääasiakkaaseen.
- **`AsiakasController.java (Live Search)`**: `/asiakkaat/live-haku` (@ResponseBody).
- **`TarjousController.java`**: Tarjousrivit `BigDecimal`-laskennalla (25.5 % ALV-tuki) ja OpenPDF-generoinnilla.
- **`AsetuksetController.java`**: Työntekijöiden ja tuoterekisterin dynaamiset lisäykset/muokkaukset (`/asetukset/muokkaa-tuotetta/{id}`). Välittää dynaamisen yksikkölistauksen (`model.addAttribute("yksikot", TuoteYksikko.values())`).

---

## 💻 5. Käyttöliittymäkerros (JSP-näkymät)

Kaikki sivut käyttävät dynaamista kontekstipolkua `${pageContext.request.contextPath}` ja paikallisia Bootstrap-resursseja.

- **`asiakasprofiili.jsp`**: 
  - Uudistettu, siisti ja tilankäyttöoptimoitu näkymä ilman turhia pystysuoria kuiluja.
  - Pääkehys sisältää perustiedot dynaamisella ja erittäin lyhyellä hyvinvointialueen tulostuksella (`${asiakas.hyvinvointialue.nimi}`), keskitetyt hallintapainikkeet ja skrollaavan **Asiakkaan lokin**.
  - Alaosassa on kolme täysleveää korttia allekkain tyhjien tilojen estämiseksi:
    1. **Palveluyksiköt ja toimipisteet** (Uusi, joustava Flexbox-rivi, joka listaa dynaamisesti alayksiköt omilla osoitteillaan, kuvauksillaan ja mahdollisilla erillisillä hyvinvointialue-badgeillaan).
    2. **Yhteyshenkilöt** (Dynaaminen Flexbox-rivi, joka tukee jatkossa joustavaa kohdistamista joko emoyhtiöön tai suoraan tiettyyn alayksikköön).
    3. **Ostetut tuotteet ja palvelut** (Koko sivun leveä taulukko dynaamisilla muokkauslinkeillä).
  - Modal-lomakkeet: Alustetaan sivun alussa globaalisti estämään tumman backdrop-kalvon jumiutuminen. Mukana uusi lomake `lisaaPalveluyksikkoModal` täydellisellä osoite- ja kuvauksenhallinnalla.
- **`asetukset.jsp`**: Tuoterekisteri hyödyntää dynaamista `${yksikot}`-listaa, joka reagoi lennosta uusiin yksiköihin (kuten `km`).
- **`tarjoukset.jsp`**: Tarjouslaskentasivu JavaScript-rivimonistuksella ja valmiilla uudella **25.5 % ALV**-verokannalla.
- **`dashboard.jsp`**, `asiakkaat.jsp` (live Fetch-haku), `kalenteri.jsp`, `raportit.jsp`.
