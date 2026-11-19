<%@ page contentType="text/html;charset=UTF-8" language="java" %>
	<%@ taglib prefix="c" uri="jakarta.tags.core" %>
		<!DOCTYPE html>
		<html lang="fi">

		<head>
			<meta charset="UTF-8">
			<meta name="viewport" content="width=device-width, initial-scale=1.0">
			<title>Asiakkaat - Astori</title>
			<!-- Lataa paikallisen Bootstrap-tyylitiedoston resources-juuresta -->
			<link href="${pageContext.request.contextPath}/resources/bootstrap.min.css" rel="stylesheet" />
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

			<!-- 🌟 PÄIVITETTY YLÄPALKKI -->
			<nav class="navbar navbar-expand-lg navbar-dark bg-dark mb-4 shadow-sm">
				<div class="container">
					<a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/">Astori</a>
					<div class="navbar-nav me-auto">
						<a class="nav-link" href="${pageContext.request.contextPath}/">Etusivu</a>
						<a class="nav-link active fw-bold"
							href="${pageContext.request.contextPath}/asiakkaat">Asiakkaat</a> <a class="nav-link"
							href="${pageContext.request.contextPath}/asetukset">Asetukset</a> <a class="nav-link"
							href="${pageContext.request.contextPath}/raportit">Raportit</a>
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
				<div class="d-flex justify-content-between align-items-center mb-4">
					<h2 class="text-dark fw-bold mb-0">Asiakashallinta</h2>
					<button type="button" class="btn btn-primary fw-bold px-4 shadow-sm" data-bs-toggle="modal"
						data-bs-target="#lisaaAsiakasModal">
						+ Lisää uusi asiakas</button>
				</div>


				<!-- Asiakashaku -->
				<form action="${pageContext.request.contextPath}/asiakkaat" method="get" class="mb-4">
					<input type="hidden" name="returnPage" value="${currentPage}">
					<div class="row g-2 align-items-center bg-light p-3 rounded shadow-sm border">

						<!-- 1. Vapaasanahaku -->
						<div class="col-md-3">
							<label class="form-label small fw-bold text-secondary mb-1">Tekstihaku</label>
							<input type="text" name="haku" class="form-control form-control-lg" id="reaaliaikainenHaku"
								value="${haku}" placeholder="Nimi, sähköposti tai Y-tunnus...">
						</div>

						<!-- 2. Aluerajoitus -->
						<div class="col-md-3">
							<label class="form-label small fw-bold text-secondary mb-1">Hyvinvointialue</label>
							<select name="alue" class="form-select form-select-lg">
								<option value="">-- Kaikki alueet --</option>
								<c:forEach items="${hyvinvointialueet}" var="alueEnum">
									<option value="${alueEnum.name()}" ${alueEnum.name()==valittuAlue ? 'selected' : ''
										}>
										${alueEnum.getNimi()}</option>
								</c:forEach>
							</select>
						</div>

						<div class="col-md-3">
							<label class="form-label small fw-bold text-secondary mb-1">Asiakkuuden tila</label>
							<select name="tila" class="form-select form-select-lg">
								<option value="">-- Kaikki tilat --</option>
								<c:forEach items="${tilat}" var="tilaEnum">
									<option value="${tilaEnum.name()}" ${tilaEnum.name()==valittuTila ? 'selected' : ''}>
										${tilaEnum.nayttorivi}
									</option>
								</c:forEach>
							</select>
						</div>

						<div class="col-md-3">
							<label class="form-label small fw-bold text-secondary mb-1">Yritystyyppi</label>
							<div class="d-flex flex-column">
								<div class="form-check">
									<input class="form-check-input" type="checkbox" name="kotihoito" value="true"
										id="suodataKotihoito" ${valittuKotihoito ? 'checked' : ''}>
									<label class="form-check-label" for="suodataKotihoito">Kotihoitoyritys</label>
								</div>
								<div class="form-check">
									<input class="form-check-input" type="checkbox" name="asumispalvelu" value="true"
										id="suodataAsumispalvelu" ${valittuAsumispalvelu ? 'checked' : ''}>
									<label class="form-check-label" for="suodataAsumispalvelu">Asumispalveluyritys</label>
								</div>
							</div>
						</div>

						<div class="col-12 d-flex justify-content-end">
							<div class="d-flex gap-2">
								<button type="submit" class="btn btn-lg btn-primary fw-bold w-100">
									🔍 Hae</button>
								<c:if test="${not empty haku or not empty valittuAlue or not empty valittuTila or valittuKotihoito or valittuAsumispalvelu}">
									<a href="${pageContext.request.contextPath}/asiakkaat"
										class="btn btn-lg btn-outline-secondary d-flex align-items-center justify-content-center px-3 fw-bold"
										title="Tyhjennä haku" style="white-space: nowrap;"> ✖
									</a>
								</c:if>
							</div>
						</div>

					</div>
				</form>




				<div class="row">
					<div class="col-12 mb-4">
						<div class="table-responsive border">
							<table class="table table-hover align-middle mb-0">
								<thead class="table-light">
									<tr>
										<th>Asiakkaan nimi</th>
										<th>Y-tunnus</th>
										<th>Puhelinnumero</th>
										<th>Sähköposti</th>
										<th>Tila</th>
										<th>Yritystyyppi</th>
										<th class="text-end">Toiminnot</th>
									</tr>
								</thead>
								<tbody id="asiakasTaulukkoRunko">
									<c:forEach var="a" items="${asiakkaat}">
										<tr>
											<td><strong><a href="${pageContext.request.contextPath}/asiakas/${a.id}?returnPage=${currentPage}"
														class="text-decoration-none text-dark">${a.nimi}</a></strong>
											</td>
											<td>${a.yTunnus}</td>
											<td>${a.puhelin}</td>
											<td>${a.sahkoposti}</td>
											<td>
												<c:choose>
													<c:when test="${a.tila == 'PROSPEKTI'}">
														<span
															class="badge bg-warning text-dark fw-bold text-uppercase p-2 shadow-sm">Prospekti</span>
													</c:when>
													<c:when test="${a.tila == 'KONTAKTOITU'}">
														<span
															class="badge bg-info text-dark fw-bold text-uppercase p-2 shadow-sm">Kontaktoitu</span>
													</c:when>
													<c:when test="${a.tila == 'TARJOUS_JATETTY'}">
														<span
															class="badge bg-primary fw-bold text-uppercase p-2 shadow-sm">Tarjous
															jätetty</span>
													</c:when>
													<c:when test="${a.tila == 'AKTIIVINEN'}">
														<span
															class="badge bg-success fw-bold text-uppercase p-2 shadow-sm">Aktiivinen</span>
													</c:when>
													<c:when test="${a.tila == 'PAATTYNYT'}">
														<span
															class="badge bg-secondary fw-bold text-uppercase p-2 shadow-sm">Päättynyt</span>
													</c:when>
													<c:otherwise>
														<span
															class="badge bg-light text-dark border p-2">${a.tila}</span>
													</c:otherwise>
												</c:choose>
											</td>
											<td>
												<c:if test="${a.kotihoitoyritys}">
													<span class="badge bg-info text-dark me-1">Kotihoito</span>
												</c:if>
												<c:if test="${a.asumispalveluyritys}">
													<span class="badge bg-warning text-dark">Asumispalvelut</span>
												</c:if>
											</td>

											<td class="text-end"><a
													href="${pageContext.request.contextPath}/asiakas/${a.id}?returnPage=${currentPage}"
													class="btn btn-sm btn-outline-primary fw-bold">Avaa
													profiili</a></td>
										</tr>
									</c:forEach>
									<c:if test="${empty asiakkaat}">
										<tr>
											<td colspan="7" class="text-center py-4 text-muted">Ei
												hakutuloksia tai asiakkaita järjestelmässä.</td>
										</tr>
									</c:if>
								</tbody>
							</table>
						</div>

						<!-- SIVUTUSLINKIT KOKO SIVUN LEVEYDELLE -->
						<c:if test="${totalPages > 1}">
							<nav aria-label="Asiakaslistan sivutus" id="sivutusNavigaatio"
								class="d-flex justify-content-center mt-4">
								<ul class="pagination shadow-sm">
									<li class="page-item ${currentPage == 0 ? 'disabled' : ''}">
										<a class="page-link" href="?page=${currentPage - 1}&haku=${haku}&alue=${valittuAlue}&tila=${valittuTila}&kotihoito=${valittuKotihoito}&asumispalvelu=${valittuAsumispalvelu}">&laquo;
											Edellinen</a>
									</li>
									<c:forEach var="i" begin="0" end="${totalPages - 1}">
										<li class="page-item ${currentPage == i ? 'active' : ''}">
											<a class="page-link" href="?page=${i}&haku=${haku}&alue=${valittuAlue}&tila=${valittuTila}&kotihoito=${valittuKotihoito}&asumispalvelu=${valittuAsumispalvelu}">${i + 1}</a>
										</li>
									</c:forEach>
									<li class="page-item ${currentPage >= totalPages - 1 ? 'disabled' : ''}">
										<a class="page-link" href="?page=${currentPage + 1}&haku=${haku}&alue=${valittuAlue}&tila=${valittuTila}&kotihoito=${valittuKotihoito}&asumispalvelu=${valittuAsumispalvelu}">Seuraava
											&raquo;</a>
									</li>
								</ul>
							</nav>
						</c:if>
					</div>
				</div>
				<!-- .row päättyminen -->
			</div>
			<!-- .container päättyminen -->

			<!-- BOOTSTRAP POP-UP LOMAKE (MODAL) UUDELLE ASIAKKAALLE -->
			<div class="modal fade" id="lisaaAsiakasModal" tabindex="-1" aria-hidden="true">
				<div class="modal-dialog modal-dialog-centered">
					<div class="modal-content border-0 shadow-lg">
						<div class="modal-header bg-primary text-white">
							<h5 class="modal-title fw-bold">Lisää uusi asiakas</h5>
							<button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
						</div>
						<form id="lisaaAsiakasLomake" action="${pageContext.request.contextPath}/lisaa-asiakas" method="post">
							<div class="modal-body p-4">
								<div class="mb-3">
									<label for="nimi" class="form-label fw-semibold text-secondary">Nimi
										/ Organisaatio</label> <input type="text" class="form-control" id="nimi"
										name="nimi" required placeholder="esim. Sote-Hyvinvointi Oy">
								</div>

								<!-- Y-TUNNUS UUDEN ASIAKKAAN LOMAKKEELLE -->
								<div class="mb-3">
									<label for="yTunnus" class="form-label fw-semibold text-secondary">Y-tunnus
										(vapaaehtoinen)</label> <input type="text" class="form-control" id="yTunnus"
										name="yTunnus" placeholder="esim. 1234567-8" maxlength="9">
								</div>

								<div class="mb-3">
									<label for="hyvinvointialueet" class="form-label">Hyvinvointialueet</label>
									<select class="form-select" id="hyvinvointialueet" name="hyvinvointialueet" multiple size="5">
										<c:forEach var="alue" items="${hyvinvointialueet}">
											<option value="${alue}">${alue.nimi}</option>
										</c:forEach>
									</select>
									<div class="form-text">Voit valita useita alueita pitämällä Ctrl-näppäintä (Macilla Cmd) painettuna.</div>
								</div>

								<div class="mb-3">
									<label for="sahkoposti"
										class="form-label fw-semibold text-secondary">Sähköposti</label>
									<input type="email" class="form-control" id="sahkoposti" name="sahkoposti" required
										placeholder="yhteys@yritys.fi">
								</div>
								<div class="mb-3">
									<label for="puhelin" class="form-label fw-semibold text-secondary">Puhelin</label>
									<input type="text" class="form-control" id="puhelin" name="puhelin" required
										placeholder="040 123 4567">
								</div>
								<div class="mb-3">
									<label class="form-label fw-semibold text-secondary">Yritystyyppi</label>
									<div class="form-check">
										<input class="form-check-input" type="checkbox" name="kotihoitoyritys"
											value="true" id="uusiAsiakasKotihoito">
										<label class="form-check-label" for="uusiAsiakasKotihoito">Kotihoitoyritys</label>
									</div>
									<div class="form-check">
										<input class="form-check-input" type="checkbox" name="asumispalveluyritys"
											value="true" id="uusiAsiakasAsumispalvelu">
										<label class="form-check-label" for="uusiAsiakasAsumispalvelu">Asumispalveluyritys</label>
									</div>
								</div>
								<div class="mb-3">
									<label for="tila" class="form-label fw-semibold text-secondary">Asiakkuuden
										alkutila</label> <select class="form-select" id="tila" name="tila" required>
										<c:forEach var="t" items="${tilat}">
											<option value="${t}">${t}</option>
										</c:forEach>
									</select>
								</div>

								<hr class="text-muted my-3">
								<h6 class="fw-bold text-dark mb-3">Osoite- ja käyntitiedot
									(vapaaehtoinen)</h6>

								<div class="mb-3">
									<label for="katuosoite"
										class="form-label fw-semibold text-secondary">Katuosoite</label>
									<input type="text" class="form-control" id="katuosoite" name="katuosoite"
										placeholder="esim. Keskuskatu 10">
								</div>
								<div class="row">
									<div class="col-md-4 mb-3">
										<label for="postinumero"
											class="form-label fw-semibold text-secondary">Postinumero</label>
										<input type="text" class="form-control" id="postinumero" name="postinumero"
											placeholder="00100" maxlength="5">
									</div>
									<div class="col-md-8 mb-3">
										<label for="postitoimipaikka"
											class="form-label fw-semibold text-secondary">Postitoimipaikka</label>
										<input type="text" class="form-control" id="postitoimipaikka"
											name="postitoimipaikka" placeholder="Helsinki">
									</div>
								</div>
								<div class="mb-3">
									<label for="kotisivu" class="form-label fw-semibold text-secondary">Kotisivut
										(URL)</label> <input type="url" class="form-control" id="kotisivu"
										name="kotisivu" placeholder="https://yritys.fi">
								</div>

								<div class="mb-3">
									<label for="kuvaus" class="form-label fw-semibold text-secondary">Toiminnan
										kuvaus / Taustatiedot</label>
									<!-- 💡 PÄIVITETTY: Vaihdettu textarea laajaa kuvausta varten -->
									<textarea class="form-control" id="kuvaus" name="kuvaus" rows="4"
										placeholder="Kirjoita vapaamuotoinen kuvaus yrityksen toiminnasta, historiasta ja tarpeista..."></textarea>
								</div>


							</div>
							<div class="modal-footer bg-light">
								<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Peruuta</button>
								<button type="submit" class="btn btn-primary px-4 fw-bold">Tallenna
									asiakas</button>
							</div>
						</form>
					</div>
				</div>
			</div>

			<!-- Lataa paikallisen Bootstrap-JavaScriptin resources-juuresta -->
			<script src="${pageContext.request.contextPath}/resources/bootstrap.bundle.min.js"></script>

			<script>
				document.addEventListener('DOMContentLoaded', function () {
					var hakukentta = document.getElementById('reaaliaikainenHaku')
					var taulukkoRunko = document.getElementById('asiakasTaulukkoRunko')
					var sivutusNav = document.getElementById('sivutusNavigaatio')
					var hakulomake = hakukentta ? hakukentta.form : null
					var hakuPyynto = 0

					// Tallennetaan alkuperäiset 10 sivutettua asiakasta muistiin
					var alkuperainenSisalto = taulukkoRunko ? taulukkoRunko.innerHTML : ''

					var lisaaAsiakasLomake = document.getElementById('lisaaAsiakasLomake')
					if (lisaaAsiakasLomake) {
						lisaaAsiakasLomake.addEventListener('submit', function (event) {
							var puuttuvatTiedot = []
							var aluevalinta = document.getElementById('hyvinvointialueet')
							var kotihoitoValittu = document.getElementById('uusiAsiakasKotihoito').checked
							var asumispalveluValittu = document.getElementById('uusiAsiakasAsumispalvelu').checked

							if (!aluevalinta || aluevalinta.selectedOptions.length === 0) {
								puuttuvatTiedot.push('hyvinvointialue')
							}
							if (!kotihoitoValittu && !asumispalveluValittu) {
								puuttuvatTiedot.push('yritystyyppi (kotihoito tai asumispalvelu)')
							}

							if (puuttuvatTiedot.length > 0) {
								var varoitus = 'Huomio: seuraavat tiedot puuttuvat: ' +
									puuttuvatTiedot.join(', ') +
									'. Haluatko tallentaa asiakkaan silti?'
								if (!window.confirm(varoitus)) {
									event.preventDefault()
								}
							}
						})
					}

					if (hakukentta && taulukkoRunko) {
						hakukentta.addEventListener('input', function (e) {
							var hakusana = e.target.value.trim()
							var suodattimet = hakulomake.querySelectorAll(
								'select[name="alue"], select[name="tila"]'
							)
							var suodatinKaytossa = Array.prototype.some.call(suodattimet, function (suodatin) {
								return suodatin.value !== ''
							}) || hakulomake.querySelector('[name="kotihoito"]').checked ||
								hakulomake.querySelector('[name="asumispalvelu"]').checked

							// Jos hakukenttä tyhjennetään, palautetaan alkuperäinen sivutettu lista
							if (hakusana.length === 0 && !suodatinKaytossa) {
								hakuPyynto++
								taulukkoRunko.innerHTML = alkuperainenSisalto
								if (sivutusNav) {
									sivutusNav.style.display = ''
								}
								return
							}

							var pyyntoId = ++hakuPyynto
							var parametrit = new URLSearchParams(new FormData(hakulomake))
							parametrit.set('haku', hakusana)

							// Tehdään haku taustalta lennosta samoilla suodattimilla kuin lomakehaku
							fetch('${pageContext.request.contextPath}/asiakkaat/live-haku?' + parametrit.toString())
								.then(function (response) {
									if (!response.ok) {
										throw new Error('Hakupyyntö epäonnistui: ' + response.status)
									}
									return response.text()
								})
								.then(function (htmlRivit) {
									if (pyyntoId !== hakuPyynto) {
										return
									}
									// Päivitetään taulukon rivit lennosta hakutuloksilla
									taulukkoRunko.innerHTML = htmlRivit
									// Piilotetaan sivutuspainikkeet reaaliaikaisen haun ajaksi
									if (sivutusNav) {
										sivutusNav.style.display = 'none'
									}
								})
								.catch(function (err) {
									console.error('Haku epäonnistui:', err)
								})
						})
					}
				})
			</script>


		</body>

		</html>