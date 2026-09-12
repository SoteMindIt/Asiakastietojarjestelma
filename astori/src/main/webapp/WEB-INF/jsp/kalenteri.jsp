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
			<a class="navbar-brand fw-bold"
				href="${pageContext.request.contextPath}/">Astori</a>

			<div class="navbar-nav me-auto">
				<a class="nav-link" href="${pageContext.request.contextPath}/">Etusivu</a>
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
							<label for="tyyppi" class="form-label fw-semibold text-secondary">Tapahtuman
								tyyppi</label> <select class="form-select" id="tyyppi" name="tyyppi"
								required>
								<option value="">-- Valitse tyyppi --</option>
								<c:forEach var="t" items="${tapahtumaTyypit}">
									<option value="${t.id}">${t.nimi}</option>
								</c:forEach>
							</select>
						</div>

						<div class="mb-3">
							<label for="asiakasHaku"
								class="form-label fw-semibold text-secondary">Liitä
								asiakkaaseen (Valinnainen)</label> <input type="text"
								class="form-control" id="asiakasHaku" list="asiakasLista"
								placeholder="Kirjoita nimi tai valitse listasta..."> <input
								type="hidden" id="asiakasId" name="asiakasId">
							<datalist id="asiakasLista">
								<c:forEach var="a" items="${kaikkiAsiakkaat}">
									<option data-id="${a.id}" value="${a.nimi}"></option>
								</c:forEach>
							</datalist>
							<small class="form-text text-muted">Jätä tyhjäksi, jos
								kyseessä on sisäinen merkintä.</small>
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
								<c:forEach var="t" items="${tapahtumaTyypit}">
									<option value="${t.id}">${t.nimi}</option>
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
								<c:forEach var="a" items="${kaikkiAsiakkaat}">
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
							class="btn btn-outline-danger fw-bold">Poista</button>
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

	<!-- Bootstrap Bundle suoraan resources-juuresta -->
	<script
		src="${pageContext.request.contextPath}/resources/bootstrap.bundle.min.js"></script>

	<!-- 💡 TURVALLINEN HTML-SÄILÖ (Korjattu: Ei rivinvaihtoja tai sisennyksiä tagien välissä) -->
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

                <c:set var="tyypinNimi" value="${not empty tap.tyyppi ? tap.tyyppi.nimi : 'Yleinen'}" />
                
                // --- ASIAKKAAN NIMEN LIITTÄMINEN JA LYHENNYS (UUSI) ---
                <c:set var="asiakasOsuus" value="" />
                <c:if test="${not empty tap.asiakas}">
                    <c:choose>
                        <%-- Jos nimi on yli 10 merkkiä, katkaistaan se ja lisätään kolme pistettä --%>
                        <c:when test="${fn:length(tap.asiakas.nimi) > 10}">
                            <c:set var="asiakasOsuus" value=", ${fn:substring(tap.asiakas.nimi, 0, 10)}..." />
                        </c:when>
                        <%-- Jos nimi on 10 merkkiä tai lyhyempi, näytetään se sellaisenaan --%>
                        <c:otherwise>
                            <c:set var="asiakasOsuus" value=", ${tap.asiakas.nimi}" />
                        </c:otherwise>
                    </c:choose>
                </c:if>

                valmiitTapahtumat.push({
                    id: '${tap.id}',
                    // 💡 PÄIVITETTY: Kalenteriruudun otsikkoon leivotaan nyt tyyppi, lyhennetty asiakas ja käyttäjätunnus
                    title: `<c:out value="${tyypinNimi}"/><c:out value="${asiakasOsuus}"/><c:out value="${ktunnus}"/>`,
                    start: '${tap.ajankohta.toString()}',
                    extendedProps: {
                    	tyypinNimi: `<c:out value="${tyypinNimi}"/>`,
                        alkuperainenOtsikko: `<c:out value="${tap.otsikko}"/>`,
                        description: (() => {
                            let el = document.getElementById('tap-kuvaus-${tap.id}');
                            return el ? (el.innerText || el.textContent) : '';
                        })(),
                        asiakasId: '${not empty tap.asiakas ? tap.asiakas.id : ""}',
                        asiakasNimi: `<c:out value="${not empty tap.asiakas ? tap.asiakas.nimi : ''}"/>`,
                        tyyppiId: '${not empty tap.tyyppi ? tap.tyyppi.id : ""}'
                    },
                    backgroundColor: '${not empty tap.tyyppi ? tap.tyyppi.vari : "#0d6efd"}',
                    borderColor: '${not empty tap.tyyppi ? tap.tyyppi.vari : "#0d6efd"}',
                    textColor: '${tap.tyyppi.vari == "#ffc107" ? "#000000" : "#ffffff"}'
                }); 
            </c:forEach>


            /* 2. Alustetaan kalenteri */
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
                    
                    // 💡 KORJATTU: Luetaan otsikko suoraan puhtaasta extendedProps-muuttujasta
                    var otsikkoKentta = document.getElementById('muokkaaOtsikko')
                    if (otsikkoKentta) {
                        otsikkoKentta.value = info.event.extendedProps.alkuperainenOtsikko || '';
                    }
                    
                    var kuvausKentta = document.getElementById('muokkaaKuvaus')
                    if (kuvausKentta) {
                        kuvausKentta.value = (info.event.extendedProps.description || '').trim()
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
                        tyyppiSelect.value = info.event.extendedProps.tyyppiId || ""
                    }
                    
                    var asiakasSelect = document.getElementById('muokkaaAsiakasId')
                    if (asiakasSelect) {
                        asiakasSelect.value = info.event.extendedProps.asiakasId || ""
                    }
                    
                    var form = document.getElementById('muokkaaTapahtumaForm')
                    if(form) {
                        form.action = "${pageContext.request.contextPath}/kalenteri/paivita/" + info.event.id
                    }

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
                },
                
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
                
                // 💡 UUSI: Tooltip-alustus, kun tapahtuma piirretään ruudulle
                eventDidMount: function(info) {
                    var props = info.event.extendedProps;
                    
                    // Rakennetaan siisti HTML-sisältö tooltipille
                    var tooltipSisalto = 
                        '<strong>Tyyppi:</strong> ' + props.tyypinNimi + '<br>' +
                        '<strong>Otsikko:</strong> ' + props.alkuperainenOtsikko + '<br>' +
                        '<strong>Asiakas:</strong> ' + props.asiakasNimi + '<br>' +
                        '<strong>Lisätiedot:</strong> ' + (props.description.trim() || 'Ei merkintöjä');

                    // Alustetaan Bootstrap 5 Tooltip kyseiselle kalenterielementille
                    new bootstrap.Tooltip(info.el, {
                        title: tooltipSisalto,
                        placement: 'top',
                        trigger: 'hover',
                        container: 'body',
                        html: true // Sallii <strong> ja <br> tagit laatikon sisällä
                    });
                },
                
                events: valmiitTapahtumat
            });

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
        });
	</script>

</body>
</html>
