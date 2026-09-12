<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="fi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Asetukset - Astori</title>
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
	padding: 20px;
	box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
	border: 1px solid #dee2e6;
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
				<a class="nav-link" href="${pageContext.request.contextPath}/">Asiakkaat</a>
				<a class="nav-link active fw-bold"
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

		<!-- JOS TUNNUS ON VARATTU, NÄYTETÄÄN VIRHE -->
		<c:if test="${param.virhe == 'tunnus_varattu'}">
			<div class="alert alert-danger alert-dismissible fade show fw-bold"
				role="alert">
				Virhe: Käyttäjätunnus on jo varattu järjestelmässä!
				<button type="button" class="btn-close" data-bs-dismiss="alert"
					aria-label="Close"></button>
			</div>
		</c:if>

		<!-- ILMOITUS: YRITYSTIEDOT TALLENNETTU -->
		<c:if test="${param.tallennettu == 'true'}">
			<div class="alert alert-success alert-dismissible fade show fw-bold"
				role="alert">
				✓ Yrityksen tiedot päivitetty onnistuneesti!
				<button type="button" class="btn-close" data-bs-dismiss="alert"
					aria-label="Close"></button>
			</div>
		</c:if>

		<!-- ILMOITUKSET KÄYTTÄJÄHALLINNASTA -->
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

		<div class="row g-4">
			<!-- TUOTEHALLINTA ALKAA -->
			<div class="col-md-12">
				<div class="settings-card mb-4">
					<div class="d-flex justify-content-between align-items-center mb-3">
						<h4 class="text-secondary mb-0 fw-bold">Tuoterekisteri ja
							Palvelut</h4>
						<a href="${pageContext.request.contextPath}/asetukset/lisaa-tuote"
							class="btn btn-primary fw-bold btn-sm px-3 shadow-sm"> +
							Lisää uusi tuote </a>
					</div>
					<div class="table-responsive border rounded bg-white p-0">
						<table class="table table-hover align-middle mb-0">
							<thead class="table-light">
								<tr>
									<th>ID</th>
									<th>Nimi</th>
									<th>Kuvaus</th>
									<th>Yksikkö</th>
									<th class="text-end">Hinta (ALV 0%)</th>
									<th class="text-end">ALV-kanta</th>
									<th class="text-end">Hinta (Sis. ALV)</th>
									<th></th>
								</tr>
							</thead>
							<tbody>
								<c:forEach var="tuote" items="${tuotteet}">
									<tr>
										<td class="text-muted">#${tuote.id}</td>
										<td><strong>${tuote.nimi}</strong></td>
										<td class="text-secondary">${tuote.kuvaus}</td>
										<td><span class="badge bg-light text-dark border">${tuote.yksikko.lyhenne}</span></td>
										<td class="text-end fw-bold text-dark">${tuote.hinta}€</td>
										<td class="text-end text-secondary">${tuote.alvKanta.prosenttiStr}
											%</td>
										<td class="text-end fw-bold text-primary">${tuote.verollinenHinta}
											€</td>
										<td class="text-end">
											<!-- MUOKKAA-PAINIKE -->
											<button type="button"
												class="btn btn-sm btn-outline-primary rounded-pill px-3"
												data-bs-toggle="modal"
												data-bs-target="#muokkaaTuoteModal${tuote.id}">
												Muokkaa</button>
										</td>
									</tr>

									<!-- DYNAAMINEN MODAL-IKKUNA TUOTTEEN MUOKKAUSTA VARTEN -->
									<div class="modal fade" id="muokkaaTuoteModal${tuote.id}"
										tabindex="-1" aria-hidden="true">
										<div class="modal-dialog modal-dialog-centered">
											<div class="modal-content border-0 shadow-lg">
												<div class="modal-header bg-primary text-white">
													<h5 class="modal-title fw-bold">Muokkaa tuotetta:
														${tuote.nimi}</h5>
													<button type="button" class="btn-close btn-close-white"
														data-bs-dismiss="modal"></button>
												</div>
												<form
													action="${pageContext.request.contextPath}/asetukset/muokkaa-tuotetta/${tuote.id}"
													method="post">
													<div class="modal-body p-4">
														<div class="mb-3">
															<label class="form-label small fw-bold text-secondary">Tuotteen
																/ Palvelun nimi</label> <input type="text" class="form-control"
																name="nimi" value="${tuote.nimi}" required>
														</div>
														<div class="mb-3">
															<label class="form-label small fw-bold text-secondary">Kuvaus</label>
															<textarea class="form-control" name="kuvaus" rows="3">${tuote.kuvaus}</textarea>
														</div>
														<div class="row">
															<div class="col-md-4 mb-3">
																<label class="form-label small fw-bold text-secondary">Hinta
																	(€)</label> <input type="number" step="0.01" min="0"
																	class="form-control" name="hinta"
																	value="${tuote.hinta}" required>
															</div>

															<div class="col-md-4 mb-3">
																<label class="form-label small fw-bold text-secondary">Yksikkö</label>
																<select class="form-select" name="yksikko" required>
																	<c:forEach var="y" items="${yksikot}">
																		<option value="${y.name()}"
																			${tuote.yksikko == y ? 'selected' : ''}>
																			${y.lyhenne}</option>
																	</c:forEach>
																</select>
															</div>

															<div class="col-md-4 mb-3">
																<label class="form-label small fw-bold text-secondary">ALV-kanta</label>
																<select class="form-select" name="alvKanta" required>
																	<c:forEach var="kanta" items="${alvKannat}">
																		<option value="${kanta.name()}"
																			${tuote.alvKanta == kanta ? 'selected' : ''}>
																			${kanta.nayttorivi}</option>
																	</c:forEach>
																</select>
															</div>

														</div>
													</div>
													<div class="modal-footer bg-light">
														<button type="button" class="btn btn-secondary"
															data-bs-dismiss="modal">Peruuta</button>
														<button type="submit" class="btn btn-primary fw-bold px-4">Tallenna
															muutokset</button>
													</div>
												</form>
											</div>
										</div>
									</div>
								</c:forEach>
								<c:if test="${empty tuotteet}">
									<tr>
										<td colspan="8" class="text-center py-3 text-muted">Rekisterissä
											ei ole vielä tuotteita.</td>
									</tr>
								</c:if>
							</tbody>
						</table>
					</div>
				</div>
				<div class="col-md-12">
					<div class="settings-card mb-4 border-warning"
						style="border-left: 5px solid #ffc107;">
						<h4 class="text-dark mb-2 fw-bold">Järjestelmän
							varmuuskopiointi</h4>
						<p class="text-muted small mb-3">Varmista asiakasjärjestelmän
							tietoturva lataamalla täydellinen reaaliaikainen kopio
							PostgreSQL-tietokannastasi (.sql).</p>
						<a
							href="${pageContext.request.contextPath}/asetukset/varmuuskopio"
							class="btn btn-warning fw-bold text-dark px-4 shadow-sm"> 💾
							Ota tietokannan varmuuskopio (.sql) </a>
					</div>
				</div>
			</div>

			<!-- KORTTI: KALENTERIN TAPAHTUMATYYPIT -->
			<div class="card shadow-sm my-4 border">
				<div class="card-header bg-dark text-white p-3">
					<h5 class="mb-0 fw-bold">⚙️ Kalenterin tapahtumatyypit</h5>
				</div>
				<div class="card-body p-4">

					<!-- LISÄYSLOMAKE -->
					<form
						action="${pageContext.request.contextPath}/asetukset/lisaa-tyyppi"
						method="post" class="row g-3 mb-4 align-items-end">
						<div class="col-md-5">
							<label for="lisaaNimi"
								class="form-label fw-semibold text-secondary small">Selkokielinen
								nimi (esim. Etäkokous)</label> <input type="text"
								class="form-control form-control-sm" id="lisaaNimi" name="nimi"
								required placeholder="Näkyy käyttäjälle järjestelmässä">
						</div>
						<!-- UUSI: Värivalinta lisäykseen -->
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

					<!-- TAULUKKOLISTAUS -->
					<div class="table-responsive">
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
											style="width: 16px; height: 16px; background-color: ${tt.vari}; vertical-align: middle;">
										</span></td>
										<td class="fw-bold text-dark">${tt.nimi}</td>
										<td class="text-end">
											<!-- Triggeröi muokkausmodalin ja ajaa päivitetyn JS-alustuksen (lisätty tt.vari) -->
											<button type="button"
												class="btn btn-sm btn-outline-dark rounded-pill px-3 fw-semibold"
												onclick="avaaTyypinMuokkaus('${tt.id}', '${tt.nimi}', '${tt.vari}')">
												Muokkaa</button>
										</td>
									</tr>
								</c:forEach>
								<c:if test="${empty kaikkiTapahtumaTyypit}">
									<tr>
										<td colspan="4" class="text-center text-muted py-3 italic">Järjestelmään
											ei ole vielä syötetty dynaamisia tapahtumatyyppejä.</td>
									</tr>
								</c:if>
							</tbody>
						</table>
					</div>
				</div>
			</div>

			<!-- POP-UP MODAL TYYPIN NIMEN JA VÄRIN MUOKKAUKSELLE -->
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
							<div class="modal-body p-4">
								<div class="mb-3">
									<label for="muokkaaNimi"
										class="form-label fw-semibold text-secondary small">Nimi</label>
									<input type="text" class="form-control" id="muokkaaNimi"
										name="nimi" required>
								</div>
								<!-- UUSI: Värivalinta muokkaukseen -->
								<div class="mb-3">
									<label for="muokkaaVari"
										class="form-label fw-semibold text-secondary small">Kalenteriväri</label>
									<select name="vari" id="muokkaaVari" class="form-select"
										required>
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


			<!-- POP-UP MODAL TYYPIN NIMEN MUOKKAUKSELLE -->
			<div class="modal fade" id="muokkaaTyyppiModal" tabindex="-1"
				data-bs-backdrop="static" data-bs-keyboard="true" aria-hidden="true">
				<div class="modal-dialog modal-dialog-centered">
					<div class="modal-content border-0 shadow-lg">
						<div class="modal-header bg-dark text-white">
							<h5 class="modal-title fw-bold">Muokkaa nimeä</h5>
							<button type="button" class="btn-close btn-close-white"
								data-bs-dismiss="modal"></button>
						</div>
						<form id="muokkaaTyyppiForm" method="post">
							<div class="modal-body p-4">
								<div class="mb-3">
									<label for="muokkaaNimi"
										class="form-label fw-semibold text-secondary">Uusi
										nimi</label> <input type="text" class="form-control" id="muokkaaNimi"
										name="nimi" required>
								</div>
							</div>
							<div class="modal-footer bg-light">
								<button type="button" class="btn btn-secondary"
									data-bs-dismiss="modal">Peruuta</button>
								<button type="submit" class="btn btn-success px-4 fw-bold">Tallenna
									muutokset</button>
							</div>
						</form>
					</div>
				</div>
			</div>


			<!-- OMAN YRITYKSEN TIEDOT -->
			<div class="col-md-12">
				<div class="settings-card mb-4">
					<h4 class="text-secondary mb-3 fw-bold">Oman yrityksen tiedot
						(Tarjouspohjaan)</h4>
					<form
						action="${pageContext.request.contextPath}/asetukset/tallenna-yritys"
						method="post">
						<div class="row">
							<div class="col-md-6 mb-3">
								<label class="form-label fw-semibold text-secondary">Yrityksen
									nimi</label> <input type="text" class="form-control" name="nimi"
									value="${yritys.nimi}" required placeholder="esim. Yritys Oy">
							</div>
							<div class="col-md-6 mb-3">
								<label class="form-label fw-semibold text-secondary">Y-tunnus</label>
								<input type="text" class="form-control" name="yTunnus"
									value="${yritys.yTunnus}" required placeholder="1234567-8">
							</div>
						</div>
						<div class="row">
							<div class="col-md-6 mb-3">
								<label class="form-label fw-semibold text-secondary">Sähköposti</label>
								<input type="email" class="form-control" name="sahkoposti"
									value="${yritys.sahkoposti}" placeholder="laskutus@yritys.fi">
							</div>
							<div class="col-md-6 mb-3">
								<label class="form-label fw-semibold text-secondary">Puhelinnumero</label>
								<input type="text" class="form-control" name="puhelin"
									value="${yritys.puhelin}" placeholder="040 123 4567">
							</div>
						</div>
						<div class="mb-3">
							<label class="form-label fw-semibold text-secondary">Käynti-
								/ Postiosoite</label> <input type="text" class="form-control"
								name="osoite" value="${yritys.osoite}"
								placeholder="Koodikatu 1, 00100 Helsinki">
						</div>
						<div class="row">
							<div class="col-md-8 mb-3">
								<label class="form-label fw-semibold text-secondary">Tilinumero
									(IBAN)</label> <input type="text" class="form-control" name="iban"
									value="${yritys.iban}" placeholder="FI12 3456 7890 1234 56">
							</div>
							<div class="col-md-4 mb-3">
								<label class="form-label fw-semibold text-secondary">Pankin
									BIC-koodi</label> <input type="text" class="form-control" name="bic"
									value="${yritys.bic}" placeholder="AAAFIHH">
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

			<!-- KÄYTTÄJÄHALLINTA -->
			<div class="col-md-12">
				<div class="settings-card">
					<div class="d-flex justify-content-between align-items-center mb-3">
						<h4 class="text-secondary mb-0 fw-bold">Käyttäjät ja
							Työntekijät</h4>
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
											class="badge ${k.rooli == 'ADMIN' ? 'bg-danger' : 'bg-secondary'}">
												${k.rooli == 'ADMIN' ? 'Pääkäyttäjä (Admin)' : 'Työntekijä'}
										</span></td>
										<td class="text-end">
											<button type="button"
												class="btn btn-sm btn-outline-primary rounded-pill px-3"
												data-bs-toggle="modal"
												data-bs-target="#muokkaaKayttajaModal${k.id}">
												Muokkaa</button>
										</td>
									</tr>

									<!-- MODAL-IKKUNA JOKAISEN KÄYTTÄJÄN MUOKKAUSTA VARTEN -->
									<div class="modal fade" id="muokkaaKayttajaModal${k.id}"
										tabindex="-1" aria-hidden="true">
										<div class="modal-dialog modal-dialog-centered">
											<div class="modal-content border-0 shadow-lg">
												<div class="modal-header bg-primary text-white">
													<h5 class="modal-title fw-bold">Muokkaa käyttäjää:
														${k.kayttajatunnus}</h5>
													<button type="button" class="btn-close btn-close-white"
														data-bs-dismiss="modal"></button>
												</div>
												<form
													action="${pageContext.request.contextPath}/asetukset/muokkaa-kayttajaa/${k.id}"
													method="post">
													<div class="modal-body p-4">
														<div class="row">
															<div class="col-md-6 mb-3">
																<label class="form-label small fw-bold text-secondary">Etunimi</label>
																<input type="text" class="form-control" name="etunimi"
																	value="${k.etunimi}" required>
															</div>
															<div class="col-md-6 mb-3">
																<label class="form-label small fw-bold text-secondary">Sukunimi</label>
																<input type="text" class="form-control" name="sukunimi"
																	value="${k.sukunimi}" required>
															</div>
														</div>
														<div class="mb-3">
															<label class="form-label small fw-bold text-secondary">Sähköposti</label>
															<input type="email" class="form-control"
																name="sahkoposti" value="${k.sahkoposti}" required>
														</div>
														<div class="mb-3">
															<label class="form-label small fw-bold text-secondary">Puhelinnumero</label>
															<input type="text" class="form-control" name="puhelin"
																value="${k.puhelin}" required>
														</div>
														<div class="mb-3">
															<label class="form-label small fw-bold text-secondary">Käyttöoikeustaso</label>
															<select class="form-select" name="rooli" required>
																<option value="USER"
																	${k.rooli == 'USER' ? 'selected' : ''}>Työntekijä
																	(USER)</option>
																<option value="ADMIN"
																	${k.rooli == 'ADMIN' ? 'selected' : ''}>Pääkäyttäjä
																	(ADMIN)</option>
															</select>
														</div>
													</div>
													<div class="modal-footer bg-light">
														<button type="button" class="btn btn-secondary"
															data-bs-dismiss="modal">Peruuta</button>
														<button type="submit" class="btn btn-primary fw-bold px-4">Tallenna
															muutokset</button>
													</div>
												</form>
											</div>
										</div>
									</div>
								</c:forEach>
							</tbody>
						</table>
					</div>
				</div>
			</div>
		</div>
	</div>

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
					<div class="modal-body p-4">
						<div class="row">
							<div class="col-md-6 mb-3">
								<label class="form-label fw-semibold text-secondary">Käyttäjätunnus</label>
								<input type="text" class="form-control" name="tunnus" required
									placeholder="esim. matti">
							</div>
							<div class="col-md-6 mb-3">
								<label class="form-label fw-semibold text-secondary">Salasana</label>
								<input type="password" class="form-control" name="salasana"
									required placeholder="••••••••">
							</div>
						</div>
						<div class="row">
							<div class="col-md-6 mb-3">
								<label class="form-label fw-semibold text-secondary">Etunimi</label>
								<input type="text" class="form-control" name="etunimi" required
									placeholder="Matti">
							</div>
							<div class="col-md-6 mb-3">
								<label class="form-label fw-semibold text-secondary">Sukunimi</label>
								<input type="text" class="form-control" name="sukunimi" required
									placeholder="Meikäläinen">
							</div>
						</div>
						<div class="mb-3">
							<label class="form-label fw-semibold text-secondary">Sähköposti</label>
							<input type="email" class="form-control" name="sahkoposti"
								required placeholder="matti@astori.fi">
						</div>
						<div class="mb-3">
							<label class="form-label fw-semibold text-secondary">Puhelin</label>
							<input type="text" class="form-control" name="puhelin" required
								placeholder="040 123 4567">
						</div>
						<div class="mb-3">
							<label class="form-label fw-semibold text-secondary">Käyttöoikeustaso</label>
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

	<!-- Lataa paikallisen Bootstrap-JavaScriptin suoraan resources-juuresta -->
	<script
		src="${pageContext.request.contextPath}/resources/bootstrap.bundle.min.js"></script>


	<!-- Scriptit -->
	<script>
		function avaaTyypinMuokkaus(id, nimi, vari) {
			// Asetetaan lomakkeen kohde-URL ääkkösettömään reittiin
			var form = document.getElementById('muokkaaTyyppiForm');
			if (form) {
				form.action = "${pageContext.request.contextPath}/asetukset/muokkaa-typpia/"
						+ id;
			}

			// Täytetään nimen arvo kenttään
			var nimiKentta = document.getElementById('muokkaaNimi');
			if (nimiKentta) {
				nimiKentta.value = nimi;
			}

			// UUSI: Täytetään tallennettu värikoodi valituksi pudotusvalikkoon
			var variSelect = document.getElementById('muokkaaVari');
			if (variSelect) {
				variSelect.value = vari || "#0d6efd"; // Oletuksena sininen jos väriä ei löydy
			}

			// Avataan modal-ikkuna ohjelmallisesti
			var muokkaaModal = new bootstrap.Modal(document
					.getElementById('muokkaaTyyppiModal'));
			muokkaaModal.show();
		}
	</script>


</body>
</html>
