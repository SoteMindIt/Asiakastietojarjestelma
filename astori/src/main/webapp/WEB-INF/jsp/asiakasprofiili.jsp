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
		<!-- TAKAISIN-LINKKI -->
		<div class="mb-3">
			<a class="btn btn-link p-0 text-decoration-none"
				href="${pageContext.request.contextPath}/asiakkaat">&larr;
				Takaisin asiakaslistaukseen</a>
		</div>
		<!-- ASIAKKAAN PROFIILIKORTTI (KATSELU TAI MUOKKAUS) -->
		<div class="profile-card border mb-4 bg-white shadow-sm p-4 rounded-3">

			<!-- 1. KATSELUTILA (Optimoitu tilankäyttö) -->
			<div id="asiakas-katselu" class="row g-4 align-items-start">
				<div class="col-lg-8">
					<div class="d-flex align-items-center gap-2 mb-2">
						<span class="badge bg-light text-secondary border px-2 py-1 small">Asiakasnumero
							#${asiakas.id}</span>
						<c:choose>
							<c:when test="${asiakas.tila == 'PROSPEKTI'}">
								<span
									class="badge bg-warning text-dark fw-bold text-uppercase px-3 py-1.5 rounded-pill shadow-sm"
									style="font-size: 0.75em;">Prospekti</span>
							</c:when>
							<c:when test="${asiakas.tila == 'KONTAKTOITU'}">
								<span
									class="badge bg-info text-dark fw-bold text-uppercase px-3 py-1.5 rounded-pill shadow-sm"
									style="font-size: 0.75em;">Kontaktoitu</span>
							</c:when>
							<c:when test="${asiakas.tila == 'TARJOUS_JATETTY'}">
								<span
									class="badge bg-primary text-white fw-bold text-uppercase px-3 py-1.5 rounded-pill shadow-sm"
									style="font-size: 0.75em;">Tarjous jätetty</span>
							</c:when>
							<c:when test="${asiakas.tila == 'AKTIIVINEN'}">
								<span
									class="badge bg-success text-white fw-bold text-uppercase px-3 py-1.5 rounded-pill shadow-sm"
									style="font-size: 0.75em;">Aktiivinen</span>
							</c:when>
							<c:when test="${asiakas.tila == 'PAATTYNYT'}">
								<span
									class="badge bg-secondary text-white fw-bold text-uppercase px-3 py-1.5 rounded-pill shadow-sm"
									style="font-size: 0.75em;">Päättynyt</span>
							</c:when>
							<c:otherwise>
								<span
									class="badge bg-light text-dark border px-3 py-1.5 rounded-pill">${asiakas.tila}</span>
							</c:otherwise>
						</c:choose>
					</div>

					<h1 class="text-dark fw-extrabold display-6 mb-3">${asiakas.nimi}</h1>

					<!-- Yrityksen toiminta ja taustat -->
					<div class="p-3 bg-light rounded-3 border mb-4">
						<h6 class="fw-bold text-uppercase text-muted mb-2"
							style="font-size: 0.75em; letter-spacing: 0.5px;">Yrityksen
							toiminta ja taustat</h6>
						<p class="mb-0 text-dark small lh-base"
							style="white-space: pre-line;">
							<c:choose>
								<c:when test="${not empty asiakas.kuvaus}">
									<c:out value="${asiakas.kuvaus}" />
								</c:when>
								<c:otherwise>
									<span class="text-muted italic">Ei määriteltyä toiminnan
										kuvausta.</span>
								</c:otherwise>
							</c:choose>
						</p>
					</div>

					<!-- Perustiedot ruudukossa -->
					<div class="row g-2 text-dark small">
						<div class="col-sm-6">
							<p class="mb-1">
								<strong>📍 Osoite:</strong> ${not empty asiakas.katuosoite ? asiakas.katuosoite : '<span class="text-muted italic">Ei määritelty</span>'}
								${asiakas.postinumero} ${asiakas.postitoimipaikka}
							</p>
							
							<p class="mb-1">
								<strong>🏢 Hyvinvointialue:</strong>
								<c:choose>
									<c:when test="${not empty asiakas.hyvinvointialue}">
            ${asiakas.hyvinvointialue.nimi}
        </c:when>
									<c:otherwise>
										<span class="text-muted italic">Ei määritelty</span>
									</c:otherwise>
								</c:choose>
							</p>


							<p class="mb-1">
								<strong>🆔 Y-tunnus:</strong> ${not empty asiakas.yTunnus ? asiakas.yTunnus : '<span class="text-muted italic">Ei määritelty</span>'}
							</p>
						</div>
						<div class="col-sm-6">
							<p class="mb-1">
								<strong>📞 Puhelin:</strong> ${not empty asiakas.puhelin ? asiakas.puhelin : '<span class="text-muted italic">Ei määritelty</span>'}
							</p>
							<p class="mb-1">
								<strong>✉️ Sähköposti:</strong> ${not empty asiakas.sahkoposti ? asiakas.sahkoposti : '<span class="text-muted italic">Ei määritelty</span>'}
							</p>
							<p class="mb-1">
								<strong>🌐 Kotisivu:</strong>
								<c:if test="${not empty asiakas.kotisivu}">
									<a href="${asiakas.kotisivu}" target="_blank"
										class="text-decoration-none">${asiakas.kotisivu}</a>
								</c:if>
								<c:if test="${empty asiakas.kotisivu}">
									<span class="text-muted italic">Ei määritelty</span>
								</c:if>
							</p>
						</div>
					</div>
				</div>

				<!-- Oikea reuna: Painikkeet ja loki -->
				<div
					class="col-lg-4 text-end d-flex flex-column h-100 justify-content-between">

					<!-- PÄÄTOIMINNOT -->
					<div class="d-flex gap-2 justify-content-end mb-3">
						<a
							href="${pageContext.request.contextPath}/asiakas/${asiakas.id}/tarjoukset"
							class="btn btn-success btn-sm fw-bold rounded-2 shadow-sm px-3">€
							Tarjouslaskenta</a>
						<button type="button"
							class="btn btn-dark btn-sm fw-bold rounded-2 shadow-sm px-3"
							onclick="avaaMuokkaus()">Muokkaa</button>
						<button type="button"
							class="btn btn-outline-danger btn-sm fw-bold rounded-2 px-2"
							onclick="if(confirm('Haluatko varmasti poistaa tämän asiakkaan ja kaikki siihen liittyvät tiedot?')) { document.getElementById('poistoForm').submit(); }">Poista</button>
					</div>
					<form id="poistoForm"
						action="${pageContext.request.contextPath}/asiakas/${asiakas.id}/poista"
						method="post" style="display: none;"></form>

					<!-- LISÄYSPAINIKKEET -->
					<div
						class="d-flex gap-2 justify-content-end flex-wrap pt-2 border-top mb-3">
						<button type="button"
							class="btn btn-xs btn-outline-success fw-bold py-1 px-2 small"
							style="font-size: 0.85em;" data-bs-toggle="modal"
							data-bs-target="#lisaaHankintaModal">+ Tuote/Palvelu</button>
						<button type="button"
							class="btn btn-xs btn-outline-primary fw-bold py-1 px-2 small"
							style="font-size: 0.85em;" data-bs-toggle="modal"
							data-bs-target="#lisaaKirjausModal">+ Lokimerkintä</button>
						<button type="button"
							class="btn btn-xs btn-outline-secondary fw-bold py-1 px-2 small"
							style="font-size: 0.85em;" data-bs-toggle="modal"
							data-bs-target="#lisaaYhModal">+ Yhteyshenkilö</button>
					</div>

					<!-- ASIAKKAAN LOKI -->
					<div class="text-start mt-2 p-3 bg-light rounded-3 border">
						<h6 class="fw-bold text-uppercase text-muted mb-2"
							style="font-size: 0.75em; letter-spacing: 0.5px;">Asiakkaan
							loki</h6>
						<div style="max-height: 200px; overflow-y: auto;" class="pe-1">
							<ul class="list-group list-group-flush bg-transparent">
								<c:forEach var="k" items="${kirjaukset}">
									<li
										class="list-group-item px-0 py-2 border-bottom-0 bg-transparent">
										<div
											class="p-2 rounded bg-white border-start border-primary border-3 shadow-sm mb-1">
											<div class="d-flex justify-content-between align-items-start">
												<p class="mb-1 text-dark small fw-normal flex-grow-1 mb-0"
													style="white-space: pre-line; font-size: 0.9em;">${k.teksti}</p>
												<button type="button"
													class="btn btn-sm btn-link p-0 ms-2 text-primary text-decoration-none small muokkaa-loki-btn"
													style="font-size: 0.8em;" data-id="${k.id}"
													data-teksti="<c:out value='${k.teksti}'/>">Muokkaa</button>
											</div>
											<small class="text-muted d-block mt-1"
												style="font-size: 0.75em;"> <fmt:parseDate
													value="${k.luontiaika}" pattern="yyyy-MM-dd'T'HH:mm"
													var="parsedAika" type="both" /> <fmt:formatDate
													value="${parsedAika}" pattern="dd.MM.yyyy 'klo' HH:mm" />
											</small>
										</div>
									</li>
								</c:forEach>
								<c:if test="${empty kirjaukset}">
									<li
										class="list-group-item px-0 py-2 text-muted italic bg-transparent small">Ei
										aiempia lokimerkintöjä.</li>
								</c:if>
							</ul>
						</div>
					</div>

				</div>
			</div>
			<!-- 2. MUOKKAUSTILA (Piilotettu oletuksena) -->
			<div id="asiakas-muokkaus" class="d-none">
				<div
					class="bg-dark text-white p-3 rounded-top mb-3 mx-n3 mt-n3 d-flex justify-content-between align-items-center">
					<h5 class="mb-0 fw-bold">Muokkaa asiakkaan tietoja</h5>
					<span class="badge bg-secondary">ID #${asiakas.id}</span>
				</div>
				<form
					action="${pageContext.request.contextPath}/asiakas/${asiakas.id}/muokkaa"
					method="post">
					<div class="row g-3">
						<div class="col-12">
							<label class="form-label fw-bold">Asiakkaan / Yrityksen
								nimi <span class="text-danger">*</span>
							</label> <input type="text" class="form-control" name="nimi"
								value="${asiakas.nimi}" required>
						</div>

						<div class="col-md-6">
							<label for="muokkaaHyvinvointialue" class="form-label fw-bold">Hyvinvointialue</label>
							<select class="form-select" id="muokkaaHyvinvointialue"
								name="hyvinvointialue">
								<option value="">-- Valitse hyvinvointialue --</option>
								<c:forEach var="alue" items="${hyvinvointialueet}">
									<!-- value pitää Javan helpompaa enumin vertailua varten olion nimenä (value="${alue}") -->
									<option value="${alue}"
										<c:if test="${asiakas.hyvinvointialue == alue.name()}">selected</c:if>>
										${alue.nimi}</option>
								</c:forEach>
							</select>
						</div>

						<div class="col-md-6">
							<label class="form-label fw-bold">Y-tunnus</label> <input
								type="text" class="form-control" id="yTunnus" name="yTunnus"
								placeholder="esim. 1234567-8" maxlength="9"
								value="${asiakas.yTunnus}">
						</div>

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

						<div class="col-12">
							<label class="form-label fw-bold">Katuosoite</label> <input
								type="text" class="form-control" name="katuosoite"
								value="${asiakas.katuosoite}">
						</div>

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

						<div class="col-12">
							<label class="form-label fw-bold">Kotisivun osoite</label> <input
								type="url" class="form-control" name="kotisivu"
								value="${asiakas.kotisivu}" placeholder="https://">
						</div>

						<div class="col-12">
							<label class="form-label fw-bold">Asiakkuuden tila
								myyntiputkessa</label> <select class="form-select" name="tila" required>
								<c:forEach var="tilaVaihtoehto" items="${tilat}">
									<option value="${tilaVaihtoehto}"
										<c:if test="${asiakas.tila == tilaVaihtoehto}">selected</c:if>>${tilaVaihtoehto.nayttorivi}</option>
								</c:forEach>
							</select>
						</div>

						<div class="col-12">
							<label class="form-label fw-bold">Toiminnan kuvaus /
								Toimiala</label>
							<textarea class="form-control" name="kuvaus" rows="3">${asiakas.kuvaus}</textarea>
						</div>
					</div>

					<div class="d-flex justify-content-end gap-2 mt-4 pt-3 border-top">
						<button type="button" class="btn btn-secondary fw-bold"
							onclick="peruutaMuokkaus()">Peruuta</button>
						<button type="submit" class="btn btn-primary fw-bold">Tallenna
							muutokset</button>
					</div>
				</form>
			</div>

		</div>

		<!-- TÄYSLEVEÄT KORTIT ALLEKKAIN (Korjaa tyhjät aukot sivuilla) -->
		<div class="row g-4 mb-4">

			<!-- 1. KORTTI: YHTEYSHENKILÖT -->
			<div class="col-12">
				<div class="profile-card border bg-white shadow-sm p-3 rounded-3">
					<h3 class="fw-bold h6 text-secondary text-uppercase mb-3"
						style="letter-spacing: 0.5px;">👥 Yhteyshenkilöt</h3>

					<c:choose>
						<c:when test="${not empty yhteyshenkilot}">
							<div class="d-flex flex-wrap gap-3">
								<c:forEach var="h" items="${yhteyshenkilot}">
									<div
										class="card p-2 shadow-sm border bg-light d-flex flex-row justify-content-between align-items-center"
										style="min-width: 280px; flex: 1 1 30%;">
										<div>
											<strong class="text-dark small d-block">${h.nimi}</strong> <span
												class="text-muted" style="font-size: 0.8em;">${h.rooli}</span>
											<div class="text-muted mt-1" style="font-size: 0.75em;">
												<div>✉️ ${h.sahkoposti}</div>
												<div>📞 ${h.puhelin}</div>
											</div>
										</div>
										<button type="button"
											class="btn btn-sm btn-outline-primary py-1 px-2 muokkaa-yh-btn"
											data-id="${h.id}" data-nimi="${h.nimi}"
											data-rooli="${h.rooli}" data-email="${h.sahkoposti}"
											data-puh="${h.puhelin}" style="font-size: 0.8em;">Muokkaa</button>
									</div>
								</c:forEach>
							</div>
						</c:when>
						<c:otherwise>
							<div
								class="p-3 bg-light rounded text-center text-muted small italic">
								Ei määriteltyjä yhteyshenkilöitä. Voit lisätä uuden henkilön
								yläpuolelta.</div>
						</c:otherwise>
					</c:choose>
				</div>
			</div>
			<!-- 2. KORTTI: MYYDYT PALVELUT (Muutettu leveäksi taulukoksi) -->
			<div class="col-12">
				<div class="profile-card border bg-white shadow-sm p-3 rounded-3">
					<div class="d-flex justify-content-between align-items-center mb-3">
						<h3 class="fw-bold h6 text-secondary text-uppercase mb-0"
							style="letter-spacing: 0.5px;">🛒 Ostetut tuotteet ja
							palvelut</h3>
						<c:if test="${not empty ostetutTuotteet}">
							<span
								class="badge bg-success-subtle text-success border border-success-subtle fw-bold px-3 py-1.5 rounded-2">
								Asiakkuuden kokonaisarvo: <!-- Alustetaan summa ennen silmukkaa dynaamisesti -->
								<c:set var="yhteissumma" value="0" /> <c:forEach var="ot"
									items="${ostetutTuotteet}">
									<c:set var="yhteissumma"
										value="${yhteissumma + ot.kokonaishinta}" />
								</c:forEach> ${yhteissumma} €
							</span>
						</c:if>
					</div>

					<c:choose>
						<c:when test="${not empty ostetutTuotteet}">
							<div class="table-responsive">
								<table
									class="table table-sm table-hover mb-0 align-middle small">
									<thead class="table-light text-secondary">
										<tr>
											<th>Tuote / Palvelu</th>
											<th>Määrä</th>
											<th>Yksikköhinta</th>
											<th>Ostopäivä</th>
											<th class="text-end">Yhteensä</th>
										</tr>
									</thead>
									<tbody>
										<c:forEach var="ot" items="${ostetutTuotteet}">
											<tr>
												<td><a href="#"
													class="text-primary fw-bold text-decoration-none muokkaa-palvelu-linkki"
													data-bs-toggle="modal"
													data-bs-target="#muokkaaPalveluModal" data-id="${ot.id}"
													data-tuote="${ot.tuote.nimi}" data-maara="${ot.maara}"
													data-hinta="${ot.myyntihinta}"
													data-pvm="${ot.ostopaivamaara}"> ✏️ ${ot.tuote.nimi} </a></td>
												<td>${ot.maara}${ot.tuote.yksikko.lyhenne}</td>
												<td>${ot.myyntihinta}€</td>
												<td><fmt:parseDate value="${ot.ostopaivamaara}"
														pattern="yyyy-MM-dd" var="parsedOstoPvm" type="date" /> <fmt:formatDate
														value="${parsedOstoPvm}" pattern="dd.MM.yyyy" /></td>
												<td class="text-end fw-bold text-dark">${ot.kokonaishinta}
													€</td>
											</tr>
										</c:forEach>
									</tbody>
								</table>
							</div>
						</c:when>
						<c:otherwise>
							<div
								class="p-3 bg-light rounded text-center text-muted small italic">
								Ei kirjattuja hankintoja. Voit kirjata uuden hankinnan
								yläpuolelta.</div>
						</c:otherwise>
					</c:choose>
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
	<!-- /container -->
	<!-- ==================== MODAL-IKKUNAT ==================== -->

	<!-- MODAL UUDEN HANKINNAN / PALVELUN KIRJAAMISEEN -->
	<div class="modal fade" id="lisaaHankintaModal" tabindex="-1"
		aria-labelledby="lisaaHankintaModalLabel" aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content border-0 shadow-lg">
				<form
					action="${pageContext.request.contextPath}/asiakas/${asiakas.id}/lisaa-tuote"
					method="post">
					<div class="modal-header bg-dark text-white">
						<h5 class="modal-title fw-bold" id="lisaaHankintaModalLabel">Kirjaa
							uusi hankinta</h5>
						<button type="button" class="btn-close btn-close-white"
							data-bs-dismiss="modal" aria-label="Close"></button>
					</div>
					<div class="modal-body p-4">
						<div class="mb-3">
							<label class="form-label fw-bold text-secondary">Valitse
								palvelu tai tuote *</label> <select class="form-select" name="tuoteId"
								required>
								<option value="">-- Valitse palvelu/tuote --</option>
								<c:forEach var="t" items="${kaikkiTuotteet}">
									<option value="${t.id}">${t.nimi}</option>
								</c:forEach>
							</select>
						</div>
						<div class="mb-3">
							<label class="form-label fw-bold text-secondary">Määrä *</label>
							<input type="number" class="form-control" name="maara" min="1"
								value="1" required placeholder="Syötä kappalemäärä tai tunnit">
						</div>
						<div class="mb-3">
							<label class="form-label fw-bold text-secondary">Ostopäivämäärä
								*</label> <input type="date" class="form-control" name="ostopaivamaara"
								required>
						</div>
					</div>
					<div class="modal-footer bg-light">
						<button type="button" class="btn btn-secondary"
							data-bs-dismiss="modal">Peruuta</button>
						<button type="submit" class="btn btn-success fw-bold">Kirjaa
							hankinta</button>
					</div>
				</form>
			</div>
		</div>
	</div>

	<!-- MODAL UUDEN LOKIMERKINNÄN LISÄÄMISEEN -->
	<div class="modal fade" id="lisaaKirjausModal" tabindex="-1"
		aria-labelledby="lisaaKirjausModalLabel" aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content border-0 shadow-lg">
				<form
					action="${pageContext.request.contextPath}/asiakas/${asiakas.id}/lisaa-kirjaus"
					method="post">
					<div class="modal-header bg-dark text-white">
						<h5 class="modal-title fw-bold" id="lisaaKirjausModalLabel">Lisää
							uusi lokimerkintä</h5>
						<button type="button" class="btn-close btn-close-white"
							data-bs-dismiss="modal" aria-label="Close"></button>
					</div>
					<div class="modal-body p-4">
						<div class="mb-3">
							<label class="form-label fw-bold text-secondary">Muistiinpanot
								/ Tapahtumatiedot *</label>
							<textarea class="form-control" name="teksti" rows="5" required
								placeholder="Kirjoita tähän lokimerkinnän sisältö..."></textarea>
						</div>
					</div>
					<div class="modal-footer bg-light">
						<button type="button" class="btn btn-secondary"
							data-bs-dismiss="modal">Peruuta</button>
						<button type="submit" class="btn btn-primary fw-bold">Tallenna
							kirjaus</button>
					</div>
				</form>
			</div>
		</div>
	</div>

	<!-- MODAL UUDEN YHTEYSHENKILÖN LISÄÄMISEEN -->
	<div class="modal fade" id="lisaaYhModal" tabindex="-1"
		aria-labelledby="lisaaYhModalLabel" aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content border-0 shadow-lg">
				<form method="post"
					action="${pageContext.request.contextPath}/asiakas/${asiakas.id}/lisaa-yhteyshenkilo">
					<div class="modal-header bg-dark text-white">
						<h5 class="modal-title fw-bold" id="lisaaYhModalLabel">Lisää
							uusi yhteyshenkilö</h5>
						<button type="button" class="btn-close btn-close-white"
							data-bs-dismiss="modal" aria-label="Close"></button>
					</div>
					<div class="modal-body p-4">
						<div class="mb-3">
							<label class="form-label fw-bold">Nimi *</label> <input
								type="text" class="form-control" name="nimi"
								placeholder="Yhteyshenkilön nimi" required>
						</div>
						<div class="mb-3">
							<label class="form-label fw-bold">Rooli / Nimike</label> <input
								type="text" class="form-control" name="rooli"
								placeholder="esim. Toimitusjohtaja">
						</div>
						<div class="mb-3">
							<label class="form-label fw-bold">Sähköposti</label> <input
								type="email" class="form-control" name="sahkoposti"
								placeholder="esim. nimi@yritys.fi">
						</div>
						<div class="mb-3">
							<label class="form-label fw-bold">Puhelin</label> <input
								type="text" class="form-control" name="puhelin"
								placeholder="Puhelinnumero">
						</div>
					</div>
					<div class="modal-footer bg-light">
						<button type="button" class="btn btn-secondary"
							data-bs-dismiss="modal">Peruuta</button>
						<button type="submit" class="btn btn-success fw-bold">Tallenna
							yhteyshenkilö</button>
					</div>
				</form>
			</div>
		</div>
	</div>
	<!-- MODAL YHTEYSHENKILÖN MUOKKAUKSEEN -->
	<div class="modal fade" id="muokkaaYhModal" tabindex="-1"
		aria-labelledby="muokkaaYhModalLabel" aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content border-0 shadow-lg">
				<form id="muokkaaYhForm" method="post" action="">
					<input type="hidden" name="asiakasId" value="${asiakas.id}">
					<div class="modal-header bg-dark text-white">
						<h5 class="modal-title fw-bold" id="muokkaaYhModalLabel">Muokkaa
							yhteyshenkilöä</h5>
						<button type="button" class="btn-close btn-close-white"
							data-bs-dismiss="modal" aria-label="Close"></button>
					</div>
					<div class="modal-body">
						<div class="mb-3">
							<label for="yhNimi" class="form-label fw-bold">Nimi</label> <input
								type="text" class="form-control" id="yhNimi" name="nimi"
								required>
						</div>
						<div class="mb-3">
							<label for="yhRooli" class="form-label fw-bold">Rooli /
								Nimike</label> <input type="text" class="form-control" id="yhRooli"
								name="rooli">
						</div>
						<div class="mb-3">
							<label for="yhSahkoposti" class="form-label fw-bold">Sähköposti</label>
							<input type="email" class="form-control" id="yhSahkoposti"
								name="sahkoposti">
						</div>
						<div class="mb-3">
							<label for="yhPuhelin" class="form-label fw-bold">Puhelin</label>
							<input type="text" class="form-control" id="yhPuhelin"
								name="puhelin">
						</div>
					</div>
					<div class="modal-footer bg-light">
						<button type="button" class="btn btn-secondary"
							data-bs-dismiss="modal">Peruuta</button>
						<button type="submit" class="btn btn-primary fw-bold">Tallenna
							muutokset</button>
					</div>
				</form>
			</div>
		</div>
	</div>

	<!-- MODAL LOKIMERKINNÄN MUOKKAUKSEEN -->
	<div class="modal fade" id="muokkaaLokiModal" tabindex="-1"
		aria-labelledby="muokkaaLokiModalLabel" aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content border-0 shadow-lg">
				<form id="muokkaaLokiForm" method="post" action="">
					<input type="hidden" name="asiakasId" value="${asiakas.id}">
					<div class="modal-header bg-dark text-white">
						<h5 class="modal-title fw-bold" id="muokkaaLokiModalLabel">Muokkaa
							lokimerkintää</h5>
						<button type="button" class="btn-close btn-close-white"
							data-bs-dismiss="modal" aria-label="Close"></button>
					</div>
					<div class="modal-body p-4">
						<div class="mb-3">
							<label class="form-label fw-bold text-secondary">Muistiinpanot
								/ Tapahtumatiedot *</label>
							<textarea class="form-control" id="lokiTeksti" name="teksti"
								rows="5" required></textarea>
						</div>
					</div>
					<div class="modal-footer bg-light">
						<button type="button" class="btn btn-secondary"
							data-bs-dismiss="modal">Peruuta</button>
						<button type="submit" class="btn btn-primary fw-bold">Tallenna
							muutokset</button>
					</div>
				</form>
			</div>
		</div>
	</div>

	<!-- MODAL MYYDYNTUOTTEEN / PALVELUN MUOKKAUKSEEN -->
	<div class="modal fade" id="muokkaaPalveluModal" tabindex="-1"
		aria-labelledby="muokkaaPalveluModalLabel" aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content border-0 shadow-lg">
				<form id="muokkaaPalveluForm" method="post" action="">
					<input type="hidden" name="asiakasId" value="${asiakas.id}">
					<div class="modal-header bg-dark text-white">
						<h5 class="modal-title fw-bold" id="muokkaaPalveluModalLabel">Muokkaa
							myytyä palvelua</h5>
						<button type="button" class="btn-close btn-close-white"
							data-bs-dismiss="modal" aria-label="Close"></button>
					</div>
					<div class="modal-body p-4">
						<div class="mb-3">
							<label class="form-label fw-bold text-secondary">Palvelu
								/ Tuote</label> <input type="text" class="form-control bg-light"
								id="muokkaaPalveluNimi" readonly>
						</div>
						<div class="mb-3">
							<label class="form-label fw-bold text-secondary">Määrä *</label>
							<input type="number" class="form-control"
								id="muokkaaPalveluMaara" name="maara" min="1" required>
						</div>
						<div class="mb-3">
							<label class="form-label fw-bold text-secondary">Myyntihinta
								(€) *</label> <input type="number" class="form-control"
								id="muokkaaPalveluHinta" name="myyntihinta" step="0.01" required>
						</div>
						<div class="mb-3">
							<label class="form-label fw-bold text-secondary">Ostopäivämäärä
								*</label> <input type="date" class="form-control" id="muokkaaPalveluPvm"
								name="ostopaivamaara" required>
						</div>
					</div>
					<div class="modal-footer bg-light">
						<button type="button" class="btn btn-secondary"
							data-bs-dismiss="modal">Peruuta</button>
						<button type="submit" class="btn btn-primary fw-bold">Tallenna
							muutokset</button>
					</div>
				</form>
			</div>
		</div>
	</div>

	<!-- ==================== JAVASCRIPT-TOIMINNOT ==================== -->
	<script
		src="${pageContext.request.contextPath}/resources/bootstrap.bundle.min.js"></script>
	<script>
		function avaaMuokkaus() {
			document.getElementById('asiakas-katselu').classList.add('d-none')
			document.getElementById('asiakas-muokkaus').classList.remove('d-none')
		}

		function peruutaMuokkaus() {
			document.getElementById('asiakas-muokkaus').classList.add('d-none')
			document.getElementById('asiakas-katselu').classList.remove('d-none')
		}

		// ALUSTETAAN GLOBAALIT MODAL-OLIOT (Estää taustan jumiutumisen)
		const yhModalOlio = new bootstrap.Modal(document.getElementById('muokkaaYhModal'));
		const lokiModalOlio = new bootstrap.Modal(document.getElementById('muokkaaLokiModal'));
		const palveluModalOlio = new bootstrap.Modal(document.getElementById('muokkaaPalveluModal'));

		/* 1. Yhteyshenkilön muokkaustoiminto */
		document.querySelectorAll('.muokkaa-yh-btn').forEach(btn => {
			btn.addEventListener('click', function() {
				const id = this.getAttribute('data-id')
				const nimi = this.getAttribute('data-nimi')
				const rooli = this.getAttribute('data-rooli')
				const email = this.getAttribute('data-email')
				const puh = this.getAttribute('data-puh')
				
				const form = document.getElementById('muokkaaYhForm')
				form.action = '${pageContext.request.contextPath}/yhteyshenkilo/muokkaa/' + id
				
				document.getElementById('yhNimi').value = nimi
				document.getElementById('yhRooli').value = rooli
				document.getElementById('yhSahkoposti').value = email
				document.getElementById('yhPuhelin').value = puh
				
				yhModalOlio.show()
			})
		})
		
		/* 2. Lokimerkinnän muokkaustoiminto */
		document.querySelectorAll('.muokkaa-loki-btn').forEach(btn => {
			btn.addEventListener('click', function() {
				const id = this.getAttribute('data-id')
				const teksti = this.getAttribute('data-teksti')
				
				const form = document.getElementById('muokkaaLokiForm')
				form.action = '${pageContext.request.contextPath}/kirjaus/muokkaa/' + id
				
				document.getElementById('lokiTeksti').value = teksti
				
				lokiModalOlio.show()
			})
		})
		
		/* 3. Myydyn palvelun muokkaustoiminto nimen linkistä */
		document.querySelectorAll('.muokkaa-palvelu-linkki').forEach(linkki => {
			linkki.addEventListener('click', function(e) {
				e.preventDefault()
				
				const id = this.getAttribute('data-id')
				const tuoteNimi = this.getAttribute('data-tuote')
				const maara = this.getAttribute('data-maara')
				const hinta = this.getAttribute('data-hinta')
				const pvm = this.getAttribute('data-pvm')
				
				const form = document.getElementById('muokkaaPalveluForm')
				form.action = '${pageContext.request.contextPath}/palvelu/muokkaa/' + id
				
				document.getElementById('muokkaaPalveluNimi').value = tuoteNimi
				document.getElementById('muokkaaPalveluMaara').value = maara
				document.getElementById('muokkaaPalveluHinta').value = hinta
				document.getElementById('muokkaaPalveluPvm').value = pvm
				
				palveluModalOlio.show()
			})
		})
	</script>
</body>
</html>
