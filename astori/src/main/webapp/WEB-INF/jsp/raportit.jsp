<%@ page contentType="text/html;charset=UTF-8" language="java" %>
	<%@ taglib prefix="c" uri="jakarta.tags.core" %>
		<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
			<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
				<!DOCTYPE html>
				<html lang="fi">

				<head>
					<meta charset="UTF-8">
					<meta name="viewport" content="width=device-width, initial-scale=1.0">
					<title>Raportit ja Käyttöloki - Astori</title>
					<!-- Lataa paikallisen Bootstrap-tyylitiedoston resources-juuresta -->
					<link href="${pageContext.request.contextPath}/resources/bootstrap.min.css" rel="stylesheet" />


					<style>
						body {
							background-color: #f8f9fa;
						}

						.report-card {
							background: white;
							border-radius: 8px;
							padding: 20px;
							box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
							border: 1px solid #dee2e6;
						}

						.table-responsive {
							background: white;
							border-radius: 8px;
							padding: 15px;
							box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
						}


						#kirjaukset-pane:not(.active)~* .vain-kirjaukset-tabille,
						body:has(#kirjaukset-pane:not(.active)) .vain-kirjaukset-tabille {
							display: none !important;
						}

						body:has(#loki-pane.active) #kirjausHakuFrame {
							display: none !important;
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
								<a class="nav-link" href="${pageContext.request.contextPath}/asiakkaat">Asiakkaat</a> <a
									class="nav-link" href="${pageContext.request.contextPath}/asetukset">Asetukset</a>
								<a class="nav-link active fw-bold"
									href="${pageContext.request.contextPath}/raportit">Raportit</a> <a class="nav-link"
									href="${pageContext.request.contextPath}/kalenteri">Kalenteri</a>
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
						<div class="mb-4">
							<h2 class="text-dark fw-bold mb-1">Järjestelmän raportit</h2>
							<p class="text-muted">Tarkastele järjestelmän tilaa, tilastoja ja
								lakisääteistä käyttölokia.</p>
						</div>

						<!-- TILASTOKORTIT -->
						<div class="row mb-5">
							<div class="col-md-4 mb-3">
								<div class="report-card d-flex align-items-center justify-content-between">
									<div>
										<h6 class="text-uppercase text-muted fw-bold mb-1"
											style="font-size: 0.8rem; letter-spacing: 1px;">Asiakkaat
											yhteensä</h6>
										<h2 class="text-dark fw-bold mb-0">${asiakkaatYhteensa}</h2>
									</div>
									<div class="bg-primary bg-opacity-10 text-primary rounded p-3">
										<svg xmlns="http://w3.org" width="24" height="24" fill="currentColor"
											class="bi bi-people-fill" viewBox="0 0 16 16">
											<path
												d="M7 14s-1 0-1-1 1-4 5-4 5 3 5 4-1 1-1 1zm4-6a3 3 0 1 0 0-6 3 3 0 0 0 0 6m-5.784 6A2.24 2.24 0 0 1 5 13c0-1.355.68-2.75 1.936-3.72A6.3 6.3 0 0 0 5 9c-4 0-5 3-5 4s1 1 1 1zM4.5 8a2.5 2.5 0 1 0 0-5 2.5 2.5 0 0 0 0 5" />
										</svg>
									</div>
								</div>
							</div>

							<div class="col-md-4 mb-3">
								<div class="report-card d-flex align-items-center justify-content-between">
									<div>
										<h6 class="text-uppercase text-muted fw-bold mb-1"
											style="font-size: 0.8rem; letter-spacing: 1px;">Lokitapahtumat</h6>
										<h2 class="text-dark fw-bold mb-0">${lokirivejaYhteensa}</h2>
									</div>
									<div class="bg-info bg-opacity-10 text-info rounded p-3">
										<!-- Korjattu aloitustägi yhdelle riville oikealla W3C-osoitteella -->
										<svg xmlns="http://w3.org" width="24" height="24" fill="currentColor"
											class="bi bi-shield-check" viewBox="0 0 16 16">
											<path
												d="M5.338 1.59a61 61 0 0 0-2.837.856.481.481 0 0 0-.328.39c-.554 4.157.726 7.19 2.253 9.188a10.7 10.7 0 0 0 2.287 2.233c.346.244.652.244 1 .01a10.7 10.7 0 0 0 2.287-2.233c1.527-1.997 2.807-5.031 2.253-9.188a.48.48 0 0 0-.328-.39c-.651-.213-1.75-.56-2.837-.855C9.552 1.29 8.931 1.057 8 1.057c-.93 0-1.552.232-2.662.533zM7.468 7.668a.5.5 0 1 1 .708-.708L9.44 8.224l2.096-2.097a.5.5 0 1 1 .707.707l-2.45 2.45a.5.5 0 0 1-.708 0z" />
										</svg>
									</div>
								</div>
							</div>
						</div>


						<!--Tässä kohdassa oli hakuehot olivat aiemmin. Olivat silloin yhteiset kaikilla välilehdille-->


						<!-- 💡 UUSI: VÄLILEHTIEN PAINIKKEET (Säilyttää sivuston asettelun siistinä) -->
						<ul class="nav nav-tabs mb-4" id="raporttiTabs" role="tablist">
							<li class="nav-item" role="presentation">
								<button class="nav-link active fw-bold text-dark" id="kirjaukset-tab"
									data-bs-toggle="tab" data-bs-target="#kirjaukset-pane" type="button" role="tab"
									aria-controls="kirjaukset-pane" aria-selected="true">📋
									Asiakaskohtaiset päiväkirjaukset</button>
							</li>

							<li class="nav-item" role="presentation">
								<button class="nav-link fw-bold text-dark" id="tarkeat-tab" data-bs-toggle="tab"
									data-bs-target="#tarkeatSisalto" type="button" role="tab"
									aria-controls="tarkeatSisalto" aria-selected="false">
									📌 Tärkeät huomiot (${tarkeatKirjaukset.size()})</button>
							</li>

							<li class="nav-item">
								<button class="nav-link fw-bold text-dark" id="myynti-tab" data-bs-toggle="tab"
									data-bs-target="#myyntiSisalto" type="button" role="tab">💰 Myyntiraportti</button>
							</li>

							<li class="nav-item">
								<button class="nav-link fw-bold text-dark" id="ajot-tab" data-bs-toggle="tab"
									data-bs-target="#ajotSisalto" type="button" role="tab">Ajopäiväkirja</button>
							</li>

							<li class="nav-item" role="presentation">
								<button class="nav-link fw-bold text-dark" id="loki-tab" data-bs-toggle="tab"
									data-bs-target="#loki-pane" type="button" role="tab" aria-controls="loki-pane"
									aria-selected="false">
									🛡️ Järjestelmän käyttöloki (Audit Trail)</button>
							</li>
						</ul>

						<!-- 🔌 KORJAUS: Palautetaan globaali piilokenttä välilehtien JavaScript-kuuntelijoita varten -->
						<input type="hidden" id="aktiivinenTabInput" name="tab"
							value="${not empty param.tab ? param.tab : 'kirjaukset'}">

						<div id="kirjausHakuFrame" class="card border shadow-sm p-3 mb-4 bg-white rounded-3">
							<form id="raporttiHakuForm" action="${pageContext.request.contextPath}/raportit" method="get"
								class="row g-2 align-items-end">
								<input type="hidden" name="sivu" value="0">
								<input type="hidden" name="kSivu" value="0">
								<input type="hidden" id="raporttiHakuTab" name="tab" value="kirjaukset">

								<div class="col-md-3 col-sm-6 text-start">
									<label for="alkuPvm_k"
										class="form-label small fw-bold text-secondary">Alkupäivämäärä</label>
										<input type="date" id="alkuPvm_k" name="alkuPvm"
										class="form-control form-control-sm" value="${alkuPvm}">
								</div>

								<div class="col-md-3 col-sm-6 text-start">
									<label for="loppuPvm_k"
										class="form-label small fw-bold text-secondary">Loppupäivämäärä</label>
										<input type="date" id="loppuPvm_k" name="loppuPvm"
										class="form-control form-control-sm" value="${loppuPvm}">
								</div>

								<div class="col-md-3 col-12 text-start">
									<label for="suodatinTyyppi_k"
										class="form-label small fw-bold text-secondary">Kirjaustyyppi /
										Luokitus</label>
									<select name="tyyppi" id="suodatinTyyppi_k"
										class="form-select form-select-sm">
										<option value="">-- Kaikki kirjaukset (Ei rajoitusta) --</option>
										<c:forEach items="${kirjaustyypit}" var="kt">
											<option value="${kt.id}" ${kt.id==valittuTyyppiId ? 'selected' : ''
											}>${kt.nimi}</option>
										</c:forEach>
									</select>
								</div>

								<div class="col-md-3 col-12 d-flex gap-2">
									<button type="submit"
										class="btn btn-sm btn-primary fw-bold px-3 w-100 rounded-pill">🔍 Hae /
										Suodata</button>
									<a id="nollaaRaporttiHaku" href="${pageContext.request.contextPath}/raportit?tab=kirjaukset"
										class="btn btn-sm btn-outline-secondary px-3 w-100 rounded-pill">Nollaa</a>
								</div>
							</form>
						</div>

						<!-- VÄLILEHTIEN SISÄLLÖT -->
						<div class="tab-content" id="raporttiTabsSisalto">

							<!-- ==================== ALIVÄLILEHTI 1: ASIAKASKIRJAUKSET ==================== -->
							<div class="tab-pane fade show active" id="kirjaukset-pane" role="tabpanel"
								aria-labelledby="kirjaukset-tab">

								<div class="d-flex justify-content-between align-items-center mb-3">
										<h5 class="text-secondary mb-0 small fw-bold">Asiakaskohtaiset päiväkirjaukset aikajärjestyksessä, uusin ensin</h5>
									<c:if test="${kaytossaOletus30Pv}">
										<span
											class="badge bg-warning-subtle text-warning border border-warning-subtle px-3 py-1 rounded-pill small fw-bold">
											Näytetään automaattisesti viimeiset 30 vuorokautta
										</span>
									</c:if>
								</div>

								<div class="list-group shadow-sm mb-3">
									<c:forEach var="kj" items="${kirjausRivit}">
										<div class="list-group-item p-3 text-start">
											<div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-2">
												<small class="text-muted fw-semibold">${kj.luontiaika.toString().replace('T', ' ').substring(0, 16)}</small>
												<a href="${pageContext.request.contextPath}/asiakas/${kj.asiakas.id}" class="fw-bold text-decoration-none"><c:out value="${kj.asiakas.nimi}" /></a>
												<c:if test="${kj.kirjaustyyppi != null}">
													<span class="badge text-white fw-bold" style="background-color: ${kj.kirjaustyyppi.vari};">${kj.kirjaustyyppi.nimi}</span>
												</c:if>
											</div>
											<p class="mb-0 text-dark small" style="white-space: pre-line; line-height: 1.5;"><c:out value="${kj.teksti}" /></p>
										</div>
									</c:forEach>
									<c:if test="${empty kirjausRivit}">
										<div class="p-4 bg-white text-center text-muted border rounded small">Ei kirjauksia valitulla ajanjaksolla.</div>
									</c:if>
								</div>

								<!-- SIVUTUSPALLKI 1 -->
								<c:if test="${kirjausKokonaissivut > 1}">
									<nav aria-label="Kirjausten sivutus" class="d-flex justify-content-center mb-3">
										<ul class="pagination pagination-sm mb-0">
											<li class="page-item ${nykyinenKirjausSivu == 0 ? 'disabled' : ''}">
												<a class="page-link"
													href="${pageContext.request.contextPath}/raportit?sivu=${nykyinenSivu}&kSivu=${nykyinenKirjausSivu - 1}&alkuPvm=${alkuPvm}&loppuPvm=${loppuPvm}&tyyppi=${not empty valittuTyyppiId ? valittuTyyppiId : ''}">&laquo;
													Edellinen</a>
											</li>
											<c:forEach var="i" begin="0" end="${kirjausKokonaissivut - 1}">
												<li class="page-item ${nykyinenKirjausSivu == i ? 'active' : ''}">
													<a class="page-link"
														href="${pageContext.request.contextPath}/raportit?sivu=${nykyinenSivu}&kSivu=${i}&alkuPvm=${alkuPvm}&loppuPvm=${loppuPvm}&tyyppi=${not empty valittuTyyppiId ? valittuTyyppiId : ''}">${i
														+ 1}</a>
												</li>
											</c:forEach>
											<li
												class="page-item ${nykyinenKirjausSivu == kirjausKokonaissivut - 1 ? 'disabled' : ''}">
												<a class="page-link"
													href="${pageContext.request.contextPath}/raportit?sivu=${nykyinenSivu}&kSivu=${nykyinenKirjausSivu + 1}&alkuPvm=${alkuPvm}&loppuPvm=${loppuPvm}&tyyppi=${not empty valittuTyyppiId ? valittuTyyppiId : ''}">Seuraava
													&raquo;</a>
											</li>
										</ul>
									</nav>
								</c:if>
							</div> <!-- /tab-pane 1 -->


							<!-- ==================== ALIVÄLILEHTI 2: KÄYTTÖLOKI (AUDIT TRAIL) ==================== -->
							<div class="tab-pane fade" id="loki-pane" role="tabpanel" aria-labelledby="loki-tab">

								<!-- 🔍 ITSENÄINEN HAKULOMAKE JÄRJESTELMÄLOKILLE -->
								<div class="card border shadow-sm p-3 mb-4 bg-white rounded-3">
									<form action="${pageContext.request.contextPath}/raportit" method="get"
										class="row g-2 align-items-end">
										<input type="hidden" name="sivu" value="0">
										<input type="hidden" name="kSivu" value="0">
										<input type="hidden" name="tab" value="loki">

										<div class="col-md-4 col-sm-6 text-start">
											<label for="alkuPvm_l"
												class="form-label small fw-bold text-secondary">Alkupäivämäärä</label>
											<input type="date" id="alkuPvm_l" name="alkuPvm"
												class="form-control form-control-sm" value="${alkuPvm}">
										</div>

										<div class="col-md-4 col-sm-6 text-start">
											<label for="loppuPvm_l"
												class="form-label small fw-bold text-secondary">Loppupäivämäärä</label>
											<input type="date" id="loppuPvm_l" name="loppuPvm"
												class="form-control form-control-sm" value="${loppuPvm}">
										</div>

										<div class="col-md-4 col-12 d-flex gap-2">
											<button type="submit"
												class="btn btn-sm btn-primary fw-bold px-3 w-100 rounded-pill">🕵️‍♂️
												Päivitä ajanjakso</button>
											<a href="${pageContext.request.contextPath}/raportit?tab=loki"
												class="btn btn-sm btn-outline-secondary px-3 w-100 rounded-pill">Nollaa</a>
										</div>
									</form>
								</div>

								<div class="d-flex justify-content-between align-items-center mb-3">
									<h5 class="text-secondary mb-0 small fw-bold">Auditoitavat järjestelmätapahtumat ja
										käyttäjälokit</h5>
								</div>

								<div class="table-responsive border rounded-3 shadow-sm bg-white">
									<table class="table table-hover align-middle mb-0 small">
										<thead class="table-light text-secondary">
											<tr>
												<th>Aika</th>
												<th>Käyttäjä</th>
												<th>Toiminto</th>
												<th>Tapahtuman kuvaus</th>
											</tr>
										</thead>
										<tbody>
											<c:forEach var="rivi" items="${lokirivit}">
												<tr>
													<td class="text-muted text-nowrap">
														<c:if test="${not empty rivi.aikaleima}">
															${rivi.aikaleima.toString().replace('T', ' ').substring(0,
															19)}
														</c:if>
													</td>
													<td><span
															class="badge bg-secondary px-2.5 py-1.5">${rivi.kayttajatunnus}</span>
													</td>
													<td><span class="badge 
														<c:choose>
															<c:when test=" ${rivi.toiminto=='KATSELU' }">bg-light text-dark border</c:when>
															<c:when test="${rivi.toiminto == 'LISÄYS'}">bg-success
															</c:when>
															<c:when test="${rivi.toiminto == 'MUOKKAUS'}">bg-warning
																text-dark</c:when>
															<c:when test="${rivi.toiminto == 'POISTO'}">bg-danger
															</c:when>
															<c:otherwise>bg-info</c:otherwise>
															</c:choose>">
															${rivi.toiminto}
														</span></td>
													<td class="text-dark fw-medium">${rivi.kuvaus}</td>
												</tr>
											</c:forEach>
											<c:if test="${empty lokirivit}">
												<tr>
													<td colspan="4" class="text-center py-4 text-muted italic">Lokiin ei
														ole vielä tallentunut yhtään tapahtumaa valitulla aikavälillä.
													</td>
												</tr>
											</c:if>
										</tbody>
									</table>
								</div>

								<c:if test="${kokonaissivut > 1}">
									<nav aria-label="Lokin sivutus" class="d-flex justify-content-center mt-4 mb-3">
										<ul class="pagination pagination-sm mb-0">
											<li class="page-item ${nykyinenSivu == 0 ? 'disabled' : ''}">
												<a class="page-link"
													href="${pageContext.request.contextPath}/raportit?sivu=${nykyinenSivu - 1}&kSivu=${nykyinenKirjausSivu}&alkuPvm=${alkuPvm}&loppuPvm=${loppuPvm}">&laquo;
													Edellinen</a>
											</li>
											<c:forEach var="i" begin="0" end="${kokonaissivut - 1}">
												<li class="page-item ${nykyinenSivu == i ? 'active' : ''}">
													<a class="page-link"
														href="${pageContext.request.contextPath}/raportit?sivu=${i}&kSivu=${nykyinenKirjausSivu}&alkuPvm=${alkuPvm}&loppuPvm=${loppuPvm}">${i
														+ 1}</a>
												</li>
											</c:forEach>
											<li
												class="page-item ${nykyinenSivu == kokonaissivut - 1 ? 'disabled' : ''}">
												<a class="page-link"
													href="${pageContext.request.contextPath}/raportit?sivu=${nykyinenSivu + 1}&kSivu=${nykyinenKirjausSivu}&alkuPvm=${alkuPvm}&loppuPvm=${loppuPvm}">Seuraava
													&raquo;</a>
											</li>
										</ul>
									</nav>
								</c:if>
							</div> <!-- /tab-pane 2 -->


							<!-- ==================== ALIVÄLILEHTI 3: MYYNTIRAPORTTI ==================== -->
							<div class="tab-pane fade" id="myyntiSisalto" role="tabpanel" aria-labelledby="myynti-tab">

								<div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
									<div>
										<h5 class="fw-bold text-dark mb-0">Toteutunut liikevaihto ajanjaksolta</h5>
										<small class="text-muted">
											<c:choose>
												<c:when test="${kaytossaOletusKuluvaKk}">Näytetään oletuksena kuluvan
													kuukauden myynnit. Voit vaihtaa ajanjaksoa yllä olevilla päivämäärillä.</c:when>
												<c:otherwise>Myynnit näytetään yllä valitulta ajanjaksolta.</c:otherwise>
											</c:choose>
										</small>
									</div>

									<div class="d-flex gap-2">
										<div class="bg-light p-2 rounded border text-center shadow-xs"
											style="min-width: 120px;">
											<div class="text-uppercase text-secondary fw-semibold"
												style="font-size: 0.7em;">Veroton (0%)</div>
											<div class="fw-bold text-dark" style="font-size: 1.1em;">
												<fmt:formatNumber value="${kokonaisVeroton}" type="currency"
													currencySymbol="€" />
											</div>
										</div>
										<div class="bg-light p-2 rounded border text-center shadow-xs"
											style="min-width: 100px;">
											<div class="text-uppercase text-secondary fw-semibold"
												style="font-size: 0.7em;">ALV-osuus</div>
											<div class="fw-bold text-muted" style="font-size: 1.1em;">
												<fmt:formatNumber value="${kokonaisAlv}" type="currency"
													currencySymbol="€" />
											</div>
										</div>
										<div class="bg-primary-subtle p-2 rounded border border-primary-subtle text-center shadow-xs"
											style="min-width: 130px;">
											<div class="text-uppercase text-primary fw-bold" style="font-size: 0.7em;">
												Verollinen YHT</div>
											<div class="fw-bold text-primary" style="font-size: 1.1em;">
												<fmt:formatNumber value="${kokonaisVerollinen}" type="currency"
													currencySymbol="€" />
											</div>
										</div>
									</div>
								</div>

								<div class="table-responsive">
									<table class="table table-hover align-middle table-sm border small">
										<thead class="table-light text-secondary">
											<tr>
												<th scope="col">Päivämäärä</th>
												<th scope="col">Asiakas / Organisaatio</th>
												<th scope="col">Tuote / Palvelu</th>
												<th scope="col" class="text-end">Määrä</th>
												<th scope="col" class="text-end">Yksikköhinta</th>
												<th scope="col" class="text-center">ALV</th>
												<th scope="col" class="text-end">Veroton</th>
												<th scope="col" class="text-end">ALV €</th>
												<th scope="col" class="text-end fw-bold text-dark">Verollinen</th>
											</tr>
										</thead>
										<tbody>
											<c:forEach items="${myyntirivit}" var="rivi">
												<tr>
													<td class="text-muted fw-semibold">
														<fmt:parseDate value="${rivi.ostopaivamaara}"
															pattern="yyyy-MM-dd" var="parsedDate" />
														<fmt:formatDate value="${parsedDate}" pattern="dd.MM.yyyy" />
													</td>
													<td><a href="${pageContext.request.contextPath}/asiakas/${rivi.asiakas.id}"
															class="text-primary fw-bold text-decoration-none">
															<c:out value="${rivi.asiakas.nimi}" />
														</a></td>
													<td class="fw-semibold text-dark">
														<c:out value="${rivi.tuote.nimi}" />
													</td>
													<td class="text-end">${rivi.maara}</td>
													<td class="text-end">
														<fmt:formatNumber value="${rivi.myyntihinta}" type="currency"
															currencySymbol="€" />
													</td>
													<td class="text-center"><span
															class="badge bg-light text-secondary border">${rivi.alvKanta.getProsentti()}%</span>
													</td>
													<td class="text-end">
														<fmt:formatNumber value="${rivi.getKokonaishinta()}"
															type="currency" currencySymbol="€" />
													</td>
													<td class="text-end text-muted">
														<fmt:formatNumber value="${rivi.getAlvOsuus()}" type="currency"
															currencySymbol="€" />
													</td>
													<td class="text-end fw-bold text-primary">
														<fmt:formatNumber value="${rivi.getVerollinenKokonaishinta()}"
															type="currency" currencySymbol="€" />
													</td>
												</tr>
											</c:forEach>
											<c:if test="${empty myyntirivit}">
												<tr>
													<td colspan="9" class="text-center py-4 text-muted italic">Valitulta
														ajanjaksolta ei löytynyt toteutuneita tuotemyyntejä.</td>
												</tr>
											</c:if>
										</tbody>
									</table>
								</div>
							</div> <!-- /tab-pane 3 -->

							<!-- Tämä sulkee nyt Myyntiraportti-välilehden siististi! -->

							<!-- ==================== ALIVÄLILEHTI 4: 📌 TÄRKEÄT HUOMIOT ==================== -->
							<div class="tab-pane fade p-3 bg-white border border-top-0 rounded-bottom shadow-sm"
								id="tarkeatSisalto" role="tabpanel" aria-labelledby="tarkeat-tab">

								<div class="mb-3">
									<h5 class="fw-bold text-danger mb-0">📌 Asiakkuuksien tärkeät ja huomionarvoiset
										kirjaukset</h5>
									<small class="text-muted">Näkymään nousevat kaikki ne merkinnät, jotka ovat merkitty
										tärkeäksi</small>
								</div>

								<div class="table-responsive">
									<table class="table table-hover align-middle table-sm mb-0 border small">
										<thead class="table-dark">
											<tr>
												<th scope="col" style="width: 15%;">Päivämäärä</th>
												<th scope="col" style="width: 20%;">Asiakas / Organisaatio</th>
												<th scope="col" style="width: 65%;">Tärkeä merkintä / Huomio</th>
											</tr>
										</thead>
										<tbody>
											<c:forEach items="${tarkeatKirjaukset}" var="tk">

												<!-- 🔌 Suodatetaan lennosta vain ne tärkeät, jotka vastaavat valittua kirjaustyyppiä (jos haku päällä) -->
												<c:if
													test="${empty valittuTyyppiId or (tk.kirjaustyyppi != null and tk.kirjaustyyppi.id == valittuTyyppiId)}">
													<tr class="table-danger-subtle">
														<td class="text-muted fw-semibold">
															<c:set var="luontiAikaStr"
																value="${tk.luontiaika.toString().substring(0, 16)}" />
															<fmt:parseDate value="${luontiAikaStr}"
																pattern="yyyy-MM-dd'T'HH:mm" var="parsittuTa" />
															<fmt:formatDate value="${parsittuTa}"
																pattern="dd.MM.yyyy 'klo' HH:mm" />
														</td>
														<td>
															<a href="${pageContext.request.contextPath}/asiakas/${tk.asiakas.id}"
																class="text-primary fw-bold text-decoration-none">
																<c:out value="${tk.asiakas.nimi}" />
															</a>
															<c:if test="${tk.kirjaustyyppi != null}">
																<br>
																<span
																	class="badge text-white fw-bold px-2 py-0.5 rounded-pill mt-1"
																	style="background-color: ${tk.kirjaustyyppi.vari}; font-size: 0.7rem;">
																	${tk.kirjaustyyppi.nimi}
																</span>
															</c:if>
														</td>
														<td class="text-dark py-2"
															style="white-space: pre-line; line-height: 1.4;">
															<c:out value="${tk.teksti}" />
														</td>
													</tr>
												</c:if>

											</c:forEach>
											<c:if test="${empty tarkeatKirjaukset}">
												<tr>
													<td colspan="3" class="text-center py-4 text-muted italic">Valitulta
														ajanjaksolta ei ole merkitty yhtään kirjausta tärkeäksi.</td>
												</tr>
											</c:if>
										</tbody>
									</table>
								</div>
							</div> <!-- /tab-pane 4 -->

							<div class="tab-pane fade" id="ajotSisalto" role="tabpanel" aria-labelledby="ajot-tab">
								<div class="d-flex justify-content-between align-items-start flex-wrap gap-2 mb-3">
									<div>
										<h4 class="h5 fw-bold mb-1">Asiakkailta laskutettavat ajot</h4>
										<p class="text-muted small mb-0">Kirjaa asiakasajot ja seuraa matkamittarista laskettuja kilometrejä.</p>
									</div>
									<div class="text-end">
										<div class="small text-muted">Kilometrit valitulla aikavälillä</div>
										<strong><fmt:formatNumber value="${ajojenKilometrit}" minFractionDigits="0" maxFractionDigits="2" /> km</strong>
									</div>
								</div>

								<c:if test="${param.ajoVirhe == 'virheellinen'}">
									<div class="alert alert-danger" role="alert">Tarkista ajon tiedot ja varmista, että loppulukema ei ole alkulukemaa pienempi.</div>
								</c:if>

								<div class="border rounded p-3 bg-white mb-4">
									<form action="${pageContext.request.contextPath}/raportit/ajot/lisaa" method="post" class="row g-3">
										<div class="col-md-4">
											<label for="uusiAjoAsiakkaat" class="form-label">Asiakkaat (valinnainen)</label>
											<select id="uusiAjoAsiakkaat" name="asiakasIds" class="form-select" multiple size="4">
												<c:forEach items="${omatAsiakkaat}" var="asiakas">
													<option value="${asiakas.id}"><c:out value="${asiakas.nimi}" /></option>
												</c:forEach>
											</select>
											<div class="form-text">Voit valita useita asiakkaita Ctrl- tai Cmd-näppäimellä tai jättää valinnan tyhjäksi.</div>
										</div>
										<div class="col-md-2">
											<label for="uusiAjoPaivamaara" class="form-label">Päivämäärä</label>
											<input id="uusiAjoPaivamaara" name="paivamaara" type="text" data-finnish-date placeholder="pp.kk.vvvv" inputmode="numeric" autocomplete="off" class="form-control" value="${tanaan}" required>
										</div>
										<div class="col-md-3">
											<label for="uusiAjoLahto" class="form-label">Lähtöpaikka</label>
											<input id="uusiAjoLahto" name="lahtopaikka" maxlength="200" class="form-control" required>
										</div>
										<div class="col-md-3">
											<label for="uusiAjoKohde" class="form-label">Kohde</label>
											<input id="uusiAjoKohde" name="kohde" maxlength="200" class="form-control" required>
										</div>
										<div class="col-md-6">
											<label for="uusiAjoTarkoitus" class="form-label">Selite</label>
											<textarea id="uusiAjoTarkoitus" name="tarkoitus" rows="3" class="form-control" required></textarea>
										</div>
										<div class="col-md-3 d-flex align-items-end">
											<div class="form-check mb-2"><input id="uusiAjoEdestakainen" name="edestakainen" type="checkbox" class="form-check-input"><label for="uusiAjoEdestakainen" class="form-check-label">Edestakainen matka</label></div>
										</div>
										<div class="col-md-2">
											<label for="uusiAjoAlku" class="form-label">Mittari alussa</label>
											<input id="uusiAjoAlku" name="alkumatkamittari" type="number" min="0" step="0.01" class="form-control" required>
										</div>
										<div class="col-md-2">
											<label for="uusiAjoLoppu" class="form-label">Mittari lopussa</label>
											<input id="uusiAjoLoppu" name="loppumatkamittari" type="number" min="0" step="0.01" class="form-control" required>
										</div>
										<div class="col-12 d-flex justify-content-end">
											<button type="submit" class="btn btn-primary">Lisää ajo</button>
										</div>
									</form>
								</div>

								<form action="${pageContext.request.contextPath}/raportit" method="get" class="row g-2 align-items-end border-bottom pb-3 mb-3">
									<input type="hidden" name="tab" value="ajotSisalto">
									<div class="col-md-3">
										<label for="ajoAlku" class="form-label small fw-bold">Alkupäivä</label>
										<input id="ajoAlku" name="ajoAlku" type="text" data-finnish-date placeholder="pp.kk.vvvv" inputmode="numeric" autocomplete="off" class="form-control" value="${ajoAlku}" required>
									</div>
									<div class="col-md-3">
										<label for="ajoLoppu" class="form-label small fw-bold">Loppupäivä</label>
										<input id="ajoLoppu" name="ajoLoppu" type="text" data-finnish-date placeholder="pp.kk.vvvv" inputmode="numeric" autocomplete="off" class="form-control" value="${ajoLoppu}" required>
									</div>
									<div class="col-md-4">
										<label for="ajoAsiakas" class="form-label small fw-bold">Asiakas</label>
										<select id="ajoAsiakas" name="ajoAsiakas" class="form-select">
										<option value="">Kaikki asiakkaat</option>
										<c:forEach items="${omatAsiakkaat}" var="asiakas">
												<option value="${asiakas.id}" ${asiakas.id == valittuAjoAsiakas ? 'selected' : ''}><c:out value="${asiakas.nimi}" /></option>
											</c:forEach>
										</select>
									</div>
									<div class="col-md-2 d-flex gap-2">
										<button class="btn btn-outline-primary w-100" type="submit">Hae</button>
										<a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/raportit?tab=ajotSisalto">Tyhjennä</a>
									</div>
								</form>

								<div class="table-responsive">
									<table class="table table-hover align-middle mb-0">
										<thead><tr><th>Päivä</th><th>Asiakas</th><th>Reitti</th><th>Selite</th><th>Mittarilukemat</th><th>Km</th><th></th></tr></thead>
										<tbody>
											<c:forEach items="${asiakasAjot}" var="ajo">
												<tr>
													<td><c:out value="${ajo.paivamaara}" /></td>
													<td>
														<c:choose>
															<c:when test="${not empty ajo.asiakkaat}">
																<c:forEach items="${ajo.asiakkaat}" var="ajoAsiakas" varStatus="asiakasStatus">
																	<c:if test="${not asiakasStatus.first}">, </c:if><c:out value="${ajoAsiakas.nimi}" />
																</c:forEach>
															</c:when>
															<c:otherwise><span class="text-muted">Ei asiakasta</span></c:otherwise>
														</c:choose>
													</td>
													<td><c:out value="${ajo.lahtopaikka}" /> &rarr; <c:out value="${ajo.kohde}" /><c:if test="${ajo.edestakainen}"> &rarr; <c:out value="${ajo.lahtopaikka}" /> <span class="badge text-bg-light">meno-paluu</span></c:if></td>
													<td style="white-space: pre-wrap;"><c:out value="${ajo.tarkoitus}" /></td>
													<td><fmt:formatNumber value="${ajo.alkumatkamittari}" maxFractionDigits="2" /> &rarr; <fmt:formatNumber value="${ajo.loppumatkamittari}" maxFractionDigits="2" /></td>
													<td><fmt:formatNumber value="${ajo.kilometrit}" minFractionDigits="0" maxFractionDigits="2" /></td>
													<td class="text-end text-nowrap">
														<textarea id="ajo-selite-${ajo.id}" class="d-none"><c:out value="${ajo.tarkoitus}" /></textarea>
														<select id="ajo-valitut-asiakkaat-${ajo.id}" class="d-none" multiple>
															<c:forEach items="${ajo.asiakkaat}" var="ajoAsiakas">
																<option value="${ajoAsiakas.id}" selected></option>
															</c:forEach>
														</select>
														<button type="button" class="btn btn-sm btn-outline-primary muokkaa-ajo" data-bs-toggle="modal" data-bs-target="#muokkaaAjoModal" data-id="${ajo.id}" data-paivamaara="${ajo.paivamaara}" data-lahtopaikka="<c:out value='${ajo.lahtopaikka}'/>" data-kohde="<c:out value='${ajo.kohde}'/>" data-alku="${ajo.alkumatkamittari}" data-loppu="${ajo.loppumatkamittari}" data-edestakainen="${ajo.edestakainen}">Muokkaa</button>
														<form action="${pageContext.request.contextPath}/raportit/ajot/poista/${ajo.id}" method="post" class="d-inline" onsubmit="return confirm('Poistetaanko tämä ajo?');"><button type="submit" class="btn btn-sm btn-outline-danger">Poista</button></form>
													</td>
												</tr>
											</c:forEach>
											<c:if test="${empty asiakasAjot}"><tr><td colspan="7" class="text-center text-muted py-4">Ei ajoja valitulla haulla.</td></tr></c:if>
										</tbody>
									</table>
								</div>
							</div>

							<div class="modal fade" id="muokkaaAjoModal" tabindex="-1" aria-hidden="true">
								<div class="modal-dialog modal-lg modal-dialog-scrollable">
									<div class="modal-content">
										<form id="muokkaaAjoForm" method="post">
											<div class="modal-header"><h5 class="modal-title">Muokkaa ajoa</h5><button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Sulje"></button></div>
											<div class="modal-body row g-3">
												<div class="col-md-6"><label for="muokkaaAjoAsiakkaat" class="form-label">Asiakkaat (valinnainen)</label><select id="muokkaaAjoAsiakkaat" name="asiakasIds" class="form-select" multiple size="5"><c:forEach items="${omatAsiakkaat}" var="asiakas"><option value="${asiakas.id}"><c:out value="${asiakas.nimi}" /></option></c:forEach></select><div class="form-text">Voit valita useita asiakkaita tai tyhjentää valinnan.</div></div>
												<div class="col-md-6"><label for="muokkaaAjoPaivamaara" class="form-label">Päivämäärä</label><input id="muokkaaAjoPaivamaara" name="paivamaara" type="text" data-finnish-date placeholder="pp.kk.vvvv" inputmode="numeric" autocomplete="off" class="form-control" required></div>
												<div class="col-md-6"><label for="muokkaaAjoLahto" class="form-label">Lähtöpaikka</label><input id="muokkaaAjoLahto" name="lahtopaikka" maxlength="200" class="form-control" required></div>
												<div class="col-md-6"><label for="muokkaaAjoKohde" class="form-label">Kohde</label><input id="muokkaaAjoKohde" name="kohde" maxlength="200" class="form-control" required></div>
												<div class="col-12"><label for="muokkaaAjoTarkoitus" class="form-label">Selite</label><textarea id="muokkaaAjoTarkoitus" name="tarkoitus" rows="4" class="form-control" required></textarea></div>
												<div class="col-md-4 d-flex align-items-end"><div class="form-check mb-2"><input id="muokkaaAjoEdestakainen" name="edestakainen" type="checkbox" class="form-check-input"><label for="muokkaaAjoEdestakainen" class="form-check-label">Edestakainen matka</label></div></div>
												<div class="col-md-4"><label for="muokkaaAjoAlku" class="form-label">Mittari alussa</label><input id="muokkaaAjoAlku" name="alkumatkamittari" type="number" min="0" step="0.01" class="form-control" required></div>
												<div class="col-md-4"><label for="muokkaaAjoLoppu" class="form-label">Mittari lopussa</label><input id="muokkaaAjoLoppu" name="loppumatkamittari" type="number" min="0" step="0.01" class="form-control" required></div>
												<input type="hidden" name="ajoAlku" value="${ajoAlku}"><input type="hidden" name="ajoLoppu" value="${ajoLoppu}"><input type="hidden" name="ajoAsiakas" value="${valittuAjoAsiakas}">
											</div>
											<div class="modal-footer"><button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Peruuta</button><button type="submit" class="btn btn-primary">Tallenna</button></div>
										</form>
									</div>
								</div>
							</div>

						</div> <!-- /#raporttiTabsSisalto päättyy puhtaasti -->
					</div>
					<!-- Lataa paikallisen Bootstrap-JavaScriptin resources-juuresta -->
					<script src="${pageContext.request.contextPath}/resources/bootstrap.bundle.min.js"></script>
					<script>
						function formatFinnishDate(value) {
							const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(value);
							return match ? match[3] + '.' + match[2] + '.' + match[1] : value;
						}

						function parseFinnishDate(value) {
							const match = /^(\d{1,2})\.(\d{1,2})\.(\d{4})$/.exec(value.trim());
							if (!match) return null;
							const day = Number(match[1]);
							const month = Number(match[2]);
							const year = Number(match[3]);
							const date = new Date(Date.UTC(year, month - 1, day));
							if (date.getUTCFullYear() !== year || date.getUTCMonth() !== month - 1 || date.getUTCDate() !== day) return null;
							return year + '-' + String(month).padStart(2, '0') + '-' + String(day).padStart(2, '0');
						}

						const dateForms = new Set();
						document.querySelectorAll('[data-finnish-date]').forEach(function (input) {
							input.value = formatFinnishDate(input.value);
							input.addEventListener('input', function () { input.setCustomValidity(''); });
							if (input.form && !dateForms.has(input.form)) {
								dateForms.add(input.form);
								input.form.addEventListener('submit', function (event) {
									const dateInputs = Array.from(input.form.querySelectorAll('[data-finnish-date]'));
									const isoDates = dateInputs.map(function (dateInput) {
										return parseFinnishDate(dateInput.value);
									});
									const invalidIndex = isoDates.findIndex(function (isoDate) { return !isoDate; });
									if (invalidIndex !== -1) {
										event.preventDefault();
										const invalidInput = dateInputs[invalidIndex];
										invalidInput.setCustomValidity('Anna päivämäärä muodossa pp.kk.vvvv.');
										invalidInput.reportValidity();
										return;
									}
									dateInputs.forEach(function (dateInput, index) {
										dateInput.value = isoDates[index];
									});
								}, true);
							}
						});

						document.querySelectorAll('.muokkaa-ajo').forEach(function (button) {
							button.addEventListener('click', function () {
								const form = document.getElementById('muokkaaAjoForm');
								form.action = '${pageContext.request.contextPath}/raportit/ajot/muokkaa/' + button.dataset.id;
								const valitutAsiakkaat = Array.from(
									document.getElementById('ajo-valitut-asiakkaat-' + button.dataset.id).options,
									function (option) { return option.value; }
								);
								Array.from(document.getElementById('muokkaaAjoAsiakkaat').options).forEach(function (option) {
									option.selected = valitutAsiakkaat.includes(option.value);
								});
								document.getElementById('muokkaaAjoPaivamaara').value = formatFinnishDate(button.dataset.paivamaara);
								document.getElementById('muokkaaAjoLahto').value = button.dataset.lahtopaikka;
								document.getElementById('muokkaaAjoKohde').value = button.dataset.kohde;
								document.getElementById('muokkaaAjoTarkoitus').value = document.getElementById('ajo-selite-' + button.dataset.id).value;
								document.getElementById('muokkaaAjoAlku').value = button.dataset.alku;
								document.getElementById('muokkaaAjoLoppu').value = button.dataset.loppu;
								document.getElementById('muokkaaAjoEdestakainen').checked = button.dataset.edestakainen === 'true';
							});
						});
					</script>


					<!--SÄILYTETÄÄN AKTIIVINEN VÄLILEHTI SEKÄ SIVUTUKSEN ETTEI HAUN YLI -->
					<script>
						document.addEventListener("DOMContentLoaded", function () {
							const urlParams = new URLSearchParams(window.location.search);
							const tabParam = urlParams.get('tab');
							const tabParameters = {
								'kirjaukset-tab': 'kirjaukset',
								'tarkeat-tab': 'tarkeatSisalto',
								'myynti-tab': 'myyntiSisalto',
								'ajot-tab': 'ajotSisalto',
								'loki-tab': 'loki'
							};
							function aktiivinenRaporttiTab() {
								const activeTab = document.querySelector('#raporttiTabs .nav-link.active');
								return activeTab ? tabParameters[activeTab.id] || 'kirjaukset' : 'kirjaukset';
							}

							// 1. Avataan oikea välilehti sivun latautuessa urliin perustuen
							if (tabParam === 'loki' || (urlParams.has('sivu') && !urlParams.has('kSivu'))) {
								const lokiTab = document.getElementById('loki-tab');
								if (lokiTab) {
									new bootstrap.Tab(lokiTab).show();
									document.getElementById('aktiivinenTabInput').value = 'loki';
								}
							}
							if (tabParam === 'ajotSisalto') {
								const ajotTab = document.getElementById('ajot-tab');
								if (ajotTab) {
									new bootstrap.Tab(ajotTab).show();
									document.getElementById('aktiivinenTabInput').value = 'ajotSisalto';
								}
							}
							if (tabParam === 'tarkeatSisalto') {
								const tarkeatTab = document.getElementById('tarkeat-tab');
								if (tarkeatTab) new bootstrap.Tab(tarkeatTab).show();
							}
							if (tabParam === 'myyntiSisalto') {
								const myyntiTab = document.getElementById('myynti-tab');
								if (myyntiTab) new bootstrap.Tab(myyntiTab).show();
							}

							document.getElementById('raporttiHakuForm')?.addEventListener('submit', function () {
								document.getElementById('raporttiHakuTab').value = aktiivinenRaporttiTab();
							});
							document.getElementById('nollaaRaporttiHaku')?.addEventListener('click', function (event) {
								event.preventDefault();
								window.location.href = '${pageContext.request.contextPath}/raportit?tab=' + aktiivinenRaporttiTab();
							});

							// 2. Kuunnellaan käyttäjän välilehtiklikkauksia ja päivitetään hakulomakkeen piilokenttää lennosta
							document.getElementById('kirjaukset-tab')?.addEventListener('shown.bs.tab', function () {
								document.getElementById('aktiivinenTabInput').value = 'kirjaukset';
							});

							document.getElementById('loki-tab')?.addEventListener('shown.bs.tab', function () {
								document.getElementById('aktiivinenTabInput').value = 'loki';
							});

							document.getElementById('ajot-tab')?.addEventListener('shown.bs.tab', function () {
								document.getElementById('aktiivinenTabInput').value = 'ajotSisalto';
							});

							// 3. Varmistetaan, että myös sivutuspalkkien linkit säilyttävät tiedon aktiivisesta välilehdestä
							document.querySelectorAll('.pagination .page-link').forEach(link => {
								const href = link.getAttribute('href');
								if (href && !href.includes('&tab=')) {
									const nykyinenTab = document.getElementById('aktiivinenTabInput').value;
									link.setAttribute('href', href + '&tab=' + nykyinenTab);
								}
							});
						});
					</script>
				</body>

				</html>