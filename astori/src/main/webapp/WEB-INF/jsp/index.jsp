<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<html>
<head>
    <title>Asiakastietojärjestelmä</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 10px; text-align: left; }
        th { background-color: #f4f4f4; }
        .form-box { background: #f9f9f9; padding: 20px; border: 1px solid #ddd; max-width: 400px; }
    </style>
</head>
<body>

    <h1>Asiakastietojärjestelmä</h1>

    <div class="form-box">
        <h3>Lisää uusi asiakas</h3>
        <form action="lisaa-asiakas" method="post">
            <p>Nimi: <br><input type="text" name="nimi" required></p>
            <p>Sähköposti: <br><input type="email" name="sahkoposti" required></p>
            <p>Puhelin: <br><input type="text" name="puhelin" required></p>
            <button type="submit">Tallenna asiakas</button>
        </form>
    </div>

    <h2>Kaikki asiakkaat</h2>
    <table>
        <tr>
            <th>ID</th>
            <th>Nimi</th>
            <th>Sähköposti</th>
            <th>Puhelin</th>
            <th>Toiminnot</th>
        </tr>
        <c:forEach var="asiakas" items="${asiakkaat}">
            <tr>
                <td>${asiakas.id}</td>
                <td><strong>${asiakas.nimi}</strong></td>
                <td>${asiakas.sahkoposti}</td>
                <td>${asiakas.puhelin}</td>
                <td><a href="asiakas/${asiakas.id}">Avaa profiili</a></td>
            </tr>
        </c:forEach>
    </table>

</body>
</html>