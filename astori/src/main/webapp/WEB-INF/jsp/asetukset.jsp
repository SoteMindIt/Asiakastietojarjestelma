<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="fi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Asetukset - Astori</title>
<link
	href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css"
	rel="stylesheet" />
<style>
body {
	background-color: #f8f9fa;
}

.table-responsive, .settings-card {
	background: white;
	border-radius: 8px;
	padding: 20px;
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
				<a class="nav-link" href="${pageContext.request.contextPath}/">Asiakkaat</a>
				<a class="nav-link active fw-bold"
					href="${pageContext.request.contextPath}/asetukset">Asetukset</a>
			</div>
			<div class="d-flex align-items-center">
				<span class="navbar-text text-white me-3">Käyttäjä: <strong>${kirjautunutKayttaja}</strong></span>
				<a href="${pageContext.request.contextPath}/logout"
					class="btn btn-outline-danger btn-sm">Kirjaudu ulos</a>
			</div>
		</div>
	</nav>

	<div class="container py-2">
		<h2 class="text-dark fw-bold mb-4">Järjestelmän asetukset</h2>

		<div class="row">
			<!-- TUOTEHALLINTA -->
			<div class="col-md-12">
				<div class="settings-card border mb-4">
					<div class="d-flex justify-content-between align-items-center mb-3">
						<h4 class="text-secondary mb-0">Tuoterekisteri & Palvelut</h4>
						<!-- MUUTETTU PAINIKE: Vie suoraan omalle lomakesivulleen -->
						<a href="${pageContext.request.contextPath}/asetukset/uusi"
							class="btn btn-primary fw-bold px-4 shadow-sm"> + Lisää uusi
							tuote/palvelu </a>
					</div>

					<div class="table-responsive border p-0">
						<table class="table table-hover align-middle mb-0">
							<thead class="table-light">
								<tr>
									<th>ID</th>
									<th>Nimi</th>
									<th>Kuvaus</th>
									<th>Yksikkö</th>
									<th class="text-end">Hinta (alv 0%)</th>
								</tr>
							</thead>
							<tbody>
								<c:forEach var="tuote" items="${tuotteet}">
									<tr>
										<td class="text-muted">#${tuote.id}</td>
										<td><strong>${tuote.nimi}</strong></td>
										<td class="text-secondary">${tuote.kuvaus}</td>
										<td><span class="badge bg-light text-dark border">${tuote.yksikko.lyhenne}</span></td>
										<td class="text-end fw-bold">${tuote.hinta}€</td>
									</tr>
								</c:forEach>
								<c:if test="${empty tuotteet}">
									<tr>
										<td colspan="5" class="text-center py-4 text-muted">Rekisterissä
											ei ole vielä tuotteita tai palveluita.</td>
									</tr>
								</c:if>
							</tbody>
						</table>
					</div>
				</div>
			</div>
		</div>
	</div>

	<script src="${pageContext.request.contextPath}/resources/bootstrap.bundle.min.js"></script>

</body>
</html>
