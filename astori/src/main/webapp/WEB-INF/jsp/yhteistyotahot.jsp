<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fi">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Yhteistyötahot - Astori</title>
	<link href="${pageContext.request.contextPath}/resources/bootstrap.min.css" rel="stylesheet" />
</head>
<body class="bg-light">
	<nav class="navbar navbar-expand-lg navbar-dark bg-dark mb-4 shadow-sm">
		<div class="container">
			<a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/">Astori</a>
			<div class="navbar-nav me-auto">
				<a class="nav-link" href="${pageContext.request.contextPath}/">Etusivu</a>
				<a class="nav-link" href="${pageContext.request.contextPath}/asiakkaat">Asiakkaat</a>
				<a class="nav-link active fw-bold" href="${pageContext.request.contextPath}/yhteistyotahot">Yhteistyötahot</a>
				<a class="nav-link" href="${pageContext.request.contextPath}/asetukset">Asetukset</a>
				<a class="nav-link" href="${pageContext.request.contextPath}/raportit">Raportit</a>
				<a class="nav-link" href="${pageContext.request.contextPath}/kalenteri">Kalenteri</a>
			</div>
			<div class="d-flex align-items-center">
				<span class="navbar-text text-white me-3">Käyttäjä:
					<strong>${kirjautunutKayttaja}</strong></span>
				<a href="${pageContext.request.contextPath}/logout" class="btn btn-outline-danger btn-sm">Kirjaudu ulos</a>
			</div>
		</div>
	</nav>

	<main class="container pb-4">
		<c:if test="${param.success == 'created'}">
			<div class="alert alert-success" role="status">Yhteistyötaho lisätty.</div>
		</c:if>
		<c:if test="${param.error == 'nimi'}">
			<div class="alert alert-danger" role="alert">Nimi on pakollinen.</div>
		</c:if>

		<div class="d-flex justify-content-between align-items-center flex-wrap gap-3 mb-4">
			<div>
				<h1 class="h2 fw-bold text-dark mb-1">Yhteistyötahot</h1>
				<p class="text-muted mb-0">Yhteinen rekisteri järjestelmän käyttäjille.</p>
			</div>
			<button type="button" class="btn btn-primary fw-bold px-4 shadow-sm"
				data-bs-toggle="modal" data-bs-target="#lisaaYhteistyotahoModal">
				+ Lisää yhteistyötaho
			</button>
		</div>

		<div class="table-responsive bg-white border rounded-3 shadow-sm p-2">
			<table class="table table-hover align-middle mb-0">
				<thead class="table-light">
					<tr>
						<th>Nimi</th>
						<th>Puhelinnumero</th>
						<th>Sähköposti</th>
						<th>Rooli</th>
						<th>Selite</th>
					</tr>
				</thead>
				<tbody>
					<c:forEach var="yhteistyotaho" items="${yhteistyotahot}">
						<tr>
							<td class="fw-semibold"><c:out value="${yhteistyotaho.nimi}" /></td>
							<td><c:out value="${yhteistyotaho.puhelin}" /></td>
							<td><c:out value="${yhteistyotaho.sahkoposti}" /></td>
							<td><c:out value="${yhteistyotaho.rooli}" /></td>
							<td><c:out value="${yhteistyotaho.selite}" /></td>
						</tr>
					</c:forEach>
					<c:if test="${empty yhteistyotahot}">
						<tr>
							<td colspan="5" class="text-center text-muted py-4">
								Yhteistyötahoja ei ole vielä lisätty.
							</td>
						</tr>
					</c:if>
				</tbody>
			</table>
		</div>
	</main>

	<div class="modal fade" id="lisaaYhteistyotahoModal" tabindex="-1"
		aria-labelledby="lisaaYhteistyotahoModalLabel" aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered modal-lg">
			<div class="modal-content border-0 shadow-lg">
				<form action="${pageContext.request.contextPath}/yhteistyotahot/lisaa" method="post">
					<div class="modal-header bg-primary text-white">
						<h2 class="modal-title fs-5 fw-bold" id="lisaaYhteistyotahoModalLabel">Lisää yhteistyötaho</h2>
						<button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Sulje"></button>
					</div>
					<div class="modal-body p-4">
						<div class="mb-3">
							<label class="form-label fw-semibold" for="yhteistyotahoNimi">Nimi *</label>
							<input class="form-control" id="yhteistyotahoNimi" name="nimi" type="text" required>
						</div>
						<div class="row g-3">
							<div class="col-md-6">
								<label class="form-label fw-semibold" for="yhteistyotahoPuhelin">Puhelinnumero</label>
								<input class="form-control" id="yhteistyotahoPuhelin" name="puhelin" type="tel">
							</div>
							<div class="col-md-6">
								<label class="form-label fw-semibold" for="yhteistyotahoSahkoposti">Sähköpostiosoite</label>
								<input class="form-control" id="yhteistyotahoSahkoposti" name="sahkoposti" type="email">
							</div>
							<div class="col-12">
								<label class="form-label fw-semibold" for="yhteistyotahoRooli">Rooli</label>
								<input class="form-control" id="yhteistyotahoRooli" name="rooli" type="text">
							</div>
							<div class="col-12">
								<label class="form-label fw-semibold" for="yhteistyotahoSelite">Selite</label>
								<textarea class="form-control" id="yhteistyotahoSelite" name="selite" rows="3"></textarea>
							</div>
						</div>
					</div>
					<div class="modal-footer bg-light">
						<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Peruuta</button>
						<button type="submit" class="btn btn-primary fw-bold">Tallenna yhteistyötaho</button>
					</div>
				</form>
			</div>
		</div>
	</div>

	<script src="${pageContext.request.contextPath}/resources/bootstrap.bundle.min.js"></script>
</body>
</html>
