<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lisää uusi tuote - Astori</title>
    <link href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        body { background-color: #f8f9fa; }
        .form-card { background: white; border-radius: 8px; padding: 30px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); max-width: 600px; margin: 0 auto; }
    </style>
</head>
<body>

    <!-- YLÄPALKKI -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark mb-4 shadow-sm">
        <div class="container">
            <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/">Astori</a>
            <div class="navbar-nav me-auto">
                <a class="nav-link" href="${pageContext.request.contextPath}/">Asiakkaat</a>
                <a class="nav-link active fw-bold" href="${pageContext.request.contextPath}/asetukset">Asetukset</a>
            </div>
            <div class="d-flex align-items-center">
                <span class="navbar-text text-white me-3">Käyttäjä: <strong>${kirjautunutKayttaja}</strong></span>
                <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline-danger btn-sm">Kirjaudu ulos</a>
            </div>
        </div>
    </nav>

    <div class="container py-2">
        <!-- TAKAISIN-LINKKI ASETUKSIIN -->
        <div class="mb-3 mx-auto" style="max-width: 600px;">
            <a class="btn btn-link p-0 text-decoration-none" href="${pageContext.request.contextPath}/asetukset">&larr; Takaisin asetuksiin</a>
        </div>

        <!-- LOMAKEKORTTI -->
        <div class="form-card border">
            <h2 class="text-dark fw-bold h4 mb-4">Lisää uusi tuote tai palvelu</h2>
            
            <!-- LOMAKKEEN ACTION KORJATTU VASTAAMAAN ASETUKSETCONTROLLERIA -->
            <form action="${pageContext.request.contextPath}/asetukset/lisaa-tuote" method="post">
                <div class="mb-3">
                    <label for="nimi" class="form-label fw-semibold text-secondary">Tuotteen tai palvelun nimi</label>
                    <input type="text" class="form-control" id="nimi" name="nimi" required placeholder="esim. Konsultointityö, Lisenssi vuosimaksu">
                </div>
                
                <div class="mb-3">
                    <label for="kuvaus" class="form-label fw-semibold text-secondary">Kuvaus</label>
                    <textarea class="form-control" id="kuvaus" name="kuvaus" rows="4" placeholder="Kirjoita lyhyt kuvaus tuotteesta tai palvelusta..."></textarea>
                </div>
                
                <div class="row">
                    <div class="col-md-6 mb-4">
                        <label for="hinta" class="form-label fw-semibold text-secondary">Oletushinta (€)</label>
                        <input type="number" class="form-control" id="hinta" name="hinta" step="0.01" min="0" required placeholder="0.00">
                    </div>
                    <div class="col-md-6 mb-4">
                        <label for="yksikko" class="form-label fw-semibold text-secondary">Yksikkö</label>
                        <select class="form-select" id="yksikko" name="yksikko" required>
                            <option value="KPL">kpl</option>
                            <option value="TUNTI">tunti</option>
                            <option value="KK">kk</option>
                            <option value="PV">päivä</option>
                        </select>
                    </div>
                </div>
                
                <div class="d-flex gap-2 justify-content-end border-top pt-3">
                    <a href="${pageContext.request.contextPath}/asetukset" class="btn btn-secondary px-4">Peruuta</a>
                    <button type="submit" class="btn btn-primary px-4 fw-bold">Tallenna asetuksiin</button>
                </div>
            </form>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/resources/js/bootstrap.bundle.min.js"></script>
</body>
</html>
