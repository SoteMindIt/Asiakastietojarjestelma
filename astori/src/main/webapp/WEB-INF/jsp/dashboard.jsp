<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="fi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Työpöytä - Astori</title>
<link href="${pageContext.request.contextPath}/resources/bootstrap.min.css" rel="stylesheet" />
<style>
body { background-color: #f8f9fa; }
.dashboard-card { background: white; border-radius: 8px; padding: 20px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); border: 1px solid #dee2e6; transition: transform 0.2s; }
.dashboard-card:hover { transform: translateY(-3px); }
.icon-box { width: 48px; height: 48px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 24px; }
</style>
</head>
<body>

	<!-- YLÄPALKKI -->
	<nav class="navbar navbar-expand-lg navbar-dark bg-dark mb-4 shadow-sm">
		<div class="container">
			<a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/">Astori</a>
			<div class="navbar-nav me-auto">
				<a class="nav-link active fw-bold" href="${pageContext.request.contextPath}/">Etusivu</a> 
				<a class="nav-link" href="${pageContext.request.contextPath}/asiakkaat">Asiakkaat</a> 
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
		<div class="mb-4">
			<h2 class="text-dark fw-bold mb-1">Tervetuloa Astoriin!</h2>
			<p class="text-muted">Tässä on yleisnäkymä järjestelmän tämänhetkisestä tilanteesta.</p>
		</div>

				<!-- 📊 TIETOLAATIKOT (DASHBOARD-KORTIT) -->
		<div class="row g-4 mb-5">
			<!-- Kortti 1: Asiakkaat -->
			<div class="col-md-4">
				<div class="dashboard-card d-flex align-items-center justify-content-between">
					<div>
						<h6 class="text-secondary fw-semibold mb-1">Asiakkaat yhteensä</h6>
						<!-- 💡 KORJATTU: Käytetään nimeä asiakkaatLaskuri, näytetään 0 jos tyhjä -->
						<h3 class="fw-bold text-dark mb-0">${not empty asiakkaatLaskuri ? asiakkaatLaskuri : '0'} kpl</h3>
						<small class="text-muted">Aktiiviset asiakkuutesi</small>
					</div>
					<div class="icon-box bg-primary bg-opacity-10 text-primary">👤</div>
				</div>
			</div>
			<!-- Kortti 2: Tarjoukset -->
			<div class="col-md-4">
				<div class="dashboard-card d-flex align-items-center justify-content-between">
					<div>
						<h6 class="text-secondary fw-semibold mb-1">Avoimet tarjoukset</h6>
						<!-- 💡 KORJATTU: Käytetään nimeä tarjouksetLaskuri, näytetään 0 jos tyhjä -->
						<h3 class="fw-bold text-dark mb-0">${not empty tarjouksetLaskuri ? tarjouksetLaskuri : '0'} kpl</h3>
						<small class="text-muted">Jätetyt tarjouslaskelmat</small>
					</div>
					<div class="icon-box bg-success bg-opacity-10 text-success">💼</div>
				</div>
			</div>
			<!-- Kortti 3: Tehtävät -->
			<div class="col-md-4">
				<div class="dashboard-card d-flex align-items-center justify-content-between">
					<div>
						<h6 class="text-secondary fw-semibold mb-1">Tehtävät loppupäivälle</h6>
						<!-- 💡 KORJATTU: Käytetään nimeä tehtavatLaskuri, näytetään 0 jos tyhjä -->
						<h3 class="fw-bold text-dark mb-0">${not empty tehtavatLaskuri ? tehtavatLaskuri : '0'} kpl</h3>
						<small class="text-muted">Tämän päivän agenda</small>
					</div>
					<div class="icon-box bg-warning bg-opacity-10 text-warning">📅</div>
				</div>
			</div>
		</div>

		<div class="row g-4">
			<div class="col-lg-8">
				<div class="bg-white p-4 rounded-3 border shadow-sm">
					<h4 class="text-dark fw-bold mb-4">Seuraavat kalenterimerkinnät</h4>
					
					<c:forEach var="tap" items="${tulevatTapahtumat}">
						<!-- 💡 KORJATTU: Tehty toString()-vertailut, jotka toimivat aina kaikilla palvelimilla -->
						<div class="p-3 mb-3 rounded border-start border-4 
							<c:choose>
								<c:when test="${tap.tyyppi.toString() == 'TAPAAMINEN'}">border-success bg-success bg-opacity-10</c:when>
								<c:when test="${tap.tyyppi.toString() == 'PUHELU' || tap.tyyppi.toString() == 'SOITTO'}">border-warning bg-warning bg-opacity-10</c:when>
								<c:when test="${tap.tyyppi.toString() == 'SÄHKÖPOSTI'}">border-info bg-info bg-opacity-10</c:when>
								<c:otherwise>border-primary bg-primary bg-opacity-10</c:otherwise>
							</c:choose>">
							
							<div class="d-flex justify-content-between align-items-start">
								<a href="#" class="text-primary fw-bold d-block mb-1 text-decoration-none" 
								   data-bs-toggle="modal" data-bs-target="#muokkaaTapahtumaModal${tap.id}">
								   ${tap.otsikko}
								</a>
								<span class="badge bg-white text-dark border small">${tap.tyyppi.toString()}</span>
							</div>

							<c:if test="${not empty tap.asiakas}">
								<small class="d-block text-secondary fw-semibold mb-1">
									Asiakas: <a href="${pageContext.request.contextPath}/asiakas/${tap.asiakas.id}" class="text-decoration-none">${tap.asiakas.nimi}</a>
								</small>
							</c:if>

							<small class="text-muted d-block">
								${tap.ajankohta.toString().replace('T', ' ').substring(0, 16)}
							</small>
						</div>

						<!-- MODAL-IKKUNA TAPAHTUMAN MUOKKAUKSELLE -->
						<div class="modal fade" id="muokkaaTapahtumaModal${tap.id}" tabindex="-1" aria-hidden="true">
							<div class="modal-dialog modal-dialog-centered">
								<div class="modal-content border-0 shadow-lg">
									<div class="modal-header bg-dark text-white">
										<h5 class="modal-title fw-bold">Muokkaa tapahtumaa</h5>
										<button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
									</div>
									<form action="${pageContext.request.contextPath}/kalenteri/paivita/${tap.id}" method="post">
										<div class="modal-body p-4 text-start">
											<div class="mb-3">
												<label class="form-label fw-semibold text-secondary">Otsikko</label>
												<input type="text" class="form-control" name="otsikko" value="${tap.otsikko}" required>
											</div>
											<div class="mb-3">
												<label class="form-label fw-semibold text-secondary">Tyyppi</label>
												<select class="form-select" name="tyyppi" required>
													<option value="TAPAAMINEN" ${tap.tyyppi.toString() == 'TAPAAMINEN' ? 'selected' : ''}>TAPAAMINEN</option>
													<option value="PUHELU" ${tap.tyyppi.toString() == 'PUHELU' ? 'selected' : ''}>PUHELU</option>
													<option value="SÄHKÖPOSTI" ${tap.tyyppi.toString() == 'SÄHKÖPOSTI' ? 'selected' : ''}>SÄHKÖPOSTI</option>
												</select>
											</div>
											<div class="mb-3">
												<label class="form-label fw-semibold text-secondary">Ajankohta</label>
												<input type="datetime-local" class="form-control" name="ajankohtaStr" value="${tap.ajankohta}" required>
											</div>
											<div class="mb-3">
												<label class="form-label fw-semibold text-secondary">Kuvaus / Muistiinpanot</label>
												<textarea class="form-control" name="kuvaus" rows="3">${tap.kuvaus}</textarea>
											</div>
											<input type="hidden" name="asiakasId" value="${not empty tap.asiakas ? tap.asiakas.id : ''}">
										</div>
										<div class="modal-footer bg-light">
											<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Peruuta</button>
											<button type="submit" class="btn btn-success px-4 fw-bold">Tallenna muutokset</button>
										</div>
									</form>
								</div>
							</div>
						</div>
					</c:forEach>

					<c:if test="${empty tulevatTapahtumat}">
						<div class="text-center py-5 text-muted">
							<p class="mb-0 fs-5">Ei tulevia kalenterimerkintöjä.</p>
						</div>
					</c:if>
				</div>
			</div>
			
			<div class="col-lg-4">
				<div class="bg-white p-4 rounded-3 border shadow-sm h-100">
					<h5 class="fw-bold text-dark mb-3">Pikalinkit</h5>
					<div class="list-group list-group-flush">
						<a href="${pageContext.request.contextPath}/asiakkaat" class="list-group-item list-group-item-action ps-0 text-primary">➡️ Hallitse asiakkaita</a>
						<a href="${pageContext.request.contextPath}/kalenteri" class="list-group-item list-group-item-action ps-0 text-primary">➡️ Avaa iso kalenteri</a>
					</div>
				</div>
			</div>
		</div>
	</div>

	<script src="${pageContext.request.contextPath}/resources/bootstrap.bundle.min.js"></script>
</body>
</html>
