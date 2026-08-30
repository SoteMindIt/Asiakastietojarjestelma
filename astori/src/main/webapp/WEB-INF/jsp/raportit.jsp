<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="fi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Raportit ja Käyttöloki - Astori</title>
<!-- Lataa paikallisen Bootstrap-tyylitiedoston resources-juuresta -->
<link
	href="${pageContext.request.contextPath}/resources/bootstrap.min.css"
	rel="stylesheet" />
<style>
body {
	background-color: #f8f9fa;
}

.report-card {
	background: white;
	border-radius: 8px;
	padding: 20px;
	box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
	border: 1px solid #dee2e6;
}

.table-responsive {
	background: white;
	border-radius: 8px;
	padding: 15px;
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
				<a class="nav-link" href="${pageContext.request.contextPath}/">Etusivu</a>
				<a class="nav-link"
					href="${pageContext.request.contextPath}/asiakkaat">Asiakkaat</a> <a
					class="nav-link"
					href="${pageContext.request.contextPath}/asetukset">Asetukset</a> <a
					class="nav-link active fw-bold"
					href="${pageContext.request.contextPath}/raportit">Raportit</a> <a
					class="nav-link"
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
			<h2 class="text-dark fw-bold mb-1">Järjestelmän raportit</h2>
			<p class="text-muted">Tarkastele järjestelmän tilaa, tilastoja ja
				lakisääteistä käyttölokia.</p>
		</div>

		<!-- TILASTOKORTIT -->
		<div class="row mb-5">
			<div class="col-md-4 mb-3">
				<div
					class="report-card d-flex align-items-center justify-content-between">
					<div>
						<h6 class="text-uppercase text-muted fw-bold mb-1"
							style="font-size: 0.8rem; letter-spacing: 1px;">Asiakkaat
							yhteensä</h6>
						<h2 class="text-dark fw-bold mb-0">${asiakkaatYhteensa}</h2>
					</div>
					<div class="bg-primary bg-opacity-10 text-primary rounded p-3">
						<!-- 💡 KORJAUS: Päivitetty standardinmukainen W3C-osoite SVG-kuvakkeelle -->
						<svg xmlns="http://w3.org" width="24" height="24"
							fill="currentColor" class="bi bi-people-fill" viewBox="0 0 16 16">
							<path
								d="M7 14s-1 0-1-1 1-4 5-4 5 3 5 4-1 1-1 1zm4-6a3 3 0 1 0 0-6 3 3 0 0 0 0 6m-5.784 6A2.24 2.24 0 0 1 5 13c0-1.355.68-2.75 1.936-3.72A6.3 6.3 0 0 0 5 9c-4 0-5 3-5 4s1 1 1 1zM4.5 8a2.5 2.5 0 1 0 0-5 2.5 2.5 0 0 0 0 5" />
						</svg>
					</div>
				</div>
			</div>

			<div class="col-md-4 mb-3">
				<div
					class="report-card d-flex align-items-center justify-content-between">
					<div>
						<h6 class="text-uppercase text-muted fw-bold mb-1"
							style="font-size: 0.8rem; letter-spacing: 1px;">Lokitapahtumat</h6>
						<h2 class="text-dark fw-bold mb-0">${lokirivit != null ? lokirivit.size() : 0}</h2>
					</div>
					<div class="bg-info bg-opacity-10 text-info rounded p-3">
						<!-- 💡 KORJAUS: Päivitetty standardinmukainen W3C-osoite SVG-kuvakkeelle -->
						<svg xmlns="http://w3.org" width="24" height="24"
							fill="currentColor" class="bi bi-shield-check"
							viewBox="0 0 16 16">
						  <path
								d="M5.338 1.59a61 61 0 0 0-2.837.856.481.481 0 0 0-.328.39c-.554 4.157.726 7.19 2.253 9.188a10.7 10.7 0 0 0 2.287 2.233c.346.244.652.244 1 .01a10.7 10.7 0 0 0 2.287-2.233c1.527-1.997 2.807-5.031 2.253-9.188a.48.48 0 0 0-.328-.39c-.651-.213-1.75-.56-2.837-.855C9.552 1.29 8.931 1.057 8 1.057c-.93 0-1.552.232-2.662.533zM7.468 7.668a.5.5 0 1 1 .708-.708L9.44 8.224l2.096-2.097a.5.5 0 1 1 .707.707l-2.45 2.45a.5.5 0 0 1-.708 0z" />
						</svg>
					</div>
				</div>
			</div>
		</div>

		<!-- AUDIT TRAIL LOKI -->
		<h4 class="text-secondary mb-3">Auditoitava käyttöloki (Audit
			Trail)</h4>
		<div class="table-responsive border">
			<table class="table table-hover align-middle mb-0">
				<thead class="table-light">
					<tr>
						<th>Aika</th>
						<th>Käyttäjä</th>
						<th>Toiminto</th>
						<th>Tapahtuman kuvaus</th>
					</tr>
				</thead>
				<tbody>
					<c:forEach var="rivi" items="${lokirivit}">
						<tr>
							<td class="text-muted text-nowrap">
								${rivi.aikaleima.toString().replace('T', ' ').substring(0, 19)}
							</td>
							<td><span class="badge bg-secondary p-2">${rivi.kayttajatunnus}</span></td>
							<td><span
								class="badge 
									<c:choose>
										<c:when test="${rivi.toiminto == 'KATSELU'}">bg-light text-dark border</c:when>
										<c:when test="${rivi.toiminto == 'LISÄYS'}">bg-success</c:when>
										<c:when test="${rivi.toiminto == 'MUOKKAUS'}">bg-warning text-dark</c:when>
										<c:when test="${rivi.toiminto == 'POISTO'}">bg-danger</c:when>
										<c:otherwise>bg-info</c:otherwise>
									</c:choose>">
									${rivi.toiminto} </span></td>
							<td class="text-dark">${rivi.kuvaus}</td>
						</tr>
					</c:forEach>
					<c:if test="${empty lokirivit}">
						<tr>
							<td colspan="4" class="text-center py-4 text-muted">Lokiin
								ei ole vielä tallentunut yhtään tapahtumaa.</td>
						</tr>
					</c:if>
				</tbody>
			</table>
		</div>
	</div>

	<!-- Lataa paikallisen Bootstrap-JavaScriptin resources-juuresta -->
	<script
		src="${pageContext.request.contextPath}/resources/bootstrap.bundle.min.js"></script>
</body>
</html>
