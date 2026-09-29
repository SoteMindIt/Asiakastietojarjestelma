# AI_CONTEXT.md - Astori CRM Järjestelmäarkkitehtuuri

## 1. Järjestelmän yleiskuva
Astori on moderni asiakkuudenhallintajärjestelmä ei pelkästään sote-alalle, vaan myös muille aloille (CRM). Järjestelmä on rakennettu Spring Boot 3.x -kehyksellä, hyödyntää PostgreSQL-tietokantaa ja sen käyttöliittymäkerros on toteutettu JSP (JavaServer Pages) -tekniikalla ja Bootstrap 5 -muotoilulla.

- **Tekniikka:** Java 17, Spring Boot 3.x, Maven (war-pakkaus)
- **Tietokanta:** PostgreSQL (tietokanta: `asiakastiedot`) + Spring Data JPA (`ddl-auto=update`)
- **Käyttöliittymä:** JSP (sijainti: `/WEB-INF/jsp/`) ja Generic Code Editor (Wild Web Developer) oletuksena.
- **Lisäkirjastot:** Spring Security Crypto/Web, OpenPDF 1.3.40 (raportointi), FullCalendar 6

---

## ⚙️ 2. Konfiguraatiot ja Perusrakenne

### pom.xml (Maven)
- Riippuvuudet: `spring-boot-starter-web`, `spring-boot-starter-data-jpa`, `postgresql`, `spring-security-crypto`, `openpdf` (versio 1.3.40), `tomcat-embed-jasper` ja `jakarta.servlet.jsp.jstl` (JSP/JSTL-tuki Spring Boot 3:ssa).

### application.properties
- Tietokantayhteys: `jdbc:postgresql://localhost:5432/asiakastiedot` (tunnus: `postgres`, salasana: `admin`).
- JPA-asetukset: Dialekti `PostgreSQLDialect`, `ddl-auto=update`, `show-sql=true`.
- MVC-asetukset: Prefiksi `/WEB-INF/jsp/` ja suffiksi `.jsp`.

---

## 🏛️ 3. Tietomallit (Entities / Models)

### Asiakas.java
- Kentät: Long id (Identity), String nimi (nullable=false), String puhelin, String sahkoposti, String katuosoite, String postinumero, String postitoimipaikka, String kotisivu, String yTunnus (length=9), String kuvaus.
- Koordinaatit: `Double leveysaste` (Latitude) ja `Double pituusaste` (Longitude) valmiina tulevaa 100 km säteellistä kilometrihakua ja geokoodausta varten.
- Tila: `@Enumerated(EnumType.STRING) AsiakkaanTila tila` (Oletus: PROSPEKTI).
- Hyvinvointialue: `@Enumerated(EnumType.STRING) Hyvinvointialue hyvinvointialue` (Kytketty dynaamiseen enumiin).
- Relaatiot (Kytketty täydellä `CascadeType.ALL, orphanRemoval = true` suhteella automaattista ja turvallista asiakkaan poistamista varten):
  - `@ManyToOne @JoinColumn(name = "kayttaja_id") Kayttaja kayttaja`
  - `@OneToMany` palveluyksiköt, yhteyshenkilöt, kirjaukset ja tarjoukset.
- Konstruktori: 11 argumentin standardkonstruktori.

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
- Kentät: `String prosenttiStr`, `String nayttorivi` (suomenkielinen seloste dynaamisille pikalomakkeille).

### AsiakasTuote.java
- Relaatiot: `@ManyToOne` kytkökset `Asiakas` ja `Tuote`.
- Kentät: `BigDecimal myyntihinta`, `BigDecimal maara`, `@Enumerated(EnumType.STRING) AlvKanta alvKanta`.
- Matemaattiset metodit:
  - `getKokonaishinta()` -> Palauttaa raa'an verottoman yhteishinnan (Hinta * Määrä).
  - `getAlvOsuus()` -> Laskee ALV:n osuuden euroina käyttäen enumin prosenttia.
  - `getVerollinenKokonaishinta()` -> Laskee lopullisen verollisen hinnan (Veroton + ALV).

### AsiakasAjo.java (Asiakkaalta laskutettavien ajojen seuranta)
- Taulu `asiakasajot`; pakollinen `@ManyToOne Asiakas`-linkki asiakkaaseen.
- Kentät: `LocalDate paivamaara`, lähtöpaikka, kohde, tarkoitus, `BigDecimal`-alku- ja loppumatkamittari, `boolean edestakainen` ja vapaaehtoinen laskuviite.
- `getKilometrit()` laskee loppu- ja alkumatkamittarin erotuksen. Edestakaisuutta ei kerrota erikseen kahdella, koska mittarilukemat kattavat koko ajetun matkan.
- Asiakkaalla on `@OneToMany(cascade = CascadeType.ALL, orphanRemoval = true)` -suhde ajoihinsa; asiakkaan poisto poistaa myös ajot.
- Tämä on omaa asiakaskohtaista ajoseurantaa varten. Se ei kirjaa yksityisajoja eikä laske kilometrikorvauksia.

