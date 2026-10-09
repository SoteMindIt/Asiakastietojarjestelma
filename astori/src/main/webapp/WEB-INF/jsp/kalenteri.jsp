<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>
<!DOCTYPE html>
<html lang="fi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Kalenteri - Astori</title>
<!-- Bootstrap tyylit resources-juuresta -->
<link
	href="${pageContext.request.contextPath}/resources/bootstrap.min.css"
	rel="stylesheet" />
<!-- FullCalendar 6 -kirjaston skriptit -->
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

.clock-picker-backdrop {
	position: fixed;
	inset: 0;
	z-index: 2050;
	display: grid;
	place-items: center;
	padding: 16px;
	background: rgba(18, 28, 42, 0.45);
}

.clock-picker-dialog {
	width: min(340px, 100%);
	padding: 20px;
	border-radius: 8px;
	background: #fff;
	box-shadow: 0 16px 48px rgba(0, 0, 0, 0.24);
	text-align: center;
}

.clock-picker-time {
	margin: 0 0 14px;
	border: 0;
	background: transparent;
	color: #263746;
	font-size: 2rem;
	font-weight: 700;
	font-variant-numeric: tabular-nums;
}

.clock-picker-time button {
	border: 0;
	border-radius: 4px;
	padding: 2px 5px;
	background: transparent;
	color: inherit;
	font: inherit;
}

.clock-picker-time button.active {
	background: #e7f1ff;
	color: #0d6efd;
}

.clock-picker-face {
	position: relative;
	width: 260px;
	height: 260px;
	max-width: 100%;
	margin: 0 auto 16px;
	border-radius: 50%;
	background: #edf2f6;
}

.clock-picker-hand {
	position: absolute;
	left: 50%;
	top: 50%;
	width: 2px;
	height: 92px;
	transform-origin: 50% 0;
	background: #0d6efd;
}

.clock-picker-hand::after {
	position: absolute;
	left: -4px;
	bottom: -4px;
	width: 10px;
	height: 10px;
	border-radius: 50%;
	background: #0d6efd;
	content: '';
}

.clock-picker-value {
	position: absolute;
	left: 50%;
	top: 50%;
	width: 34px;
	height: 34px;
	transform: translate(-50%, -50%);
	border: 0;
	border-radius: 50%;
	background: transparent;
	color: #263746;
	font-size: 0.85rem;
	z-index: 1;
}

.clock-picker-value.selected {
	background: #0d6efd;
	color: #fff;
}

.clock-picker-adjust {
	display: flex;
	align-items: center;
	justify-content: center;
	gap: 14px;
	margin: -7px 0 12px;
}

