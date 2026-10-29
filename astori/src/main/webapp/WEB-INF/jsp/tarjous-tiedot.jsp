<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="fi">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Tarjous ${tarjous.tarjousNumero} - Astori</title>
	<link href="${pageContext.request.contextPath}/resources/bootstrap.min.css" rel="stylesheet" />
</head>
<body class="bg-light">
	<nav class="navbar navbar-expand-lg navbar-dark bg-dark mb-4 shadow-sm">
		<div class="container">
			<a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/">Astori</a>
			<div class="navbar-nav me-auto">
				<a class="nav-link" href="${pageContext.request.contextPath}/">Etusivu</a>
				<a class="nav-link" href="${pageContext.request.contextPath}/asiakkaat">Asiakkaat</a>
				<a class="nav-link" href="${pageContext.request.contextPath}/raportit">Raportit</a>
			</div>
		</div>
	</nav>

	<main class="container pb-4">
		<div class="d-flex justify-content-between align-items-start flex-wrap gap-3 mb-4">
			<div>
				<a href="${pageContext.request.contextPath}/asiakas/${tarjous.asiakas.id}/tarjoukset" class="text-decoration-none">&larr; Takaisin tarjouksiin</a>
				<h1 class="h3 fw-bold mt-2">Tarjous <c:out value="${tarjous.tarjousNumero}" /></h1>
				<div class="text-muted"><c:out value="${tarjous.asiakas.nimi}" /></div>
			</div>
			<div class="d-flex gap-2">
				<a class="btn btn-primary" href="${pageContext.request.contextPath}/tarjous/${tarjous.id}/muokkaa">Muokkaa tarjousta</a>
				<a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/tarjous/${tarjous.id}/lataa-pdf">Lataa PDF</a>
			</div>
		</div>

		<div class="card border-0 shadow-sm mb-4">
			<div class="card-body">
				<div class="row g-3">
					<div class="col-sm-4"><div class="small text-muted">Päivämäärä</div><c:out value="${tarjous.pvm}" /></div>
					<div class="col-sm-4"><div class="small text-muted">Voimassa asti</div><c:out value="${tarjous.voimassaoloPvm}" /></div>
					<div class="col-sm-4"><div class="small text-muted">Asiakas</div><c:out value="${tarjous.asiakas.nimi}" /></div>
				</div>
				<c:if test="${not empty tarjous.lisatiedot}">
					<hr>
					<div class="small text-muted mb-1">Lisätiedot</div>
					<div style="white-space: pre-wrap;"><c:out value="${tarjous.lisatiedot}" /></div>
				</c:if>
			</div>
		</div>

		<div class="card border-0 shadow-sm">
			<div class="card-body">
				<h2 class="h5 fw-bold mb-3">Tarjousrivit</h2>
				<div class="table-responsive">
					<table class="table table-hover align-middle">
						<thead class="table-light">
							<tr>
								<th>Tuote / palvelu</th>
								<th class="text-end">Määrä</th>
								<th class="text-end">Yksikköhinta</th>
								<th class="text-end">ALV</th>
								<th class="text-end">Veroton</th>
								<th class="text-end">Verollinen</th>
							</tr>
						</thead>
						<tbody>
							<c:forEach var="rivi" items="${tarjous.rivit}">
								<tr>
									<td><c:out value="${rivi.tuotteenNimi}" /></td>
									<td class="text-end"><fmt:formatNumber value="${rivi.maara}" maxFractionDigits="2" /></td>
									<td class="text-end"><fmt:formatNumber value="${rivi.yksikkohinta}" type="currency" currencySymbol="€" /></td>
									<td class="text-end"><fmt:formatNumber value="${rivi.alvProsentti}" maxFractionDigits="1" /> %</td>
									<td class="text-end"><fmt:formatNumber value="${rivi.verotonYhteensa}" type="currency" currencySymbol="€" /></td>
									<td class="text-end"><fmt:formatNumber value="${rivi.verollinenYhteensa}" type="currency" currencySymbol="€" /></td>
								</tr>
							</c:forEach>
						</tbody>
						<tfoot>
							<tr><th colspan="4" class="text-end">Veroton yhteensä</th><td colspan="2" class="text-end"><fmt:formatNumber value="${tarjous.verotonYhteensa}" type="currency" currencySymbol="€" /></td></tr>
							<tr><th colspan="4" class="text-end">ALV yhteensä</th><td colspan="2" class="text-end"><fmt:formatNumber value="${tarjous.alvYhteensa}" type="currency" currencySymbol="€" /></td></tr>
							<tr class="table-success"><th colspan="4" class="text-end">Verollinen yhteensä</th><td colspan="2" class="text-end fw-bold"><fmt:formatNumber value="${tarjous.verollinenYhteensa}" type="currency" currencySymbol="€" /></td></tr>
						</tfoot>
					</table>
				</div>
			</div>
		</div>
	</main>
</body>
</html>
