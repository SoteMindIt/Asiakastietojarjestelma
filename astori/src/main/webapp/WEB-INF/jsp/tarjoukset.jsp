<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
	<%@ taglib prefix="c" uri="jakarta.tags.core" %>
		<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
			<!DOCTYPE html>
			<html lang="fi">

			<head>
				<meta charset="UTF-8">
				<meta name="viewport" content="width=device-width, initial-scale=1.0">
				<title>Tarjouslaskenta - ${asiakas.nimi}</title>
				<!-- Käytetään paikallista Bootstrapia -->
				<link href="${pageContext.request.contextPath}/resources/bootstrap.min.css" rel="stylesheet" />
				<style>
					body {
						background-color: #f8f9fa;
					}

					.main-card {
						background: white;
						border-radius: 8px;
						padding: 25px;
						box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
					}

					.summary-box {
						background: #f1f3f5;
						border-radius: 6px;
						padding: 15px;
						max-width: 350px;
						margin-left: auto;
					}
				</style>
			</head>

			<body>

				<!-- YLÄPALKKI -->
				<nav class="navbar navbar-expand-lg navbar-dark bg-dark mb-4 shadow-sm">
					<div class="container">
						<a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/">Astori</a>

						<div class="navbar-nav me-auto">
							<a class="nav-link" href="${pageContext.request.contextPath}/">Etusivu</a>
							<a class="nav-link" href="${pageContext.request.contextPath}/asiakkaat">Asiakkaat</a>
							<a class="nav-link" href="${pageContext.request.contextPath}/asetukset">Asetukset</a>
							<a class="nav-link" href="${pageContext.request.contextPath}/raportit">Raportit</a>
							<a class="nav-link" href="${pageContext.request.contextPath}/kalenteri">Kalenteri</a>
						</div>

						<div class="d-flex align-items-center">
							<span class="navbar-text text-white me-3">Käyttäjä:
								<strong>${kirjautunutKayttaja}</strong></span>
							<a href="${pageContext.request.contextPath}/logout"
								class="btn btn-outline-danger btn-sm">Kirjaudu ulos</a>
						</div>
					</div>
				</nav>

				<div class="container py-2">

					<c:if test="${not empty virheViesti}">
						<div class="alert alert-danger alert-dismissible fade show fw-bold mb-3" role="alert">
							${virheViesti}</div>
					</c:if>

					<!-- TAKAISIN-LINKKI -->
					<div class="mb-3">
						<a class="btn btn-link p-0 text-decoration-none"
							href="${pageContext.request.contextPath}/asiakas/${asiakas.id}">&larr;
							Takaisin asiakasprofiiliin</a>
					</div>

					<div class="main-card border mb-4">
						<span class="text-muted small">Asiakkaan tarjoushallinta</span>
						<h1 class="text-dark fw-bold mb-3">${asiakas.nimi}</h1>

						<h3 class="fw-bold h5 text-secondary mt-4 mb-3">Aiemmat tarjoukset</h3>
						<c:choose>
							<c:when test="${empty tarjoukset}">
								<div class="alert alert-info">Ei aiempia tallennettuja tarjouksia tälle asiakkaalle.
								</div>
							</c:when>
							<c:otherwise>
								<div class="table-responsive">
									<table class="table table-striped align-middle border">
										<thead class="table-light">
											<tr>
												<th>Tarjousnumero</th>
												<th>Päivämäärä</th>
												<th>Voimassaolo</th>
												<th>Veroton (€)</th>
												<th>ALV (€)</th>
												<th>Loppusumma (€)</th>
												<th>Toiminnot</th>
											</tr>
										</thead>
										<tbody>
											<c:forEach items="${tarjoukset}" var="t">
												<tr>
													<td><strong>${t.tarjousNumero}</strong></td>
													<td>${t.pvm}</td>
													<td>${t.voimassaoloPvm}</td>
													<td>
														<fmt:formatNumber value="${t.verotonYhteensa}"
															pattern="#,##0.00 €" />
													</td>
													<td>
														<fmt:formatNumber value="${t.alvYhteensa}"
															pattern="#,##0.00 €" />
													</td>
													<td><strong class="text-success">
															<fmt:formatNumber value="${t.verollinenYhteensa}"
																pattern="#,##0.00 €" />
														</strong></td>
													<td>
														<div class="d-flex gap-2">
															<a class="btn btn-sm btn-primary fw-bold"
																href="${pageContext.request.contextPath}/tarjous/${t.id}/lataa-pdf">Lataa
																PDF</a>
															<form
																action="${pageContext.request.contextPath}/tarjous/${t.id}/poista"
																method="post" style="display: inline;"
																onsubmit="return confirm('Haluatko varmasti poistaa tarjouksen ${t.tarjousNumero}?');">
																<button type="submit"
																	class="btn btn-sm btn-danger fw-bold">Poista</button>
															</form>
														</div>
													</td>
												</tr>
											</c:forEach>
										</tbody>
									</table>
								</div>
							</c:otherwise>
						</c:choose>
					</div>

					<!-- UUDEN TARJOUKSEN LASKENTA JA LUONTI -->
					<div class="main-card border">
						<h3 class="fw-bold h4 mb-4 text-dark">Luo uusi tarjouslaskelma</h3>
						<form action="${pageContext.request.contextPath}/asiakkaat/${asiakas.id}/tarjoukset/tallenna"
							method="post">

							<div class="row g-3 mb-4">
								<div class="col-md-6">
									<label class="form-label fw-bold">Tarjousnumero:</label>
									<input type="text" class="form-control" name="tarjousNumero" required
										placeholder="esim. T-2026-001">
								</div>
								<div class="col-md-6">
									<label class="form-label fw-bold">Voimassaolopäivä:</label>
									<input type="date" class="form-control" name="voimassaoloPvm" required>
								</div>
							</div>

							<div class="mb-4">
								<label class="form-label fw-bold">Tarjouksen kuvaus / Lisätiedot:</label>
								<textarea class="form-control" name="lisatiedot" rows="4"
									placeholder="Kirjoita tähän tarkempi kuvaus palvelun sisällöstä, aikataulusta tai muista ehdoista..."></textarea>
							</div>

							<h4 class="fw-bold h5 mb-3 text-secondary">Tarjousrivit</h4>
							<div class="table-responsive">
								<table class="table border" id="rivit-table">
									<thead class="table-light">
										<tr>
											<th>Valitse tuote rekisteristä / Kirjoita nimi</th>
											<th style="width: 120px;">Määrä</th>
											<th style="width: 140px;">Yksikköhinta (€)</th>
											<th style="width: 130px;">ALV %</th>
											<th style="width: 100px;">Toiminnot</th>
										</tr>
									</thead>
									<tbody>
										<tr>
											<td>
												<select class="form-select" name="tuote[]" required
													onchange="paivitaRivinHinta(this)">
													<option value="" data-hinta="0">-- Valitse tuote --</option>
													<c:forEach var="tuote" items="${tuoteLista}">
														<option value="${tuote.nimi}" data-hinta="${tuote.hinta}">
															${tuote.nimi} (${tuote.hinta} €)</option>
													</c:forEach>
												</select>
											</td>
											<td><input type="number" class="form-control" name="maara[]" value="1"
													step="any" required oninput="laskeYhteissummat()"></td>
											<td><input type="number" class="form-control" name="hinta[]" step="any"
													required oninput="laskeYhteissummat()"></td>
											<td>
												<select class="form-select" name="alv[]" onchange="laskeYhteissummat()">
													<option value="25.5">25.5 %</option>
													<option value="14.0">14.0 %</option>
													<option value="10.0">10.0 %</option>
													<option value="0.0">0.0 %</option>
												</select>
											</td>
											<td><button type="button" class="btn btn-outline-danger w-100"
													onclick="poistaRivi(this)">Poista</button></td>
										</tr>
									</tbody>
								</table>
							</div>

							<div class="d-flex justify-content-between align-items-start mt-3">
								<button type="button" class="btn btn-outline-primary fw-bold" onclick="lisaaRivi()">+
									Lisää uusi rivi</button>



								<!-- TÄSTÄ ALKAA UUSI SIVUTETTU JA KORJATTU PÄIVITYS -->
								<div class="d-flex justify-content-between align-items-start flex-wrap gap-3 mt-3">
									<button type="button" class="btn btn-outline-primary fw-bold rounded-pill px-4"
										onclick="lisaaRivi()">
										➕ Lisää uusi rivi
									</button>

									<div class="summary-box border shadow-sm bg-light p-3 rounded-3"
										style="min-width: 300px;">
										<div class="d-flex justify-content-between mb-1 small text-secondary">
											<span>Veroton yhteensä:</span>
											<span id="summa-veroton" class="fw-bold text-dark">0,00 €</span>
										</div>
										<div class="d-flex justify-content-between mb-2 small text-secondary">
											<span>ALV yhteensä:</span>
											<span id="summa-alv" class="fw-bold text-dark">0,00 €</span>
										</div>
										<div class="d-flex justify-content-between border-top pt-2">
											<span class="fw-bold text-dark h6 mb-0">Loppusumma:</span>
											<span id="summa-verollinen" class="fw-bold text-success h5 mb-0">0,00
												€</span>
										</div>
									</div>
								</div>

								<div class="mt-4 border-top pt-3 text-end">
									<button type="submit"
										class="btn btn-success btn-lg fw-bold px-5 rounded-pill shadow-sm">
										💾 Tallenna ja laske tarjous
									</button>
								</div>
						</form>
					</div>
				</div>

				<!-- REAALIAIKAINEN LASKENTALOGIIKKA JA AUTOMAATTINEN HINNAN PAIVITYS -->
				<script>
					// 1. Hakee valitun tuotteen hinnan rekisteristä ja päivittää sen riville
					function paivitaRivinHinta(selectElement) {
						var valittuOption = selectElement.options[selectElement.selectedIndex];
						var hinta = valittuOption.getAttribute('data-hinta') || 0;
						var rivi = selectElement.closest('tr');
						var hintaInput = rivi.querySelector('input[name="hinta[]"]');
						if (hintaInput) {
							hintaInput.value = hinta;
						}
						laskeYhteissummat();
					}

					// 2. Laskee kaikkien rivien summat reaaliaikaisesti yhteenvetolaatikkoon
					function laskeYhteissummat() {
						var verotonYhteensa = 0;
						var alvYhteensa = 0;
						var rivit = document.querySelectorAll('#rivit-table tbody tr');

						rivit.forEach(function (rivi) {
							var maaraInput = rivi.querySelector('input[name="maara[]"]');
							var hintaInput = rivi.querySelector('input[name="hinta[]"]');
							var alvSelect = rivi.querySelector('select[name="alv[]"]');

							if (maaraInput && hintaInput && alvSelect) {
								var maara = parseFloat(maaraInput.value) || 0;
								var hinta = parseFloat(hintaInput.value) || 0;
								var alvProsentti = parseFloat(alvSelect.value) || 0;

								var riviVeroton = maara * hinta;
								var riviAlv = riviVeroton * (alvProsentti / 100.0);

								verotonYhteensa += riviVeroton;
								alvYhteensa += riviAlv;
							}
						});

						var verollinenYhteensa = verotonYhteensa + alvYhteensa;

						// Päivitetään summat käyttöliittymään suomalaisella muotoilulla
						document.getElementById('summa-veroton').innerText = verotonYhteensa
							.toFixed(2).replace('.', ',') + ' €';
						document.getElementById('summa-alv').innerText = alvYhteensa
							.toFixed(2).replace('.', ',') + ' €';
						document.getElementById('summa-verollinen').innerText = verollinenYhteensa
							.toFixed(2).replace('.', ',') + ' €';
					}

					// 3. Lisää uuden tyhjän tuoterivin taulukkoon
					function lisaaRivi() {
						var tBody = document.querySelector('#rivit-table tbody');
						var ensimmainenRivi = tBody.querySelector('tr');
						if (!ensimmainenRivi)
							return;

						// Monistetaan ensimmäinen rivi pohjaksi
						var uusiRivi = ensimmainenRivi.cloneNode(true);

						// Tyhjennetään uuden rivin syötekentät
						var select = uusiRivi.querySelector('select[name="tuote[]"]');
						if (select)
							select.selectedIndex = 0;

						var maara = uusiRivi.querySelector('input[name="maara[]"]');
						if (maara)
							maara.value = "1";

						var hinta = uusiRivi.querySelector('input[name="hinta[]"]');
						if (hinta)
							hinta.value = "";

						var alv = uusiRivi.querySelector('select[name="alv[]"]');
						if (alv)
							alv.selectedIndex = 0; // Oletuksena 25.5 %

						tBody.appendChild(uusiRivi);
						laskeYhteissummat();
					}

					// 4. Poistaa valitun tuoterivin taulukosta
					function poistaRivi(painike) {
						var tBody = document.querySelector('#rivit-table tbody');

						// Estetään viimeisen rivin poistaminen
						if (tBody.querySelectorAll('tr').length <= 1) {
							alert('Tarjouksessa täytyy olla vähintään yksi rivi.');
							return;
						}
						var rivi = painike.closest('tr');
						rivi.remove();
						laskeYhteissummat();
					}

					// Ajetaan laskenta kerran käynnistyksen yhteydessä
					document.addEventListener('DOMContentLoaded', function () {
						laskeYhteissummat();
					});
				</script>
			</body>

			</html>