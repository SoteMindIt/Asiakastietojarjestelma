<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html lang="fi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Asiakasprofiili - ${asiakas.nimi}</title>
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
		<!-- TAKAISIN-LINKKI -->
		<div class="mb-3">
			<a class="btn btn-link p-0 text-decoration-none"
				href="${pageContext.request.contextPath}/">&larr; Takaisin
				asiakaslistaukseen</a>
		</div>

		<!-- ASIAKKAAN PERUSTIEDOT JA TOIMINTOPAINIKKEET -->
		<div class="profile-card border mb-4">
			<div class="row align-items-start">
				<div class="col-md-7">
					<span class="text-muted small">Asiakasnumero #${asiakas.id}</span>
					<h1 class="text-dark fw-bold mb-3">${asiakas.nimi}</h1>

					<p class="mb-1">
						<strong>Sähköposti:</strong> ${not empty asiakas.sahkoposti ? asiakas.sahkoposti : '<span class="text-muted italic small">Ei määritelty</span>'}
					</p>
					<p class="mb-1">
						<strong>Puhelin:</strong> ${not empty asiakas.puhelin ? asiakas.puhelin : '<span class="text-muted italic small">Ei määritelty</span>'}
					</p>
					<p class="mb-1">
						<strong>Osoite:</strong> ${not empty asiakas.katuosoite ? asiakas.katuosoite : '<span class="text-muted italic small">Ei määritelty</span>'}
						${asiakas.postinumero} ${asiakas.postitoimipaikka}
					</p>
					
					<p class="mb-1">
						<strong>Y-tunnus:</strong> ${not empty asiakas.yTunnus ? asiakas.yTunnus : '<span class="text-muted italic small">Ei määritelty</span>'}
					</p>
					
					<p class="mb-1">
						<strong>Kotisivu:</strong>
						<c:if test="${not empty asiakas.kotisivu}">
							<a href="${asiakas.kotisivu}" target="_blank">${asiakas.kotisivu}</a>
						</c:if>
						<c:if test="${empty asiakas.kotisivu}">
							<span class="text-muted italic small">Ei määritelty</span>
						</c:if>
					</p>
				</div>
				<div class="col-md-5 text-end">
					<div class="mb-3">
						<span class="badge bg-primary p-2 fs-6">Tila:
							${asiakas.tila}</span>
					</div>
					<!-- KORJATTU: btn-group korvattu d-flex gap-2 -luokalla, jotta painikkeiden väliin tulee rako -->
					<div class="d-flex gap-2 justify-content-end">
						<a
							href="${pageContext.request.contextPath}/asiakas/${asiakas.id}/tarjoukset"
							class="btn btn-success fw-bold rounded shadow-sm"> €
							Tarjouslaskenta </a>
						<button type="button"
							class="btn btn-dark fw-bold rounded shadow-sm"
							data-bs-toggle="modal" data-bs-target="#muokkaaAsiakasModal">
							Muokkaa</button>
						<button type="button"
							class="btn btn-danger fw-bold rounded shadow-sm"
							onclick="if(confirm('Haluatko varmasti poistaa tämän asiakkaan ja kaikki siihen liittyvät tiedot?')) { document.getElementById('poistoForm').submit(); }">
							Poista asiakas</button>
					</div>
					<form id="poistoForm"
						action="${pageContext.request.contextPath}/asiakas/${asiakas.id}/poista"
						method="post" style="display: none;"></form>
				</div>
			</div>
		</div>
		<!-- KOLMESARAKKEINEN OSIO -->
		<div class="row g-4 mb-4">

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
									class="text-dark small">${ot.tuote.nimi}</strong> <span
									class="badge bg-light text-secondary border float-end"
									style="font-size: 0.8em;"> <fmt:parseDate
											value="${ot.ostopaivamaara}" pattern="yyyy-MM-dd"
											var="parsedOstoPvm" type="date" /> <fmt:formatDate
											value="${parsedOstoPvm}" pattern="dd.MM.yyyy" />
								</span> <br> <span class="text-muted small">${ot.maara}
										${ot.tuote.yksikko} x ${ot.myyntihinta} € </span><br> <span
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
							<select class="form-select form-select-sm" name="tuoteId"
								required>
								<option value="">-- Valitse palvelu/tuote --</option>
								<c:forEach var="tuote" items="${kaikkiTuotteet}">
									<option value="${tuote.id}">${tuote.nimi}
										(${tuote.hinta} €)</option>
								</c:forEach>
							</select>
						</div>
						<div class="mb-2">
							<input type="number" class="form-control form-control-sm"
								name="maara" min="1" value="1" required placeholder="Määrä">
						</div>
						<div class="mb-2">
							<label class="form-label text-secondary small mb-1 fw-bold">Ostopäivä:</label>
							<input type="date" class="form-control form-control-sm"
								name="ostopaivamaara">
						</div>
						<button type="submit" class="btn btn-primary btn-sm w-100 fw-bold">Kirjaa
							hankinta</button>
					</form>
				</div>
			</div>
		</div>
		<!-- LISTAUS ASIAKKAAN AIEMMISTA TARJOUKSISTA -->
		<div class="profile-card border mt-4">
			<h3 class="fw-bold h5 text-dark mb-3">Tallennetut tarjoukset
				(${tarjouksetMaara})</h3>
			<div class="table-responsive">
				<table class="table table-sm table-hover mb-0 align-middle">
					<thead class="table-light">
						<tr>
							<th>Tarjousnumero</th>
							<th>Päivämäärä</th>
							<th>Voimassaolo</th>
							<th class="text-end">Summa (Verollinen)</th>
							<th class="text-end">Toiminnot</th>
						</tr>
					</thead>
					<tbody>
						<c:forEach var="t" items="${tarjoukset}">
							<tr>
								<td><strong>${t.tarjousNumero}</strong></td>
								<td>${t.pvm}</td>
								<td>${t.voimassaoloPvm}</td>
								<td class="text-end fw-bold text-success">${t.verollinenYhteensa}
									€</td>
								<td class="text-end"><a
									href="${pageContext.request.contextPath}/tarjous/${t.id}/lataa-pdf"
									class="btn btn-sm btn-outline-secondary px-2">Lataa PDF</a></td>
							</tr>
						</c:forEach>
						<c:if test="${empty tarjoukset}">
							<tr>
								<td colspan="5" class="text-center text-muted py-3">Ei
									tallennettuja tarjouksia.</td>
							</tr>
						</c:if>
					</tbody>
				</table>
			</div>
		</div>

	</div>
	<!-- container päättyy -->

	<!-- BOOTSTRAP POP-UP LOMAKE (MODAL) ASIAKKUUDEN TIETOJEN MUOKKAUKSEEN -->
	<div class="modal fade" id="muokkaaAsiakasModal" tabindex="-1"
		aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered modal-lg">
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
							<label class="form-label fw-bold">Asiakkaan / Yrityksen
								nimi <span class="text-danger">*</span>
							</label> <input type="text" class="form-control" name="nimi"
								value="${asiakas.nimi}" required>
						</div>
						<div class="row g-3 mb-3">
							<div class="col-md-6">
								<label class="form-label fw-bold">Puhelinnumero</label> <input
									type="tel" class="form-control" name="puhelin"
									value="${asiakas.puhelin}">
							</div>
							<div class="col-md-6">
								<label class="form-label fw-bold">Sähköposti</label> <input
									type="email" class="form-control" name="sahkoposti"
									value="${asiakas.sahkoposti}">
							</div>
						</div>
						<div class="mb-3">
							<label class="form-label fw-bold">Katuosoite</label> <input
								type="text" class="form-control" name="katuosoite"
								value="${asiakas.katuosoite}">
						</div>
						<div class="mb-3">
							<label for="yTunnus"
								class="form-label fw-semibold text-secondary">Y-tunnus</label>
							<!-- value-attribuutti hakee valmiiksi tallennetun Y-tunnuksen kenttään -->
							<input type="text" class="form-control" id="yTunnus"
								name="yTunnus" placeholder="esim. 1234567-8" maxlength="9"
								value="${asiakas.yTunnus}">
						</div>
						<div class="row g-3 mb-3">
							<div class="col-md-4">
								<label class="form-label fw-bold">Postinumero</label> <input
									type="text" class="form-control" name="postinumero"
									value="${asiakas.postinumero}" maxlength="10">
							</div>
							<div class="col-md-8">
								<label class="form-label fw-bold">Postitoimipaikka</label> <input
									type="text" class="form-control" name="postitoimipaikka"
									value="${asiakas.postitoimipaikka}">
							</div>
						</div>
						<div class="mb-3">
							<label class="form-label fw-bold">Kotisivun osoite</label> <input
								type="url" class="form-control" name="kotisivu"
								value="${asiakas.kotisivu}" placeholder="https://">
						</div>
						<div class="mb-3">
							<label class="form-label fw-bold">Asiakkuuden tila
								myyntiputkessa</label> <select class="form-select" name="tila" required>
								<c:forEach var="tilaVaihtoehto" items="${tilat}">
									<option value="${tilaVaihtoehto}"
										<c:if test="${asiakas.tila == tilaVaihtoehto}">selected</c:if>>
										${tilaVaihtoehto.nayttorivi}</option>
								</c:forEach>
							</select>
						</div>
					</div>
					<div class="modal-footer bg-light">
						<button type="button" class="btn btn-secondary fw-bold"
							data-bs-dismiss="modal">Peruuta</button>
						<button type="submit" class="btn btn-primary fw-bold">Tallenna
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
