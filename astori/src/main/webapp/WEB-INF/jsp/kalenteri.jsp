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

						<!-- 🔌 KORJAUS: Erillinen päivämäärän ja keston valinta (15:00 - 16:00 oletuksella) -->
						<div class="row g-2 mb-3">
							<div class="col-md-6">
								<label for="paivaStr"
									class="form-label fw-semibold text-secondary">Päivämäärä</label>
								<input type="date" class="form-control" id="paivaStr"
									name="paivaStr" required>
							</div>
							<div class="col-md-3">
								<label for="alkuAikaStr"
									class="form-label fw-semibold text-secondary">Alku</label> <input
									type="time" class="form-control" id="alkuAikaStr"
									name="alkuAikaStr" required>
							</div>
							<div class="col-md-3">
								<label for="loppuAikaStr"
									class="form-label fw-semibold text-secondary">Loppu</label> <input
									type="time" class="form-control" id="loppuAikaStr"
									name="loppuAikaStr" required>
							</div>
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

							<!-- 🔌 KORJAUS: Erillinen keston valinta muokkauksessa -->
							<div class="row g-2 mb-3">
								<div class="col-md-6">
									<label for="muokkaaPaiva"
										class="form-label fw-semibold text-secondary">Päivämäärä</label>
									<input type="date" class="form-control" id="muokkaaPaiva"
										name="paivaStr" required>
								</div>
								<div class="col-md-3">
									<label for="muokkaaAlku"
										class="form-label fw-semibold text-secondary">Alku</label> <input
										type="time" class="form-control" id="muokkaaAlku"
										name="alkuAikaStr" required>
								</div>
								<div class="col-md-3">
									<label for="muokkaaLoppu"
										class="form-label fw-semibold text-secondary">Loppu</label> <input
										type="time" class="form-control" id="muokkaaLoppu"
										name="loppuAikaStr" required>
								</div>
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

		<!-- 🔌 TURVALLISUUS: Siirretään backend-tapahtumat HTML-attribuutteihin, jotta rivinvaihtovirhe JavaScriptissä poistuu -->
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
		<script
			src="${pageContext.request.contextPath}/resources/bootstrap.bundle.min.js"></script>

	</div>
	<script>
		document
				.addEventListener(
						'DOMContentLoaded',
						function() {
							var lastClickTime = 0;
							var lastClickedDate = null;
							var yhElement = document
									.getElementById('muokkaaTapahtumaModal');
							var editModal = yhElement ? new bootstrap.Modal(
									yhElement) : null;

							// 🔌 Parsitaan HTML-alkiot turvallisesti ilman JavaScript-rivinvaihtovirheitä
							var valmiitTapahtumat = [];
							document
									.querySelectorAll('.tapahtuma-alkio')
									.forEach(
											function(el) {
												var otsikko = el
														.getAttribute('data-otsikko');
												if (el
														.getAttribute('data-asiakas-loytyi') === 'true') {
													otsikko += ' ('
															+ el
																	.getAttribute('data-asiakas-nimi')
															+ ')';
												}

												valmiitTapahtumat
														.push({
															id : el
																	.getAttribute('data-id'),
															title : otsikko,
															start : el
																	.getAttribute('data-start'),
															end : el
																	.getAttribute('data-end')
																	|| null,
															color : el
																	.getAttribute('data-color'),
															extendedProps : {
																description : el
																		.getAttribute('data-kuvaus'),
																alkuperainenOtsikko : el
																		.getAttribute('data-otsikko'),
																tyypinNimi : el
																		.getAttribute('data-tyyppi-nimi'),
																tyyppiId : el
																		.getAttribute('data-tyyppi-id'),
																asiakasNimi : el
																		.getAttribute('data-asiakas-nimi')
																		|| 'Ei kytketty',
																asiakasId : el
																		.getAttribute('data-asiakas-id'),
																ajankohtaRaw : el
																		.getAttribute('data-start'),
																loppuaikaRaw : el
																		.getAttribute('data-end')
															}
														});
											});

							/* 2. Alustetaan FullCalendar 6 */
							var calendarEl = document
									.getElementById('calendar');
							if (calendarEl) {
								var calendar = new FullCalendar.Calendar(
										calendarEl,
										{
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

												var form = document
														.getElementById('muokkaaTapahtumaForm');
												if (form)
													form.action = '${pageContext.request.contextPath}/kalenteri/paivita/'
															+ event.id;

												if (document
														.getElementById('muokkaaOtsikko'))
													document
															.getElementById('muokkaaOtsikko').value = props.alkuperainenOtsikko;
												if (document
														.getElementById('muokkaaTyyppi'))
													document
															.getElementById('muokkaaTyyppi').value = props.tyyppiId;

												// Pilkotaan aloitusaika turvallisesti (YYYY-MM-DD ja HH:MM)
												if (props.ajankohtaRaw
														&& props.ajankohtaRaw
																.includes('T')) {
													var osatAlku = props.ajankohtaRaw
															.split('T');
													if (document
															.getElementById('muokkaaPaiva'))
														document
																.getElementById('muokkaaPaiva').value = osatAlku[0];
													if (document
															.getElementById('muokkaaAlku'))
														document
																.getElementById('muokkaaAlku').value = osatAlku[1]
																.substring(0, 5);
												}

												// Pilkotaan lopetusaika turvallisesti (HH:MM)
												if (props.loppuaikaRaw
														&& props.loppuaikaRaw
																.includes('T')) {
													var osatLoppu = props.loppuaikaRaw
															.split('T');
													if (document
															.getElementById('muokkaaLoppu'))
														document
																.getElementById('muokkaaLoppu').value = osatLoppu[1]
																.substring(0, 5);
												} else {
													if (document
															.getElementById('muokkaaLoppu'))
														document
																.getElementById('muokkaaLoppu').value = "";
												}

												if (document
														.getElementById('muokkaaAsiakasId'))
													document
															.getElementById('muokkaaAsiakasId').value = props.asiakasId;
												if (document
														.getElementById('muokkaaKuvaus'))
													document
															.getElementById('muokkaaKuvaus').value = props.description;

												var poistaBtn = document
														.getElementById('poistaTapahtumaPainike');
												if (poistaBtn) {
													poistaBtn.onclick = function(
															e) {
														e.preventDefault();
														if (confirm("Haluatko varmasti poistaa tämän kalenterivarauksen lopullisesti?")) {
															var poistoForm = document
																	.createElement('form');
															poistoForm.method = 'POST';
															poistoForm.action = '${pageContext.request.contextPath}/kalenteri/poista-suoraan/'
																	+ event.id;

															var lahdeInput = document
																	.createElement('input');
															lahdeInput.type = 'hidden';
															lahdeInput.name = 'lahde';
															lahdeInput.value = 'kalenteri';

															poistoForm
																	.appendChild(lahdeInput);
															document.body
																	.appendChild(poistoForm);
															poistoForm.submit();
														}
													};
												}

												if (editModal)
													editModal.show();
											},

											dateClick : function(info) {
												var currentTime = new Date()
														.getTime();
												var clickDelay = currentTime
														- lastClickTime;
												if (lastClickedDate === info.dateStr
														&& clickDelay < 400) {

													var valittuPaiva = info.dateStr
															.substring(0, 10);

													// 🔌 TÄYTETÄÄN KESTO: Asetetaan valittu päivä ja toivomasi oletusaika 15:00 - 16:00
													if (document
															.getElementById('paivaStr'))
														document
																.getElementById('paivaStr').value = valittuPaiva;
													if (document
															.getElementById('alkuAikaStr'))
														document
																.getElementById('alkuAikaStr').value = "15:00";
													if (document
															.getElementById('loppuAikaStr'))
														document
																.getElementById('loppuAikaStr').value = "16:00";

													var addModal = new bootstrap.Modal(
															document
																	.getElementById('lisaaTapahtumaModal'));
													if (addModal)
														addModal.show();
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
														+ (props.description
																.trim() || 'Ei merkintöjä');

												new bootstrap.Tooltip(
														info.el,
														{
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

							var hakuInput = document
									.getElementById('asiakasHaku');
							if (hakuInput) {
								hakuInput
										.addEventListener(
												'input',
												function(e) {
													var inputValue = e.target.value;
													var options = document
															.querySelectorAll('#asiakasLista option');
													var hiddenInput = document
															.getElementById('asiakasId');
													if (hiddenInput) {
														hiddenInput.value = "";
														for (var i = 0; i < options.length; i++) {
															if (options[i].value === inputValue) {
																hiddenInput.value = options[i]
																		.getAttribute('data-id');
																break;
															}
														}
													}
												});
							}

							var lisaaModalEl = document
									.getElementById('lisaaTapahtumaModal');
							if (lisaaModalEl) {
								lisaaModalEl
										.addEventListener(
												'show.bs.modal',
												function() {
													if (document
															.getElementById('asiakasHaku'))
														document
																.getElementById('asiakasHaku').value = "";
													if (document
															.getElementById('asiakasId'))
														document
																.getElementById('asiakasId').value = "";
												});
							}
						});
	</script>

</body>
</html>
