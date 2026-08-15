<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="fi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Asiakasprofiili - ${asiakas.nimi}</title>
<!-- Lataa paikallisen Bootstrap-tyylitiedoston resources-juuresta -->
<link
	href="${pageContext.request.contextPath}/resources/bootstrap.min.css"
	rel="stylesheet" />
<style>
body {
	background-color: #f8f9fa;
}

.profile-card {
	background: white;
	border-radius: 8px;
	padding: 25px;
	box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.col-card {
	background: white;
	border-radius: 8px;
	padding: 20px;
	border: 1px solid #dee2e6;
	box-shadow: 0 1px 3px rgba(0, 0, 0, 0.02);
	height: 100%;
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
				<a class="nav-link active fw-bold" href="${pageContext.request.contextPath}/">Asiakkaat</a>
				<a class="nav-link"
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
		<!-- TAKAISIN-LINKKI -->
		<div class="mb-3">
			<a class="btn btn-link p-0 text-decoration-none"
				href="${pageContext.request.contextPath}/">&larr; Takaisin
				asiakaslistaukseen</a>
		</div>

		<!-- ASIAKKAAN PERUSTIEDOT, MUOKKAUS JA POISTO -->
		<div class="profile-card border mb-4">
			<div class="d-flex justify-content-between align-items-start">
				<div>
					<span class="text-muted small">Asiakasnumero #${asiakas.id}</span>
					<h1 class="text-dark fw-bold mb-3">${asiakas.nimi}</h1>
					<p class="mb-1">
						<strong>Sähköposti:</strong> ${asiakas.sahkoposti}
					</p>
					<p class="mb-0">
						<strong>Puhelin:</strong> ${asiakas.puhelin}
					</p>
				</div>
				<div class="text-end">
					<div class="mb-2">
						<span
							class="badge fs-6 ${asiakas.tila == 'KAUPPA' ? 'bg-success' : (asiakas.tila == 'EI_KAUPPAA' ? 'bg-danger' : 'bg-warning text-dark')}">
							Tila: ${asiakas.tila.nayttorivi} </span>
					</div>
					<div class="d-flex gap-2 justify-content-end">
						<button type="button"
							class="btn btn-outline-secondary btn-sm fw-bold"
							data-bs-toggle="modal" data-bs-target="#muokkaaAsiakasModal">
							Muokkaa tietoja</button>
						<form
							action="${pageContext.request.contextPath}/asiakas/${asiakas.id}/poista"
							method="post"
							onsubmit="return confirm('Oletko varma, että haluat poistaa tämän asiakkaan ja KAIKKI hänen tiedot järjestelmästä lopullisesti?');">
							<button type="submit" class="btn btn-danger btn-sm fw-bold">Poista
								asiakas</button>
						</form>
					</div>
				</div>
			</div>
		</div>

		<!-- KOLMESARAKKEINEN OSIO -->
		<div class="row g-4">

			<!-- 1. SARAKE: YHTEYSHENKILÖT -->
			<div class="col-md-4">
				<div class="col-card">
					<h3 class="fw-bold h5 text-secondary mb-3">Yhteyshenkilöt</h3>
					<ul class="list-group list-group-flush mb-4">
						<c:forEach var="h" items="${yhteyshenkilot}">
							<li class="list-group-item px-0 py-2"><strong
								class="text-dark">${h.nimi}</strong> <span
								class="text-muted small">(${h.rooli})</span><br> <small
								class="text-secondary">Puh: ${h.puhelin} | E-mail:
									${h.sahkoposti}</small></li>
						</c:forEach>
						<c:if test="${empty yhteyshenkilot}">
							<li class="list-group-item px-0 py-3 text-muted italic">Ei
								määriteltyjä yhteyshenkilöitä.</li>
						</c:if>
					</ul>

					<h4 class="fw-bold h6 text-dark mt-3">Lisää yhteyshenkilö</h4>
					<form
						action="${pageContext.request.contextPath}/asiakas/${asiakas.id}/lisaa-yhteyshenkilo"
						method="post">
						<div class="mb-2">
							<input type="text" class="form-control form-control-sm"
								name="nimi" placeholder="Nimi" required>
						</div>
						<div class="mb-2">
							<input type="text" class="form-control form-control-sm"
								name="rooli" placeholder="Rooli (esim. Toimitusjohtaja)">
						</div>
						<div class="mb-2">
							<input type="email" class="form-control form-control-sm"
								name="sahkoposti" placeholder="Sähköposti">
						</div>
						<div class="mb-2">
							<input type="text" class="form-control form-control-sm"
								name="puhelin" placeholder="Puhelin">
						</div>
						<button type="submit" class="btn btn-primary btn-sm w-100 fw-bold">Lisää</button>
					</form>
				</div>
			</div>

			<!-- 2. SARAKE: KIRJAUKSET / LOKI -->
			<div class="col-md-4">
				<div class="col-card">
					<h3 class="fw-bold h5 text-secondary mb-3">Asiakkaan loki</h3>
					<div style="max-height: 250px; overflow-y: auto;" class="mb-3">
						<ul class="list-group list-group-flush">
							<c:forEach var="k" items="${kirjaukset}">
								<li class="list-group-item px-0 py-2">
									<p class="mb-1 text-dark small">${k.teksti}</p> <small
									class="text-muted d-block" style="font-size: 0.82em;">${k.luontiaika}</small>
								</li>
							</c:forEach>
							<c:if test="${empty kirjaukset}">
								<li class="list-group-item px-0 py-3 text-muted italic">Ei
									aiempia lokimerkintöjä.</li>
							</c:if>
						</ul>
					</div>

					<h4 class="fw-bold h6 text-dark mt-3">Uusi kirjaus</h4>
					<form
						action="${pageContext.request.contextPath}/asiakas/${asiakas.id}/lisaa-kirjaus"
						method="post">
						<div class="mb-2">
							<textarea class="form-control form-control-sm" name="teksti"
								rows="4" placeholder="Kirjoita muistiinpanot tähän..." required></textarea>
						</div>
						<button type="submit" class="btn btn-primary btn-sm w-100 fw-bold">Tallenna
							merkintä</button>
					</form>
				</div>
			</div>
			<!-- 3. SARAKE: MYYDYT PALVELUT -->
			<div class="col-md-4">
				<div class="col-card">
					<h3 class="fw-bold h5 text-secondary mb-3">Asiakkaalle myydyt
						palvelut</h3>
					<c:set var="yhteissumma" value="0" />
					<div style="max-height: 250px; overflow-y: auto;" class="mb-2">
						<ul class="list-group list-group-flush">
							<c:forEach var="ot" items="${ostetutTuotteet}">
								<li class="list-group-item px-0 py-2"><strong
									class="text-dark small">${ot.tuote.nimi}</strong><br> <span
									class="text-muted small"> ${ot.maara}
										${ot.tuote.yksikko.lyhenne} x ${ot.myyntihinta} € </span><br> <span
									class="small fw-bold text-success">Yhteensä:
										${ot.kokonaishinta} €</span> <c:set var="yhteissumma"
										value="${yhteissumma + ot.kokonaishinta}" /></li>
							</c:forEach>
							<c:if test="${empty ostetutTuotteet}">
								<li class="list-group-item px-0 py-3 text-muted italic">Ei
									kirjattuja hankintoja.</li>
							</c:if>
						</ul>
					</div>

					<c:if test="${not empty ostetutTuotteet}">
						<div class="pt-2 mb-3 border-top text-end">
							<span class="fw-bold h6">Kokonaisarvo: <span
								class="text-success">${yhteissumma} €</span></span>
						</div>
					</c:if>

					<h4 class="fw-bold h6 text-dark mt-2">Kirjaa uusi hankinta</h4>
					<form
						action="${pageContext.request.contextPath}/asiakas/${asiakas.id}/lisaa-tuote"
						method="post">
						<div class="mb-2">
							<select name="tuoteId" class="form-select form-select-sm"
								required>
								<option value="">-- Valitse tuote --</option>
								<c:forEach var="t" items="${kaikkiTuotteet}">
									<option value="${t.id}">${t.nimi}(${t.hinta}€ /
										${t.yksikko.lyhenne})</option>
								</c:forEach>
							</select>
						</div>
						<div class="mb-2">
							<input type="number" class="form-control form-control-sm"
								name="maara" value="1" min="1" required placeholder="Määrä">
						</div>
						<button type="submit" class="btn btn-success btn-sm w-100 fw-bold">Tallenna
							hankinta</button>
					</form>
				</div>
			</div>
		</div>
		<!-- .row päättyminen -->

		<!-- UUSI ALARIVI: ASIAKKAAN PDF-LIITETIEDOSTOT -->
		<div class="row mt-4">
			<div class="col-12">
				<div class="col-card" style="padding: 25px;">
					<h3 class="fw-bold h5 text-secondary mb-3">Asiakkaan
						PDF-dokumentit ja Sopimukset</h3>
					<c:if test="${param.virhe == 'vain_pdf_sallittu'}">
						<div class="alert alert-danger py-2 small fw-bold">Virhe:
							Vain PDF-tiedostot ovat sallittuja!</div>
					</c:if>
					<div class="row">
						<!-- Vasen puoli: Tallennetut tiedostot -->
						<div class="col-md-7 border-end">
							<h4 class="fw-bold h6 text-dark mb-3">Tallennetut tiedostot</h4>
							<div class="table-responsive border rounded bg-light p-0"
								style="max-height: 200px; overflow-y: auto;">
								<table class="table table-hover align-middle mb-0 small">
									<thead class="table-light">
										<tr>
											<th>Tiedoston nimi</th>
											<th>Kuvaus</th>
											<th>Latausaika</th>
										</tr>
									</thead>
									<tbody>
										<c:forEach var="liite" items="${liitteet}">
											<tr>
												<td><a
													href="${pageContext.request.contextPath}/liite/${liite.id}"
													class="fw-bold text-primary text-decoration-none">📄
														${liite.tiedostonNimi}</a></td>
												<td class="text-secondary">${liite.kuvaus}</td>
												<td class="text-muted" style="font-size: 0.85em;">${liite.latausaika}</td>
											</tr>
										</c:forEach>
										<c:if test="${empty liitteet}">
											<tr>
												<td colspan="3" class="text-center py-4 text-muted italic">Ei
													PDF-liitteitä.</td>
											</tr>
										</c:if>
									</tbody>
								</table>
							</div>
						</div>
						<!-- Oikea puoli: Latauslomake -->
						<div class="col-md-5">
							<h4 class="fw-bold h6 text-dark mb-3">Lataa uusi
								PDF-dokumentti</h4>
							<form
								action="${pageContext.request.contextPath}/asiakas/${asiakas.id}/lisaa-liite"
								method="post" enctype="multipart/form-data">
								<div class="mb-2">
									<label class="form-label small fw-semibold text-secondary mb-1">Valitse
										PDF-tiedosto</label> <input type="file"
										class="form-control form-control-sm" name="tiedosto"
										accept="application/pdf" required>
								</div>
								<div class="mb-3">
									<label class="form-label small fw-semibold text-secondary mb-1">Kuvaus
										/ Sisältö</label> <input type="text"
										class="form-control form-control-sm" name="kuvaus"
										placeholder="esim. Allekirjoitettu sopimus" required>
								</div>
								<button type="submit"
									class="btn btn-primary btn-sm fw-bold px-3">Tallenna
									dokumentti</button>
							</form>
						</div>
					</div>
				</div>
			</div>
		</div>

	</div>
	<!-- .container päättyminen -->

	<!-- BOOTSTRAP POP-UP LOMAKE ASIAKKAAN MUOKKAUKSEEN -->
	<div class="modal fade" id="muokkaaAsiakasModal" tabindex="-1"
		aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content border-0 shadow-lg">
				<div class="modal-header bg-dark text-white">
					<h5 class="modal-title fw-bold">Muokkaa asiakkaan tietoja</h5>
					<button type="button" class="btn-close btn-close-white"
						data-bs-dismiss="modal"></button>
				</div>
				<form
					action="${pageContext.request.contextPath}/asiakas/${asiakas.id}/muokkaa"
					method="post">
					<div class="modal-body p-4">
						<div class="mb-3">
							<label class="form-label fw-semibold text-secondary">Nimi</label><input
								type="text" class="form-control" name="nimi"
								value="${asiakas.nimi}" required>
						</div>
						<div class="mb-3">
							<label class="form-label fw-semibold text-secondary">Sähköposti</label><input
								type="email" class="form-control" name="sahkoposti"
								value="${asiakas.sahkoposti}" required>
						</div>
						<div class="mb-3">
							<label class="form-label fw-semibold text-secondary">Puhelin</label><input
								type="text" class="form-control" name="puhelin"
								value="${asiakas.puhelin}" required>
						</div>
						<div class="mb-3">
							<label class="form-label fw-semibold text-secondary">Asiakkaan
								tila</label> <select class="form-select" name="tila" required>
								<option value="PROSPEKTI"
									${asiakas.tila == 'PROSPEKTI' ? 'selected' : ''}>Prospekti</option>
								<option value="KONTAKTOITU"
									${asiakas.tila == 'KONTAKTOITU' ? 'selected' : ''}>Kontaktoitu</option>
								<option value="KAUPPA"
									${asiakas.tila == 'KAUPPA' ? 'selected' : ''}>Kauppa</option>
								<option value="EI_KAUPPAA"
									${asiakas.tila == 'EI_KAUPPAA' ? 'selected' : ''}>Ei
									kauppaa</option>
							</select>
						</div>
					</div>
					<div class="modal-footer bg-light">
						<button type="button" class="btn btn-secondary"
							data-bs-disabled="modal">Peruuta</button>
						<button type="submit" class="btn btn-primary px-4 fw-bold">Tallenna
							muutokset</button>
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
