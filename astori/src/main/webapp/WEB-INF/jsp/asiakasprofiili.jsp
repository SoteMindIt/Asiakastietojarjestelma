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
	.
	rotate-180
	{
	transform
	:
	rotate(
	180deg
	);
}

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

			<!-- ==================== 1. KATSELUTILA (Oletusnäkymä) ==================== -->

			<!-- ==================== 1. KATSELUTILA (Oletusnäkymä) ==================== -->
			<div id="asiakas-katselu">

				<!-- YLÄRIVI: Nimi vasemmalla, KAIKKI painikkeet oikealla rinnakkain -->
				<div
					class="d-flex justify-content-between align-items-center flex-wrap gap-3 mb-4">
					<div>
						<h2 class="fw-bold h4 text-dark mb-1">${asiakas.nimi}</h2>
						<div class="d-flex gap-2 align-items-center flex-wrap">
							<span class="badge bg-secondary">ID #${asiakas.id}</span>
							<c:if test="${not empty Myyntiputki_tila}">
								<span
									class="badge bg-primary-subtle text-primary border border-primary-subtle px-2.5 py-1 rounded-2 fw-semibold">
									${Myyntiputki_tila.nayttorivi} </span>
							</c:if>
							<c:if test="${not empty asiakas.yTunnus}">
								<span
									class="badge bg-light text-secondary border px-2.5 py-1 rounded-2">
									Y-tunnus: ${asiakas.yTunnus} </span>
							</c:if>
						</div>
					</div>

					<!-- 💡 LISÄTYT PAINIKKEET: Kaikki toimintapainikkeet siististi nimen oikealla puolelle -->
					<div class="d-flex gap-2 align-items-center flex-wrap">
						<button type="button"
							class="btn btn-sm btn-outline-dark fw-bold py-1.5 px-2.5 small rounded-pill"
							style="font-size: 0.85em;" data-bs-toggle="modal"
							data-bs-target="#lisaaPalveluyksikkoModal">+
							Palveluyksikkö</button>
						<button type="button"
							class="btn btn-sm btn-outline-success fw-bold py-1.5 px-2.5 small rounded-pill"
							style="font-size: 0.85em;" data-bs-toggle="modal"
							data-bs-target="#lisaaHankintaModal">+ Tuote/Palvelu</button>
						<button type="button"
							class="btn btn-sm btn-outline-primary py-1.5 px-2.5 small rounded-pill"
							style="font-size: 0.85em;" data-bs-toggle="modal"
							data-bs-target="#lisaaKirjausModal">+ Lokimerkintä</button>
						<button type="button"
							class="btn btn-sm btn-outline-secondary py-1.5 px-2.5 small rounded-pill"
							style="font-size: 0.85em;" data-bs-toggle="modal"
							data-bs-target="#lisaaYhModal">+ Yhteyshenkilö</button>

						<!-- Alkuperäinen muokkauspainike pienenä erottimena -->
						<button
							class="btn btn-sm btn-primary fw-bold py-1.5 px-3 shadow-sm rounded-pill ms-md-2"
							style="font-size: 0.85em;" onclick="avaaMuokkaus()">✏️
							Muokkaa</button>
					</div>
				</div>

				<!-- PERUSTIEDOT KAKSISARAKKEISENA -->
				<div class="row g-4 mb-4">

					<!-- Vasen sarake: Yrityksen omat perustiedot -->
					<div class="col-md-6">
						<div class="pe-md-3">
							<p class="mb-2">
								<strong>📞 Puhelinnumero:</strong> ${not empty asiakas.puhelin ? asiakas.puhelin : '<span class="text-muted italic">Ei määritelty</span>'}
							</p>
							<p class="mb-2">
								<strong>✉️ Sähköposti:</strong> ${not empty asiakas.sahkoposti ? asiakas.sahkoposti : '<span class="text-muted italic">Ei määritelty</span>'}
							</p>
							<p class="mb-2">
								<strong>🌐 Kotisivu:</strong>
								<c:choose>
									<c:when test="${not empty asiakas.kotisivu}">
										<a href="${asiakas.kotisivu}" target="_blank"
											class="text-primary text-decoration-none fw-bold">${asiakas.kotisivu}</a>
									</c:when>
									<c:otherwise>
										<span class="text-muted italic">Ei määritelty</span>
									</c:otherwise>
								</c:choose>
							</p>
							<p class="mb-2">
								<strong>📍 Katuosoite:</strong> ${not empty asiakas.katuosoite ? asiakas.katuosoite : '<span class="text-muted italic">Ei määritelty</span>'}
							</p>
							<p class="mb-2">
								<strong>📮 Postitoimipaikka:</strong> ${not empty asiakas.postitoimipaikka ? asiakas.postinumero += ' ' += asiakas.postitoimipaikka : '<span class="text-muted italic">Ei määritelty</span>'}
							</p>
							<p class="mb-0">
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
						</div>
					</div>

					<!-- Oikea sarake: Asiakkaan yleinen pääyhteyshenkilö -->
					<div class="col-md-6">
						<div
							class="p-3 bg-light rounded-3 border h-100 d-flex flex-column justify-content-center">
							<h6 class="fw-bold text-uppercase text-secondary mb-2"
								style="font-size: 0.75em; letter-spacing: 0.5px;">👥
								Organisaation pääyhteyshenkilö</h6>

							<c:set var="paayhteyshenkiloLoytyi" value="false" />
							<c:forEach var="h" items="${yhteyshenkilot}">
								<c:if
									test="${empty h.palveluyksikko && !paayhteyshenkiloLoytyi}">
									<div class="text-dark">
										<div class="fw-bold h6 mb-0">${h.nimi}</div>
										<div class="text-muted small mb-2">${h.rooli}</div>
										<div class="small">
											<div class="mb-1">✉️ ${h.sahkoposti}</div>
											<div>📞 ${h.puhelin}</div>
										</div>
									</div>
									<c:set var="paayhteyshenkiloLoytyi" value="true" />
								</c:if>
							</c:forEach>

							<c:if test="${!paayhteyshenkiloLoytyi}">
								<div class="text-muted italic small text-center py-2">
									Ei määriteltyä yleistä pääyhteyshenkilöä.<br> Voit lisätä
									sellaisen yläpuolelta.
								</div>
							</c:if>
						</div>
					</div>

				</div>

				<!-- 💡 HUOM: Erillinen painikerivi on nyt poistettu kokonaan, sillä ne ovat ylhäällä! -->

			</div>
			<!-- /asiakas-katselu -->


			<c:if test="${not empty asiakas.kuvaus}">
				<div class="mb-4 p-3 bg-white rounded-3 border">
					<h6 class="fw-bold text-uppercase text-secondary mb-2"
						style="font-size: 0.75em; letter-spacing: 0.5px;">📝
						Asiakkaan kuvaus ja sisäiset huomiot</h6>
					<div class="text-dark small"
						style="white-space: pre-line; line-height: 1.5;">
						${asiakas.kuvaus}</div>
				</div>
			</c:if>


			<!-- 💡 LOKI JA MUISTIINPANOT (Kokoontaitettava versio nuoli-indikaattorilla) -->
			<div class="mb-4">
				<div class="profile-card border bg-white shadow-sm p-3 rounded-3">

					<!-- Klikattava otsikkorivi, joka toimii haitarin kytkimenä -->
					<div class="d-flex justify-content-between align-items-center"
						style="cursor: pointer;" data-bs-toggle="collapse"
						data-bs-target="#lokiKirjauksetCollapse" aria-expanded="false"
						aria-controls="lokiKirjauksetCollapse"
						onclick="this.querySelector('.accordion-nuoli-loki').classList.toggle('rotate-180')">

						<h6 class="fw-bold text-uppercase text-secondary mb-0"
							style="letter-spacing: 0.5px; font-size: 0.75em;">📋
							Asiakkaan loki ja muistiinpanot (${kirjaukset.size()})</h6>

						<!-- Dynaaminen nuolikuvake, joka kääntyy (oma luokka erottamaan muista haitareista) -->
						<span class="accordion-nuoli-loki text-muted fw-bold"
							style="transition: transform 0.2s ease; display: inline-block;">
							▼ </span>
					</div>

					<!-- TÄMÄ LOKISISÄLTÖ ON OLETUSARVOISESTI PIILOSSA (Aukeaa klikkaamalla otsikkoa) -->
					<div class="collapse mt-3" id="lokiKirjauksetCollapse">
						<div class="bg-light rounded-3 border p-3"
							style="max-height: 300px; overflow-y: auto;">

							<c:forEach var="k" items="${kirjaukset}">
								<div
									class="p-2 border-bottom mb-2 text-dark small position-relative bg-white rounded shadow-sm">
									<div
										class="d-flex justify-content-between align-items-center mb-1">
										<!-- Luontiaika suomalaisessa muodossa -->
										<small class="text-muted fw-semibold"> <c:set
												var="lokiAika"
												value="${k.luontiaika.toString().substring(0, 16)}" /> <fmt:parseDate
												value="${lokiAika}" pattern="yyyy-MM-dd'T'HH:mm"
												var="parsituLoki" type="both" /> <fmt:formatDate
												value="${parsituLoki}" pattern="dd.MM.yyyy 'klo' HH:mm" />
										</small>

										<!-- Painikkeet: Muokkaa ja arkistoiva Poista rinnakkain -->
										<div class="d-flex gap-2">
											<button type="button"
												class="btn btn-sm btn-link text-primary py-0 px-1 text-decoration-none muokkaa-loki-btn"
												style="font-size: 0.85em;" data-id="${k.id}"
												data-teksti="<c:out value='${k.teksti}'/>">Muokkaa</button>

											<form
												action="${pageContext.request.contextPath}/kirjaus/poista/${k.id}"
												method="post" class="d-inline"
												onsubmit="return confirm('Haluatko varmasti poistaa tämän lokimerkinnän? Merkintä arkistoidaan järjestelmälokiin.')">
												<input type="hidden" name="asiakasId" value="${asiakas.id}">
												<button type="submit"
													class="btn btn-sm btn-link text-danger py-0 px-1 text-decoration-none"
													style="font-size: 0.85em; font-weight: 500;">
													Poista</button>
											</form>
										</div>
									</div>
									<div style="white-space: pre-line; line-height: 1.4;">${k.teksti}</div>
								</div>
							</c:forEach>

							<!-- Jos kirjauksia ei ole ollenkaan -->
							<c:if test="${empty kirjaukset}">
								<div class="text-center py-4 text-muted italic small">
									Asiakkaalle ei ole vielä tehty lokimerkintöjä. Voit lisätä
									ensimmäisen yläpuolelta.</div>
							</c:if>

						</div>
					</div>
					<!-- /collapse -->

				</div>
			</div>


			<!-- /asiakas-katselu -->

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

			<!-- UUSI KORTTI: PALVELUYKSIKÖT (Kokoontaitettava versio nuoli-indikaattorilla) -->
			<div class="col-12">
				<div class="profile-card border bg-white shadow-sm p-3 rounded-3">

					<!-- Klikattava otsikkorivi, joka toimii kytkimenä -->
					<div class="d-flex justify-content-between align-items-center"
						style="cursor: pointer;" data-bs-toggle="collapse"
						data-bs-target="#palveluyksikotCollapse" aria-expanded="false"
						aria-controls="palveluyksikotCollapse"
						onclick="this.querySelector('.accordion-nuoli').classList.toggle('rotate-180')">

						<h3 class="fw-bold h6 text-secondary text-uppercase mb-0"
							style="letter-spacing: 0.5px;">🏢 Palveluyksiköt ja
							toimipisteet (${asiakas.palveluyksikot.size()})</h3>

						<!-- Dynaaminen nuolikuvake, joka kääntyy -->
						<span class="accordion-nuoli text-muted fw-bold"
							style="transition: transform 0.2s ease; display: inline-block;">
							▼ </span>
					</div>

					<!-- TÄMÄ OSIO ON OLETUSARVOISESTI PIILOSSA (Ota 'show' pois class-listasta jos haluat piiloon heti latauksessa) -->
					<div class="collapse mt-3" id="palveluyksikotCollapse">
						<c:choose>
							<c:when test="${not empty asiakas.palveluyksikot}">
								<div class="d-flex flex-wrap gap-3">
									<c:forEach var="yksikko" items="${asiakas.palveluyksikot}">
										<div
											class="card p-3 shadow-sm border bg-light d-flex flex-column justify-content-between"
											style="min-width: 300px; flex: 1 1 30%;">
											<div>
												<div
													class="d-flex justify-content-between align-items-start mb-2">
													<div>
														<strong class="text-dark h6 mb-0 d-block">${yksikko.nimi}</strong>
														<c:if test="${not empty yksikko.hyvinvointialue}">
															<span
																class="badge bg-primary-subtle text-primary border border-primary-subtle rounded-pill mt-1"
																style="font-size: 0.75em;">
																${yksikko.hyvinvointialue.nimi} </span>
														</c:if>
													</div>
													<button type="button"
														class="btn btn-sm btn-outline-primary py-0 px-2 muokkaa-py-btn"
														style="font-size: 0.8em;" data-id="${yksikko.id}"
														data-nimi="${yksikko.nimi}"
														data-alue="${yksikko.hyvinvointialue}"
														data-katu="${yksikko.katuosoite}"
														data-pno="${yksikko.postinumero}"
														data-ptp="${yksikko.postitoimipaikka}"
														data-puh="${yksikko.puhelin}"
														data-email="${yksikko.sahkoposti}"
														data-kuvaus="<c:out value='${yksikko.kuvaus}'/>">
														Muokkaa</button>
												</div>

												<!-- Osoite- ja yhteystiedot -->
												<div class="text-muted small mt-2">
													<c:if test="${not empty yksikko.katuosoite}">
														<div class="mb-1">📍 ${yksikko.katuosoite},
															${yksikko.postinumero} ${yksikko.postitoimipaikka}</div>
													</c:if>
													<c:if test="${not empty yksikko.puhelin}">
														<div class="mb-1">📞 ${yksikko.puhelin}</div>
													</c:if>
													<c:if test="${not empty yksikko.sahkoposti}">
														<div class="mb-1">✉️ ${yksikko.sahkoposti}</div>
													</c:if>
												</div>

												<!-- Yksikön omat yhteyshenkilöt -->
												<div class="mt-3 pt-2 border-top">
													<h6 class="fw-bold text-uppercase text-secondary mb-2"
														style="font-size: 0.7em; letter-spacing: 0.5px;">Yksikön
														vastuuhenkilöt</h6>
													<c:forEach var="yh" items="${yksikko.yhteyshenkilot}">
														<div
															class="p-2 bg-white rounded border shadow-sm mb-1 text-dark small">
															<div
																class="d-flex justify-content-between align-items-center">
																<strong>👤 ${yh.nimi}</strong> <span class="text-muted"
																	style="font-size: 0.85em;">${yh.rooli}</span>
															</div>
															<div class="text-muted"
																style="font-size: 0.85em; margin-left: 18px;">
																<span class="me-2">✉️ ${yh.sahkoposti}</span> <span>📞
																	${yh.puhelin}</span>
															</div>
														</div>
													</c:forEach>
													<c:if test="${empty yksikko.yhteyshenkilot}">
														<div class="text-muted italic small text-center py-1">Ei
															nimettyjä omia vastuuhenkilöitä.</div>
													</c:if>
												</div>

												<!-- Lyhyt kuvausteksti -->
												<c:if test="${not empty yksikko.kuvaus}">
													<div
														class="mt-2 p-2 bg-white rounded border small text-secondary"
														style="font-size: 0.85em; white-space: pre-line;">
														${yksikko.kuvaus}</div>
												</c:if>
											</div>
										</div>
									</c:forEach>
								</div>
							</c:when>
							<c:otherwise>
								<div
									class="p-3 bg-light rounded text-center text-muted small italic">
									Asiakkaalle ei ole vielä luotu erillisiä palveluyksiköitä. Voit
									lisätä ensimmäisen yksikön yläpuolelta.</div>
							</c:otherwise>
						</c:choose>
					</div>

				</div>
			</div>

		</div>


		<!-- KORTTI: YHTEYSHENKILÖT (Kokoontaitettava versio nuoli-indikaattorilla) -->
		<div class="col-12">
			<div class="profile-card border bg-white shadow-sm p-3 rounded-3">

				<!-- Klikattava otsikkorivi, joka toimii kytkimenä -->
				<div class="d-flex justify-content-between align-items-center"
					style="cursor: pointer;" data-bs-toggle="collapse"
					data-bs-target="#yhteyshenkilotCollapse" aria-expanded="false"
					aria-controls="yhteyshenkilotCollapse"
					onclick="this.querySelector('.accordion-nuoli-yh').classList.toggle('rotate-180')">

					<h3 class="fw-bold h6 text-secondary text-uppercase mb-0"
						style="letter-spacing: 0.5px;">👥 Järjestelmän kaikki
						yhteyshenkilöt (${yhteyshenkilot.size()})</h3>

					<!-- Dynaaminen nuolikuvake, joka kääntyy (oma luokka erottamaan palveluyksiköistä) -->
					<span class="accordion-nuoli-yh text-muted fw-bold"
						style="transition: transform 0.2s ease; display: inline-block;">
						▼ </span>
				</div>

				<!-- TÄMÄ OSIO ON OLETUSARVOISESTI PIILOSSA (Aukeaa klikkaamalla) -->
				<div class="collapse mt-3" id="yhteyshenkilotCollapse">
					<c:choose>
						<c:when test="${not empty yhteyshenkilot}">
							<div class="d-flex flex-wrap gap-3">
								<c:forEach var="h" items="${yhteyshenkilot}">
									<div
										class="card p-3 shadow-sm border bg-light d-flex flex-row justify-content-between align-items-center"
										style="min-width: 280px; flex: 1 1 30%;">
										<div>
											<div class="d-flex align-items-center gap-2 flex-wrap">
												<strong class="text-dark small d-block">${h.nimi}</strong>

												<!-- Jos henkilö kuuluu tiettyyn palveluyksikköön, näytetään siitä siisti badge -->
												<c:if test="${not empty h.palveluyksikko}">
													<span
														class="badge bg-secondary-subtle text-secondary border border-secondary-subtle rounded-pill"
														style="font-size: 0.7em;"> 🏢
														${h.palveluyksikko.nimi} </span>
												</c:if>
											</div>
											<span class="text-muted d-block" style="font-size: 0.8em;">${h.rooli}</span>
											<div class="text-muted mt-2" style="font-size: 0.75em;">
												<div class="mb-1">✉️ ${h.sahkoposti}</div>
												<div>📞 ${h.puhelin}</div>
											</div>
										</div>
										<button type="button"
											class="btn btn-sm btn-outline-primary py-1 px-2 muokkaa-yh-btn"
											data-id="${h.id}" data-nimi="${h.nimi}"
											data-rooli="${h.rooli}" data-email="${h.sahkoposti}"
											data-puh="${h.puhelin}" style="font-size: 0.8em;">
											Muokkaa</button>
									</div>
								</c:forEach>
							</div>
						</c:when>
						<c:otherwise>
							<div
								class="p-3 bg-light rounded text-center text-muted small italic">
								Asiakkaalle ei ole vielä luotu yhteyshenkilöitä. Voit lisätä
								ensimmäisen yläpuolelta.</div>
						</c:otherwise>
					</c:choose>
				</div>

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
							<table class="table table-sm table-hover mb-0 align-middle small">
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
												data-bs-toggle="modal" data-bs-target="#muokkaaPalveluModal"
												data-id="${ot.id}" data-tuote="${ot.tuote.nimi}"
												data-maara="${ot.maara}" data-hinta="${ot.myyntihinta}"
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

	<!-- 1. MODAL UUDEN PALVELUYKSIKÖN LISÄÄMISEEN (Palautettu oikea ID) -->
	<div class="modal fade" id="lisaaPalveluyksikkoModal" tabindex="-1"
		aria-labelledby="lisaaPalveluyksikkoModalLabel" aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered modal-lg">
			<div class="modal-content border-0 shadow-lg">
				<form
					action="${pageContext.request.contextPath}/asiakas/${asiakas.id}/lisaa-palveluyksikko"
					method="post">
					<div class="modal-header bg-dark text-white">
						<h5 class="modal-title fw-bold" id="lisaaPalveluyksikkoModalLabel">Lisää
							uusi palveluyksikkö</h5>
						<button type="button" class="btn-close btn-close-white"
							data-bs-dismiss="modal" aria-label="Close"></button>
					</div>
					<div class="modal-body p-4 text-start">
						<div class="mb-3">
							<label class="form-label fw-bold text-secondary small">Palveluyksikön
								/ Toimipisteen nimi *</label> <input type="text" class="form-control"
								name="nimi"
								placeholder="esim. Hoivakoti Hopeatähti tai Osasto B" required>
						</div>

						<div class="row g-3">
							<div class="col-md-6 mb-3">
								<label class="form-label fw-bold text-secondary small">Hyvinvointialue</label>
								<select class="form-select" name="hyvinvointialue">
									<option value="">-- Valitse hyvinvointialue (jos eri)
										--</option>
									<c:forEach var="alue" items="${hyvinvointialueet}">
										<option value="${alue}">${alue.nimi}</option>
									</c:forEach>
								</select>
							</div>
							<div class="col-md-6 mb-3">
								<label class="form-label fw-bold text-secondary small">Katuosoite</label>
								<input type="text" class="form-control" name="katuosoite"
									placeholder="esim. Puistotie 4">
							</div>
						</div>

						<div class="row g-3">
							<div class="col-md-4 mb-3">
								<label class="form-label fw-bold text-secondary small">Postinumero</label>
								<input type="text" class="form-control" name="postinumero"
									placeholder="00100" maxlength="10">
							</div>
							<div class="col-md-8 mb-3">
								<label class="form-label fw-bold text-secondary small">Postitoimipaikka</label>
								<input type="text" class="form-control" name="postitoimipaikka"
									placeholder="Helsinki">
							</div>
						</div>

						<div class="row g-3">
							<div class="col-md-6 mb-3">
								<label class="form-label fw-bold text-secondary small">Yksikön
									puhelinnumero</label> <input type="tel" class="form-control"
									name="puhelin" placeholder="esim. 040 123 4567">
							</div>
							<div class="col-md-6 mb-3">
								<label class="form-label fw-bold text-secondary small">Yksikön
									sähköposti</label> <input type="email" class="form-control"
									name="sahkoposti" placeholder="yksikko@yritys.fi">
							</div>
						</div>

						<!-- 💡 UUSI OSIO: Yksikön ensimmäisen yhteyshenkilön tiedot (Vapaaehtoinen) -->
						<div class="p-3 bg-light rounded-3 border mb-3 mt-2">
							<h6
								class="fw-bold text-uppercase text-secondary mb-3 shadow-sm-none"
								style="font-size: 0.75em; letter-spacing: 0.5px;">👤
								Yksikön yhteyshenkilö / Vastuuhenkilö</h6>

							<div class="mb-3">
								<label class="form-label text-dark small fw-normal mb-1">Yhteyshenkilön
									nimi</label> <input type="text" class="form-control bg-white"
									name="yhNimi" placeholder="esim. Johanna Jokinen">
							</div>

							<div class="mb-3">
								<label class="form-label text-dark small fw-normal mb-1">Rooli
									/ Nimike</label> <input type="text" class="form-control bg-white"
									name="yhRooli"
									placeholder="esim. Yksikönjohtaja tai Vastaava hoitaja">
							</div>

							<div class="row g-3">
								<div class="col-md-6 mb-2">
									<label class="form-label text-dark small fw-normal mb-1">Suora
										puhelinnumero</label> <input type="tel" class="form-control bg-white"
										name="yhPuhelin" placeholder="040 123 4567">
								</div>
								<div class="col-md-6 mb-2">
									<label class="form-label text-dark small fw-normal mb-1">Suora
										sähköposti</label> <input type="email" class="form-control bg-white"
										name="yhSahkoposti" placeholder="johanna.jokinen@yritys.fi">
								</div>
							</div>
						</div>

						<div class="mb-3">
							<label class="form-label fw-bold text-secondary small">Lisätiedot
								/ Yksikön kuvaus</label>
							<textarea class="form-control" name="kuvaus" rows="3"
								placeholder="Kirjoita tähän vapaamuotoisia huomioita..."></textarea>
						</div>
					</div>
					<div class="modal-footer bg-light">
						<button type="button" class="btn btn-secondary"
							data-bs-dismiss="modal">Peruuta</button>
						<button type="submit" class="btn btn-success fw-bold px-4">Tallenna
							yksikkö</button>
					</div>
				</form>
			</div>
		</div>
	</div>

	<!-- 2. UUSI MODAL PALVELUYKSIKÖN MUOKKAUKSEEN (Sisältää JavaScriptin vaatimat ID-tunnisteet) -->
	<div class="modal fade" id="muokkaaPyModal" tabindex="-1"
		aria-labelledby="muokkaaPyModalLabel" aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered modal-lg">
			<div class="modal-content border-0 shadow-lg">
				<form id="muokkaaPyForm" method="post" action="">
					<input type="hidden" name="asiakasId" value="${asiakas.id}">
					<div class="modal-header bg-dark text-white">
						<h5 class="modal-title fw-bold" id="muokkaaPyModalLabel">Muokkaa
							palveluyksikköä</h5>
						<button type="button" class="btn-close btn-close-white"
							data-bs-dismiss="modal" aria-label="Close"></button>
					</div>
					<div class="modal-body p-4 text-start">
						<div class="mb-3">
							<label class="form-label fw-bold text-secondary small">Palveluyksikön
								/ Toimipisteen nimi *</label> <input type="text" class="form-control"
								id="pyNimi" name="nimi" required>
						</div>

						<div class="row g-3">
							<div class="col-md-6 mb-3">
								<label class="form-label fw-bold text-secondary small">Hyvinvointialue</label>
								<select class="form-select" id="pyHyvinvointialue"
									name="hyvinvointialue">
									<option value="">-- Valitse hyvinvointialue --</option>
									<c:forEach var="alue" items="${hyvinvointialueet}">
										<option value="${alue}">${alue.nimi}</option>
									</c:forEach>
								</select>
							</div>
							<div class="col-md-6 mb-3">
								<label class="form-label fw-bold text-secondary small">Katuosoite</label>
								<input type="text" class="form-control" id="pyKatuosoite"
									name="katuosoite">
							</div>
						</div>

						<div class="row g-3">
							<div class="col-md-4 mb-3">
								<label class="form-label fw-bold text-secondary small">Postinumero</label>
								<input type="text" class="form-control" id="pyPostinumero"
									name="postinumero" maxlength="10">
							</div>
							<div class="col-md-8 mb-3">
								<label class="form-label fw-bold text-secondary small">Postitoimipaikka</label>
								<input type="text" class="form-control" id="pyPostitoimipaikka"
									name="postitoimipaikka">
							</div>
						</div>

						<div class="row g-3">
							<div class="col-md-6 mb-3">
								<label class="form-label fw-bold text-secondary small">Yksikön
									puhelinnumero</label> <input type="tel" class="form-control"
									id="pyPuhelin" name="puhelin">
							</div>
							<div class="col-md-6 mb-3">
								<label class="form-label fw-bold text-secondary small">Yksikön
									sähköposti</label> <input type="email" class="form-control"
									id="pySahkoposti" name="sahkoposti">
							</div>
						</div>

						<div class="mb-3">
							<label class="form-label fw-bold text-secondary small">Lisätiedot
								/ Yksikön kuvaus</label>
							<textarea class="form-control" id="pyKuvaus" name="kuvaus"
								rows="3"></textarea>
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

	<!-- 💡 PALAUTETTU: MODAL LOKIMERKINNÄN MUOKKAUKSEEN -->
	<div class="modal fade" id="muokkaaLokiModal" tabindex="-1"
		aria-labelledby="muokkaaLokiModalLabel" aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content border-0 shadow-lg">
				<!-- JavaScript tunnistaa tämän lomakkeen id:n perusteella -->
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
							<!-- JavaScript syöttää muokattavan tekstin tähän id-kenttään -->
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

						<!-- DYNAAMINEN PUDOTUSVALIKKO PALVELUYKSIKÖN VALINTAAN -->
						<div class="mb-3 pt-2 border-top">
							<label class="form-label fw-bold text-secondary small">Kohdistetaanko
								tiettyyn palveluyksikköön?</label> <select class="form-select"
								name="palveluyksikkoId">
								<option value="">-- Yleinen organisaatiotason kontakti
									--</option>
								<c:forEach var="yksikko" items="${asiakas.palveluyksikot}">
									<option value="${yksikko.id}">${yksikko.nimi}</option>
								</c:forEach>
							</select>
							<div class="form-text text-muted" style="font-size: 0.8em;">
								Jos jätät tämän tyhjäksi, henkilö näkyy yrityksen yleisissä
								yhteystiedoissa.</div>
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
					<div class="modal-body p-4">
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

	<!-- MODAL PALVELUYKSIKÖN MUOKKAUKSEEN -->
	<div class="modal fade" id="muokkaaPyModal" tabindex="-1"
		aria-labelledby="muokkaaPyModalLabel" aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered modal-lg">
			<div class="modal-content border-0 shadow-lg">
				<form id="muokkaaPyForm" method="post" action="">
					<input type="hidden" name="asiakasId" value="${asiakas.id}">
					<div class="modal-header bg-dark text-white">
						<h5 class="modal-title fw-bold" id="muokkaaPyModalLabel">Muokkaa
							palveluyksikköä</h5>
						<button type="button"
							class="btn btn-sm btn-outline-primary py-0 px-2 muokkaa-py-btn"
							style="font-size: 0.8em;" data-id="${yksikko.id}"
							data-nimi="${yksikko.nimi}"
							data-alue="${yksikko.hyvinvointialue}"
							data-katu="${yksikko.katuosoite}"
							data-pno="${yksikko.postinumero}"
							data-ptp="${yksikko.postitoimipaikka}"
							data-puh="${yksikko.puhelin}" data-email="${yksikko.sahkoposti}"
							data-kuvaus="<c:out value='${yksikko.kuvaus}'/>">
							Muokkaa</button>
					</div>
					<div class="modal-body p-4 text-start">
						<div class="mb-3">
							<label class="form-label fw-bold text-secondary small">Palveluyksikön
								/ Toimipisteen nimi *</label> <input type="text" class="form-control"
								id="pyNimi" name="nimi" required>
						</div>

						<div class="row g-3">
							<div class="col-md-6 mb-3">
								<label class="form-label fw-bold text-secondary small">Hyvinvointialue</label>
								<select class="form-select" id="pyHyvinvointialue"
									name="hyvinvointialue">
									<option value="">-- Valitse hyvinvointialue --</option>
									<c:forEach var="alue" items="${hyvinvointialueet}">
										<option value="${alue}">${alue.nimi}</option>
									</c:forEach>
								</select>
							</div>
							<div class="col-md-6 mb-3">
								<label class="form-label fw-bold text-secondary small">Katuosoite</label>
								<input type="text" class="form-control" id="pyKatuosoite"
									name="katuosoite">
							</div>
						</div>

						<div class="row g-3">
							<div class="col-md-4 mb-3">
								<label class="form-label fw-bold text-secondary small">Postinumero</label>
								<input type="text" class="form-control" id="pyPostinumero"
									name="postinumero" maxlength="10">
							</div>
							<div class="col-md-8 mb-3">
								<label class="form-label fw-bold text-secondary small">Postitoimipaikka</label>
								<input type="text" class="form-control" id="pyPostitoimipaikka"
									name="postitoimipaikka">
							</div>
						</div>

						<div class="row g-3">
							<div class="col-md-6 mb-3">
								<label class="form-label fw-bold text-secondary small">Yksikön
									puhelinnumero</label> <input type="tel" class="form-control"
									id="pyPuhelin" name="puhelin">
							</div>
							<div class="col-md-6 mb-3">
								<label class="form-label fw-bold text-secondary small">Yksikön
									sähköposti</label> <input type="email" class="form-control"
									id="pySahkoposti" name="sahkoposti">
							</div>
						</div>

						<div class="mb-3">
							<label class="form-label fw-bold text-secondary small">Lisätiedot
								/ Yksikön kuvaus</label>
							<textarea class="form-control" id="pyKuvaus" name="kuvaus"
								rows="3"></textarea>
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

		
		const yhElement = document.getElementById('muokkaaYhModal');
		const yhModalOlio = yhElement ? new bootstrap.Modal(yhElement) : null;

		const lokiElement = document.getElementById('muokkaaLokiModal');
		const lokiModalOlio = lokiElement ? new bootstrap.Modal(lokiElement) : null;

		const palveluElement = document.getElementById('muokkaaPalveluModal');
		const palveluModalOlio = palveluElement ? new bootstrap.Modal(palveluElement) : null;

		
		/* 1. Yhteyshenkilön muokkaustoiminto */
		document.querySelectorAll('.muokkaa-yh-btn').forEach(btn => {
			btn.addEventListener('click', function() {
				const id = this.getAttribute('data-id')
				const nimi = this.getAttribute('data-nimi')
				const rooli = this.getAttribute('data-rooli')
				const email = this.getAttribute('data-email')
				const puh = this.getAttribute('data-puh')
				
				const form = document.getElementById('muokkaaYhForm')
				if (form) form.action = '${pageContext.request.contextPath}/yhteyshenkilo/muokkaa/' + id
				
				if (document.getElementById('yhNimi')) document.getElementById('yhNimi').value = nimi
				if (document.getElementById('yhRooli')) document.getElementById('yhRooli').value = rooli
				if (document.getElementById('yhSahkoposti')) document.getElementById('yhSahkoposti').value = email
				if (document.getElementById('yhPuhelin')) document.getElementById('yhPuhelin').value = puh
				
				if (yhModalOlio) yhModalOlio.show()
			})
		})
		
		/* 2. Lokimerkinnän muokkaustoiminto */
		document.querySelectorAll('.muokkaa-loki-btn').forEach(btn => {
			btn.addEventListener('click', function() {
				const id = this.getAttribute('data-id')
				const teksti = this.getAttribute('data-teksti')
				
				const form = document.getElementById('muokkaaLokiForm')
				if (form) form.action = '${pageContext.request.contextPath}/kirjaus/muokkaa/' + id
				
				if (document.getElementById('lokiTeksti')) document.getElementById('lokiTeksti').value = teksti
				
				if (lokiModalOlio) lokiModalOlio.show()
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
				if (form) form.action = '${pageContext.request.contextPath}/palvelu/muokkaa/' + id
				
				if (document.getElementById('muokkaaPalveluNimi')) document.getElementById('muokkaaPalveluNimi').value = tuoteNimi
				if (document.getElementById('muokkaaPalveluMaara')) document.getElementById('muokkaaPalveluMaara').value = maara
				if (document.getElementById('muokkaaPalveluHinta')) document.getElementById('muokkaaPalveluHinta').value = hinta
				if (document.getElementById('muokkaaPalveluPvm')) document.getElementById('muokkaaPalveluPvm').value = pvm
				
				if (palveluModalOlio) palveluModalOlio.show()
			})
		})

				/* 4. Palveluyksikön muokkaustoiminto */
		document.querySelectorAll('.muokkaa-py-btn').forEach(btn => {
			btn.addEventListener('click', function() {
				const id = this.getAttribute('data-id')
				const nimi = this.getAttribute('data-nimi')
				const alue = this.getAttribute('data-alue')
				const katu = this.getAttribute('data-katu')
				const pno = this.getAttribute('data-pno')
				const ptp = this.getAttribute('data-ptp')
				const puh = this.getAttribute('data-puh')
				const email = this.getAttribute('data-email')
				const kuvaus = this.getAttribute('data-kuvaus')
				
				const form = document.getElementById('muokkaaPyForm')
				form.action = '${pageContext.request.contextPath}/palveluyksikko/muokkaa/' + id
				
				document.getElementById('pyNimi').value = nimi
				document.getElementById('pyHyvinvointialue').value = alue
				document.getElementById('pyKatuosoite').value = katu
				document.getElementById('pyPostinumero').value = pno
				document.getElementById('pyPostitoimipaikka').value = ptp
				document.getElementById('pyPuhelin').value = puh
				document.getElementById('pySahkoposti').value = email
				document.getElementById('pyKuvaus').value = kuvaus
				
				// Alustetaan ja näytetään modal suoralla, puhtaalla komennolla ilman kytkentöjä
				const modalElement = document.getElementById('muokkaaPyModal');
				if (modalElement) {
					const uusiModal = new bootstrap.Modal(modalElement);
					uusiModal.show();
				}
			})
		})



		
	</script>
</body>
</html>
