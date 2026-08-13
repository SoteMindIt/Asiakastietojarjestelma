<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<html>
<head>
    <title>Asiakasprofiili - ${asiakas.nimi}</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .row { display: flex; gap: 40px; margin-top: 20px; }
        .col { flex: 1; background: #f9f9f9; padding: 20px; border: 1px solid #ddd; }
        .back-link { display: inline-block; margin-bottom: 20px; }
        ul { padding-left: 20px; }
        li { margin-bottom: 10px; }
    </style>
</head>
<body>

    <a class="back-link" href="../">&larr; Takaisin asiakaslistaukseen</a>

    <h1>Asiakas: ${asiakas.nimi}</h1>
    <p><strong>Sähköposti:</strong> ${asiakas.sahkoposti}</p>
    <p><strong>Puhelin:</strong> ${asiakas.puhelin}</p>

    <div class="row">
        <!-- YHTEYSHENKILÖT -->
        <div class="col">
            <h3>Yhteyshenkilöt</h3>
            <ul>
                <c:forEach var="h" items="${yhteyshenkilot}">
                    <li><strong>${h.nimi}</strong> (${h.rooli})<br>Puh: ${h.puhelin} | E-mail: ${h.sahkoposti}</li>
                </c:forEach>
            </ul>
            
            <h4>Lisää yhteyshenkilö</h4>
            <form action="/astori/asiakas/${asiakas.id}/lisaa-yhteyshenkilo" method="post">
                <input type="text" name="nimi" placeholder="Nimi" required><br><br>
                <input type="text" name="rooli" placeholder="Rooli (esim. Toimitusjohtaja)"><br><br>
                <input type="email" name="sahkoposti" placeholder="Sähköposti"><br><br>
                <input type="text" name="puhelin" placeholder="Puhelin"><br><br>
                <button type="submit">Lisää</button>
            </form>
        </div>

        <!-- KIRJAUKSET / LOKI -->
        <div class="col">
            <h3>Asiakkaan loki ja kirjaukset</h3>
            <ul>
                <c:forEach var="k" items="${kirjaukset}">
                    <li>${k.teksti} <br><small style="color:gray;">${k.luontiaika}</small></li>
                </c:forEach>
            </ul>

            <h4>Uusi kirjaus</h4>
            <form action="/astori/asiakas/${asiakas.id}/lisaa-kirjaus" method="post">
                <textarea name="teksti" rows="4" style="width:100%;" placeholder="Kirjoita tähän muistiinpanot puhelusta tai tapaamisesta..." required></textarea><br><br>
                <button type="submit">Tallenna merkintä</button>
            </form>
        </div>
    </div>

</body>
</html>