### Muustiinpano.java (UUSI - Työpöydän sisäiset muistilistat)
- Kentät: `Long id` (Identity), `String teksti` (columnDefinition = "TEXT", nullable = false), `LocalDateTime luontiaika`, `String kayttajatunnus`.
- Käyttö: Tallentaa organisaation tai työntekijän yleiset muistettavat asiat, ilmoitukset tai sisäiset listat, joita ei kytketä mihinkään tiettyyn asiakasorganisaatioon.

### Kirjaustyyppi.java (UUSI - Dynaamiset CRM-hakuluokitukset)
- Kentät: `Long id` (Identity), `String nimi` (nullable=false), `String vari` (nullable=false, pituus=7).
- Käyttö: Tallentaa dynaamiset kirjausten aiheluokitukset (esim. *Koulutuskysely*, *Laitehuolto*) ja niihin kytketyt badge Hex-värit (esim. `#0d6efd`) vapaiden CRM-hakuehtojen muodostamiseksi.

### Kirjaus.java (Asiakkaan päiväkirjaukset / sovitut asiat)
- Kentät: `Long id`, `String teksti` (columnDefinition = "TEXT"), `LocalDateTime luontiaika`, `boolean tarkea` (merkintä tärkeäksi / huomionarvoiseksi, oletussarake tietokannassa `DEFAULT false`).
- Relaatiot:
  - `@ManyToOne @JoinColumn(name = "asiakas_id", nullable = false) Asiakas asiakas`.
  - `@ManyToOne @JoinColumn(name = "kirjaustyyppi_id", nullable = true) Kirjaustyyppi kirjaustyyppi` (Kytkentä dynaamiseen hakuluokitukseen. Nullable=true takaa taaksepäinYhteensopivuuden vanhoille riveille).
  - `@ManyToMany` (Self-referencing): `List<Kirjaus> linkitetytKirjaukset` -> Jira-tyylinen molemminpuolinen linkitys toisiin sovittuihin asioihin. Liitostaulu tietokannassa: `public.kirjaus_linkitykset` (`kirjaus_id`, `linkitetty_kirjaus_id`).
  - Sisältää apumetodin `linkitäKirjaukseen(Kirjaus toinenKirjaus)`.

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

## 🔌 4. Repository-rajapinnat (Repositories)

### AsiakasRepository.java
- `Page<Asiakas> findByKayttajaKayttajatunnus(String kayttajatunnus, Pageable pageable)`
- `findByKayttajaKayttajatunnusAndHaku` -> Vapaa tekstihaku viidelle kentälle.
- **Päivitetty aluesuodatus (`LEFT JOIN DISTINCT`):** Hakumetodit `findByKayttajaKayttajatunnusAndHyvinvointialue` sekä `findByKayttajaKayttajatunnusAndHyvinvointialueAndHaku` kytkevät hakuun mukaan sekä asiakkaan oman että kaikkien sen palveluyksikköjen hyvinvointialueet ilman tuplarivejä.
- **Uudet dynaamiset CRM-hakumetodit kirjaustyypeille (`JOIN DISTINCT`):**
  - `findByKayttajaKayttajatunnusAndKirjaustyyppi` -> Suodattaa pelkän kirjaustyypin mukaan.
  - `findByKayttajaKayttajatunnusAndKirjaustyyppiAndHaku` -> Tekstihaku + Kirjaustyyppi.
  - `findByKayttajaKayttajatunnusAndHyvinvointialueAndKirjaustyyppi` -> Hyvinvointialue + Kirjaustyyppi.
  - `findByKayttajaKayttajatunnusAndHyvinvointialueAndKirjaustyyppiAndHaku` -> Jättihaku kaikilla kolmella ehdolla ristiin.
- `countByKayttajaKayttajatunnus` -> Korjattu ja varma laskuri.

### MuistiinpanoRepository.java (UUSI)
- `List<Muistiinpano> findByKayttajatunnusOrderByLuontiaikaDesc(String kayttajatunnus)` -> Hakee työntekijän yleiset etusivun muistilistat ja tiedotteet kronologisesti siten, että uusimmat nousevat aina listan kärkeen.

### KirjaustyyppiRepository.java (UUSI)
- Standardi `JpaRepository<Kirjaustyyppi, Long>` -rajapinta dynaamisten hakuluokitusten hallintaan.

### KirjausRepository.java, PalveluyksikkoRepository.java, YhteyshenkiloRepository.java, TapahtumaTyyppiRepository.java, LokiRepository.java.

### AsiakasAjoRepository.java
- `haeAjot(tunnus, alku, loppu, asiakasId)` hakee aikavälin ajot kirjautuneen käyttäjän omilta asiakkailta, vapaaehtoisella asiakassuodattimella, uusin ensin.
- `haeAsiakkaatJoillaAjoja(tunnus)` palauttaa vain ne kirjautuneen käyttäjän asiakkaat, joille on jo kirjattu ajo.

### KirjausRepository.java (Raporttihaku)
- `findAsiakasKirjauksetAjanjaksolta(...)` hakee kirjautuneen käyttäjän asiakkaiden merkinnät aikaväliltä, valinnaisella kirjaustyyppisuodattimella ja aikajärjestyksessä uusimmasta vanhimpaan. Sivutus tapahtuu kyselyn jälkeen.

