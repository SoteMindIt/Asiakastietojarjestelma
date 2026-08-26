<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="fi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Asiakastietojärjestelmä</title>
<!-- Lataa paikallisen Bootstrap-tyylitiedoston resources-juuresta -->
<link
	href="${pageContext.request.contextPath}/resources/bootstrap.min.css"
	rel="stylesheet" />
<style>
body {
	background-color: #f8f9fa;
}

.table-responsive {
	background: white;
	border-radius: 8px;
	padding: 10px;
	box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
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
					href="${pageContext.request.contextPath}/">Asiakkaat</a> <a
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
		<div class="d-flex justify-content-between align-items-center mb-4">
			<h2 class="text-dark fw-bold mb-0">Asiakastietojärjestelmä</h2>
			<button type="button" class="btn btn-primary fw-bold px-4 shadow-sm"
				data-bs-toggle="modal" data-bs-target="#lisaaAsiakasModal">
				+ Lisää uusi asiakas</button>
		</div>

		<!-- 🔍 HAKULOMAKE -->
		<div class="row mb-3">
			<div class="col-md-6 col-lg-5">
				<form action="${pageContext.request.contextPath}/" method="get"
					class="d-flex gap-2">
					<input type="text" name="haku" class="form-control shadow-sm"
						placeholder="Hae nimellä, sähköpostilla, puhelimella tai Y-tunnuksella..."
						value="${haku}">
					<button type="submit" class="btn btn-primary fw-bold shadow-sm">Hae</button>
					<c:if test="${not empty haku}">
						<a href="${pageContext.request.contextPath}/"
							class="btn btn-outline-secondary shadow-sm">Tyhjennä</a>
					</c:if>
				</form>
			</div>
		</div>

		<div class="row g-4">
			<!-- VASEN SARAKE: ASIAKASLISTA (Leveys 8/12 työpöydällä) -->
			<div class="col-lg-8">
				<h4 class="text-secondary mb-3">Kaikki asiakkaat</h4>
				<div class="table-responsive border">
					<table class="table table-hover align-middle mb-0">
						<thead class="table-light">
							<tr>
								<th>ID</th>
								<th>Nimi</th>
								<th>Y-tunnus</th>
								<th>Sähköposti</th>
								<th>Puhelin</th>
								<th>Tila</th>
								<th class="text-end">Toiminnot</th>
							</tr>
						</thead>
						<tbody>
							<c:forEach var="asiakas" items="${asiakkaat}">
								<tr>
									<td class="text-muted">#${asiakas.id}</td>
									<td><strong class="text-dark">${asiakas.nimi}</strong></td>
									<td><span class="text-muted">${not empty asiakas.YTunnus ? asiakas.YTunnus : '-'}</span></td>
									<td>${asiakas.sahkoposti}</td>
									<td>${asiakas.puhelin}</td>
									<td><span
										class="badge 
											<c:choose>
												<c:when test="${asiakas.tila == 'PROSPEKTI'}">bg-info text-white</c:when>
												<c:when test="${asiakas.tila == 'KONTAKTOITU'}">bg-warning text-dark</c:when>
												<c:when test="${asiakas.tila == 'TARJOUS_JATETTY'}">bg-primary</c:when>
												<c:when test="${asiakas.tila == 'AKTIIVINEN'}">bg-success</c:when>
												<c:otherwise>bg-secondary</c:otherwise>
											</c:choose>">
											${asiakas.tila} </span></td>
									<td class="text-end"><a
										href="${pageContext.request.contextPath}/asiakas/${asiakas.id}"
										class="btn btn-sm btn-outline-primary px-3 rounded-pill fw-semibold">
											Avaa profiili </a></td>
								</tr>
							</c:forEach>
							<c:if test="${empty asiakkaat}">
								<tr>
									<td colspan="7" class="text-center py-4 text-muted">Ei
										hakutuloksia tai asiakkaita järjestelmässä.</td>
								</tr>
							</c:if>
						</tbody>
					</table>
				</div>

				<!-- SIVUTUSLINKIT -->
				<c:if test="${totalPages > 1}">
					<nav aria-label="Asiakaslistan sivutus"
						class="d-flex justify-content-center mt-4">
						<ul class="pagination shadow-sm">
							<li class="page-item ${currentPage == 0 ? 'disabled' : ''}">
								<a class="page-link"
								href="?page=${currentPage - 1}&haku=${haku}">&laquo;
									Edellinen</a>
							</li>
							<c:forEach var="i" begin="0" end="${totalPages - 1}">
								<li class="page-item ${currentPage == i ? 'active' : ''}">
									<a class="page-link" href="?page=${i}&haku=${haku}">${i + 1}</a>
								</li>
							</c:forEach>
							<li
								class="page-item ${currentPage >= totalPages - 1 ? 'disabled' : ''}">
								<a class="page-link"
								href="?page=${currentPage + 1}&haku=${haku}">Seuraava
									&raquo;</a>
							</li>
						</ul>
					</nav>
				</c:if>
			</div>
			<!-- OIKEA SARAKE: TULEVAT KALENTERIMERKINNÄT (Leveys 4/12) -->
			<div class="col-lg-4">
				<h4 class="text-secondary mb-3">Tulevat tehtävät ja tapaamiset</h4>
				<div class="card shadow-sm border-0 rounded-3">
					<div class="card-body p-3">
						<c:forEach var="tap" items="${tulevatTapahtumat}">
							<div
								class="p-3 mb-2 rounded border-start border-4 
		<c:choose>
			<c:when test="${tap.tyyppi.name() == 'TAPAAMINEN'}">border-success bg-success bg-opacity-10</c:when>
			<c:when test="${tap.tyyppi.name() == 'PUHELU' || tap.tyyppi.name() == 'SOITTO'}">border-warning bg-warning bg-opacity-10</c:when>
			<c:when test="${tap.tyyppi.name() == 'SÄHKÖPOSTI'}">border-info bg-info bg-opacity-10</c:when>
			<c:otherwise>border-primary bg-primary bg-opacity-10</c:otherwise>
		</c:choose>">

								<div class="d-flex justify-content-between align-items-start">
									<!-- 🔗 1. KLIKATTAVA SININEN LINKKI JOKA AVAA MODALIN -->
									<a href="#"
										class="text-primary fw-bold d-block mb-1 text-decoration-none"
										data-bs-toggle="modal"
										data-bs-target="#muokkaaTapahtumaModal${tap.id}">
										${tap.otsikko} </a> <span
										class="badge bg-white text-dark border small">${tap.tyyppi}</span>
								</div>

								<!-- Jos tapahtumaan on kytketty asiakas, näytetään linkki häneen -->
								<c:if test="${not empty tap.asiakas}">
									<small class="d-block text-secondary fw-semibold mb-1">
										👤 Asiakas: <a
										href="${pageContext.request.contextPath}/asiakas/${tap.asiakas.id}"
										class="text-decoration-none">${tap.asiakas.nimi}</a>
									</small>
								</c:if>

								<small class="text-muted d-block"> 📅
									${tap.ajankohta.toString().replace('T', ' ').substring(0, 16)}
								</small>
							</div>

							<!-- 🎛️ 2. DYNAAMINEN POKSAHDUSIKKUNA (MODAL) JOKAISELLE TAPAHTUMALLE -->
							<div class="modal fade" id="muokkaaTapahtumaModal${tap.id}"
								tabindex="-1" aria-hidden="true">
								<div class="modal-dialog modal-dialog-centered">
									<div class="modal-content border-0 shadow-lg">
										<div class="modal-header bg-dark text-white">
											<h5 class="modal-title fw-bold">Muokkaa tapahtumaa</h5>
											<button type="button" class="btn-close btn-close-white"
												data-bs-dismiss="modal"></button>
										</div>
										<!-- Lomake lähettää tiedot suoraan controllerin päivitysreittiin -->
										<form
											action="${pageContext.request.contextPath}/kalenteri/paivita/${tap.id}"
											method="post">
											<div class="modal-body p-4">

												<!-- Otsikko -->
												<div class="mb-3">
													<label class="form-label fw-semibold text-secondary">Otsikko</label>
													<input type="text" class="form-control" name="otsikko"
														value="${tap.otsikko}" required>
												</div>

												<!-- Tyyppi -->
												<div class="mb-3">
													<label class="form-label fw-semibold text-secondary">Tyyppi</label>
													<select class="form-select" name="tyyppi" required>
														<c:forEach var="tyyppiOption" items="${tilat}">
															<!-- Hyödynnetään enumeja -->
															<!-- Huom: Koska etusivulle viedään 'tilat', käytetään vakioita tai arvoja vapaasti -->
															<option value="TAPAAMINEN"
																${tap.tyyppi.name() == 'TAPAAMINEN' ? 'selected' : ''}>TAPAAMINEN</option>
															<option value="PUHELU"
																${tap.tyyppi.name() == 'PUHELU' ? 'selected' : ''}>PUHELU</option>
															<option value="SÄHKÖPOSTI"
																${tap.tyyppi.name() == 'SÄHKÖPOSTI' ? 'selected' : ''}>SÄHKÖPOSTI</option>
														</c:forEach>
													</select>
												</div>

												<!-- Ajankohta -->
												<div class="mb-3">
													<label class="form-label fw-semibold text-secondary">Ajankohta</label>
													<input type="datetime-local" class="form-control"
														name="ajankohtaStr" value="${tap.ajankohta}" required>
												</div>

												<!-- Kuvaus -->
												<div class="mb-3">
													<label class="form-label fw-semibold text-secondary">Kuvaus
														/ Muistiinpanot</label>
													<textarea class="form-control" name="kuvaus" rows="3">${tap.kuvaus}</textarea>
												</div>

												<!-- Piilotettu asiakasId varmuuden vuoksi, jos sitä ei muuteta etusivulta -->
												<input type="hidden" name="asiakasId"
													value="${not empty tap.asiakas ? tap.asiakas.id : ''}">

											</div>
											<div class="modal-footer bg-light">
												<button type="button" class="btn btn-secondary"
													data-bs-dismiss="modal">Peruuta</button>
												<button type="submit" class="btn btn-success px-4 fw-bold">Tallenna
													muutokset</button>
											</div>
										</form>
									</div>
								</div>
							</div>
						</c:forEach>


						<c:if test="${empty tulevatTapahtumat}">
							<div class="text-center py-4 text-muted small">Ei tulevia
								kalenterimerkintöjä lähitulevaisuudessa.</div>
						</c:if>
					</div>
				</div>
			</div>
		</div>
		<!-- .row päättyminen kunnolla -->
	</div>
	<!-- .container päättyminen -->

	<!-- BOOTSTRAP POP-UP LOMAKE (MODAL) UUDELLE ASIAKKAALLE -->
	<div class="modal fade" id="lisaaAsiakasModal" tabindex="-1"
		aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content border-0 shadow-lg">
				<div class="modal-header bg-primary text-white">
					<h5 class="modal-title fw-bold">Lisää uusi asiakas</h5>
					<button type="button" class="btn-close btn-close-white"
						data-bs-dismiss="modal"></button>
				</div>
				<form action="${pageContext.request.contextPath}/lisaa-asiakas"
					method="post">
					<div class="modal-body p-4">
						<div class="mb-3">
							<label for="nimi" class="form-label fw-semibold text-secondary">Nimi
								/ Organisaatio</label> <input type="text" class="form-control" id="nimi"
								name="nimi" required placeholder="esim. Sote-Hyvinvointi Oy">
						</div>

						<!-- LISÄTTY Y-TUNNUS UUDEN ASIAKKAAN LOMAKKEELLE -->
						<div class="mb-3">
							<label for="yTunnus"
								class="form-label fw-semibold text-secondary">Y-tunnus
								(vapaaehtoinen)</label> <input type="text" class="form-control"
								id="yTunnus" name="yTunnus" placeholder="esim. 1234567-8"
								maxlength="9">
						</div>

						<div class="mb-3">
							<label for="sahkoposti"
								class="form-label fw-semibold text-secondary">Sähköposti</label>
							<input type="email" class="form-control" id="sahkoposti"
								name="sahkoposti" required placeholder="yhteys@yritys.fi">
						</div>
						<div class="mb-3">
							<label for="puhelin"
								class="form-label fw-semibold text-secondary">Puhelin</label> <input
								type="text" class="form-control" id="puhelin" name="puhelin"
								required placeholder="040 123 4567">
						</div>
						<div class="mb-3">
							<label for="tila" class="form-label fw-semibold text-secondary">Asiakkuuden
								alkutila</label> <select class="form-select" id="tila" name="tila"
								required>
								<c:forEach var="t" items="${tilat}">
									<option value="${t}">${t}</option>
								</c:forEach>
							</select>
						</div>
					</div>
					<div class="modal-footer bg-light">
						<button type="button" class="btn btn-secondary"
							data-bs-dismiss="modal">Peruuta</button>
						<button type="submit" class="btn btn-primary px-4 fw-bold">Tallenna
							asiakas</button>
					</div>
				</form>
			</div>
		</div>
	</div>

	<!-- Lataa paikallisen Bootstrap-JavaScriptin resources-juuresta -->
	<script
		src="${pageContext.request.contextPath}/resources/bootstrap.bundle.min.js"></script>
</body>
</html>
