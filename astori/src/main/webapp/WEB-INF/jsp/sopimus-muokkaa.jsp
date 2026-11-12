<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fi">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Muokkaa sopimusta - Astori</title>
	<link href="${pageContext.request.contextPath}/resources/bootstrap.min.css" rel="stylesheet" />
</head>
<body class="bg-light">
	<nav class="navbar navbar-expand-lg navbar-dark bg-dark mb-4 shadow-sm">
		<div class="container">
			<a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/">Astori</a>
			<div class="navbar-nav me-auto">
				<a class="nav-link" href="${pageContext.request.contextPath}/">Etusivu</a>
				<a class="nav-link" href="${pageContext.request.contextPath}/asiakkaat">Asiakkaat</a>
				<a class="nav-link" href="${pageContext.request.contextPath}/raportit">Raportit</a>
			</div>
		</div>
	</nav>

	<main class="container pb-4">
		<a class="text-decoration-none" href="${pageContext.request.contextPath}/asiakas/${asiakas.id}">&larr; Takaisin asiakkaaseen</a>
		<div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mt-2 mb-4">
			<div>
				<h1 class="h3 fw-bold mb-1">Muokkaa palvelusopimusta</h1>
				<div class="text-muted"><c:out value="${asiakas.nimi}" /> — <c:out value="${sopimus.tiedostonNimi}" /></div>
			</div>
			<a class="btn btn-outline-secondary"
				href="${pageContext.request.contextPath}/asiakas/${asiakas.id}/sopimus/${sopimus.id}/lataa">Avaa nykyinen PDF</a>
		</div>

		<c:if test="${not empty virhe}">
			<div class="alert alert-danger" role="alert"><c:out value="${virhe}" /></div>
		</c:if>
		<div class="alert alert-info" role="status">
			Tallennettaessa sopimuksen tiedot myös PDF päivitetään.
		</div>
		<c:if test="${vanhaSopimusIlmanTietoja}">
			<div class="alert alert-warning" role="alert">
				Tämän vanhan sopimuksen tietoja ei ole tallennettu tietokantaan. Täytä lomakkeen tiedot uudelleen; nykyinen PDF säilyy ennallaan.
			</div>
		</c:if>

		<form class="card border-0 shadow-sm"
			action="${pageContext.request.contextPath}/asiakas/${asiakas.id}/sopimus/${sopimus.id}/muokkaa" method="post">
			<div class="card-body p-4">
				<div class="row g-3">
					<div class="col-md-6">
						<label class="form-label fw-bold" for="palveluntarjoajanNimi">Palveluntarjoaja *</label>
						<input id="palveluntarjoajanNimi" class="form-control" name="palveluntarjoajanNimi"
							value="<c:out value='${sopimustiedot.palveluntarjoajanNimi}'/>" maxlength="150" required>
					</div>
					<div class="col-md-6">
						<label class="form-label fw-bold" for="palveluntarjoajanYTunnus">Palveluntarjoajan Y-tunnus *</label>
						<input id="palveluntarjoajanYTunnus" class="form-control" name="palveluntarjoajanYTunnus"
							value="<c:out value='${sopimustiedot.palveluntarjoajanYTunnus}'/>" maxlength="20" required>
					</div>
					<div class="col-12">
						<label class="form-label fw-bold" for="palveluntarjoajanOsoite">Palveluntarjoajan osoite *</label>
						<input id="palveluntarjoajanOsoite" class="form-control" name="palveluntarjoajanOsoite"
							value="<c:out value='${sopimustiedot.palveluntarjoajanOsoite}'/>" maxlength="250" required>
					</div>
					<div class="col-12">
						<label class="form-label fw-bold" for="sopimuksenKohdeJaSisalto">2. Sopimuksen kohde ja sisältö *</label>
						<textarea id="sopimuksenKohdeJaSisalto" class="form-control" name="sopimuksenKohdeJaSisalto"
							rows="5" maxlength="5000" required><c:out value="${sopimustiedot.sopimuksenKohdeJaSisalto}"/></textarea>
					</div>
					<div class="col-12">
						<label class="form-label fw-bold" for="hintaJaMaksuehdot">3. Palvelun hinta ja maksuehdot *</label>
						<textarea id="hintaJaMaksuehdot" class="form-control" name="hintaJaMaksuehdot"
							rows="5" maxlength="5000" required><c:out value="${sopimustiedot.hintaJaMaksuehdot}"/></textarea>
					</div>
					<div class="col-md-4">
						<label class="form-label fw-bold" for="aloituspaiva">Sopimus alkaa *</label>
						<input id="aloituspaiva" class="form-control" type="date" name="aloituspaiva"
							value="${sopimustiedot.aloituspaiva}" required>
					</div>
					<div class="col-md-4">
						<label class="form-label fw-bold" for="asiakkaanEdustaja">Asiakkaan edustaja *</label>
						<input id="asiakkaanEdustaja" class="form-control" name="asiakkaanEdustaja"
							value="<c:out value='${sopimustiedot.asiakkaanEdustaja}'/>" maxlength="150" required>
					</div>
					<div class="col-md-6">
						<label class="form-label fw-bold" for="palveluntarjoajanEdustaja">Palveluntarjoajan edustaja *</label>
						<input id="palveluntarjoajanEdustaja" class="form-control" name="palveluntarjoajanEdustaja"
							value="<c:out value='${sopimustiedot.palveluntarjoajanEdustaja}'/>" maxlength="150" required>
					</div>
					<div class="col-12">
						<fieldset>
							<legend class="form-label fw-bold">Allekirjoitustapa *</legend>
							<div class="form-check">
								<input class="form-check-input" type="radio" name="allekirjoitustapa" id="paperinen"
									value="paperinen" ${!sopimustiedot.sahkoinenAllekirjoitus ? 'checked' : ''}>
								<label class="form-check-label" for="paperinen">Kaksi paperikappaletta</label>
							</div>
							<div class="form-check">
								<input class="form-check-input" type="radio" name="allekirjoitustapa" id="sahkoinen"
									value="sahkoinen" ${sopimustiedot.sahkoinenAllekirjoitus ? 'checked' : ''}>
								<label class="form-check-label" for="sahkoinen">Sähköinen allekirjoitus</label>
							</div>
						</fieldset>
					</div>
				</div>
			</div>
			<div class="card-footer bg-white d-flex justify-content-end gap-2 py-3">
				<a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/asiakas/${asiakas.id}">Peruuta</a>
				<button type="submit" class="btn btn-primary fw-bold">Tallenna muutokset</button>
			</div>
		</form>
	</main>
</body>
</html>
