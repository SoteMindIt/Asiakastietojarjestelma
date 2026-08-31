<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="fi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Asiakkaat - Astori</title>
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

	<!-- 🌟 PÄIVITETTY YLÄPALKKI -->
	<nav class="navbar navbar-expand-lg navbar-dark bg-dark mb-4 shadow-sm">
		<div class="container">
			<a class="navbar-brand fw-bold"
				href="${pageContext.request.contextPath}/">Astori</a>
			<div class="navbar-nav me-auto">
				<a class="nav-link" href="${pageContext.request.contextPath}/">Etusivu</a>
				<a class="nav-link active fw-bold"
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
		<div class="d-flex justify-content-between align-items-center mb-4">
			<h2 class="text-dark fw-bold mb-0">Asiakashallinta</h2>
			<button type="button" class="btn btn-primary fw-bold px-4 shadow-sm"
				data-bs-toggle="modal" data-bs-target="#lisaaAsiakasModal">
				+ Lisää uusi asiakas</button>
		</div>


		<form action="${pageContext.request.contextPath}/asiakkaat"
			method="get" class="mb-4">
			<div class="mb-4">
				<input type="text" class="form-control form-control-lg shadow-sm"
					id="reaaliaikainenHaku"
					placeholder="Kirjoita asiakkaan nimi, sähköposti tai Y-tunnus etsiäksesi koko tietokannasta...">
			</div>
		</form>

		<div class="row">
			<div class="col-12 mb-4">
				<div class="table-responsive border">
					<table class="table table-hover align-middle mb-0">
						<thead class="table-light">
							<tr>
								<th>Asiakkaan nimi</th>
								<th>Y-tunnus</th>
								<th>Puhelinnumero</th>
								<th>Sähköposti</th>
								<th>Tila</th>
								<th class="text-end">Toiminnot</th>
							</tr>
						</thead>
						<tbody id="asiakasTaulukkoRunko">
							<c:forEach var="a" items="${asiakkaat}">
								<tr>
									<td><strong><a
											href="${pageContext.request.contextPath}/asiakas/${a.id}"
											class="text-decoration-none text-dark">${a.nimi}</a></strong></td>
									<td>${a.yTunnus}</td>
									<td>${a.puhelin}</td>
									<td>${a.sahkoposti}</td>
									<td><c:choose>
											<c:when test="${a.tila == 'PROSPEKTI'}">
												<span
													class="badge bg-warning text-dark fw-bold text-uppercase p-2 shadow-sm">Prospekti</span>
											</c:when>
											<c:when test="${a.tila == 'KONTAKTOITU'}">
												<span
													class="badge bg-info text-dark fw-bold text-uppercase p-2 shadow-sm">Kontaktoitu</span>
											</c:when>
											<c:when test="${a.tila == 'TARJOUS_JATETTY'}">
												<span
													class="badge bg-primary fw-bold text-uppercase p-2 shadow-sm">Tarjous
													jätetty</span>
											</c:when>
											<c:when test="${a.tila == 'AKTIIVINEN'}">
												<span
													class="badge bg-success fw-bold text-uppercase p-2 shadow-sm">Aktiivinen</span>
											</c:when>
											<c:when test="${a.tila == 'PAATTYNYT'}">
												<span
													class="badge bg-secondary fw-bold text-uppercase p-2 shadow-sm">Päättynyt</span>
											</c:when>
											<c:otherwise>
												<span class="badge bg-light text-dark border p-2">${a.tila}</span>
											</c:otherwise>
										</c:choose></td>

									<td class="text-end"><a
										href="${pageContext.request.contextPath}/asiakas/${a.id}"
										class="btn btn-sm btn-outline-primary fw-bold">Avaa
											profiili</a></td>
								</tr>
							</c:forEach>
							<c:if test="${empty asiakkaat}">
								<tr>
									<td colspan="6" class="text-center py-4 text-muted">Ei
										hakutuloksia tai asiakkaita järjestelmässä.</td>
								</tr>
							</c:if>
						</tbody>
					</table>
				</div>

				<!-- SIVUTUSLINKIT KOKO SIVUN LEVEYDELLE -->
				<c:if test="${totalPages > 1}">
					<nav aria-label="Asiakaslistan sivutus" id="sivutusNavigaatio"
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
		</div>
		<!-- .row päättyminen -->
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

						<!-- Y-TUNNUS UUDEN ASIAKKAAN LOMAKKEELLE -->
						<div class="mb-3">
							<label for="yTunnus"
								class="form-label fw-semibold text-secondary">Y-tunnus
								(vapaaehtoinen)</label> <input type="text" class="form-control"
								id="yTunnus" name="yTunnus" placeholder="esim. 1234567-8"
								maxlength="9">
						</div>

						<div class="mb-3">
							<label for="hyvinvointialue" class="form-label">Hyvinvointialue</label>
							<select class="form-select" id="hyvinvointialue"
								name="hyvinvointialue">
								<option value="">-- Valitse hyvinvointialue --</option>
								<c:forEach var="alue" items="${hyvinvointialueet}">
									<option value="${alue}">${alue}</option>
								</c:forEach>
							</select>
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

						<hr class="text-muted my-3">
						<h6 class="fw-bold text-dark mb-3">Osoite- ja käyntitiedot
							(vapaaehtoinen)</h6>

						<div class="mb-3">
							<label for="katuosoite"
								class="form-label fw-semibold text-secondary">Katuosoite</label>
							<input type="text" class="form-control" id="katuosoite"
								name="katuosoite" placeholder="esim. Keskuskatu 10">
						</div>
						<div class="row">
							<div class="col-md-4 mb-3">
								<label for="postinumero"
									class="form-label fw-semibold text-secondary">Postinumero</label>
								<input type="text" class="form-control" id="postinumero"
									name="postinumero" placeholder="00100" maxlength="5">
							</div>
							<div class="col-md-8 mb-3">
								<label for="postitoimipaikka"
									class="form-label fw-semibold text-secondary">Postitoimipaikka</label>
								<input type="text" class="form-control" id="postitoimipaikka"
									name="postitoimipaikka" placeholder="Helsinki">
							</div>
						</div>
						<div class="mb-3">
							<label for="kotisivu"
								class="form-label fw-semibold text-secondary">Kotisivut
								(URL)</label> <input type="url" class="form-control" id="kotisivu"
								name="kotisivu" placeholder="https://yritys.fi">
						</div>

						<div class="mb-3">
							<label for="kuvaus" class="form-label fw-semibold text-secondary">Toiminnan
								kuvaus / Taustatiedot</label>
							<!-- 💡 PÄIVITETTY: Vaihdettu textarea laajaa kuvausta varten -->
							<textarea class="form-control" id="kuvaus" name="kuvaus" rows="4"
								placeholder="Kirjoita vapaamuotoinen kuvaus yrityksen toiminnasta, historiasta ja tarpeista..."></textarea>
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

	<script>
		document.addEventListener('DOMContentLoaded', function() {
			var hakukentta = document.getElementById('reaaliaikainenHaku')
			var taulukkoRunko = document.getElementById('asiakasTaulukkoRunko')
			var sivutusNav = document.getElementById('sivutusNavigaatio')
			
			// Tallennetaan alkuperäiset 10 sivutettua asiakasta muistiin
			var alkuperainenSisalto = taulukkoRunko ? taulukkoRunko.innerHTML : ''

			if (hakukentta && taulukkoRunko) {
				hakukentta.addEventListener('input', function(e) {
					var hakusana = e.target.value.trim()
					
					// Jos hakukenttä tyhjennetään, palautetaan alkuperäinen sivutettu lista
					if (hakusana.length === 0) {
						taulukkoRunko.innerHTML = alkuperainenSisalto
						if (sivutusNav) {
							sivutusNav.style.display = ''
						}
						return
					}
					
					// Tehdään haku taustalta lennosta ilman sivun lataamista
					fetch('${pageContext.request.contextPath}/asiakkaat/live-haku?haku=' + encodeURIComponent(hakusana))
						.then(function(response) {
							return response.text()
						})
						.then(function(htmlRivit) {
							// Päivitetään taulukon rivit lennosta hakutuloksilla
							taulukkoRunko.innerHTML = htmlRivit
							// Piilotetaan sivutuspainikkeet reaaliaikaisen haun ajaksi
							if (sivutusNav) {
								sivutusNav.style.display = 'none'
							}
						})
						.catch(function(err) {
							console.error('Haku epäonnistui:', err)
						})
				})
			}
		})
	</script>


</body>
</html>
