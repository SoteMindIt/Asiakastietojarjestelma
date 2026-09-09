<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>
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
			<!-- Logo vie aina etusivulle (Dashboard) -->
			<a class="navbar-brand fw-bold"
				href="${pageContext.request.contextPath}/">Astori</a>

			<div class="navbar-nav me-auto">

				<!-- 1. Etusivu -->
				<a class="nav-link" href="${pageContext.request.contextPath}/">Etusivu</a>

				<!-- 2. Asiakkaat (Vie omalle sivulleen) -->
				<a class="nav-link"
					href="${pageContext.request.contextPath}/asiakkaat">Asiakkaat</a> <a
					class="nav-link"
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
								asiakkaaseen (Valinnainen)</label> <input type="text"
								class="form-control" id="asiakasHaku" list="asiakasLista"
								placeholder="Kirjoita nimi tai valitse listasta..."> <input
								type="hidden" id="asiakasId" name="asiakasId">
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
									<option value="${t}">${t}</option>
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

	<!-- GENEERINEN PONNAHDUSIKKUNA (MODAL) TAPAHTUMAN MUOKKAUKSELLE -->
	<div class="modal fade" id="muokkaaTapahtumaModal" tabindex="-1"
		aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content border-0 shadow-lg">
				<div class="modal-header bg-dark text-white">
					<h5 class="modal-title fw-bold">Muokkaa tapahtumaa</h5>
					<button type="button" class="btn-close btn-close-white"
						data-bs-dismiss="modal"></button>
				</div>

				<form id="muokkaaTapahtumaForm" method="post">
					<input type="hidden" name="lahde" value="kalenteri">
					<div class="modal-body p-4 text-start">
						<div class="mb-3">
							<label class="form-label fw-semibold text-secondary">Otsikko
								/ Aihe</label> <input type="text" class="form-control"
								id="muokkaaOtsikko" name="otsikko" required>
						</div>
						<div class="mb-3">
							<label class="form-label fw-semibold text-secondary">Tapahtuman
								tyyppi</label> <select class="form-select" id="muokkaaTyyppi"
								name="tyyppi" required>
								<c:forEach var="t" items="${tyypit}">
									<option value="${t}">${t}</option>
								</c:forEach>
							</select>
						</div>
						<div class="mb-3">
							<label class="form-label fw-semibold text-secondary">Ajankohta
								ja kellonaika</label> <input type="datetime-local" class="form-control"
								id="muokkaaAjankohta" name="ajankohtaStr" required>
						</div>
						<div class="mb-3">
							<label class="form-label fw-semibold text-secondary">Liitetty
								asiakas</label> <select class="form-select" id="muokkaaAsiakasId"
								name="asiakasId">
								<option value="">-- Ei kytketty asiakkaaseen --</option>
								<c:forEach var="a" items="${asiakkaat}">
									<option value="${a.id}">${a.nimi}</option>
								</c:forEach>
							</select>
						</div>
						<div class="mb-3">
							<label class="form-label fw-semibold text-secondary">Lisätiedot
								/ Muistiinpanot</label>
							<textarea class="form-control" id="muokkaaKuvaus" name="kuvaus"
								rows="3"></textarea>
						</div>
					</div>
					<div class="modal-footer bg-light d-flex justify-content-between">
						<button type="submit" id="poistaTapahtumaPainike"
							class="btn btn-outline-danger fw-bold"
							onclick="return confirm('Haluatko varmasti poistaa tämän tapahtuman?');">
							Poista</button>
						<div>
							<button type="button" class="btn btn-secondary me-2"
								data-bs-dismiss="modal">Peruuta</button>
							<button type="submit" class="btn btn-success px-4 fw-bold">Tallenna</button>
						</div>
					</div>
				</form>
			</div>
		</div>
	</div>

	<script
		src="${pageContext.request.contextPath}/resources/bootstrap.bundle.min.js"></script>

	<!-- 💡 TURVALLINEN HTML-SÄILÖ: Tulostetaan kuvaukset HTML-elementteihin, joissa rivinvaihdot ovat täysin sallittuja -->
	<div style="display: none;">
		<c:forEach var="tap" items="${tapahtumat}">
			<div id="tap-kuvaus-${tap.id}">
				<c:out value="${tap.kuvaus}" />
			</div>
		</c:forEach>
	</div>


	<!-- ==================== JAVASCRIPT-TOIMINNOT ==================== -->
	<script>
        document.addEventListener('DOMContentLoaded', function() {
            var calendarEl = document.getElementById('calendar')
            var lastClickedDate = null
            var lastClickTime = 0

            /* 1. Rakennetaan tapahtumalista turvallisesti lukemalla kuvaukset HTML-puusta */
            var valmiitTapahtumat = []
            <c:forEach var="tap" items="${tapahtumat}">
                <c:set var="ktunnus" value="" />
                <c:if test="${not empty tap.kayttaja}">
                    <c:set var="ktunnus" value=" [${tap.kayttaja.kayttajatunnus}]" />
                </c:if>

                valmiitTapahtumat.push({
                    id: '${tap.id}',
                    title: `<c:out value="${tap.otsikko}"/><c:out value="${ktunnus}"/>`,
                    start: '${tap.ajankohta.toString()}',
                    extendedProps: {
                        description: (() => {
                            let el = document.getElementById('tap-kuvaus-${tap.id}');
                            return el ? (el.innerText || el.textContent) : '';
                        })(),
                        asiakasId: '${not empty tap.asiakas ? tap.asiakas.id : ""}',
                        asiakasNimi: `<c:out value="${not empty tap.asiakas ? tap.asiakas.nimi : ''}"/>`,
                        tyyppiNimi: '${tap.tyyppi}'
                    },
                    <c:choose>
                        <c:when test="${tap.tyyppi.toString() == 'PUHELU' || tap.tyyppi.toString() == 'SOITTO'}">
                            backgroundColor: '#ffc107', borderColor: '#ffc107', textColor: '#000000'
                        </c:when>
                        <c:when test="${tap.tyyppi.toString() == 'TAPAAMINEN'}">
                            backgroundColor: '#198754', borderColor: '#198754', textColor: '#ffffff'
                        </c:when>
                        <c:when test="${tap.tyyppi.toString() == 'SÄHKÖPOSTI'}">
                            backgroundColor: '#0dcaf0', borderColor: '#0dcaf0', textColor: '#000000'
                        </c:when>
                        <c:otherwise>
                            backgroundColor: '#0d6efd', borderColor: '#0d6efd', textColor: '#ffffff'
                        </c:otherwise>
                    </c:choose>
                }); 
            </c:forEach>

            /* 2. Alustetaan kalenteri ja syötetään valmis lista suoraan events-asetukseen */
            var calendar = new FullCalendar.Calendar(calendarEl, {
                initialView: 'dayGridMonth',
                locale: 'fi',
                firstDay: 1,
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
                
                eventClick: function(info) {
                    info.jsEvent.preventDefault()
                    var otsikkoKentta = document.getElementById('muokkaaOtsikko')
                    if (otsikkoKentta) {
                        let fullTitle = info.event.title || ''
                        otsikkoKentta.value = fullTitle.includes(' [') ? fullTitle.split(' [')[0] : fullTitle
                    }
                    var kuvausKentta = document.getElementById('muokkaaKuvaus')
                    if (kuvausKentta) {
                        kuvausKentta.value = info.event.extendedProps.description || ''
                    }
                    var ajankohtaKentta = document.getElementById('muokkaaAjankohta')
                    if (ajankohtaKentta && info.event.start) {
                        let pvm = new Date(info.event.start)
                        let vuosi = pvm.getFullYear()
                        let kuukausi = String(pvm.getMonth() + 1).padStart(2, '0')
                        let paiva = String(pvm.getDate()).padStart(2, '0')
                        let tunnit = String(pvm.getHours()).padStart(2, '0')
                        let minuutit = String(pvm.getMinutes()).padStart(2, '0')
                        ajankohtaKentta.value = vuosi + '-' + kuukausi + '-' + paiva + 'T' + tunnit + ':' + minuutit
                    }
                    var tyyppiSelect = document.getElementById('muokkaaTyyppi')
                    if(tyyppiSelect) {
                        tyyppiSelect.value = info.event.extendedProps.tyyppiNimi
                    }
                    var asiakasSelect = document.getElementById('muokkaaAsiakasId')
                    if (asiakasSelect) {
                        asiakasSelect.value = info.event.extendedProps.asiakasId || ""
                    }
                    var form = document.getElementById('muokkaaTapahtumaForm')
                    if(form) {
                        form.action = "${pageContext.request.contextPath}/kalenteri/paivita/" + info.event.id
                    }
                    
                    // Poistopainikkeen suora ja toimiva JavaScript-ohjaus oikeaan reittiin
                    var poistoNappi = document.getElementById('poistaTapahtumaPainike');
                    if (poistoNappi) {
                        var uusiPoistoNappi = poistoNappi.cloneNode(true);
                        poistoNappi.parentNode.replaceChild(uusiPoistoNappi, poistoNappi);
                        
                        uusiPoistoNappi.addEventListener('click', function() {
                            if (confirm('Haluatko varmasti poistaa tämän tapahtuman?')) {
                                let poistoForm = document.createElement('form');
                                poistoForm.method = 'POST';
                                poistoForm.action = "${pageContext.request.contextPath}/kalenteri/poista-suoraan/" + info.event.id;
                                document.body.appendChild(poistoForm);
                                poistoForm.submit();
                            }
                        });
                    }
                    
                    var editModal = new bootstrap.Modal(document.getElementById('muokkaaTapahtumaModal'))
                    editModal.show()
                }, // 💡 KORJATTU: Tämä sulkeva välimerkki oli aiemmin kadoksissa ja aiheutti SyntaxErrorin!
                
                dateClick: function(info) {
                    var currentTime = new Date().getTime()
                    var clickDelay = currentTime - lastClickTime
                    if (lastClickedDate === info.dateStr && clickDelay < 400) {
                        let valittuPvm = info.dateStr 
                        if (valittuPvm.length === 10) { valittuPvm += "T09:00" } 
                        else { valittuPvm = valittuPvm.substring(0, 16) }
                        document.getElementById('ajankohtaStr').value = valittuPvm
                        var addModal = new bootstrap.Modal(document.getElementById('lisaaTapahtumaModal'))
                        addModal.show()
                    }
                    lastClickedDate = info.dateStr
                    lastClickTime = currentTime
                },
                
                events: valmiitTapahtumat
            })
            
            /* 3. Piirretään valmis kalenteri ruudulle */
            calendar.render()

            document.getElementById('asiakasHaku').addEventListener('input', function(e) {
                var inputValue = e.target.value
                var options = document.querySelectorAll('#asiakasLista option')
                var hiddenInput = document.getElementById('asiakasId')
                hiddenInput.value = "" 
                for (var i = 0; i < options.length; i++) {
                    if (options[i].value === inputValue) {
                        hiddenInput.value = options[i].getAttribute('data-id')
                        break
                    }
                }
            })

            document.getElementById('lisaaTapahtumaModal').addEventListener('show.bs.modal', function () {
                document.getElementById('asiakasHaku').value = ""
                document.getElementById('asiakasId').value = ""
            })
        })
    </script>
</body>
</html>

