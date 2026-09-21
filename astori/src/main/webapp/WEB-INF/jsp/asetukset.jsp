<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html lang="fi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Asetukset - Astori</title>
<!-- Bootstrap tyylit resources-juuresta -->
<link
	href="${pageContext.request.contextPath}/resources/bootstrap.min.css"
	rel="stylesheet" />
<style>
body {
	background-color: #f8f9fa;
}

.settings-card {
	background: white;
	border-radius: 8px;
	padding: 24px;
	box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
	border: 1px solid #e3e6f0;
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
					class="nav-link active fw-bold"
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
		<h2 class="text-dark fw-bold mb-4">Järjestelmän asetukset</h2>

		<!-- ILMOITUKSET -->
		<c:if test="${param.virhe == 'tunnus_varattu'}">
			<div class="alert alert-danger alert-dismissible fade show fw-bold"
				role="alert">
				Virhe: Käyttäjätunnus on jo varattu järjestelmässä!
				<button type="button" class="btn-close" data-bs-dismiss="alert"
					aria-label="Close"></button>
			</div>
		</c:if>
		<c:if test="${param.success == 'company_updated'}">
			<div class="alert alert-success alert-dismissible fade show fw-bold"
				role="alert">
				✓ Yrityksen tiedot päivitetty onnistuneesti!
				<button type="button" class="btn-close" data-bs-dismiss="alert"
					aria-label="Close"></button>
			</div>
		</c:if>
		<c:if test="${param.success == 'user_created'}">
			<div class="alert alert-success alert-dismissible fade show fw-bold"
				role="alert">
				✓ Uusi käyttäjätunnus luotu onnistuneesti!
				<button type="button" class="btn-close" data-bs-dismiss="alert"
					aria-label="Close"></button>
			</div>
		</c:if>
		<c:if test="${param.success == 'user_updated'}">
			<div class="alert alert-success alert-dismissible fade show fw-bold"
				role="alert">
				✓ Käyttäjän tiedot ja käyttöoikeustaso päivitetty!
				<button type="button" class="btn-close" data-bs-dismiss="alert"
					aria-label="Close"></button>
			</div>
		</c:if>
		<c:if test="${param.success == 'product_created'}">
			<div class="alert alert-success alert-dismissible fade show fw-bold"
				role="alert">
				✓ Uusi tuote lisätty onnistuneesti tuoterekisteriin!
				<button type="button" class="btn-close" data-bs-dismiss="alert"
					aria-label="Close"></button>
			</div>
		</c:if>
		<c:if test="${param.success == 'product_updated'}">
			<div class="alert alert-success alert-dismissible fade show fw-bold"
				role="alert">
				✓ Tuotteen tiedot päivitetty onnistuneesti!
				<button type="button" class="btn-close" data-bs-dismiss="alert"
					aria-label="Close"></button>
			</div>
		</c:if>
		<c:if test="${param.success == 'kirjaustyyppi_created'}">
			<div class="alert alert-success alert-dismissible fade show fw-bold"
				role="alert">
				✓ Uusi asiakaskirjauksen hakuluokitus luotu onnistuneesti!
				<button type="button" class="btn-close" data-bs-dismiss="alert"
					aria-label="Close"></button>
			</div>
		</c:if>
		<c:if test="${param.success == 'kirjaustyyppi_updated'}">
			<div class="alert alert-success alert-dismissible fade show fw-bold"
				role="alert">
				✓ Asiakaskirjauksen hakuluokitus päivitetty!
				<button type="button" class="btn-close" data-bs-dismiss="alert"
					aria-label="Close"></button>
			</div>
		</c:if>

		<div class="row g-4">

			<!-- 👤 1. LAATIKKO: KÄYTTÄJÄHALLINTA (Oletuksena suljettu haitari) -->
			<div class="col-md-12">
				<div
					class="accordion shadow-sm border rounded-3 overflow-hidden bg-white mb-4"
					id="kayttajaPaaHaitari">
					<div class="accordion-item border-0">
						<h2 class="accordion-header m-0 p-0" id="kayttajaOtsikko">
							<button class="accordion-button collapsed fw-bold text-dark py-3"
								type="button" data-bs-toggle="collapse"
								data-bs-target="#kayttajaPaneeliRunko" aria-expanded="false"
								aria-controls="kayttajaPaneeliRunko">👤 Avaa / Sulje
								käyttäjätunnukset ja työntekijät</button>
						</h2>
						<div id="kayttajaPaneeliRunko" class="accordion-collapse collapse"
							aria-labelledby="kayttajaOtsikko"
							data-bs-parent="#kayttajaPaaHaitari">
							<div class="accordion-body p-4 bg-light">
								<div
									class="d-flex justify-content-between align-items-center mb-3">
									<h5 class="text-secondary mb-0 fw-bold h6">Käyttäjätunnusten
										hallinta</h5>
									<button type="button"
										class="btn btn-success fw-bold btn-sm px-3 shadow-sm"
										data-bs-toggle="modal" data-bs-target="#lisaaKayttajaModal">
										+ Luo uusi käyttäjätunnus</button>
								</div>
								<div class="table-responsive border rounded bg-white p-0">
									<table class="table table-hover align-middle mb-0">
										<thead class="table-light">
											<tr>
												<th>Käyttäjätunnus</th>
												<th>Nimi</th>
												<th>Sähköposti</th>
												<th>Puhelin</th>
												<th>Käyttötaso</th>
												<th class="text-end">Toiminnot</th>
											</tr>
										</thead>
										<tbody>
											<c:forEach var="k" items="${kayttajat}">
												<tr>
													<td><span
														class="badge bg-dark text-white fw-bold px-2 py-1">${k.kayttajatunnus}</span></td>
													<td><strong>${k.etunimi} ${k.sukunimi}</strong></td>
													<td>${k.sahkoposti}</td>
													<td class="text-secondary">${k.puhelin}</td>
													<td><span
														class="badge ${k.rooli == 'ADMIN' ? 'bg-danger' : 'bg-secondary'}">${k.rooli == 'ADMIN' ? 'Pääkäyttäjä' : 'Työntekijä'}</span></td>
													<td class="text-end">
														<button type="button"
															class="btn btn-sm btn-outline-primary rounded-pill px-3"
															data-bs-toggle="modal"
															data-bs-target="#muokkaaKayttajaModal${k.id}">Muokkaa</button>
													</td>
												</tr>
											</c:forEach>
										</tbody>
									</table>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
			<!-- /Käyttäjähallinta päättyy -->
			<!-- 📦 2. LAATIKKO: TUOTEREKISTERI JA PALVELUT (Oletuksena suljettu haitari) -->
			<div class="col-md-12">
				<div
					class="accordion shadow-sm border rounded-3 overflow-hidden bg-white mb-4"
					id="tuoteYleishaitari">
					<div class="accordion-item border-0">

						<!-- Klikattava pääotsikko (Oletuksena kiinni 'collapsed') -->
						<h2 class="accordion-header m-0 p-0" id="tuotePaaotsikko">
							<button class="accordion-button collapsed fw-bold text-dark py-3"
								type="button" data-bs-toggle="collapse"
								data-bs-target="#tuotePaneeliRunko" aria-expanded="false"
								aria-controls="tuotePaneeliRunko">📦 Avaa / Sulje
								tuoterekisterin hinnasto</button>
						</h2>

						<!-- Koko hinnastotaulukko (Oletuksena piilossa ilman 'show'-luokkaa) -->
						<div id="tuotePaneeliRunko"
							class="accordion-collapse collapse border-0 p-0 m-0 w-100"
							aria-labelledby="tuotePaaotsikko"
							data-bs-parent="#tuoteYleishaitari">
							<div class="table-responsive p-0 m-0 w-100 border-0">
								<table class="table table-hover align-middle mb-0 w-100">
									<thead class="table-light">
										<tr>
											<th>Nimi</th>
											<th>Kuvaus</th>
											<th>Yksikkö</th>
											<th class="text-end">Hinta (ALV 0%)</th>
											<th class="text-end">ALV-kanta</th>
											<th class="text-end">Hinta (Sis. ALV)</th>
											<th class="text-end">Toiminnot</th>
										</tr>
									</thead>
									<tbody>
										<c:forEach var="tuote" items="${tuotteet}">
											<tr>
												<td><strong>${tuote.nimi}</strong></td>
												<td class="text-secondary small">${tuote.kuvaus}</td>
												<td><span class="badge bg-light text-dark border">${tuote.yksikko.lyhenne}</span></td>
												<td class="text-end fw-bold text-dark">${tuote.hinta}€</td>
												<td class="text-end text-secondary">${tuote.alvKanta.prosenttiStr}%</td>
												<td class="text-end fw-bold text-primary">${tuote.verollinenHinta}€</td>
												<td class="text-end">
													<button type="button"
														class="btn btn-sm btn-outline-primary rounded-pill px-3"
														data-bs-toggle="modal"
														data-bs-target="#muokkaaTuoteModal${tuote.id}">Muokkaa</button>
												</td>
											</tr>
										</c:forEach>
									</tbody>
								</table>
							</div>
						</div>

					</div>
				</div>
			</div>
			<!-- /Tuoterekisteri päättyy -->

			<!-- 📝 3. LAATIKKO: ASIAKASKIRJAUSTEN TYYPIT / HAKULUOKITTELUT (Oletuksena suljettu haitari) -->
			<div class="col-md-12">
				<div
					class="accordion shadow-sm border rounded-3 overflow-hidden bg-white mb-4"
					id="kirjaustyyppiPaaHaitari">
					<div class="accordion-item border-0">

						<!-- Klikattava pääotsikko (Oletuksena kiinni 'collapsed') -->
						<h2 class="accordion-header m-0 p-0" id="kirjaustyyppiOtsikko">
							<button class="accordion-button collapsed fw-bold text-dark py-3"
								type="button" data-bs-toggle="collapse"
								data-bs-target="#kirjaustyyppiPaneeliRunko"
								aria-expanded="false" aria-controls="kirjaustyyppiPaneeliRunko">
								📝 Avaa / Sulje asiakaskirjausten tyypit (Hakuluokittelut)</button>
						</h2>

						<!-- Sisältörunko (Oletuksena piilossa ilman 'show'-luokkaa) -->
						<div id="kirjaustyyppiPaneeliRunko"
							class="accordion-collapse collapse"
							aria-labelledby="kirjaustyyppiOtsikko"
							data-bs-parent="#kirjaustyyppiPaaHaitari">
							<div class="accordion-body p-4 bg-light">

								<!-- LISÄYSLOMAKE -->
								<form
									action="${pageContext.request.contextPath}/asetukset/lisaa-kirjaustyyppi"
									method="post" class="row g-3 mb-4 align-items-end">
									<div class="col-md-5">
										<label for="lisaaKirjausNimi"
											class="form-label fw-semibold text-secondary small">Kirjaustyypin
											/ Hakuehdon nimi (esim. Koulutuskysely)</label> <input type="text"
											class="form-control form-control-sm" id="lisaaKirjausNimi"
											name="nimi" required
											placeholder="Käytetään hakuehtona järjestelmässä">
									</div>
									<div class="col-md-4">
										<label for="lisaaKirjausVari"
											class="form-label fw-semibold text-secondary small">Tunnusväri
											(Badge-väri)</label> <select name="vari" id="lisaaKirjausVari"
											class="form-select form-select-sm" required>
											<option value="#0d6efd">Sininen</option>
											<option value="#198754">Vihreä</option>
											<option value="#dc3545">Punainen</option>
											<option value="#ffc107">Keltainen</option>
											<option value="#fd7e14">Oranssi</option>
											<option value="#6f42c1">Violetti</option>
											<option value="#6c757d">Harmaa</option>
										</select>
									</div>
									<div class="col-md-3">
										<button type="submit"
											class="btn btn-sm btn-success w-100 fw-bold py-2 rounded-pill">+
											Luo uusi luokitus</button>
									</div>
								</form>

								<hr>

								<!-- TAULUKKOLISTAUS -->
								<div class="table-responsive border rounded bg-white p-0">
									<table class="table table-hover align-middle mb-0">
										<thead class="table-light">
											<tr>
												<th style="width: 250px;">Tunnusväri / Badge</th>
												<th>Status / Hakuehto</th>
												<th class="text-end">Toiminnot</th>
											</tr>
										</thead>
										<tbody>
											<c:forEach var="kt" items="${kaikkiKirjaustyypit}">
												<tr>
													<td><span class="badge text-white fw-bold px-3 py-1.5"
														style="background-color: ${kt.vari}; border-radius: 50px; font-size: 0.85rem;">
															${kt.nimi} </span></td>
													<td class="text-secondary small">Käytettävissä
														dynaamisena hakuehtona CRM-hauissa</td>
													<td class="text-end">
														<button type="button"
															class="btn btn-sm btn-outline-dark rounded-pill px-3"
															onclick="avaaKirjaustyypinMuokkaus('${kt.id}', '${kt.nimi}', '${kt.vari}')">Muokkaa</button>
													</td>
												</tr>
											</c:forEach>
											<c:if test="${empty kaikkiKirjaustyypit}">
												<tr>
													<td colspan="3" class="text-center text-muted py-3 italic">Järjestelmään
														ei ole vielä syötetty dynaamisia kirjaustyyppejä hakuja
														varten.</td>
												</tr>
											</c:if>
										</tbody>
									</table>
								</div>

							</div>
						</div>
					</div>
				</div>
			</div>
			<!-- /Asiakaskirjausten tyypit päättyy -->
			<!-- ⚙️ 4. LAATIKKO: OMAN YRITYKSEN TIEDOT (Oletuksena suljettu haitari) -->
			<div class="col-md-12">
				<div
					class="accordion shadow-sm border rounded-3 overflow-hidden bg-white mb-4"
					id="yritysPaaHaitari">
					<div class="accordion-item border-0">
						<h2 class="accordion-header m-0 p-0" id="yritysOtsikko">
							<button class="accordion-button collapsed fw-bold text-dark py-3"
								type="button" data-bs-toggle="collapse"
								data-bs-target="#yritysPaneeliRunko" aria-expanded="false"
								aria-controls="yritysPaneeliRunko">⚙️ Avaa / Sulje oman
								yrityksen tiedot (Tarjouspohjaan)</button>
						</h2>
						<div id="yritysPaneeliRunko" class="accordion-collapse collapse"
							aria-labelledby="yritysOtsikko"
							data-bs-parent="#yritysPaaHaitari">
							<div class="accordion-body p-4 bg-light">
								<form
									action="${pageContext.request.contextPath}/asetukset/tallenna-yritys"
									method="post">
									<div class="row">
										<div class="col-md-6 mb-3">
											<label class="form-label fw-semibold text-secondary small">Yrityksen
												nimi</label> <input type="text" class="form-control" name="nimi"
												value="${yritys != null ? yritys.nimi : ''}" required
												placeholder="esim. Yritys Oy">
										</div>
										<div class="col-md-6 mb-3">
											<label class="form-label fw-semibold text-secondary small">Y-tunnus</label>
											<input type="text" class="form-control" name="yTunnus"
												value="${yritys != null ? yritys.yTunnus : ''}" required
												placeholder="1234567-8">
										</div>
									</div>
									<div class="row">
										<div class="col-md-6 mb-3">
											<label class="form-label fw-semibold text-secondary small">Sähköposti</label>
											<input type="email" class="form-control" name="sahkoposti"
												value="${yritys != null ? yritys.sahkoposti : ''}"
												placeholder="laskutus@yritys.fi">
										</div>
										<div class="col-md-6 mb-3">
											<label class="form-label fw-semibold text-secondary small">Puhelinnumero</label>
											<input type="text" class="form-control" name="puhelin"
												value="${yritys != null ? yritys.puhelin : ''}"
												placeholder="040 123 4567">
										</div>
									</div>
									<div class="mb-3">
										<label class="form-label fw-semibold text-secondary small">Käynti-
											/ Postiosoite</label> <input type="text" class="form-control"
											name="osoite" value="${yritys != null ? yritys.osoite : ''}"
											placeholder="Koodikatu 1, 00100 Helsinki">
									</div>
									<div class="row">
										<div class="col-md-8 mb-3">
											<label class="form-label fw-semibold text-secondary small">Tilinumero
												(IBAN)</label> <input type="text" class="form-control" name="iban"
												value="${yritys != null ? yritys.iban : ''}"
												placeholder="FI12 3456 7890 1234 56">
										</div>
										<div class="col-md-4 mb-3">
											<label class="form-label fw-semibold text-secondary small">Pankin
												BIC-koodi</label> <input type="text" class="form-control" name="bic"
												value="${yritys != null ? yritys.bic : ''}"
												placeholder="AAAFIHH">
										</div>
									</div>
									<div class="text-end mt-2">
										<button type="submit"
											class="btn btn-primary fw-bold px-4 shadow-sm">Tallenna
											yrityksen tiedot</button>
									</div>
								</form>
							</div>
						</div>
					</div>
				</div>
			</div>
			<!-- /Yritystiedot päättyy -->


			<!-- /Varmuuskopiointi päättyy -->

			<!-- ⚙️ 6. LAATIKKO: KALENTERIN TAPAHTUMATYYPIT (Oletuksena suljettu haitari) -->
			<div class="col-md-12">
				<div
					class="accordion shadow-sm border rounded-3 overflow-hidden bg-white mb-4"
					id="kalenteriPaaHaitari">
					<div class="accordion-item border-0">
						<h2 class="accordion-header m-0 p-0" id="kalenteriOtsikko">
							<button class="accordion-button collapsed fw-bold text-dark py-3"
								type="button" data-bs-toggle="collapse"
								data-bs-target="#kalenteriPaneeliRunko" aria-expanded="false"
								aria-controls="kalenteriPaneeliRunko">⚙️ Avaa / Sulje
								kalenterin tapahtumatyypit</button>
						</h2>
						<div id="kalenteriPaneeliRunko"
							class="accordion-collapse collapse"
							aria-labelledby="kalenteriOtsikko"
							data-bs-parent="#kalenteriPaaHaitari">
							<div class="accordion-body p-4 bg-light">
								<form
									action="${pageContext.request.contextPath}/asetukset/lisaa-tyyppi"
									method="post" class="row g-3 mb-4 align-items-end">
									<div class="col-md-5">
										<label for="lisaaNimi"
											class="form-label fw-semibold text-secondary small">Selkokielinen
											nimi (esim. Etäkokous)</label> <input type="text"
											class="form-control form-control-sm" id="lisaaNimi"
											name="nimi" required
											placeholder="Näkyy käyttäjälle kalenterissa">
									</div>
									<div class="col-md-4">
										<label for="lisaaVari"
											class="form-label fw-semibold text-secondary small">Kalenteriväri</label>
										<select name="vari" id="lisaaVari"
											class="form-select form-select-sm" required>
											<option value="#0d6efd">Sininen</option>
											<option value="#dc3545">Punainen</option>
											<option value="#198754">Vihreä</option>
											<option value="#ffc107">Keltainen</option>
											<option value="#fd7e14">Oranssi</option>
											<option value="#6f42c1">Violetti</option>
										</select>
									</div>
									<div class="col-md-3">
										<button type="submit"
											class="btn btn-sm btn-primary w-100 fw-bold py-2 rounded-pill">+
											Lisää tyyppi</button>
									</div>
								</form>
								<hr>
								<div class="table-responsive border rounded bg-white">
									<table
										class="table table-hover table-striped align-middle mb-0 small">
										<thead class="table-light text-secondary">
											<tr>
												<th>Väri</th>
												<th>Tapahtumatyyppi</th>
												<th class="text-end">Toiminnot</th>
											</tr>
										</thead>
										<tbody>
											<c:forEach var="tt" items="${kaikkiTapahtumaTyypit}">
												<tr>
													<td><span
														class="d-inline-block rounded-circle shadow-sm border border-secondary border-opacity-25"
														style="width: 16px; height: 16px; background-color: ${tt.vari}; vertical-align: middle;"></span></td>
													<td class="fw-bold text-dark">${tt.nimi}</td>
													<td class="text-end">
														<button type="button"
															class="btn btn-sm btn-outline-dark rounded-pill px-3 fw-semibold"
															onclick="avaaTyypinMuokkaus('${tt.id}', '${tt.nimi}', '${tt.vari}')">Muokkaa</button>
													</td>
												</tr>
											</c:forEach>
										</tbody>
									</table>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
			<!-- /Kalenterityypit päättyy -->

		</div>
		<!-- /.row päättyy -->

		<!-- 💾 UUSI SIJOITUS: JÄRJESTELMÄN VARMUUSKOPIOINTI HAITAROINNIN ULKOPUOLELLA ALIMPANAN -->
		<div class="w-100 mt-2 mb-4">
			<div class="settings-card border-warning text-start"
				style="border-left: 5px solid #ffc107;">
				<h4 class="text-dark mb-2 fw-bold h5">💾 Järjestelmän
					varmuuskopiointi</h4>
				<p class="text-muted small mb-3">Varmista asiakasjärjestelmän
					tietoturva lataamalla täydellinen reaaliaikainen kopio
					PostgreSQL-tietokannastasi (.sql) yhdellä klikkauksella.</p>
				<a href="${pageContext.request.contextPath}/asetukset/varmuuskopio"
					class="btn btn-warning fw-bold text-dark px-4 shadow-sm"> Ota
					reaaliaikainen tietokantakopio (.sql) </a>
			</div>
		</div>

	</div>
	<!-- /.container päättyy -->
	<!-- BOOTSTRAP POP-UP LOMAKE UUDELLE KÄYTTÄJÄLLE -->
	<div class="modal fade" id="lisaaKayttajaModal" tabindex="-1"
		aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content border-0 shadow-lg">
				<div class="modal-header bg-success text-white">
					<h5 class="modal-title fw-bold">Luo uusi käyttäjätunnus</h5>
					<button type="button" class="btn-close btn-close-white"
						data-bs-dismiss="modal"></button>
				</div>
				<form
					action="${pageContext.request.contextPath}/asetukset/lisaa-kayttaja"
					method="post">
					<div class="modal-body p-4 text-start">
						<div class="row">
							<div class="col-md-6 mb-3">
								<label class="form-label fw-semibold text-secondary small">Käyttäjätunnus</label>
								<input type="text" class="form-control" name="tunnus" required>
							</div>
							<div class="col-md-6 mb-3">
								<label class="form-label fw-semibold text-secondary small">Salasana</label>
								<input type="password" class="form-control" name="salasana"
									required>
							</div>
						</div>
						<div class="row">
							<div class="col-md-6 mb-3">
								<label class="form-label fw-semibold text-secondary small">Etunimi</label>
								<input type="text" class="form-control" name="etunimi" required>
							</div>
							<div class="col-md-6 mb-3">
								<label class="form-label fw-semibold text-secondary small">Sukunimi</label>
								<input type="text" class="form-control" name="sukunimi" required>
							</div>
						</div>
						<div class="mb-3">
							<label class="form-label fw-semibold text-secondary small">Sähköposti</label>
							<input type="email" class="form-control" name="sahkoposti"
								required>
						</div>
						<div class="mb-3">
							<label class="form-label fw-semibold text-secondary small">Puhelin</label>
							<input type="text" class="form-control" name="puhelin" required>
						</div>
						<div class="mb-3">
							<label class="form-label fw-semibold text-secondary small">Käyttöoikeustaso</label>
							<select class="form-select" name="rooli" required>
								<option value="USER" selected>Työntekijä (USER)</option>
								<option value="ADMIN">Pääkäyttäjä (ADMIN)</option>
							</select>
						</div>
					</div>
					<div class="modal-footer bg-light">
						<button type="button" class="btn btn-secondary"
							data-bs-dismiss="modal">Peruuta</button>
						<button type="submit" class="btn btn-success px-4 fw-bold">Luo
							tunnukset</button>
					</div>
				</form>
			</div>
		</div>
	</div>

	<!-- POP-UP MODAL KALENTERITYYPIN NIMEN JA VÄRIN MUOKKAUKSELLE -->
	<div class="modal fade" id="muokkaaTyyppiModal" tabindex="-1"
		data-bs-backdrop="static" data-bs-keyboard="true" aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content border-0 shadow-lg">
				<div class="modal-header bg-dark text-white">
					<h5 class="modal-title fw-bold">Muokkaa tapahtumatyyppiä</h5>
					<button type="button" class="btn-close btn-close-white"
						data-bs-dismiss="modal"></button>
				</div>
				<form id="muokkaaTyyppiForm" method="post">
					<div class="modal-body p-4 text-start">
						<div class="mb-3">
							<label for="muokkaaNimi"
								class="form-label fw-semibold text-secondary small">Nimi</label>
							<input type="text" class="form-control" id="muokkaaNimi"
								name="nimi" required>
						</div>
						<div class="mb-3">
							<label for="muokkaaVari"
								class="form-label fw-semibold text-secondary small">Kalenteriväri</label>
							<select name="vari" id="muokkaaVari" class="form-select" required>
								<option value="#0d6efd">Sininen</option>
								<option value="#dc3545">Punainen</option>
								<option value="#198754">Vihreä</option>
								<option value="#ffc107">Keltainen</option>
								<option value="#fd7e14">Oranssi</option>
								<option value="#6f42c1">Violetti</option>
							</select>
						</div>
					</div>
					<div class="modal-footer bg-light d-flex justify-content-between">
						<button type="button"
							class="btn btn-sm btn-outline-secondary rounded-pill px-3"
							data-bs-dismiss="modal">Peruuta</button>
						<button type="submit"
							class="btn btn-sm btn-success rounded-pill px-4 fw-bold">Tallenna
							muutokset</button>
					</div>
				</form>
			</div>
		</div>
	</div>

	<!-- POP-UP MODAL ASIAKASKIRJAUSTYYPEILLE (HAKULUOKITTELUT) -->
	<div class="modal fade" id="muokkaaKirjaustyyppiModal" tabindex="-1"
		data-bs-backdrop="static" data-bs-keyboard="true" aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content border-0 shadow-lg">
				<div class="modal-header bg-dark text-white">
					<h5 class="modal-title fw-bold">Muokkaa kirjaustyyppiä /
						hakuehtoa</h5>
					<button type="button" class="btn-close btn-close-white"
						data-bs-dismiss="modal"></button>
				</div>
				<form id="muokkaaKirjaustyyppiForm" method="post">
					<div class="modal-body p-4 text-start">
						<div class="mb-3">
							<label for="muokkaaKirjausNimiField"
								class="form-label fw-semibold text-secondary small">Nimi
								/ Hakuehto</label> <input type="text" class="form-control"
								id="muokkaaKirjausNimiField" name="nimi" required>
						</div>
						<div class="mb-3">
							<label for="muokkaaKirjausVariField"
								class="form-label fw-semibold text-secondary small">Tunnusväri</label>
							<select name="vari" id="muokkaaKirjausVariField"
								class="form-select" required>
								<option value="#0d6efd">Sininen</option>
								<option value="#198754">Vihreä</option>
								<option value="#dc3545">Punainen</option>
								<option value="#ffc107">Keltainen</option>
								<option value="#fd7e14">Oranssi</option>
								<option value="#6f42c1">Violetti</option>
								<option value="#6c757d">Harmaa</option>
							</select>
						</div>
					</div>
					<div class="modal-footer bg-light d-flex justify-content-between">
						<button type="button"
							class="btn btn-sm btn-outline-secondary rounded-pill px-3"
							data-bs-dismiss="modal">Peruuta</button>
						<button type="submit"
							class="btn btn-sm btn-success rounded-pill px-4 fw-bold">Tallenna
							muutokset</button>
					</div>
				</form>
			</div>
		</div>
	</div>

	<!-- BOOTSTRAP 5 CORE SCRIPT -->
	<script
		src="${pageContext.request.contextPath}/resources/bootstrap.bundle.min.js"></script>

	<script>
		function avaaTyypinMuokkaus(id, nimi, vari) {
			var form = document.getElementById('muokkaaTyyppiForm');
			if (form)
				form.action = "${pageContext.request.contextPath}/asetukset/muokkaa-typpia/"
						+ id;
			if (document.getElementById('muokkaaNimi'))
				document.getElementById('muokkaaNimi').value = nimi;
			if (document.getElementById('muokkaaVari'))
				document.getElementById('muokkaaVari').value = vari
						|| "#0d6efd";
			var muokkaaModal = new bootstrap.Modal(document
					.getElementById('muokkaaTyyppiModal'));
			muokkaaModal.show();
		}

		function avaaKirjaustyypinMuokkaus(id, nimi, vari) {
			var form = document.getElementById('muokkaaKirjaustyyppiForm');
			if (form)
				form.action = "${pageContext.request.contextPath}/asetukset/muokkaa-kirjaustyyppia/"
						+ id;
			if (document.getElementById('muokkaaKirjausNimiField'))
				document.getElementById('muokkaaKirjausNimiField').value = nimi;
			if (document.getElementById('muokkaaKirjausVariField'))
				document.getElementById('muokkaaKirjausVariField').value = vari
						|| "#0d6efd";
			var muokkaaModal = new bootstrap.Modal(document
					.getElementById('muokkaaKirjaustyyppiModal'));
			muokkaaModal.show();
		}
	</script>
</body>
</html>
