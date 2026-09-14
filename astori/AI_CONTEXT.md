# AI_CONTEXT.md - Astori CRM Järjestelmäarkkitehtuuri

## 1. Järjestelmän yleiskuva
Astori on moderni asiakkuudenhallintajärjestelmä ei pelkästään sote-alalle, vaan myös muille aloille (CRM). Järjestelmä on rakennettu Spring Boot 3.x -kehyksellä, hyödyntää PostgreSQL-tietokantaa ja sen käyttöliittymäkerros on toteutettu JSP (JavaServer Pages) -tekniikalla ja Bootstrap 5 -muotoilulla.

- **Tekniikka:** Java 17, Spring Boot 3.x, Maven (war-pakkaus)
- **Tietokanta:** PostgreSQL (tietokanta: `asiakastiedot`) + Spring Data JPA (`ddl-auto=update`)
- **Käyttöliittymä:** JSP (sijainti: `/WEB-INF/jsp/`) ja Generic Code Editor (Wild Web Developer) oletuksena.
- **Lisäkirjastot:** Spring Security Crypto/Web, OpenPDF 1.3.40 (raportointi), FullCalendar 6

---

## ⚙️ 1. Konfiguraatiot ja Perusrakenne

### pom.xml (Maven)
- Riippuvuudet: `spring-boot-starter-web`, `spring-boot-starter-data-jpa`, `postgresql`, `spring-security-crypto`, `openpdf` (versio 1.3.40), `tomcat-embed-jasper` ja `jakarta.servlet.jsp.jstl` (JSP/JSTL-tuki Spring Boot 3:ssa).

### application.properties
- Tietokantayhteys: `jdbc:postgresql://localhost:5432/asiakastiedot` (tunnus: `postgres`, salasana: `admin`).
- JPA-asetukset: Dialekti `PostgreSQLDialect`, `ddl-auto=update`, `show-sql=true`.
- MVC-asetukset: Prefiksi `/WEB-INF/jsp/` ja suffiksi `.jsp`.

---

## 🏛️ 2. Tietomallit (Entities / Models)

### Asiakas.java
- Kentät: Long id (Identity), String nimi (nullable=false), String puhelin, String sahkoposti, String katuosoite, String postinumero, String postitoimipaikka, String kotisivu, String yTunnus (length=9), String kuvaus.
- Tila: `@Enumerated(EnumType.STRING) AsiakkaanTila tila` (Oletus: PROSPEKTI).
- Hyvinvointialue: `@Enumerated(EnumType.STRING) Hyvinvointialue hyvinvointialue` (Kytketty dynaamiseen enumiin).
- Relaatiot: 
  - `@ManyToOne @JoinColumn(name = "kayttaja_id") Kayttaja kayttaja`
  - `@OneToMany(mappedBy = "asiakas", cascade = CascadeType.ALL, orphanRemoval = true) List<Palveluyksikko> palveluyksikot`
- Konstruktori: 11 argumentin standardikonstruktori.

### AsiakkaanTila.java (Enum)
- Arvot: `PROSPEKTI`, `KONTAKTOITU`, `TARJOUS_JATETTY`, `AKTIIVINEN`, `PAATTYNYT`.

### Hyvinvointialue.java (Enum)
- Arvot: 21 virallista hyvinvointialuetta (esim. `HELSINKI`, `LANSI_UUSIMAA`) + `getNimi()`-metodi selkokieliselle suomenkieliselle tulostukselle.

### Palveluyksikko.java
- Kentät: `Long id` (Identity), `String nimi` (nullable=false), `String katuosoite`, `String postinumero`, `String postitoimipaikka`, `String puhelin`, `String sahkoposti`, `String kuvaus` (columnDefinition = "TEXT").
- Hyvinvointialue: `@Enumerated(EnumType.STRING) Hyvinvointialue hyvinvointialue`.
- Relaatiot:
  - `@ManyToOne @JoinColumn(name = "asiakas_id", nullable = false) Asiakas asiakas` (Emo-organisaatiolinkitys).
  - `@OneToMany(mappedBy = "palveluyksikko", cascade = CascadeType.ALL, orphanRemoval = true) List<Yhteyshenkilo> yhteyshenkilot`.

### Yhteyshenkilo.java
- Kentät: `Long id`, `String nimi`, `String rooli`, `String sahkoposti`, `String puhelin`.
- Relaatiot:
  - `@ManyToOne @JoinColumn(name = "asiakas_id", nullable = false) Asiakas asiakas`.
  - `@ManyToOne @JoinColumn(name = "palveluyksikko_id", nullable = true) Palveluyksikko palveluyksikko`.

### Kayttaja.java
- Kentät: `Long id`, `String kayttajatunnus`, `String salasana`, `String rooli`. `@OneToMany` suhde `Asiakas`-listaan.

