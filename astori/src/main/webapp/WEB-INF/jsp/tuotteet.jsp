<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="fi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tuoterekisteri - Astori</title>
    <!-- Lataa paikallisen Bootstrap-tyylitiedoston omalta koneelta -->
    <link href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        body { background-color: #f8f9fa; }
        .table-responsive { background: white; border-radius: 8px; padding: 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
    </style>
</head>
<body>

    <!-- YLÄPALKKI / NAVIGAATIO -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark mb-4 shadow-sm">
        <div class="container">
            <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/">Astori</a>
            <div class="navbar-nav me-auto">
                <a class="nav-link" href="${pageContext.request.contextPath}/">Asiakkaat</a>
                <a class="nav-link active fw-bold" href="${pageContext.request.contextPath}/tuotteet">Tuoterekisteri</a>
            </div>
            <div class="d-flex align-items-center">
                <span class="navbar-text text-white me-3">
                    Käyttäjä: <strong>${kirjautunutKayttaja}</strong>
                </span>
                <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline-danger btn-sm">Kirjaudu ulos</a>
            </div>
        </div>
    </nav>

    <div class="container py-2">
        <!-- OTSIKKOPALKKI JA PAINIKE -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="text-dark fw-bold mb-0">Tuoterekisteri</h2>
            <!-- PAINIKE: Avaa uuden tuotteen pop-up-lomakkeen -->
            <button type="button" class="btn btn-primary fw-bold px-4 shadow-sm" data-bs-toggle="modal" data-bs-target="#lisaaTuoteModal">
                + Lisää uusi tuote/palvelu
            </button>
        </div>

        <!-- TUOTETAULUKKO -->
        <h4 class="text-secondary mb-3">Rekisteröidyt tuotteet ja palvelut</h4>
        <div class="table-responsive border">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th>ID</th>
                        <th>Tuotteen nimi</th>
                        <th>Kuvaus</th>
                        <th class="text-end">Oletushinta (alv 0%)</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="tuote" items="${tuotteet}">
                        <tr>
                            <td class="text-muted">#${tuote.id}</td>
                            <td><strong class="text-dark">${tuote.nimi}</strong></td>
                            <td class="text-secondary">${tuote.kuvaus}</td>
                            <td class="text-end fw-bold text-dark">
                                ${tuote.hinta} €
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty tuotteet}">
                        <tr>
                            <td colspan="4" class="text-center py-4 text-muted">Rekisterissä ei ole vielä tuotteita tai palveluita.</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>

    <!-- BOOTSTRAP POP-UP LOMAKE (MODAL) -->
    <div class="modal fade" id="lisaaTuoteModal" tabindex="-1" aria-labelledby="lisaaTuoteModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title fw-bold" id="lisaaTuoteModalLabel">Lisää uusi tuote tai palvelu</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Sulje"></button>
                </div>
                <form action="${pageContext.request.contextPath}/lisaa-tuote" method="post">
                    <div class="modal-body p-4">
                        <div class="mb-3">
                            <label for="nimi" class="form-label fw-semibold text-secondary">Tuotteen tai palvelun nimi</label>
                            <input type="text" class="form-control" id="nimi" name="nimi" required placeholder="esim. Konsultointityö, Lisenssi vuosimaksu">
                        </div>
                        <div class="mb-3">
                            <label for="kuvaus" class="form-label fw-semibold text-secondary">Kuvaus</label>
                            <textarea class="form-control" id="kuvaus" name="kuvaus" rows="3" placeholder="Lyhyt kuvaus tuotteesta..."></textarea>
                        </div>
                        <div class="mb-3">
                            <label for="hinta" class="form-label fw-semibold text-secondary">Oletushinta (€)</label>
                            <!-- step="0.01" sallii desimaalihinnat, kuten 49.90 -->
                            <input type="number" class="form-control" id="hinta" name="hinta" step="0.01" min="0" required placeholder="0.00">
                        </div>
                    </div>
                    <div class="modal-footer bg-light">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Peruuta</button>
                        <button type="submit" class="btn btn-primary px-4 fw-bold">Tallenna rekisteriin</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Lataa paikallisen Bootstrap-JavaScriptin sivun alalaitaan dynaamisia toimintoja varten -->
    <script src="${pageContext.request.contextPath}/resources/js/bootstrap.bundle.min.js"></script>
</body>
</html>
