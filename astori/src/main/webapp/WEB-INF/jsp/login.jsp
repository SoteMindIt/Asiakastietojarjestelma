<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kirjaudu sisään - Astori</title>
    <link href="${pageContext.request.contextPath}/resources/bootstrap.min.css" rel="stylesheet" />
    <style>
        body { background-color: #f0f2f5; height: 100vh; display: flex; align-items: center; justify-content: center; }
        .login-card { background: white; border-radius: 12px; padding: 35px; box-shadow: 0 4px 12px rgba(0,0,0,0.08); width: 100%; max-width: 400px; border: 1px solid #dee2e6; }
        .brand-title { font-size: 2rem; font-weight: 800; color: #212529; text-align: center; margin-bottom: 5px; }
        .brand-subtitle { font-size: 0.9rem; color: #6c757d; text-align: center; margin-bottom: 30px; }
    </style>
</head>
<body>
    <div class="login-card">
        <div class="brand-title">Astori</div>
        <div class="brand-subtitle">Asiakastietojärjestelmä</div>
        <c:if test="${param.error != null}">
            <div class="alert alert-danger py-2 small fw-bold text-center" role="alert">
                Väärä käyttäjätunnus tai salasana!
            </div>
        </c:if>
        <c:if test="${param.logout != null}">
            <div class="alert alert-success py-2 small fw-bold text-center" role="alert">
                Olet kirjautunut ulos järjestelmästä.
            </div>
        </c:if>
        <form action="${pageContext.request.contextPath}/login" method="post">
            <div class="mb-3">
                <label for="username" class="form-label fw-semibold text-secondary small">Käyttäjätunnus</label>
                <input type="text" class="form-control" id="username" name="username" required autofocus placeholder="esim. admin">
            </div>
            <div class="mb-4">
                <label for="password" class="form-label fw-semibold text-secondary small">Salasana</label>
                <input type="password" class="form-control" id="password" name="password" required placeholder="••••••••">
            </div>
            <button type="submit" class="btn btn-primary w-100 fw-bold py-2 shadow-sm mb-3">
                Kirjaudu sisään
            </button>
            <div class="text-center text-muted" style="font-size: 0.8rem;">
                &copy; 2026 Astori CRM. Kaikki oikeudet pidätetään.
            </div>
        </form>
    </div>
    <script src="${pageContext.request.contextPath}/resources/bootstrap.bundle.min.js"></script>
</body>
</html>
            