.clock-picker-actions {
	display: flex;
	justify-content: flex-end;
	gap: 8px;
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
			<div class="d-flex flex-wrap gap-2">
				<form method="post" action="${pageContext.request.contextPath}/asetukset/google-kalenteri/sync">
					<button type="submit" class="btn btn-outline-primary fw-bold">Synkronoi Google-kalenteri</button>
				</form>
				<button type="button" class="btn btn-primary fw-bold shadow-sm"
					data-bs-toggle="modal" data-bs-target="#lisaaTapahtumaModal">
					+ Uusi kalenterivaraus</button>
		</div>
		</div>

		<c:if test="${param.success == 'google_calendar_synced'}">
			<div class="alert alert-success alert-dismissible fade show fw-bold" role="alert">
				Google-kalenteri synkronoitu. Tuotu ${param.count} uutta tapahtumaa.
				<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
			</div>
		</c:if>
		<c:if test="${param.error == 'google_calendar_missing_credentials'}">
			<div class="alert alert-warning alert-dismissible fade show fw-bold" role="alert">
				Google-kalenterin synkronointi vaatii access tokenin tai API-avaimen.
				<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
			</div>
		</c:if>
		<c:if test="${param.error == 'google_calendar_token_expired'}">
			<div class="alert alert-warning alert-dismissible fade show fw-bold" role="alert">
				Google-kalenterin access token on vanhentunut tai virheellinen. Aseta uusi token ympäristömuuttujaan GOOGLE_CALENDAR_ACCESS_TOKEN ja käynnistä sovellus uudelleen.
				<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
			</div>
		</c:if>

		<!-- KALENTERIN RUUDUKKO -->
		<div class="calendar-card border mb-5">
			<div id="calendar"></div>
		</div>
	</div>

	<!-- BOOTSTRAP POP-UP LOMAKE UUDELLE VARAUKSELLE -->
	<div class="modal fade" id="lisaaTapahtumaModal" tabindex="-1" data-bs-focus="false" aria-hidden="true">
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
							<label for="tyyppi" class="form-label fw-semibold text-secondary">Tapahtuman tyyppi</label> 
							<select class="form-select" id="tyyppi" name="tyyppi" required>
								<option value="">-- Valitse tyyppi --</option>
								<c:forEach var="t" items="${tapahtumaTyypit}">
									<option value="${t.id}">${t.nimi}</option>
								</c:forEach>
							</select>
						</div>

						<div class="mb-3">
							<label for="asiakasHaku" class="form-label fw-semibold text-secondary">Liitä asiakkaaseen (Valinnainen)</label> 
							<input type="text" class="form-control" id="asiakasHaku" list="asiakasLista" placeholder="Kirjoita nimi tai valitse listasta..."> 
							<input type="hidden" id="asiakasId" name="asiakasId">
							<datalist id="asiakasLista">
								<c:forEach var="a" items="${kaikkiAsiakkaat}">
									<option data-id="${a.id}" value="${a.nimi}"></option>
								</c:forEach>
							</datalist>
							<small class="form-text text-muted">Jätä tyhjäksi, jos kyseessä on sisäinen merkintä.</small>
						</div>

						<div class="mb-3">
							<label for="otsikko" class="form-label fw-semibold text-secondary">Otsikko / Aihe</label> 
							<input type="text" class="form-control" id="otsikko" name="otsikko" required placeholder="esim. Sopimusneuvottelu, Seurantapuhelu">
						</div>

						<!-- 🔌 Tekstikentät valmiina clockpicker-alustusta varten -->
						<div class="row g-2 mb-3">
							<div class="col-md-6">
								<label for="paivaStr" class="form-label fw-semibold text-secondary small">Päivämäärä</label>
								<input type="date" class="form-control form-control-sm" id="paivaStr" name="paivaStr" required>
							</div>
							<div class="col-md-3">
								<label for="alkuAikaStr" class="form-label fw-semibold text-secondary small">Alku</label>
								<input type="text" class="form-control form-control-sm kellovalitsin" id="alkuAikaStr" name="alkuAikaStr" required readonly style="background-color: #fff; cursor: pointer;">
							</div>
							<div class="col-md-3">
								<label for="loppuAikaStr" class="form-label fw-semibold text-secondary small">Loppu</label>
								<input type="text" class="form-control form-control-sm kellovalitsin" id="loppuAikaStr" name="loppuAikaStr" required readonly style="background-color: #fff; cursor: pointer;">
							</div>
						</div>

						<div class="mb-3">
							<label for="kuvaus" class="form-label fw-semibold text-secondary">Lisätiedot / Muistiinpanot</label>
							<textarea class="form-control" id="kuvaus" name="kuvaus" rows="3" placeholder="Mitä sovitaan tai käydään läpi..."></textarea>
						</div>

					</div>
					<div class="modal-footer bg-light">
						<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Peruuta</button>
						<button type="submit" class="btn btn-primary px-4 fw-bold">Tallenna kalenteriin</button>
					</div>
				</form>
			</div>
		</div>
	</div>
	<!-- GENEERINEN PONNAHDUSIKKUNA (MODAL) TAPAHTUMAN MUOKKAUKSELLE -->
	<div class="modal fade" id="muokkaaTapahtumaModal" tabindex="-1" data-bs-focus="false" aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content border-0 shadow-lg">
				<div class="modal-header bg-dark text-white">
					<h5 class="modal-title fw-bold">Muokkaa tapahtumaa</h5>
					<button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
				</div>

				<form id="muokkaaTapahtumaForm" method="post">
					<input type="hidden" name="lahde" value="kalenteri">
					<div class="modal-body p-4 text-start">
						<div class="mb-3">
							<label class="form-label fw-semibold text-secondary">Otsikko / Aihe</label> 
							<input type="text" class="form-control" id="muokkaaOtsikko" name="otsikko" required>
						</div>
						<div class="mb-3">
							<label class="form-label fw-semibold text-secondary">Tapahtuman tyyppi</label> 
							<select class="form-select" id="muokkaaTyyppi" name="tyyppi" required>
								<c:forEach var="t" items="${tapahtumaTyypit}">
									<option value="${t.id}">${t.nimi}</option>
								</c:forEach>
							</select>
						</div>

						<!-- 🔌 KORJAUS: Muutettu tekstiksi ja annettu luokka 'kellovalitsin' analogista kellotaulua varten -->
						<div class="row g-2 mb-3">
							<div class="col-md-6">
								<label for="muokkaaPaiva" class="form-label fw-semibold text-secondary">Päivämäärä</label>
								<input type="date" class="form-control" id="muokkaaPaiva" name="paivaStr" required>
							</div>
							<div class="col-md-3">
								<label for="muokkaaAlku" class="form-label fw-semibold text-secondary">Alku</label> 
								<input type="text" class="form-control kellovalitsin" id="muokkaaAlku" name="alkuAikaStr" required readonly style="background-color: #fff; cursor: pointer;">
							</div>
							<div class="col-md-3">
								<label for="muokkaaLoppu" class="form-label fw-semibold text-secondary">Loppu</label> 
								<input type="text" class="form-control kellovalitsin" id="muokkaaLoppu" name="loppuAikaStr" required readonly style="background-color: #fff; cursor: pointer;">
							</div>
						</div>

						<div class="mb-3">
							<label class="form-label fw-semibold text-secondary">Liitetty asiakas</label> 
							<select class="form-select" id="muokkaaAsiakasId" name="asiakasId">
								<option value="">-- Ei kytketty asiakkaaseen --</option>
								<c:forEach var="a" items="${kaikkiAsiakkaat}">
									<option value="${a.id}">${a.nimi}</option>
								</c:forEach>
							</select>
						</div>
						<div class="mb-3">
							<label class="form-label fw-semibold text-secondary">Lisätiedot / Muistiinpanot</label>
							<textarea class="form-control" id="muokkaaKuvaus" name="kuvaus" rows="3"></textarea>
						</div>
					</div>
					<div class="modal-footer bg-light d-flex justify-content-between">
						<button type="submit" id="poistaTapahtumaPainike" class="btn btn-outline-danger fw-bold rounded-pill px-3">Poista</button>
						<div>
							<button type="button" class="btn btn-secondary rounded-pill px-3 me-2" data-bs-dismiss="modal">Peruuta</button>
							<button type="submit" class="btn btn-success px-4 fw-bold rounded-pill">Tallenna</button>
						</div>
					</div>
				</form>
			</div>
		</div>
	</div>

	<!-- HTML-tapahtumavarasto backendistä -->
	<div id="tapahtumaDataVarasto" style="display: none;">
		<c:forEach var="t" items="${tapahtumat}">
			<div class="tapahtuma-alkio" data-id="${t.id}"
				data-otsikko="${fn:escapeXml(t.otsikko)}"
				data-asiakas-loytyi="${t.asiakas != null}"
				data-asiakas-nimi="${fn:escapeXml(t.asiakas != null ? t.asiakas.nimi : '')}"
				data-start="${t.ajankohta}"
				data-end="${t.loppuaika != null ? t.loppuaika : ''}"
				data-color="${t.tyyppi != null ? t.tyyppi.vari : '#0d6efd'}"
				data-kuvaus="${fn:escapeXml(t.kuvaus != null ? t.kuvaus : '')}"
				data-tyyppi-nimi="${t.tyyppi != null ? fn:escapeXml(t.tyyppi.nimi) : 'Yleinen'}"
				data-tyyppi-id="${t.tyyppi != null ? t.tyyppi.id : ''}"
				data-asiakas-id="${t.asiakas != null ? t.asiakas.id : ''}"></div>
		</c:forEach>
	</div>

	<!-- BOOTSTRAP 5 SCRIPT-TUKI -->
	<script src="${pageContext.request.contextPath}/resources/bootstrap.bundle.min.js"></script>
		<script>
		document.addEventListener('DOMContentLoaded', function() {
			var lastClickTime = 0;
			var lastClickedDate = null;
			var yhElement = document.getElementById('muokkaaTapahtumaModal');

			// Parsitaan HTML-alkiot
			var valmiitTapahtumat = [];
			document.querySelectorAll('.tapahtuma-alkio').forEach(function(el) {
				var otsikko = el.getAttribute('data-otsikko');
				if (el.getAttribute('data-asiakas-loytyi') === 'true') {
					otsikko += ' (' + el.getAttribute('data-asiakas-nimi') + ')';
				}

				valmiitTapahtumat.push({
					id : el.getAttribute('data-id'),
					title : otsikko,
					start : el.getAttribute('data-start'),
					end : el.getAttribute('data-end') || null,
					color : el.getAttribute('data-color'),
					extendedProps : {
						description : el.getAttribute('data-kuvaus'),
						alkuperainenOtsikko : el.getAttribute('data-otsikko'),
						tyypinNimi : el.getAttribute('data-tyyppi-nimi'),
						tyyppiId : el.getAttribute('data-tyyppi-id'),
						asiakasNimi : el.getAttribute('data-asiakas-nimi') || 'Ei kytketty',
						asiakasId : el.getAttribute('data-asiakas-id'),
						ajankohtaRaw : el.getAttribute('data-start'),
						loppuaikaRaw : el.getAttribute('data-end')
					}
				});
			});

			/* 2. Alustetaan FullCalendar 6 */
			var calendarEl = document.getElementById('calendar');
			if (calendarEl) {
				var calendar = new FullCalendar.Calendar(calendarEl, {
					initialView : 'dayGridMonth',
					locale : 'fi',
					firstDay : 1,
					headerToolbar : {
						left : 'prev,next today',
						center : 'title',
						right : 'dayGridMonth,timeGridWeek,timeGridDay'
					},
					buttonText : {
						today : 'Tänään',
						month : 'Kuukausi',
						week : 'Viikko',
						day : 'Päivä'
					},

					eventClick : function(info) {
						var event = info.event;
						var props = event.extendedProps;

						var form = document.getElementById('muokkaaTapahtumaForm');
						if (form) {
							form.action = '${pageContext.request.contextPath}/kalenteri/paivita/' + event.id;
						}

						if (document.getElementById('muokkaaOtsikko')) {
							document.getElementById('muokkaaOtsikko').value = props.alkuperainenOtsikko;
						}
						if (document.getElementById('muokkaaTyyppi')) {
							document.getElementById('muokkaaTyyppi').value = props.tyyppiId;
						}

						// Pilkotaan aloitusaika turvallisesti (YYYY-MM-DD ja HH:MM)
						if (props.ajankohtaRaw && props.ajankohtaRaw.includes('T')) {
							var osatAlku = props.ajankohtaRaw.split('T');
							if (document.getElementById('muokkaaPaiva')) {
								document.getElementById('muokkaaPaiva').value = osatAlku[0];
							}
							if (document.getElementById('muokkaaAlku')) {
								document.getElementById('muokkaaAlku').value = osatAlku[1].substring(0, 5);
							}
						}

						// Pilkotaan lopetusaika turvallisesti (HH:MM)
						if (props.loppuaikaRaw && props.loppuaikaRaw.includes('T')) {
							var osatLoppu = props.loppuaikaRaw.split('T');
							if (document.getElementById('muokkaaLoppu')) {
								document.getElementById('muokkaaLoppu').value = osatLoppu[1].substring(0, 5);
							}
						} else {
							if (document.getElementById('muokkaaLoppu')) {
								document.getElementById('muokkaaLoppu').value = "";
							}
						}

						if (document.getElementById('muokkaaAsiakasId')) {
							document.getElementById('muokkaaAsiakasId').value = props.asiakasId || "";
						}
						if (document.getElementById('muokkaaKuvaus')) {
							document.getElementById('muokkaaKuvaus').value = props.description || "";
						}

						// Dynaaminen poistolomakkeen luonti
						var poistaBtn = document.getElementById('poistaTapahtumaPainike');
						if (poistaBtn) {
							poistaBtn.onclick = function(e) {
								e.preventDefault();
								if (confirm("Haluatko varmasti poistaa tämän kalenterivarauksen lopullisesti?")) {
									var poistoForm = document.createElement('form');
									poistoForm.method = 'POST';
									poistoForm.action = '${pageContext.request.contextPath}/kalenteri/poista-suoraan/' + event.id;

									var lahdeInput = document.createElement('input');
									lahdeInput.type = 'hidden';
									lahdeInput.name = 'lahde';
									lahdeInput.value = 'kalenteri';

									poistoForm.appendChild(lahdeInput);
									document.body.appendChild(poistoForm);
									poistoForm.submit();
								}
							};
						}

						if (yhElement) {
							var liveModal = bootstrap.Modal.getOrCreateInstance(yhElement);
							liveModal.show();
						}
					},

					dateClick : function(info) {
						var currentTime = new Date().getTime();
						var clickDelay = currentTime - lastClickTime;
						if (lastClickedDate === info.dateStr && clickDelay < 400) {

							var valittuPaiva = info.dateStr.substring(0, 10);

							if (document.getElementById('paivaStr')) {
								document.getElementById('paivaStr').value = valittuPaiva;
							}
							if (document.getElementById('alkuAikaStr')) {
								document.getElementById('alkuAikaStr').value = "15:00";
							}
							if (document.getElementById('loppuAikaStr')) {
								document.getElementById('loppuAikaStr').value = "16:00";
							}

							var addModal = new bootstrap.Modal(document.getElementById('lisaaTapahtumaModal'));
							if (addModal) {
								addModal.show();
							}
						}
						lastClickedDate = info.dateStr;
						lastClickTime = currentTime;
					},

					eventDidMount : function(info) {
						var props = info.event.extendedProps;

						var tooltipSisalto = '<strong>Tyyppi:</strong> '
								+ props.tyypinNimi
								+ '<br>'
								+ '<strong>Otsikko:</strong> '
								+ props.alkuperainenOtsikko
								+ '<br>'
								+ '<strong>Asiakas:</strong> '
								+ props.asiakasNimi
								+ '<br>'
								+ '<strong>Lisätiedot:</strong> '
								+ (props.description ? props.description.trim() : 'Ei merkintöjä');

						new bootstrap.Tooltip(info.el, {
							title : tooltipSisalto,
							placement : 'top',
							trigger : 'hover',
							container : 'body',
							html : true
						});
					},

					events : valmiitTapahtumat
				});

				calendar.render();
			}

			// Asiakkaan hakuvalinnan dynaaminen ID-kytkentä
			var hakuInput = document.getElementById('asiakasHaku');
			if (hakuInput) {
				hakuInput.addEventListener('input', function(e) {
					var inputValue = e.target.value;
					var options = document.querySelectorAll('#asiakasLista option');
					var hiddenInput = document.getElementById('asiakasId');
					if (hiddenInput) {
						hiddenInput.value = "";
						for (var i = 0; i < options.length; i++) {
							if (options[i].value === inputValue) {
								hiddenInput.value = options[i].getAttribute('data-id');
								break;
							}
						}
					}
				});
			}

			// Tyhjennetään pikalomakkeen haut kun lisäysikkuna suljetaan
			var lisaaModalEl = document.getElementById('lisaaTapahtumaModal');
			if (lisaaModalEl) {
				lisaaModalEl.addEventListener('show.bs.modal', function() {
					var hInput = document.getElementById('asiakasHaku');
					var hId = document.getElementById('asiakasId');
					if (hInput) { hInput.value = ""; }
					if (hId) { hId.value = ""; }
				});
			}

			var activeClockInput = null;
			var clockPicker = null;
			var selectedHour = 9;
			var selectedMinute = 0;
			var clockStage = 'hour';

			function paddedTimePart(value) {
				return String(value).padStart(2, '0');
			}

			function closeClockPicker() {
				if (clockPicker) {
					clockPicker.remove();
					clockPicker = null;
				}
				if (activeClockInput) {
					activeClockInput.focus();
					activeClockInput = null;
				}
			}

			function renderClockPicker() {
				var hourButton = clockPicker.querySelector('[data-clock-part="hour"]');
				var minuteButton = clockPicker.querySelector('[data-clock-part="minute"]');
				var face = clockPicker.querySelector('.clock-picker-face');
				hourButton.textContent = paddedTimePart(selectedHour);
				minuteButton.textContent = paddedTimePart(selectedMinute);
				hourButton.classList.toggle('active', clockStage === 'hour');
				minuteButton.classList.toggle('active', clockStage === 'minute');
				face.replaceChildren();

				var values = clockStage === 'hour'
						? Array.from({ length: 24 }, function(_, index) { return index; })
						: Array.from({ length: 12 }, function(_, index) { return index * 5; });
				var selectedValue = clockStage === 'hour' ? selectedHour : Math.floor(selectedMinute / 5) * 5;
				var selectedIndex = clockStage === 'hour' ? selectedHour % 12 : selectedValue / 5;
				var selectedRadius = clockStage === 'hour' && selectedHour >= 12 ? 65 : 105;
				var hand = document.createElement('div');
				hand.className = 'clock-picker-hand';
				hand.style.height = selectedRadius + 'px';
				hand.style.transform = 'rotate(' + (180 + selectedIndex * 30) + 'deg)';
				face.appendChild(hand);

				values.forEach(function(value, index) {
					var button = document.createElement('button');
					var position = clockStage === 'hour' ? index % 12 : index;
					var radius = clockStage === 'hour' && value >= 12 ? 65 : 105;
					var angle = position * Math.PI / 6 - Math.PI / 2;
					button.type = 'button';
					button.className = 'clock-picker-value';
					button.textContent = paddedTimePart(value);
					button.dataset.clockValue = value;
					button.classList.toggle('selected', value === selectedValue);
					button.style.left = (130 + Math.cos(angle) * radius) + 'px';
					button.style.top = (130 + Math.sin(angle) * radius) + 'px';
					face.appendChild(button);
				});

				clockPicker.querySelector('.clock-picker-adjust').style.display = clockStage === 'minute' ? 'flex' : 'none';
			}

			function openClockPicker(input) {
				if (clockPicker) {
					closeClockPicker();
				}
				activeClockInput = input;
				var parts = input.value.match(/^(\d{1,2}):(\d{2})$/);
				selectedHour = parts ? Math.min(23, parseInt(parts[1], 10)) : 9;
				selectedMinute = parts ? Math.min(59, parseInt(parts[2], 10)) : 0;
				clockStage = 'hour';
				clockPicker = document.createElement('div');
				clockPicker.className = 'clock-picker-backdrop';
				clockPicker.innerHTML = '<section class="clock-picker-dialog" role="dialog" aria-modal="true" aria-label="Valitse kellonaika">'
						+ '<h2 class="h6 mb-3">Valitse kellonaika</h2>'
						+ '<div class="clock-picker-time"><button type="button" data-clock-part="hour" aria-label="Valitse tunti"></button>'
						+ '<span>:</span><button type="button" data-clock-part="minute" aria-label="Valitse minuutit"></button></div>'
						+ '<div class="clock-picker-face" aria-label="Kellotaulu"></div>'
						+ '<div class="clock-picker-adjust"><button type="button" class="btn btn-sm btn-outline-secondary" data-minute-adjust="-1" aria-label="Vähennä minuutti">−</button>'
						+ '<span class="small text-secondary">Tarkka minuutti</span><button type="button" class="btn btn-sm btn-outline-secondary" data-minute-adjust="1" aria-label="Lisää minuutti">+</button></div>'
						+ '<div class="clock-picker-actions"><button type="button" class="btn btn-light" data-clock-action="cancel">Peruuta</button>'
						+ '<button type="button" class="btn btn-primary" data-clock-action="select">Valitse</button></div></section>';
				document.body.appendChild(clockPicker);
				renderClockPicker();

				clockPicker.addEventListener('click', function(event) {
					if (event.target === clockPicker || event.target.closest('[data-clock-action="cancel"]')) {
						closeClockPicker();
						return;
					}
					if (event.target.closest('[data-clock-action="select"]')) {
						activeClockInput.value = paddedTimePart(selectedHour) + ':' + paddedTimePart(selectedMinute);
						closeClockPicker();
						return;
					}
					var partButton = event.target.closest('[data-clock-part]');
					if (partButton) {
						clockStage = partButton.dataset.clockPart;
						renderClockPicker();
						return;
					}
					var valueButton = event.target.closest('[data-clock-value]');
					if (valueButton) {
						if (clockStage === 'hour') {
							selectedHour = parseInt(valueButton.dataset.clockValue, 10);
							clockStage = 'minute';
						} else {
						selectedMinute = parseInt(valueButton.dataset.clockValue, 10);
						}
						renderClockPicker();
						return;
					}
					var adjustButton = event.target.closest('[data-minute-adjust]');
					if (adjustButton) {
						selectedMinute = (selectedMinute + parseInt(adjustButton.dataset.minuteAdjust, 10) + 60) % 60;
						renderClockPicker();
					}
				});
			}

			document.querySelectorAll('.kellovalitsin').forEach(function(input) {
				input.setAttribute('aria-haspopup', 'dialog');
				input.addEventListener('click', function() {
					openClockPicker(input);
				});
			});

			document.addEventListener('keydown', function(event) {
				if (clockPicker && event.key === 'Escape') {
					closeClockPicker();
				}
			});
		});
	</script>

</body>
</html>
	