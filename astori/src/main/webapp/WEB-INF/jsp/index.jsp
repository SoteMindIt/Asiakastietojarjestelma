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
            <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/">Astori</a>
            <div class="navbar-nav me-auto">
                <a class="nav-link active fw-bold" href="${pageContext.request.contextPath}/">Asiakkaat</a>
                <a class="nav-link" href="${pageContext.request.contextPath}/asetukset">Asetukset</a>
                <a class="nav-link" href="${pageContext.request.contextPath}/raportit">Raportit</a>
                <a class="nav-link" href="${pageContext.request.contextPath}/kalenteri">Kalenteri</a>
            </div>
            <div class="d-flex align-items-center">
                <span class="navbar-text text-white me-3">Käyttäjä: <strong>${kirjautunutKayttaja}</strong></span>
                <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline-danger btn-sm">Kirjaudu ulos</a>
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

		<h4 class="text-secondary mb-3">Kaikki asiakkaat</h4>
		<div class="table-responsive border mb-3">
			<table class="table table-hover align-middle mb-0">
				<thead class="table-light">
					<tr>
						<th>ID</th>
						<th>Nimi</th>
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
							<td>${asiakas.sahkoposti}</td>
							<td>${asiakas.puhelin}</td>
							<td>
								<!-- UUSI KONSULTAATIOMYYNTIPUTKEN VÄRIKOODAUS -->
								<span class="badge 
									<c:choose>
										<c:when test="${asiakas.tila == 'PROSPEKTI'}">bg-info text-white</c:when>
										<c:when test="${asiakas.tila == 'KONTAKTOITU'}">bg-warning text-dark</c:when>
										<c:when test="${asiakas.tila == 'TARJOUS_JATETTY'}">bg-primary</c:when>
										<c:when test="${asiakas.tila == 'AKTIIVINEN'}">bg-success</c:when>
										<c:otherwise>bg-secondary</c:otherwise>
									</c:choose>">
									${asiakas.tila.nayttorivi}
								</span>
							</td>
							<td class="text-end"><a
								href="${pageContext.request.contextPath}/asiakas/${asiakas.id}"
								class="btn btn-sm btn-outline-primary px-3 rounded-pill fw-semibold">
									Avaa profiili </a></td>
						</tr>
					</c:forEach>
					<c:if test="${empty asiakkaat}">
						<tr>
							<td colspan="6" class="text-center py-4 text-muted">Järjestelmässä
								ei ole vielä asiakkaita.</td>
						</tr>
					</c:if>
				</tbody>
			</table>
		</div>

		<!-- SIVUTUSPAINIKKEET (Näytetään vain, jos sivuja on enemmän kuin 1) -->
		<c:if test="${totalPages > 1}">
			<nav aria-label="Asiakaslistan sivutus" class="d-flex justify-content-center mt-4">
				<ul class="pagination shadow-sm">
					
					<!-- EDELINEN-PAINIKE -->
					<li class="page-item ${currentPage == 0 ? 'disabled' : ''}">
						<a class="page-link" href="?page=${currentPage - 1}" aria-label="Edellinen">
							<span aria-hidden="true">&laquo; Edellinen</span>
						</a>
					</li>

					<!-- SIVUNUMEROT -->
					<c:forEach var="i" begin="0" end="${totalPages - 1}">
						<li class="page-item ${currentPage == i ? 'active' : ''}">
							<a class="page-link" href="?page=${i}">${i + 1}</a>
						</li>
					</c:forEach>

					<!-- SEURAAVA-PAINIKE -->
					<li class="page-item ${currentPage >= totalPages - 1 ? 'disabled' : ''}">
						<a class="page-link" href="?page=${currentPage + 1}" aria-label="Seuraava">
							<span aria-hidden="true">Seuraava &raquo;</span>
						</a>
					</li>
					
				</ul>
			</nav>
		</c:if>

	</div>
	<!-- BOOTSTRAP POP-UP LOMAKE (MODAL) UUDELLE ASIAKKAALLE -->
	<div class="modal fade" id="lisaaAsiakasModal" tabindex="-1" aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content border-0 shadow-lg">
				<div class="modal-header bg-primary text-white">
					<h5 class="modal-title fw-bold">Lisää uusi asiakas</h5>
					<button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
				</div>
				<form action="${pageContext.request.contextPath}/lisaa-asiakas" method="post">
					<div class="modal-body p-4">
						<div class="mb-3">
							<label for="nimi" class="form-label fw-semibold text-secondary">Nimi / Organisaatio</label>
							<input type="text" class="form-control" id="nimi" name="nimi"
								required placeholder="esim. Sote-Hyvinvointi Oy">
						</div>
						<div class="mb-3">
							<label for="sahkoposti" class="form-label fw-semibold text-secondary">Sähköposti</label>
							<input type="email" class="form-control" id="sahkoposti"
								name="sahkoposti" required placeholder="yhteys@yritys.fi">
						</div>
						<div class="mb-3">
							<label for="puhelin" class="form-label fw-semibold text-secondary">Puhelin</label> 
							<input type="text" class="form-control" id="puhelin" name="puhelin"
								required placeholder="040 123 4567">
						</div>
						<div class="mb-3">
							<label for="tila" class="form-label fw-semibold text-secondary">Asiakkuuden alkutila</label> 
							<select class="form-select" id="tila" name="tila" required>
								<!-- Tulostetaan kaikki ohjaimesta tulleet uudet tilat dynaamisesti loopissa -->
								<c:forEach var="t" items="${tilat}">
									<option value="${t}">${t.nayttorivi}</option>
								</c:forEach>
							</select>
						</div>
					</div>
					<div class="modal-footer bg-light">
						<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Peruuta</button>
						<button type="submit" class="btn btn-primary px-4 fw-bold">Tallenna asiakas</button>
					</div>
				</form>
			</div>
		</div>
	</div>

	<!-- Lataa paikallisen Bootstrap-JavaScriptin resources-juuresta -->
	<script src="${pageContext.request.contextPath}/resources/bootstrap.bundle.min.js"></script>
</body>
</html>
