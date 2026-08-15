<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kalenteri - Astori</title>
    <!-- Bootstrap tyylit suoraan resources-juuresta -->
    <link href="${pageContext.request.contextPath}/resources/bootstrap.min.css" rel="stylesheet" />
    <!-- FullCalendar 6 -kirjaston tyylit ja skriptit valmiina käyttöön -->
    <script src="${pageContext.request.contextPath}/resources/index.global.min.js"></script>
    <style>
        body { background-color: #f8f9fa; }
        .calendar-card { background: white; border-radius: 8px; padding: 20px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
        /* Muokataan FullCalendar muistuttamaan enemmän Microsoftin kalenteria */
        .fc-header-toolbar { margin-bottom: 20px !important; }
        .fc-button-primary { background-color: #0d6efd !important; border-color: #0d6efd !important; fw-bold; }
        .fc-button-primary:hover { background-color: #0b5ed7 !important; }
        .fc-daygrid-event { border-radius: 4px; padding: 2px 4px; font-size: 0.85em; cursor: pointer; }
    </style>
</head>
<body>

    <!-- YLÄPALKKI -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark mb-4 shadow-sm">
        <div class="container">
            <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/">Astori</a>
            <div class="navbar-nav me-auto">
                <a class="nav-link" href="${pageContext.request.contextPath}/">Asiakkaat</a>
                <a class="nav-link" href="${pageContext.request.contextPath}/asetukset">Asetukset</a>
                <a class="nav-link" href="${pageContext.request.contextPath}/raportit">Raportit</a>
                <a class="nav-link active fw-bold" href="${pageContext.request.contextPath}/kalenteri">Kalenteri</a>
            </div>
            <div class="d-flex align-items-center">
                <span class="navbar-text text-white me-3">Käyttäjä: <strong>${kirjautunutKayttaja}</strong></span>
                <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline-danger btn-sm">Kirjaudu ulos</a>
            </div>
        </div>
    </nav>

    <div class="container py-2">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="text-dark fw-bold mb-0">Kalenteri</h2>
            <!-- Painike uuden tapaamisen lisäämiseksi sivun laitaan -->
            <button type="button" class="btn btn-primary fw-bold shadow-sm" data-bs-toggle="modal" data-bs-target="#lisaaTapahtumaModal">
                + Uusi kalenterivaraus
            </button>
        </div>

        <!-- KALENTERIN RUUDUKKO -->
        <div class="calendar-card border mb-5">
            <div id="calendar"></div>
        </div>
    </div>
        <!-- BOOTSTRAP POP-UP LOMAKE UUDELLE VARAUKSELLE -->
    <div class="modal fade" id="lisaaTapahtumaModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title fw-bold">Uusi kalenterivaraus</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <form action="${pageContext.request.contextPath}/kalenteri/lisaa" method="post">
                    <div class="modal-body p-4">
                        
                        <div class="mb-3">
                            <label for="asiakasId" class="form-label fw-semibold text-secondary">Liitä asiakkaaseen</label>
                            <select class="form-select" id="asiakasId" name="asiakasId" required>
                                <option value="">-- Valitse asiakas listasta --</option>
                                <c:forEach var="a" items="${asiakkaat}">
                                    <option value="${a.id}">${a.nimi}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label for="tyyppi" class="form-label fw-semibold text-secondary">Tapahtuman tyyppi</label>
                            <select class="form-select" id="tyyppi" name="tyyppi" required>
                                <c:forEach var="t" items="${tyypit}">
                                    <option value="${t}">${t.nayttorivi}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label for="otsikko" class="form-label fw-semibold text-secondary">Otsikko / Aihe</label>
                            <input type="text" class="form-control" id="otsikko" name="otsikko" required placeholder="esim. Sopimusneuvottelu, Seurantapuhelu">
                        </div>

                        <div class="mb-3">
                            <label for="ajankohtaStr" class="form-label fw-semibold text-secondary">Ajankohta ja kellonaika</label>
                            <!-- datetime-local tuo selaimeen hienon kellon ja kalenterin valintatyökalun -->
                            <input type="datetime-local" class="form-control" id="ajankohtaStr" name="ajankohtaStr" required>
                        </div>

                        <div class="mb-3">
                            <label for="kuvaus" class="form-label fw-semibold text-secondary">Lisätiedot / Muistiinpanot</label>
                            <textarea class="form-control" id="kuvaus" name="kuvaus" rows="3" placeholder="Mitä sovitaan tai käydään läpi..."></textarea>
                        </div>

                    </div>
                    <div class="modal-footer bg-light">
                        <button type="button" class="btn btn-secondary" data-bs-disabled="modal">Peruuta</button>
                        <button type="submit" class="btn btn-primary px-4 fw-bold">Tallenna kalenteriin</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    	<!-- JAVASCRIPT-ALUSTUS KALENTERIN PIIRTÄMISEKSI -->
	<script>
        document.addEventListener('DOMContentLoaded', function() {
            var calendarEl = document.getElementById('calendar');
            
            var calendar = new FullCalendar.Calendar(calendarEl, {
                initialView: 'dayGridMonth',
                locale: 'fi', // Asetetaan kalenterin kieleksi suomi
                firstDay: 1,  // Viikko alkaa maanantaista
                headerToolbar: {
                    left: 'prev,next today',
                    center: 'title',
                    right: 'dayGridMonth,timeGridWeek,listMonth' // Kuukausi-, viikko- ja agendanäkymät
                },
                buttonText: {
                    today: 'Tämä päivä',
                    month: 'Kuukausi',
                    week: 'Viikko',
                    list: 'Lista'
                },
                
                // SYÖTETÄÄN TIETOKANNASTA TULEVAT TAPAHTUMAT JSTL-LOOPIN AVULLA KALENTERIIN
                events: [
                    <c:forEach var="tap" items="${tapahtumat}" varStatus="status">
                        {
                            title: '${tap.tyyppi.nayttorivi}: ${tap.otsikko} (${tap.asiakas.nimi})',
                            // Muutetaan LocalDateTime sellaiseen muotoon, jota JavaScript ymmärtää varmasti (ISO)
                            start: '${tap.ajankohta.toString()}', 
                            description: '${tap.kuvaus}',
                            
                            // MÄÄRITETÄÄN VÄRIT MICROSOFT-TYYLIIN TAPAHTUMATYYPIN MUKAAN
                            <c:choose>
                                <c:when test="${tap.tyyppi == 'PUHELU'}">
                                    backgroundColor: '#ffc107', borderHex: '#ffc107', textColor: '#000'
                                </c:when>
                                <c:when test="${tap.tyyppi == 'TAPAAMINEN'}">
                                    backgroundColor: '#198754', borderColor: '#198754', textColor: '#fff'
                                </c:when>
                                <c:when test="${tap.tyyppi == 'ETAKOKOUS'}">
                                    backgroundColor: '#0dcaf0', borderColor: '#0dcaf0', textColor: '#000'
                                </c:when>
                                <c:otherwise>
                                    backgroundColor: '#6c757d', borderColor: '#6c757d', textColor: '#fff'
                                </c:otherwise>
                            </c:choose>
                        }${!status.last ? ',' : ''} // Lisätään pilkku rivien väliin, paitsi viimeiseen
                    </c:forEach>
                ],
                
                // Näytetään tapahtuman kuvaus pop-up-ikkunana (alert), kun sitä klikataan
                eventClick: function(info) {
                    alert(info.event.title + "\n\nLisätiedot:\n" + (info.event.extendedProps.description || "Ei kuvailua."));
                }
            });
            
            calendar.render();
        });
    </script>

	<!-- Lataa paikallisen Bootstrap-JavaScriptin aivan tiedoston lopussa -->
	<script src="${pageContext.request.contextPath}/resources/bootstrap.bundle.min.js"></script>
</body>
</html>
    
