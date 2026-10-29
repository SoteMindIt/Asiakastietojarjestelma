<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>
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
	color: inherit;
	font: inherit;
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
			<p class="text-muted">Tässä on yleisnäkymä järjestelmän
				tämänhetkisestä tilanteesta.</p>
		</div>

		<!-- 📊 TIETOLAATIKOT (DASHBOARD-KORTIT) -->
		<div class="row g-4 mb-5">
			<!-- Kortti 1: Asiakkaat -->
			<div class="col-md-4">
				<div
					class="dashboard-card d-flex align-items-center justify-content-between">
					<div>
						<h6 class="text-secondary fw-semibold mb-1">Asiakkaat
							yhteensä</h6>
						<h3 class="fw-bold text-dark mb-0">${not empty asiakkaatLaskuri ? asiakkaatLaskuri : '0'}
							kpl</h3>
						<small class="text-muted">Aktiiviset asiakkuutesi</small>
					</div>
					<div class="icon-box bg-primary bg-opacity-10 text-primary">👤</div>
				</div>
			</div>
			<!-- Kortti 2: Tarjoukset -->
			<div class="col-md-4">
				<button type="button"
					class="dashboard-card d-flex align-items-center justify-content-between w-100 text-start"
					data-bs-toggle="modal" data-bs-target="#avoimetTarjouksetModal"
					aria-label="Näytä avoimet tarjoukset">
					<div>
						<h6 class="text-secondary fw-semibold mb-1">Avoimet
							tarjoukset</h6>
						<h3 class="fw-bold text-dark mb-0">${not empty tarjouksetLaskuri ? tarjouksetLaskuri : '0'}
							kpl</h3>
						<small class="text-muted">Avaa listaus ja hallitse tarjouksia</small>
					</div>
					<div class="icon-box bg-success bg-opacity-10 text-success">💼</div>
				</button>
			</div>
			<!-- Kortti 3: Tehtävät -->
			<div class="col-md-4">
				<div
					class="dashboard-card d-flex align-items-center justify-content-between">
					<div>
						<h6 class="text-secondary fw-semibold mb-1">Tehtävät
							loppupäivälle</h6>
						<h3 class="fw-bold text-dark mb-0">${not empty tehtavatLaskuri ? tehtavatLaskuri : '0'}
							kpl</h3>
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
					<h4 class="text-dark fw-bold mb-4">Seuraavat
						kalenterimerkinnät</h4>

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
								<span
									class="badge bg-dark text-white uppercase small tracking-wider">${tap.tyyppi.nimi}</span>
							</div>

							<!-- 2. OTSIKKO / AIHE -->
							<h5 class="mb-1">
								<a href="#"
									class="text-primary fw-semibold text-decoration-none"
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
								<small class="text-muted fw-semibold d-block"> <c:set
										var="ajankohtaTeksti"
										value="${tap.ajankohta != null ? tap.ajankohta.toString().substring(0, 16) : ''}" />
									<c:if test="${not empty ajankohtaTeksti}">
										<fmt:parseDate value="${ajankohtaTeksti}"
											pattern="yyyy-MM-dd'T'HH:mm" var="parsituPvm" type="both" />
										<fmt:formatDate value="${parsituPvm}"
											pattern="dd.MM.yyyy 'klo' HH:mm" />
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

					<c:if test="${tapahtumaSivuja > 1}">
						<nav aria-label="Kalenterimerkintöjen sivutus">
							<ul class="pagination justify-content-center mb-0">
								<c:if test="${tapahtumaSivu > 0}">
									<li class="page-item">
										<a class="page-link" href="${pageContext.request.contextPath}/?tapahtumaSivu=${tapahtumaSivu - 1}" aria-label="Edellinen sivu">Edellinen</a>
									</li>
								</c:if>
								<li class="page-item disabled">
									<span class="page-link">Sivu ${tapahtumaSivu + 1} / ${tapahtumaSivuja}</span>
								</li>
								<c:if test="${tapahtumaSivu + 1 < tapahtumaSivuja}">
									<li class="page-item">
										<a class="page-link" href="${pageContext.request.contextPath}/?tapahtumaSivu=${tapahtumaSivu + 1}" aria-label="Seuraava sivu">Seuraavat 5</a>
									</li>
								</c:if>
							</ul>
						</nav>
					</c:if>
				</div>
			</div>
			<!-- OIKEA REUNA: PIKALINKIT JA YLEISET MUISTIINPANOT -->
			<div class="col-lg-4">
				<!-- Pikalinkit -->
				<div class="bg-white p-4 rounded-3 border shadow-sm mb-4">
					<h5 class="fw-bold text-dark mb-3">Pikalinkit</h5>
					<div class="list-group list-group-flush">
						<a href="${pageContext.request.contextPath}/asiakkaat"
							class="list-group-item list-group-item-action ps-0 text-primary">➡️
							Hallitse asiakkaita</a> <a
							href="${pageContext.request.contextPath}/kalenteri"
							class="list-group-item list-group-item-action ps-0 text-primary">➡️
							Avaa iso kalenteri</a>
					</div>
				</div>

				<!-- 🔌 UUSI KORTTI: YLEISET MUISTIINPANOT ETUSIVULLE -->
				<div class="bg-white p-4 rounded-3 border shadow-sm">
					<div class="d-flex justify-content-between align-items-center mb-3">
						<h5 class="fw-bold text-dark mb-0">📌 Yleiset muistiinpanot</h5>
						<button type="button"
							class="btn btn-sm btn-primary fw-bold rounded-pill px-2.5"
							data-bs-toggle="modal" data-bs-target="#lisaaMuistiinpanoModal">
							+ Lisää</button>
					</div>

					<div class="muistiinpano-lista"
						style="max-height: 400px; overflow-y: auto;">
						<c:forEach var="mp" items="${yleisetMuistiinpanot}">
							<div class="p-3 bg-light border rounded mb-2 text-start">
								<div
									class="d-flex justify-content-between align-items-center mb-1">
									<small class="text-muted fw-semibold"> <c:set
											var="mpAika"
											value="${mp.luontiaika.toString().substring(0, 16)}" /> <fmt:parseDate
											value="${mpAika}" pattern="yyyy-MM-dd'T'HH:mm" var="pMpAika" />
										<fmt:formatDate value="${pMpAika}" pattern="dd.MM.yyyy HH:mm" />
									</small> <span class="badge bg-secondary-subtle text-secondary small"
										style="font-size: 0.7rem;">Yleinen</span>
								</div>
								<p class="mb-0 text-dark small"
									style="white-space: pre-line; line-height: 1.4;">
									<c:out value="${mp.teksti}" />
								</p>
							</div>
						</c:forEach>

						<c:if test="${empty yleisetMuistiinpanot}">
							<div class="text-center py-4 text-muted small italic">Ei
								yleisiä muistiinpanoja tallennettuna.</div>
						</c:if>
					</div>
				</div>
			</div>
		</div>
	</div>

	<!-- 💡 TURVALLINEN HTML-SÄILÖ KALENTERIKUVAUKSILLE -->
	<div style="display: none;">
		<c:forEach var="tap" items="${tulevatTapahtumat}">
			<div id="tap-kuvaus-${tap.id}">
				<c:out value="${tap.kuvaus}" />
			</div>
		</c:forEach>
	</div>
	<!-- 🔌 UUSI: POP-UP MODAL UUDELLE YLEISELLE MUISTIINPANOLLE -->
	<div class="modal fade" id="lisaaMuistiinpanoModal" tabindex="-1"
		aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content border-0 shadow-lg">
				<div class="modal-header bg-primary text-white">
					<h5 class="modal-title fw-bold">Luo uusi yleinen muistiinpano</h5>
					<button type="button" class="btn-close btn-close-white"
						data-bs-dismiss="modal"></button>
				</div>
				<!-- Kytketty uuteen MuistiinpanoControlleriin -->
				<form action="${pageContext.request.contextPath}/lisaa-muistiinpano"
					method="post">
					<div class="modal-body p-4 text-start">
						<div class="mb-1">
							<label for="mpTeksti"
								class="form-label fw-semibold text-secondary small">Muistiinpanon
								tai muistilistan sisältö *</label>
							<textarea class="form-control" id="mpTeksti" name="teksti"
								rows="5" required
								placeholder="Kirjoita tähän yleinen muistettava asia..."></textarea>
						</div>
					</div>
					<div class="modal-footer bg-light">
						<button type="button" class="btn btn-secondary"
							data-bs-dismiss="modal">Peruuta</button>
						<button type="submit" class="btn btn-primary px-4 fw-bold">Tallenna
							etusivulle</button>
					</div>
				</form>
			</div>
		</div>
	</div>

	<div class="modal fade" id="avoimetTarjouksetModal" tabindex="-1"
		aria-labelledby="avoimetTarjouksetModalLabel" aria-hidden="true">
		<div class="modal-dialog modal-xl modal-dialog-scrollable">
			<div class="modal-content border-0 shadow-lg">
				<div class="modal-header bg-success text-white">
					<h5 class="modal-title fw-bold" id="avoimetTarjouksetModalLabel">Avoimet tarjoukset</h5>
					<button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"
						aria-label="Sulje"></button>
				</div>
				<div class="modal-body">
					<c:choose>
						<c:when test="${empty avoimetTarjoukset}">
							<p class="text-center text-muted my-4">Ei avoimia tarjouksia.</p>
						</c:when>
						<c:otherwise>
							<div class="table-responsive">
								<table class="table table-hover align-middle">
									<thead class="table-light">
										<tr>
											<th>Tarjousnumero</th>
											<th>Asiakas</th>
											<th>Päivämäärä</th>
											<th>Voimassa asti</th>
											<th class="text-end">Yhteensä</th>
											<th class="text-end">Toiminnot</th>
										</tr>
									</thead>
									<tbody>
										<c:forEach var="tarjous" items="${avoimetTarjoukset}">
											<tr>
												<td class="fw-semibold"><c:out value="${tarjous.tarjousNumero}" /></td>
												<td><c:out value="${tarjous.asiakas.nimi}" /></td>
												<td><c:out value="${tarjous.pvm}" /></td>
												<td><c:out value="${tarjous.voimassaoloPvm}" /></td>
												<td class="text-end fw-semibold">
													<fmt:formatNumber value="${tarjous.verollinenYhteensa}"
														type="currency" currencySymbol="€" />
												</td>
												<td class="text-end text-nowrap">
													<a class="btn btn-sm btn-outline-primary"
														href="${pageContext.request.contextPath}/tarjous/${tarjous.id}">Tarkastele</a>
													<a class="btn btn-sm btn-primary"
														href="${pageContext.request.contextPath}/tarjous/${tarjous.id}/muokkaa">Muokkaa</a>
												</td>
											</tr>
										</c:forEach>
									</tbody>
								</table>
							</div>
						</c:otherwise>
					</c:choose>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Sulje</button>
				</div>
			</div>
		</div>
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
							class="btn btn-outline-danger fw-bold"
							onclick="return confirm('Haluatko varmasti poistaa tämän tapahtuman?');">Poista</button>
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

	<!-- JAVASCRIPT-FUNKTIOT ELEMENTTIEN DYNAAMISELLE TÄYTÖLLE -->
	<script>
	function avaaMuokkausModal(id, otsikko, tyyppiId, ajankohta, asiakasId) {
		var form = document.getElementById('muokkaaTapahtumaForm');
		form.action = '${pageContext.request.contextPath}/kalenteri/paivita/' + id;
		
		var poistaBtn = document.getElementById('poistaTapahtumaPainike');
		if (poistaBtn) {
			poistaBtn.formAction = '${pageContext.request.contextPath}/kalenteri/poista-suoraan/' + id + '?lahde=dashboard';
		}

		document.getElementById('muokkaaOtsikko').value = otsikko;
		document.getElementById('muokkaaTyyppi').value = tyyppiId;
		
		if (ajankohta && ajankohta.length >= 16) {
			document.getElementById('muokkaaAjankohta').value = ajankohta.substring(0, 16);
		} else {
			document.getElementById('muokkaaAjankohta').value = ajankohta;
		}
		
		document.getElementById('muokkaaAsiakasId').value = asiakasId || "";
		
		var kuvausElement = document.getElementById('tap-kuvaus-' + id);
		document.getElementById('muokkaaKuvaus').value = kuvausElement ? kuvausElement.innerText.trim() : '';

		var modalElement = document.getElementById('muokkaaTapahtumaModal');
		var modal = bootstrap.Modal.getOrCreateInstance(modalElement);
		modal.show();
	}
	</script>

	<!-- GLOBAALI BOOTSTRAP 5 SIVUSKRIPTI -->
	<script
		src="${pageContext.request.contextPath}/resources/bootstrap.bundle.min.js"></script>
</body>
</html>
