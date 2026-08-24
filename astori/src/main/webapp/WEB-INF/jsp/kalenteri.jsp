<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="fi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Kalenteri - Astori</title>
<!-- Bootstrap tyylit suoraan resources-juuresta -->
<link
	href="${pageContext.request.contextPath}/resources/bootstrap.min.css"
	rel="stylesheet" />
<!-- FullCalendar 6 -kirjaston tyylit ja skriptit valmiina käyttöön -->
<script
	src="${pageContext.request.contextPath}/resources/index.global.min.js"></script>
<style>
body {
	background-color: #f8f9fa;
}

.calendar-card {
	background: white;
	border-radius: 8px;
	padding: 20px;
	box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
}

.fc-header-toolbar {
	margin-bottom: 20px !important;
}

.fc-button-primary {
	background-color: #0d6efd !important;
	border-color: #0d6efd !important;
	font-weight: bold;
}

.fc-button-primary:hover {
	background-color: #0b5ed7 !important;
}

.fc-daygrid-event {
	border-radius: 4px;
	padding: 2px 4px;
	font-size: 0.85em;
	cursor: pointer;
}
</style>
</head>
<body>

	<!-- YLÄPALKKI -->
	<nav class="navbar navbar-expand-lg navbar-dark bg-dark mb-4 shadow-sm">
		<div class="container">
			<a class="navbar-brand fw-bold"
				href="${pageContext.request.contextPath}/">Astori</a>
			<div class="navbar-nav me-auto">
				<a class="nav-link" href="${pageContext.request.contextPath}/">Asiakkaat</a>
				<a class="nav-link"
					href="${pageContext.request.contextPath}/asetukset">Asetukset</a> <a
					class="nav-link" href="${pageContext.request.contextPath}/raportit">Raportit</a>
				<a class="nav-link active fw-bold"
					href="${pageContext.request.contextPath}/kalenteri">Kalenteri</a>
			</div>
			<div class="d-flex align-items-center">
				<span class="navbar-text text-white me-3">Käyttäjä: <strong>${kirjautunutKayttaja}</strong></span>
				<a href="${pageContext.request.contextPath}/logout"
					class="btn btn-outline-danger btn-sm">Kirjaudu ulos</a>
			</div>
		</div>
	</nav>

	<div class="container py-2">
		<div class="d-flex justify-content-between align-items-center mb-4">
			<h2 class="text-dark fw-bold mb-0">Kalenteri</h2>
			<button type="button" class="btn btn-primary fw-bold shadow-sm"
				data-bs-toggle="modal" data-bs-target="#lisaaTapahtumaModal">
				+ Uusi kalenterivaraus</button>
		</div>

		<!-- KALENTERIN RUUDUKKO -->
		<div class="calendar-card border mb-5">
			<div id="calendar"></div>
		</div>
	</div>

	<!-- BOOTSTRAP POP-UP LOMAKE UUDELLE VARAUKSELLE -->
	<div class="modal fade" id="lisaaTapahtumaModal" tabindex="-1"
		aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content border-0 shadow-lg">
				<div class="modal-header bg-primary text-white">
					<h5 class="modal-title fw-bold">Uusi kalenterivaraus</h5>
					<button type="button" class="btn-close btn-close-white"
						data-bs-dismiss="modal"></button>
				</div>
				<form action="${pageContext.request.contextPath}/kalenteri/lisaa"
					method="post">
					<div class="modal-body p-4">

						<div class="mb-3">
							<label for="asiakasHaku"
								class="form-label fw-semibold text-secondary">Liitä
								asiakkaaseen (Valinnainen)</label>

							<!-- Hakukenttä, joka näyttää pudotusvalikon ja suodattaa tekstiä -->
							<input type="text" class="form-control" id="asiakasHaku"
								list="asiakasLista"
								placeholder="Kirjoita nimi tai valitse listasta...">

							<!-- Piilokenttä, joka lähettää varsinaisen tietokanta-ID:n palvelimelle -->
							<input type="hidden" id="asiakasId" name="asiakasId">

							<!-- Dynaaminen lista, jonka selain näyttää pudotusvalikkona -->
							<datalist id="asiakasLista">
								<c:forEach var="a" items="${asiakkaat}">
									<option data-id="${a.id}" value="${a.nimi}"></option>
								</c:forEach>
							</datalist>
							<small class="form-text text-muted">Jätä tyhjäksi, jos
								kyseessä on sisäinen merkintä.</small>
						</div>

						<div class="mb-3">
							<label for="tyyppi" class="form-label fw-semibold text-secondary">Tapahtuman
								tyyppi</label> <select class="form-select" id="tyyppi" name="tyyppi"
								required>
								<c:forEach var="t" items="${tyypit}">
									<option value="${t}">${t.nayttorivi}</option>
								</c:forEach>
							</select>
						</div>

						<div class="mb-3">
							<label for="otsikko"
								class="form-label fw-semibold text-secondary">Otsikko /
								Aihe</label> <input type="text" class="form-control" id="otsikko"
								name="otsikko" required
								placeholder="esim. Sopimusneuvottelu, Seurantapuhelu">
						</div>

						<div class="mb-3">
							<label for="ajankohtaStr"
								class="form-label fw-semibold text-secondary">Ajankohta
								ja kellonaika</label> <input type="datetime-local" class="form-control"
								id="ajankohtaStr" name="ajankohtaStr" required>
						</div>

						<div class="mb-3">
							<label for="kuvaus" class="form-label fw-semibold text-secondary">Lisätiedot
								/ Muistiinpanot</label>
							<textarea class="form-control" id="kuvaus" name="kuvaus" rows="3"
								placeholder="Mitä sovitaan tai käydään läpi..."></textarea>
						</div>

					</div>
					<div class="modal-footer bg-light">
						<button type="button" class="btn btn-secondary"
							data-bs-dismiss="modal">Peruuta</button>
						<button type="submit" class="btn btn-primary px-4 fw-bold">Tallenna
							kalenteriin</button>
					</div>
				</form>
			</div>
		</div>
	</div>

	<!-- BOOTSTRAP POP-UP VALMIIN MERKINNÄN KATSELUUN JA POISTOON -->
	<div class="modal fade" id="katsoTapahtumaModal" tabindex="-1"
		aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content border-0 shadow-lg">
				<div class="modal-header bg-dark text-white">
					<h5 class="modal-title fw-bold" id="viewOtsikko">Kalenteritapahtuma</h5>
					<button type="button" class="btn-close btn-close-white"
						data-bs-dismiss="modal"></button>
				</div>
				<div class="modal-body p-4">
					<div class="mb-3">
						<small class="text-uppercase fw-bold text-muted d-block">Asiakas</small>
						<span id="viewAsiakas" class="fs-5 fw-semibold text-dark">-</span>
					</div>
					<div class="mb-3">
						<small class="text-uppercase fw-bold text-muted d-block">Ajankohta</small>
						<span id="viewAika" class="fs-5 text-dark">-</span>
					</div>
					<div class="mb-3">
						<small class="text-uppercase fw-bold text-muted d-block">Kuvaus
							/ Muistiinpanot</small>
						<p id="viewKuvaus"
							class="bg-light p-3 rounded border text-secondary"
							style="white-space: pre-wrap;">-</p>
					</div>
				</div>
				<div class="modal-footer bg-light d-flex justify-content-between">
					<!-- POISTOLOMAKE -->
					<form action="${pageContext.request.contextPath}/kalenteri/poista"
						method="post"
						onsubmit="return confirm('Haluatko varmasti poistaa tämän kalenterivarauksen?');">
						<input type="hidden" id="poistaTapahtumaId" name="tapahtumaId">
						<button type="submit" class="btn btn-danger fw-bold">Poista
							varaus</button>
					</form>
					<button type="button" class="btn btn-secondary px-4"
						data-bs-dismiss="modal">Sulje</button>
				</div>
			</div>
		</div>
	</div>

	<!-- BOOTSTRAP JAVASCRIPT REKISTERISTÄ -->
	<script
		src="${pageContext.request.contextPath}/resources/bootstrap.bundle.min.js"></script>

	<!-- JAVASCRIPT-ALUSTUS KALENTERIN PIIRTÄMISEKSI -->
	<script>
        document.addEventListener('DOMContentLoaded', function() {
            var calendarEl = document.getElementById('calendar');
            
            // Muuttujat tuplaklikkauksen tunnistamiseen
            var lastClickedDate = null;
            var lastClickTime = 0;

            var calendar = new FullCalendar.Calendar(calendarEl, {
                initialView: 'dayGridMonth',
                locale: 'fi', // Asetetaan kalenterin kieleksi suomi
                firstDay: 1,  // Viikko alkaa maanantaista
                headerToolbar: {
                    left: 'prev,next today',
                    center: 'title',
                    right: 'dayGridMonth,timeGridWeek,listMonth'
                },
                buttonText: {
                    today: 'Tämä päivä',
                    month: 'Kuukausi',
                    week: 'Viikko',
                    list: 'Lista'
                },
                
                // 1. TOIMINTO: TAPAHTUMAN KLIKKAUS (TIETOJEN KATSELU)
                eventClick: function(info) {
                    info.jsEvent.preventDefault();

                    // Täytetään klikatun tapahtuman tiedot modal-ikkunan kenttiin
                    document.getElementById('viewOtsikko').innerText = info.event.title;
                    document.getElementById('viewKuvaus').innerText = info.event.extendedProps.description || 'Ei kuvausta.';
                    
                    // Muotoillaan alkamisaika siististi suomalaiseen silmään
                    if (info.event.start) {
                        let pvm = new Date(info.event.start);
                        let muotoiltuAika = pvm.toLocaleDateString('fi-FI') + ' klo ' + 
                                            pvm.toLocaleTimeString('fi-FI', {hour: '2-digit', minute:'2-digit'});
                        document.getElementById('viewAika').innerText = muotoiltuAika;
                    }
                    
                    // Syötetään asiakkaan nimi extendedProps-lohkosta
                    document.getElementById('viewAsiakas').innerText = info.event.extendedProps.asiakasNimi || 'Liitetty asiakkaaseen';

                    // Asetetaan ID piilokenttään poistamista varten
                    document.getElementById('poistaTapahtumaId').value = info.event.id;

                    // Avataan katselu-modal ohjelmallisesti
                    var viewModal = new bootstrap.Modal(document.getElementById('katsoTapahtumaModal'));
                    viewModal.show();
                },
                
                // 2. TOIMINTO: TYHJÄN RUUDUN TUPLAKLIKKAUS (UUSI VARAUS)
                dateClick: function(info) {
                    var currentTime = new Date().getTime();
                    var clickDelay = currentTime - lastClickTime;

                    if (lastClickedDate === info.dateStr && clickDelay < 400) {
                        let valittuPvm = info.dateStr; 
                        
                        if (valittuPvm.length === 10) {
                            valittuPvm += "T09:00"; // Oletusaika kuukausinäkymässä
                        } else {
                            valittuPvm = valittuPvm.substring(0, 16);
                        }

                        document.getElementById('ajankohtaStr').value = valittuPvm;

                        var addModal = new bootstrap.Modal(document.getElementById('lisaaTapahtumaModal'));
                        addModal.show();
                    }

                    lastClickedDate = info.dateStr;
                    lastClickTime = currentTime;
                },
                
                // LADATAAN TAPAHTUMAT TIETOKANNASTA ILMAN HERJAAVIA KENOWIIVOJA
                events: [
                    <c:forEach var="tap" items="${tapahtumat}" varStatus="status">
                        {
                            id: '${tap.id}',
                            title: '<c:out value="${tap.otsikko}"/> [${tap.kayttaja.etunimi} ${tap.kayttaja.sukunimi.substring(0,1)}.]',
                            start: '${tap.ajankohta.toString()}', 
                            extendedProps: {
                                // c:out siivoaa automaattisesti kaikki vaaralliset merkit, jotka voisivat rikkoa JavaScriptin
                                description: '<c:out value="${tap.kuvaus}"/>',
                                asiakasNimi: '<c:out value="${tap.asiakas.nimi}"/>',
                                tyyppiRivi: '${tap.tyyppi.nayttorivi}'
                            },
                            
                            // Väritetään tapahtumat dynaamisesti tyypin perusteella
                            <c:choose>
                            <c:when test="${tap.tyyppi.name() == 'PUHELU' || tap.tyyppi.name() == 'SOITTO'}">
                                backgroundColor: '#ffc107', borderColor: '#ffc107', textColor: '#000000'
                            </c:when>
                            <c:when test="${tap.tyyppi.name() == 'TAPAAMINEN'}">
                                backgroundColor: '#198754', borderColor: '#198754', textColor: '#ffffff'
                            </c:when>
                            <c:when test="${tap.tyyppi.name() == 'SÄHKÖPOSTI'}">
                                backgroundColor: '#0dcaf0', borderColor: '#0dcaf0', textColor: '#000000'
                            </c:when>
                            <c:otherwise>
                                backgroundColor: '#0d6efd', borderColor: '#0d6efd', textColor: '#ffffff'
                            </c:otherwise>
                        </c:choose>
                        }${!status.last ? ',' : ''}
                    </c:forEach>
                ]
            });
            
            calendar.render();
            // Kuunnellaan hakukentän kirjoitusta ja muutetaan teksti ID-numeroksi
            document.getElementById('asiakasHaku').addEventListener('input', function(e) {
                var inputValue = e.target.value;
                var options = document.querySelectorAll('#asiakasLista option');
                var hiddenInput = document.getElementById('asiakasId');
                
                hiddenInput.value = ""; // Nollataan ID oletuksena

                for (var i = 0; i < options.length; i++) {
                    if (options[i].value === inputValue) {
                        hiddenInput.value = options[i].getAttribute('data-id');
                        break;
                    }
                }
            });

            // Tyhjennetään hakukentät aina, kun uusi modal-lomake avataan
            document.getElementById('lisaaTapahtumaModal').addEventListener('show.bs.modal', function () {
                document.getElementById('asiakasHaku').value = "";
                document.getElementById('asiakasId').value = "";
            });
            
            // =================================================================
            // UUSI KOODI PÄÄTTYY
            // =================================================================

        });
    </script>
</body>
</html>