---

## 🎮 5. Backend-kontrollerit (Controllers & Routes)

### AsiakasController.java
- Ohjaa dashboardia, asiakaslistauksen sivutusta ja asiakasprofiilia (`/asiakas/{id}`).
- `listaaAsiakkaat` (@GetMapping("/asiakkaat")): Ottaa vastaan `alue`-, `haku`- ja uuden `tyyppi` (kirjaustyyppi ID) -parametrit. Suodattaa asiakkaat dynaamisesti **8 eri hakuvariaation** mukaan lennosta. Vuo viedään myös asiakasprofiiliin valintalistoja varten.
- Vastaanottaa asiakastietojen muokkaukset osoitteeseen `/asiakas/{id}/muokkaa` (POST).
- `poistaAsiakas` (@PostMapping("/asiakas/{id}/poista")): Poistaa asiakkaan ja puhdistaa kaikki alirivit (yhteyshenkilöt, tarjoukset jne.) kerralla tietokannan eheyssääntöjen mukaisesti.
- Live Search reitti: `/asiakkaat/live-haku` (@ResponseBody).

### TuoteController.java (UUSI - Eriytetty arkkitehtuuri)
- Vastaa tuoterekisterin, hinnastojen ja ALV-kantojen tallennuksista ja inline-muokkauksista (Single Responsibility Principle).
- Reitit: `/asetukset/lisaa-tuote` (POST) hinnaston laajentamiseen sekä dynaamisesti kytketty `/asetukset/muokkaa-tuotetta/{id}` (POST) tuoterivien nopeaan inline-päivitykseen.

### MuistiinpanoController.java (UUSI - Eriytetty arkkitehtuuri)
- Käsittelee työpöydän globaalien muistilistojen ja organisaation sisäisten tiedotteiden tallennuksen (Single Responsibility Principle).
- Reitit: `/lisaa-muistiinpano` (POST) ottaa vastaan etusivun dynaamisesta pop-up-lomakkeesta tulleen vapaan tekstin ja kytkee sen sisäänkirjautuneen työntekijän istuntotunnukseen.

### KirjaustyyppiController.java (UUSI)
- Käsittelee dynaamisten asiakaskirjausten aiheluokitusten hallinnan (Single Responsibility Principle).
- Reitit: `/asetukset/lisaa-kirjaustyyppi` (POST) ja `/asetukset/muokkaa-kirjaustyyppia/{id}` (POST) tunnusvärien ja aihenimien tallennukseen.

### KirjausController.java
- Vastaa puhtaasti päiväkirjauksista ja sovituista asioista (Single Responsibility Principle).
- Laajennettu ottamaan vastaan `@RequestParam(value = "kirjaustyyppiId", required = false) Long kirjaustyyppiId` sekä uuden kirjauksen (`/lisaa-kirjaus`) että muokkauksen (`/muokkaa/{id}`) yhteydessä, kytkien luokituksen turvallisesti olioon.
- `poistaKirjausLinkki` (@PostMapping("/kirjaus/{id}/poista-linkki/{linkkiId}")): Katkaisee kahden kirjauksen välisen linkityksen molemminpuolisesti, jos kyseessä on inhimillinen virhe.

### RaportitController.java
- Hoitaa aikavälirajaukset, Auditin ja dynaamiset myyntilaskennat (ALV-erittelyt ja 0% KM-korvausten erottamiset).
- Ohjaa `@GetMapping("/raportit")` -reitillä asiakaskirjaukset yhteen aikajärjestyksessä (uusin ensin) esitettävään listaan. Haku rajaa kirjaukset tietokantakyselyssä kirjautuneen käyttäjän asiakkaisiin ennen sivutusta.
- Raporttisivun yhteinen päivämäärä- ja kirjaustyyppisuodatin sijaitsee välilehtien yläpuolella ja säilyttää aktiivisen välilehden haussa. Audit Trail -välilehdellä yhteinen kirjaussuodatin piilotetaan; Audit Traililla on oma päivämäärähaku. Myyntiraportilla ja Ajopäiväkirjalla on omat suodattimensa.
- Päivämäärät syötetään raporttinäkymässä suomalaisessa `pp.kk.vvvv`-muodossa ja muunnetaan selaimessa palvelimelle ISO-muotoon (`yyyy-MM-dd`).

### AsiakasAjoController.java
- Reitit: `POST /raportit/ajot/lisaa`, `POST /raportit/ajot/muokkaa/{id}` ja `POST /raportit/ajot/poista/{id}`.
- Varmistaa, että lisättävä asiakas ja käsiteltävä ajo kuuluvat kirjautuneelle käyttäjälle. Lisäykset, muokkaukset ja poistot kirjataan `Loki`-audit trailiin.

### Muut kontrollerit
- `TarjousController.java` (25.5 % ALV), `AsetuksetController.java` (ääkkösettömät reitit suojatuilla suljetuilla haitareilla ja itsenäisellä varmuuskopiokortilla, josta tuotehallinnan reitit on poistettu), `KalenteriController.java` (FullCalendar 6).