### Tuote.java
- Kentät: `Long id`, `String nimi`, `String kuvaus`, `BigDecimal hinta`. `@Enumerated(EnumType.STRING) TuoteYksikko yksikko`.

### TuoteYksikko.java (Enum)
- Arvot: `KPL`, `TUNTI`, `KK`, `PV`, `KM`. `getLyhenne()`.

### AlvKanta.java (Enum)
- Sisältää dynaamisen ALV-laskennan prosentteina (esim. `ALV_25_5` palauttaa `25.5`).

### AsiakasTuote.java
- Relaatiot: `@ManyToOne` kytkökset `Asiakas` ja `Tuote`. 
- Kentät: `BigDecimal myyntihinta`, `Integer maara`, `@Enumerated(EnumType.STRING) AlvKanta alvKanta`.
- Matemaattiset metodit:
  - `getKokonaishinta()` -> Palauttaa raa'an verottoman yhteishinnan (Hinta * Määrä).
  - `getAlvOsuus()` -> Laskee ALV:n osuuden euroina käyttäen enumin prosenttia.
  - `getVerollinenKokonaishinta()` -> Laskee lopullisen verollisen hinnan (Veroton + ALV).

### Kirjaus.java
- Kentät: `Long id`, `String teksti` (columnDefinition = "TEXT"), `LocalDateTime luontiaika`. `@ManyToOne` kytkös `Asiakas`-malliin.
### TapahtumaTyyppi.java
- Kentät: `Long id` (Identity), `String nimi` (nullable=false, unique=true), `String vari` (nullable=false, columnDefinition="VARCHAR(255) DEFAULT '#0d6efd'").
- Värivalinnat (esim. `#0d6efd`, `#dc3545`) tallennetaan suoraan tietokantaan dynaamista FullCalendar-väritystä varten.

### Tapahtuma.java (Kalenteri)
- Relaatiot: `@ManyToOne @JoinColumn(name = "tapahtuma_tyyppi_id") TapahtumaTyyppi tyyppi`, kytkökset `Asiakas`- ja `Kayttaja`-malleihin.
- Kentät: `Long id`, `String otsikko`, `LocalDateTime ajankohta`, `String kuvaus`.

### Loki.java (Audit Trail)
- Kentät: `Long id`, `LocalDateTime aikaleima`, `String kayttajatunnus`, `String toiminto` (esim. KATSELU, LISÄYS, MUOKKAUS, POISTO), `String kuvaus`.

### Muut mallit
- `Tarjous.java`, `TarjousRivi.java`, `Yritystiedot.java` (ID 1L), `Liitetiedosto.java`.

---

## 🔌 3. Repository-rajapinnat (Repositories)

### AsiakasRepository.java
- `Page<Asiakas> findByKayttajaKayttajatunnus(String kayttajatunnus, Pageable pageable)`
- `Page<Asiakas> findByKayttajaKayttajatunnusAndHaku(...)`

### PalveluyksikkoRepository.java
- `List<Palveluyksikko> findByAsiakasId(Long asiakasId)`

### YhteyshenkiloRepository.java
- `List<Yhteyshenkilo> findByAsiakasId(Long asiakasId)`

### TapahtumaTyyppiRepository.java
- `List<TapahtumaTyyppi> findAll()`

### KirjausRepository.java
- `Page<Kirjaus> findByLuontiaikaBetweenOrderByLuontiaikaDesc(LocalDateTime alku, LocalDateTime loppu, Pageable pageable)` -> Hakee dynaamisesti 20 kirjausta per sivu tietokantatasolla.

### LokiRepository.java
- `Page<Loki> findAllByOrderByAikaleimaDesc(Pageable pageable)` -> Haetaan kaikki lokit 100 rivin erissä uusin ensin.
- `Page<Loki> findByAikaleimaBetweenOrderByAikaleimaDesc(LocalDateTime alku, LocalDateTime loppu, Pageable pageable)` -> Audit Trail -aikavälihaku 100 rivin sivutuksella.

---

## 🎮 4. Backend-kontrollerit (Controllers & Routes)

- **`AsiakasController.java`**: 
  - Ohjaa dashboardia, asiakaslistauksen sivutusta ja asiakasprofiilia.
  - Vastaanottaa asiakastietojen muokkaukset osoitteeseen `/asiakas/{id}/muokkaa` (POST) Bootstrap-modalista.
  - Kirjaa uuden asiakkaan luonnin automaattisesti järjestelmälokiin (`new Loki(istuntoTunnus, "LISÄYS", ...)`), mikä sytyttää vihreän badgen raporteissa.
  - Palveluyksikkö-reitit: `/asiakas/{asiakasId}/lisaa-palveluyksikko` (POST) sekä `/palveluyksikko/muokkaa/{id}` (POST).
  - Live Search reitti: `/asiakkaat/live-haku` (@ResponseBody).
