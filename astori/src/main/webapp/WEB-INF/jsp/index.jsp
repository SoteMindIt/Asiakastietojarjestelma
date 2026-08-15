<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="fi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Asiakastietojärjestelmä</title>
<!-- Lataa paikallisen Bootstrap-tyylitiedoston omalta koneelta -->
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

	<!-- YLÄPALKKI / NAVIGAATIO -->
	<nav class="navbar navbar-expand-lg navbar-dark bg-dark mb-4 shadow-sm">
		<div class="container">
			<a class="navbar-brand fw-bold"
				href="${pageContext.request.contextPath}/">Astori</a>
			<div class="d-flex align-items-center">
				<span class="navbar-text text-white me-3"> Käyttäjä: <strong>${kirjautunutKayttaja}</strong>
				</span> <a href="${pageContext.request.contextPath}/logout"
					class="btn btn-outline-danger btn-sm">Kirjaudu ulos</a>
			</div>
		</div>
	</nav>

	<div class="container py-2">
		<!-- OTSIKKOPALKKI JA PAINIKE -->
		<div class="d-flex justify-content-between align-items-center mb-4">
			<h2 class="text-dark fw-bold mb-0">Asiakastietojärjestelmä</h2>
			<!-- PAINIKE: Avaa uuden asiakkaan pop-up-lomakkeen -->
			<button type="button" class="btn btn-primary fw-bold px-4 shadow-sm"
				data-bs-toggle="modal" data-bs-target="#lisaaAsiakasModal">
				+ Lisää uusi asiakas</button>
		</div>

		<!-- ASIAKASTAULUKKO -->
		<h4 class="text-secondary mb-3">Kaikki asiakkaat</h4>
		<div class="table-responsive border">
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
								<!-- Bootstrap Badge -efekti tilan mukaan --> <span
								class="badge ${asiakas.tila == 'KAUPPA' ? 'bg-success' : (asiakas.tila == 'EI_KAUPPAA' ? 'bg-danger' : 'bg-warning text-dark')}">
									${asiakas.tila.nayttorivi} </span>
							</td>
							<td class="text-end">
							<td class="text-end"><a
								href="${pageContext.request.contextPath}/asiakas/${asiakas.id}"
								class="btn btn-sm btn-outline-primary px-3 rounded-pill fw-semibold">
									Avaa profiili </a></td>
						</tr>
					</c:forEach>
					<c:if test="${empty asiakkaat}">
						<tr>
							<td colspan="5" class="text-center py-4 text-muted">Järjestelmässä
								ei ole vielä asiakkaita.</td>
						</tr>
					</c:if>
				</tbody>
			</table>
		</div>
	</div>

	<!-- BOOTSTRAP POP-UP LOMAKE (MODAL) -->
	<div class="modal fade" id="lisaaAsiakasModal" tabindex="-1"
		aria-labelledby="lisaaAsiakasModalLabel" aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content border-0 shadow-lg">
				<div class="modal-header bg-primary text-white">
					<h5 class="modal-title fw-bold" id="lisaaAsiakasModalLabel">Lisää
						uusi asiakas</h5>
					<button type="button" class="btn-close btn-close-white"
						data-bs-dismiss="modal" aria-label="Sulje"></button>
				</div>
				<!-- Lomakkeen toiminto korjattu käyttämään dynaamista polkua -->
				<form action="${pageContext.request.contextPath}/lisaa-asiakas"
					method="post">
					<div class="modal-body p-4">
						<div class="navbar-nav me-auto">
							<a class="nav-link active fw-bold"
								href="${pageContext.request.contextPath}/">Asiakkaat</a> <a
								class="nav-link"
								href="${pageContext.request.contextPath}/asetukset">Asetukset</a>
						</div>
						<div class="mb-3">
							<label for="nimi" class="form-label fw-semibold text-secondary">Nimi</label>
							<input type="text" class="form-control" id="nimi" name="nimi"
								required placeholder="Matti Meikäläinen">
						</div>
						<div class="mb-3">
							<label for="sahkoposti"
								class="form-label fw-semibold text-secondary">Sähköposti</label>
							<input type="email" class="form-control" id="sahkoposti"
								name="sahkoposti" required placeholder="matti@esimerkki.fi">
						</div>
						<div class="mb-3">
							<label for="puhelin"
								class="form-label fw-semibold text-secondary">Puhelin</label> <input
								type="text" class="form-control" id="puhelin" name="puhelin"
								required placeholder="040 123 4567">
						</div>
						<div class="mb-3">
							<label for="tila" class="form-label fw-semibold text-secondary">Asiakkaan
								tila</label> <select class="form-select" id="tila" name="tila" required>
								<option value="PROSPEKTI">Prospekti</option>
								<option value="KONTAKTOITU">Kontaktoitu</option>
								<option value="KAUPPA">Kauppa</option>
								<option value="EI_KAUPPAA">Ei kauppaa</option>
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

	<!-- Lataa paikallisen Bootstrap-JavaScriptin sivun alalaitaan -->
	<script
		src="${pageContext.request.contextPath}/resources/bootstrap.bundle.min.js"></script>

</body>
</html>
