<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html lang="fi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Työpöytä - Astori</title>
<link
	href="${pageContext.request.contextPath}/resources/bootstrap.min.css"
	rel="stylesheet" />
<style>
body {
	background-color: #f8f9fa;
}

.dashboard-card {
	background: white;
	border-radius: 8px;
	padding: 20px;
	box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
	border: 1px solid #dee2e6;
	transition: transform 0.2s;
}

.dashboard-card:hover {
	transform: translateY(-3px);
}

.icon-box {
	width: 48px;
	height: 48px;
	border-radius: 50%;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 24px;
}

/* 💡 Tyylivinkki: Alleviivaus näkyviin vain, kun hiiri on linkin päällä */
.text-primary:hover {
	text-decoration: underline !important;
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
				<a class="nav-link active fw-bold"
					href="${pageContext.request.contextPath}/">Etusivu</a> <a
					class="nav-link"
					href="${pageContext.request.contextPath}/asiakkaat">Asiakkaat</a> <a
					class="nav-link"
					href="${pageContext.request.contextPath}/asetukset">Asetukset</a> <a
					class="nav-link" href="${pageContext.request.contextPath}/raportit">Raportit</a>
				<a class="nav-link"
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
		<div class="mb-4">
			<h2 class="text-dark fw-bold mb-1">Tervetuloa Astoriin!</h2>
			<p class="text-muted">Tässä on yleisnäkymä järjestelmän tämänhetkisestä tilanteesta.</p>
		</div>

		<!-- 📊 TIETOLAATIKOT (DASHBOARD-KORTIT) -->
		<div class="row g-4 mb-5">
			<!-- Kortti 1: Asiakkaat -->
			<div class="col-md-4">
				<div
					class="dashboard-card d-flex align-items-center justify-content-between">
					<div>
						<h6 class="text-secondary fw-semibold mb-1">Asiakkaat yhteensä</h6>
						<h3 class="fw-bold text-dark mb-0">${not empty asiakkaatLaskuri ? asiakkaatLaskuri : '0'} kpl</h3>
						<small class="text-muted">Aktiiviset asiakkuutesi</small>
					</div>
					<div class="icon-box bg-primary bg-opacity-10 text-primary">👤</div>
				</div>
			</div>
			<!-- Kortti 2: Tarjoukset -->
			<div class="col-md-4">
				<div
					class="dashboard-card d-flex align-items-center justify-content-between">
					<div>
						<h6 class="text-secondary fw-semibold mb-1">Avoimet tarjoukset</h6>
						<h3 class="fw-bold text-dark mb-0">${not empty tarjouksetLaskuri ? tarjouksetLaskuri : '0'} kpl</h3>
						<small class="text-muted">Jätetyt tarjouslaskelmat</small>
					</div>
					<div class="icon-box bg-success bg-opacity-10 text-success">💼</div>
				</div>
			</div>
			<!-- Kortti 3: Tehtävät -->
			<div class="col-md-4">
				<div
					class="dashboard-card d-flex align-items-center justify-content-between">
					<div>
						<h6 class="text-secondary fw-semibold mb-1">Tehtävät loppupäivälle</h6>
						<h3 class="fw-bold text-dark mb-0">${not empty tehtavatLaskuri ? tehtavatLaskuri : '0'} kpl</h3>
						<small class="text-muted">Tämän päivän agenda</small>
					</div>
					<div class="icon-box bg-warning bg-opacity-10 text-warning">📅</div>
				</div>
			</div>
		</div>
		<div class="row g-4">
			<!-- VASEN REUNA: KALENTERIMERKINNÄT -->
			<div class="col-lg-8">
				<div class="bg-white p-4 rounded-3 border shadow-sm">
					<h4 class="text-dark fw-bold mb-4">Seuraavat kalenterimerkinnät</h4>

					<c:forEach var="tap" items="${tulevatTapahtumat}">
						<div
							class="p-3 mb-3 rounded border-start border-4 
							<c:choose>
								<c:when test="${tap.tyyppi.nimi == 'Tapaaminen'}">border-success bg-success bg-opacity-10</c:when>
								<c:when test="${tap.tyyppi.nimi == 'Puhelu' || tap.tyyppi.nimi == 'Soitto'}">border-warning bg-warning bg-opacity-10</c:when>
								<c:when test="${tap.tyyppi.nimi == 'Sähköposti'}">border-info bg-info bg-opacity-10</c:when>
								<c:otherwise>border-primary bg-primary bg-opacity-10</c:otherwise>
							</c:choose>">

							<!-- 1. TAPAHTUMATYYPPI -->
							<div class="mb-1">
								<!-- 💡 PÄIVITETTY: Käyttää nyt tap.tyyppi.nimi -kenttää -->
								<span class="badge bg-dark text-white uppercase small tracking-wider">${tap.tyyppi.nimi}</span>
							</div>

							<!-- 2. OTSIKKO / AIHE -->
							<h5 class="mb-1">
								<!-- 💡 KORJATTU: Luokat vaihdettu muotoon 'text-primary fw-semibold text-decoration-none' -->
								<!-- 💡 KORJATTU: JavaScriptille välitetään nyt tyypin tekstitunnuksen sijaan numeerinen tyyppi.id -->
								<a href="#" class="text-primary fw-semibold text-decoration-none"
									onclick="avaaMuokkausModal('${tap.id}', '<c:out value="${tap.otsikko}"/>', '${tap.tyyppi.id}', '${tap.ajankohta}', '${not empty tap.asiakas ? tap.asiakas.id : ''}')">
									<c:out value="${tap.otsikko}" />
								</a>
							</h5>

							<!-- 3. ASIAKAS, JOHON TAPAHTUMA ON KOHDISTETTU -->
							<div class="mb-2 text-secondary small">
								<c:choose>
									<c:when test="${not empty tap.asiakas}">
										👤 Asiakas: <strong class="text-dark">${tap.asiakas.nimi}</strong>
									</c:when>
									<c:otherwise>
										⚙️ <em>Sisäinen merkintä (Ei liitettyä asiakasta)</em>
									</c:otherwise>
								</c:choose>
							</div>

							<!-- Päivämäärä ja kellonaika -->
							<c:if test="${not empty tap.ajankohta}">
								<small class="text-muted fw-semibold d-block"> 
									<c:set var="ajankohtaTeksti" value="${tap.ajankohta != null ? tap.ajankohta.toString().substring(0, 16) : ''}" />
									<c:if test="${not empty ajankohtaTeksti}">
										<fmt:parseDate value="${ajankohtaTeksti}" pattern="yyyy-MM-dd'T'HH:mm" var="parsituPvm" type="both" />
										<fmt:formatDate value="${parsituPvm}" pattern="dd.MM.yyyy 'klo' HH:mm" />
									</c:if>
								</small>
							</c:if>

						</div>
					</c:forEach>

					<c:if test="${empty tulevatTapahtumat}">
						<div class="text-center py-5 text-muted">
							<p class="mb-0 fs-5">Ei tulevia kalenterimerkintöjä.</p>
						</div>
					</c:if>
				</div>
			</div>
				<!-- OIKEA REUNA: PIKALINKIT -->
			<div class="col-lg-4">
				<div class="bg-white p-4 rounded-3 border shadow-sm h-100">
					<h5 class="fw-bold text-dark mb-3">Pikalinkit</h5>
					<div class="list-group list-group-flush">
						<a href="${pageContext.request.contextPath}/asiakkaat"
							class="list-group-item list-group-item-action ps-0 text-primary">➡️
							Hallitse asiakkaita</a> 
						<a href="${pageContext.request.contextPath}/kalenteri"
							class="list-group-item list-group-item-action ps-0 text-primary">➡️
							Avaa iso kalenteri</a>
					</div>
				</div>
			</div>
		</div>
	</div>

	<!-- 💡 TURVALLINEN HTML-SÄILÖ -->
	<div style="display: none;">
		<c:forEach var="tap" items="${tulevatTapahtumat}">
			<div id="tap-kuvaus-${tap.id}">
				<c:out value="${tap.kuvaus}" />
			</div>
		</c:forEach>
	</div>

	<!-- YHTENÄISTETTY JA DYNAAMINEN PONNAHDUSIKKUNA (MODAL) TAPAHTUMAN MUOKKAUKSELLE ETUSIVULLA -->
	<div class="modal fade" id="muokkaaTapahtumaModal" tabindex="-1"
		data-bs-backdrop="static" data-bs-keyboard="true" aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content border-0 shadow-lg">
				<div class="modal-header bg-dark text-white">
					<h5 class="modal-title fw-bold">Muokkaa tapahtumaa</h5>
					<button type="button" class="btn-close btn-close-white"
						data-bs-dismiss="modal"></button>
				</div>

				<form id="muokkaaTapahtumaForm" method="post">
					<input type="hidden" name="lahde" value="dashboard">

					<div class="modal-body p-4 text-start">
						<div class="mb-3">
							<label class="form-label fw-semibold text-secondary">Otsikko / Aihe</label> 
							<input type="text" class="form-control" id="muokkaaOtsikko" name="otsikko" required>
						</div>

						<div class="mb-3">
							<label class="form-label fw-semibold text-secondary">Tapahtuman tyyppi</label> 
							<select class="form-select" id="muokkaaTyyppi" name="tyyppi" required>
								<!-- 💡 KORJATTU: items käyttää nyt 'tapahtumaTyypit'-nimikettä muiden sivujen mukaisesti -->
								<c:forEach var="t" items="${tapahtumaTyypit}">
									<!-- 💡 KORJATTU: value tallentaa nyt ID:n, ei nimeä -->
									<option value="${t.id}">${t.nimi}</option>
								</c:forEach>
							</select>
						</div>

						<div class="mb-3">
							<label class="form-label fw-semibold text-secondary">Ajankohta ja kellonaika</label> 
							<input type="datetime-local" class="form-control" id="muokkaaAjankohta" name="ajankohtaStr" required>
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
						<!-- 💡 KORJATTU: Lisätty poistopainikkeen HTML takaisin, jotta JS ei heitä virhettä elementin puuttumisesta -->
						<button type="submit" id="poistaTapahtumaPainike" class="btn btn-outline-danger fw-bold"
							onclick="return confirm('Haluatko varmasti poistaa tämän tapahtuman?');">Poista</button>
						<div>
							<button type="button" class="btn btn-secondary me-2" data-bs-dismiss="modal">Peruuta</button>
							<button type="submit" class="btn btn-success px-4 fw-bold">Tallenna</button>
						</div>
					</div>
				</form>
			</div>
		</div>
	</div>
	<!-- ELEMENTTIEN TÄYTTÖ JAVASCRIPTILLÄ KLIKKAUKSESSA -->
	<script>
	function avaaMuokkausModal(id, otsikko, tyyppiId, ajankohta, asiakasId) {
		// 1. Asetetaan lomakkeen ja poistopainikkeen dynaamiset reitit oikealle ID-numerolle
		var form = document.getElementById('muokkaaTapahtumaForm');
		form.action = '${pageContext.request.contextPath}/kalenteri/paivita/' + id;
		
		var poistaBtn = document.getElementById('poistaTapahtumaPainike');
		if (poistaBtn) {
			poistaBtn.formAction = '${pageContext.request.contextPath}/kalenteri/poista-suoraan/' + id + '?lahde=dashboard';
		}

		// 2. Päivitetään kenttien arvot klikatun tapahtuman mukaisiksi
		document.getElementById('muokkaaOtsikko').value = otsikko;
		
		// 💡 KORJATTU: Asettaa nyt tyyppiId-arvon pudotusvalikkoon, jotta valinta täsmää
		document.getElementById('muokkaaTyyppi').value = tyyppiId;
		
		// datetime-local vaatii muodon YYYY-MM-DDTHH:MM
		if (ajankohta && ajankohta.length >= 16) {
			document.getElementById('muokkaaAjankohta').value = ajankohta.substring(0, 16);
		} else {
			document.getElementById('muokkaaAjankohta').value = ajankohta;
		}
		
		document.getElementById('muokkaaAsiakasId').value = asiakasId || "";
		
		// Haetaan kuvaus turvallisesta html-säilöstä
		var kuvausElement = document.getElementById('tap-kuvaus-' + id);
		document.getElementById('muokkaaKuvaus').value = kuvausElement ? kuvausElement.innerText.trim() : '';

		// 3. Avataan yhtenäinen modal näkyviin
		var modalElement = document.getElementById('muokkaaTapahtumaModal');
		var modal = bootstrap.Modal.getOrCreateInstance(modalElement);
		modal.show();
	}
	</script>

	<script src="${pageContext.request.contextPath}/resources/bootstrap.bundle.min.js"></script>
</body>
</html>
		