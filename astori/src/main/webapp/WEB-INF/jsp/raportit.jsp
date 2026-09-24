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
								<button class="nav-link fw-bold text-danger" id="tarkeat-tab" data-bs-toggle="tab"
									data-bs-target="#tarkeatSisalto" type="button" role="tab"
									aria-controls="tarkeatSisalto" aria-selected="false">
									📌 Tärkeät huomiot (${tarkeatKirjaukset.size()})</button>
							</li>

							<li class="nav-item">
								<button class="nav-link fw-bold" id="myynti-tab" data-bs-toggle="tab"
									data-bs-target="#myyntiSisalto" type="button" role="tab">💰 Myyntiraportti</button>
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

						<!-- VÄLILEHTIEN SISÄLLÖT -->
						<div class="tab-content" id="raporttiTabsSisalto">

							<!-- ==================== ALIVÄLILEHTI 1: ASIAKASKIRJAUKSET ==================== -->
							<div class="tab-pane fade show active" id="kirjaukset-pane" role="tabpanel"
								aria-labelledby="kirjaukset-tab">

								<!-- 🔍 ITSENÄINEN HAKULOMAKE VAIN PÄIVÄKIRJAUKSILLE (Sisältää kirjaustyypin) -->
								<div class="card border shadow-sm p-3 mb-4 bg-white rounded-3">
									<form action="${pageContext.request.contextPath}/raportit" method="get"
										class="row g-2 align-items-end">
										<input type="hidden" name="sivu" value="0">
										<input type="hidden" name="kSivu" value="0">
										<input type="hidden" name="tab" value="kirjaukset">

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
											<a href="${pageContext.request.contextPath}/raportit?tab=kirjaukset"
												class="btn btn-sm btn-outline-secondary px-3 w-100 rounded-pill">Nollaa</a>
										</div>
									</form>
								</div>

								<div class="d-flex justify-content-between align-items-center mb-3">
									<h5 class="text-secondary mb-0 small fw-bold">Asiakkuuksiin liitetyt päiväkirjaukset
										kronologisesti</h5>
									<c:if test="${kaytossaOletus30Pv}">
										<span
											class="badge bg-warning-subtle text-warning border border-warning-subtle px-3 py-1 rounded-pill small fw-bold">
											Näytetään automaattisesti viimeiset 30 vuorokautta
										</span>
									</c:if>
								</div>

								<!-- 🎯 HAITARILISTAUS (Oletuksena kiinni, suodattuu lennosta) -->
								<div class="accordion shadow-sm mb-3 border rounded-3" id="asiakasKirjausHaitari">
									<c:set var="naytettiinYhtaan" value="false" />

									<c:forEach var="as" items="${haitariAsiakkaat}">
										<c:set var="tämänSivunKirjaukset" value="${kirjauksetKartta[as.id]}" />
										<c:if test="${not empty tämänSivunKirjaukset}">

											<c:set var="asiakkaallaOnSopiviaKirjauksia" value="false" />
											<c:forEach var="testKj" items="${tämänSivunKirjaukset}">
												<c:if
													test="${empty valittuTyyppiId or (testKj.kirjaustyyppi != null and testKj.kirjaustyyppi.id == valittuTyyppiId)}">
													<c:set var="asiakkaallaOnSopiviaKirjauksia" value="true" />
												</c:if>
											</c:forEach>

											<c:if test="${asiakkaallaOnSopiviaKirjauksia}">
												<c:set var="naytettiinYhtaan" value="true" />
												<div class="accordion-item border-0 border-bottom">
													<h2 class="accordion-header" id="heading-${as.id}">
														<button
															class="accordion-button collapsed fw-bold text-dark bg-light bg-opacity-50 py-3"
															type="button" data-bs-toggle="collapse"
															data-bs-target="#collapse-${as.id}">
															<div
																class="d-flex justify-content-between w-100 align-items-center pe-3">
																<span>🏢 ${as.nimi}</span>
																<span
																	class="badge bg-primary rounded-pill small fw-semibold">
																	${fn:length(tämänSivunKirjaukset)} merkintää tällä
																	sivulla
																</span>
															</div>
														</button>
													</h2>
													<div id="collapse-${as.id}" class="accordion-collapse collapse"
														data-bs-parent="#asiakasKirjausHaitari">
														<div class="accordion-body bg-white p-4">
															<div class="list-group list-group-flush mx-n3 my-n3">
																<c:forEach var="kj" items="${tämänSivunKirjaukset}">
																	<c:if
																		test="${empty valittuTyyppiId or (kj.kirjaustyyppi != null and kj.kirjaustyyppi.id == valittuTyyppiId)}">
																		<div
																			class="list-group-item p-3 border-0 border-bottom border-light text-start">
																			<div
																				class="d-flex justify-content-between align-items-center mb-2">
																				<small class="text-muted fw-semibold">
																					🗓️
																					${kj.luontiaika.toString().replace('T',
																					' ').substring(0, 16)}
																				</small>
																				<c:if
																					test="${kj.kirjaustyyppi != null}">
																					<span
																						class="badge text-white fw-bold px-2 py-0.5 rounded-pill"
																						style="background-color: ${kj.kirjaustyyppi.vari}; font-size: 0.75rem;">
																						${kj.kirjaustyyppi.nimi}
																					</span>
																				</c:if>
																			</div>
																			<p class="mb-0 text-dark small"
																				style="white-space: pre-line; line-height: 1.5;">
																				<c:out value="${kj.teksti}" />
																			</p>
																		</div>
																	</c:if>
																</c:forEach>
															</div>
														</div>
													</div>
												</div>
											</c:if>
										</c:if>
									</c:forEach>

									<c:if test="${naytettiinYhtaan == 'false'}">
										<div
											class="p-4 bg-white text-center text-muted border-0 rounded-3 italic small">
											Ei kirjattuja asiakastapahtumia valitulla hakuehdolla / ajanjaksolla.
										</div>
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

								<!-- 🔍 ITSENÄINEN AIKAVÄLILOMAKE MYYNTIRAPORTEILLE -->
								<div class="card border shadow-sm p-3 mb-4 bg-white rounded-3">
									<form action="${pageContext.request.contextPath}/raportit" method="get"
										class="row g-2 align-items-end">
										<input type="hidden" name="sivu" value="0">
										<input type="hidden" name="kSivu" value="0">
										<input type="hidden" name="tab" value="myyntiSisalto">

										<div class="col-md-4 col-sm-6 text-start">
											<label for="alkuPvm_m"
												class="form-label small fw-bold text-secondary">Alkupäivämäärä</label>
											<input type="date" id="alkuPvm_m" name="alkuPvm"
												class="form-control form-control-sm" value="${alkuPvm}">
										</div>

										<div class="col-md-4 col-sm-6 text-start">
											<label for="loppuPvm_m"
												class="form-label small fw-bold text-secondary">Loppupäivämäärä</label>
											<input type="date" id="loppuPvm_m" name="loppuPvm"
												class="form-control form-control-sm" value="${loppuPvm}">
										</div>

										<div class="col-md-4 col-12 d-flex gap-2">
											<button type="submit"
												class="btn btn-sm btn-primary fw-bold px-3 w-100 rounded-pill">📊
												Päivitä ajanjakso</button>
											<a href="${pageContext.request.contextPath}/raportit?tab=myyntiSisalto"
												class="btn btn-sm btn-outline-secondary px-3 w-100 rounded-pill">Nollaa</a>
										</div>
									</form>
								</div>

								<div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
									<div>
										<h5 class="fw-bold text-dark mb-0">Toteutunut liikevaihto ajanjaksolta</h5>
										<small class="text-muted">
											<c:choose>
												<c:when test="${kaytossaOletusKuluvaKk}">ℹ️ Näytetään oletuksena kuluvan
													kuukauden myynnit.</c:when>
												<c:otherwise>🔍 Hakua rajattu valitulla ajanjaksolla.</c:otherwise>
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

								<!-- 🔍 ITSENÄINEN HAKULOMAKE TÄRKEILLE HUOMIOILLE (Sisältää kirjaustyypin) -->
								<div class="card border shadow-sm p-3 mb-4 bg-white rounded-3">
									<form action="${pageContext.request.contextPath}/raportit" method="get"
										class="row g-2 align-items-end">
										<input type="hidden" name="sivu" value="0">
										<input type="hidden" name="kSivu" value="0">
										<input type="hidden" name="tab" value="tarkeatSisalto">

										<div class="col-md-3 col-sm-6 text-start">
											<label for="alkuPvm_t"
												class="form-label small fw-bold text-secondary">Alkupäivämäärä</label>
											<input type="date" id="alkuPvm_t" name="alkuPvm"
												class="form-control form-control-sm" value="${alkuPvm}">
										</div>

										<div class="col-md-3 col-sm-6 text-start">
											<label for="loppuPvm_t"
												class="form-label small fw-bold text-secondary">Loppupäivämäärä</label>
											<input type="date" id="loppuPvm_t" name="loppuPvm"
												class="form-control form-control-sm" value="${loppuPvm}">
										</div>

										<div class="col-md-3 col-12 text-start">
											<label for="suodatinTyyppi_t"
												class="form-label small fw-bold text-secondary">Kirjaustyyppi /
												Luokitus</label>
											<select name="tyyppi" id="suodatinTyyppi_t"
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
											<a href="${pageContext.request.contextPath}/raportit?tab=tarkeatSisalto"
												class="btn btn-sm btn-outline-secondary px-3 w-100 rounded-pill">Nollaa</a>
										</div>
									</form>
								</div>

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

						</div> <!-- /#raporttiTabsSisalto päättyy puhtaasti -->
					</div>
					<!-- Lataa paikallisen Bootstrap-JavaScriptin resources-juuresta -->
					<script src="${pageContext.request.contextPath}/resources/bootstrap.bundle.min.js"></script>


					<!--SÄILYTETÄÄN AKTIIVINEN VÄLILEHTI SEKÄ SIVUTUKSEN ETTEI HAUN YLI -->
					<script>
						document.addEventListener("DOMContentLoaded", function () {
							const urlParams = new URLSearchParams(window.location.search);
							const tabParam = urlParams.get('tab');

							// 1. Avataan oikea välilehti sivun latautuessa urliin perustuen
							if (tabParam === 'loki' || (urlParams.has('sivu') && !urlParams.has('kSivu'))) {
								const lokiTab = document.getElementById('loki-tab');
								if (lokiTab) {
									new bootstrap.Tab(lokiTab).show();
									document.getElementById('aktiivinenTabInput').value = 'loki';
								}
							}

							// 2. Kuunnellaan käyttäjän välilehtiklikkauksia ja päivitetään hakulomakkeen piilokenttää lennosta
							document.getElementById('kirjaukset-tab')?.addEventListener('shown.bs.tab', function () {
								document.getElementById('aktiivinenTabInput').value = 'kirjaukset';
							});

							document.getElementById('loki-tab')?.addEventListener('shown.bs.tab', function () {
								document.getElementById('aktiivinenTabInput').value = 'loki';
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