- **`RaportitController.java`**:
  - Reitti `/raportit` (GET) tarkistaa istunnon ja hoitaa sekä yleisen lokilistauksen että dynaamisen aikavälihaun.
  - Sisältää tehokkaan `LokiRepository` ja `KirjausRepository` -sivutuksen (100 riviä lokeille, 20 riviä päiväkirjauksille). 
  - Jos aikaväliä ei anneta, asettaa oletukseksi automaattisesti viimeiset 30 vuorokautta.
  - Ryhmittelee sivutetut kirjaukset muistissa `Map<Long, List<Kirjaus>>` -rakenteeseen ilman tietokantaolioiden tilan sotkemista.
- **`TarjousController.java`**: Tarjousrivit `BigDecimal`-laskennalla (uusi 25.5 % ALV-tuki) ja OpenPDF-generoinnilla.
- **`AsetuksetController.java`**: 
  - Tuoterekisteri, työntekijät ja tapahtumatyypit.
  - Ääkkösettömät reitit konfliktien estämiseksi: `/asetukset/lisaa-tyyppi` (POST) ja `/asetukset/muokkaa-typpia/{id}` (POST).
- **`KalenteriController.java`**: Vastaanottaa tapahtumatyypin numeerisen ID:n reiteissä `/kalenteri/lisaa` ja `/kalenteri/paivita/{id}`.
## 💻 5. Käyttöliittymäkerros (JSP-näkymät)

- **`asiakasprofiili.jsp`**: 
  - Asiakkaan tietojen muokkaus tapahtuu siististi **Bootstrap 5 Modal-ikkunassa** (`#muokkaaAsiakasModal`) vanhan inline-muokkauksen sijaan.
  - Ostetut tuotteet ja palvelut -kortti listaa erikseen **Yhteensä (Alv 0%)**, **ALV-prosentin** sekä **Yhteensä (Verollinen)**.
  - Yläreunassa näytetään allekkain siistein välein (`gap-2`) kaksi badgea: **Asiakkuuden kokonaisarvo (sis. ALV)** (vihreä) ja **Veroton myynti yhteensä (Alv 0%)** (harmaa).
  - Kaikki HTML-sulkutagit (`</div>`) on korjattu ja sovitettu siististi Generic Code Editorin mukaiseksi.

- **`raportit.jsp`**: 
  - Sisältää dynaamisen **Bootstrap 5 -välilehtirakenteen** (Tabs), joka jakaa näkymän erillisiin alivälilehtiin: `📋 Asiakaskohtaiset päiväkirjaukset` ja `🛡️ Järjestelmän käyttöloki (Audit Trail)`.
  - Hakulomakkeeseen on lisätty `tab`-piilokenttä sekä alalaidan JavaScript-kuuntelijat. Kun käyttäjä painaa haku- tai sivutuspainiketta, näkymä muistaa ja pitää automaattisesti auki sen välilehden, josta klikkaus tapahtui.
  - Alalaidan Bootstrap 5 -sivutuspalkit säilyttävät kaikki valitut hakupäivämäärät ja välilehtitiedot URL-osoitteessa sivujen välillä liikuttaessa.

- **`asetukset.jsp`**: 
  - Tapahtumatyypit listataan ID:n ja nimen mukaan. Muokkausmodal (`#muokkaaTyyppiModal`) lähettää muuttujan `name="nimi"` JavaScriptillä dynaamisesti päivitettyyn polkuun `/asetukset/muokkaa-typpia/{id}`.

- **`kalenteri.jsp`**: 
  - Alustaa FullCalendar 6 -kuukausinäkymän, jossa tapahtumat värjätään suoraan tietokannasta luetulla dynaamisella `vari`-sarakkeella.
  - Kalenteriruudukko näyttää vain kellonajan, tyypin nimen sekä dynaamisesti katkaistun asiakasnimen (jos yli 10 merkkiä, esim. `Puhelu, Palvelutal...`). Alkuperäinen aihe on piilotettu ruudukosta.
  - Kursoria elementin päälle vietäessä aukeaa interaktiivinen Bootstrap 5 Tooltip, joka näyttää tyypin, puhtaan alkuperäisen otsikon, täyden asiakasnimen sekä lisätiedot omilla riveillään HTML-muotoiltuna.
  - Klikattaessa muokkauslomake (`eventClick`) lukee puhtaan aiheen suoraan `extendedProps.alkuperainenOtsikko` -muuttujasta, jolloin aihe-kenttä ei sotkeudu dynaamisista liitteistä.
