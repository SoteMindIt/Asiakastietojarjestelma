<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<html>
<head>
    <title>Luo uusi kayttaja - Astori</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 50px; text-align: center; background-color: #f9f9f9; }
        .box { max-width: 320px; margin: 0 auto; padding: 25px; background: #ffffff; border: 1px solid #ccc; border-radius: 5px; box-shadow: 0px 0px 10px rgba(0,0,0,0.1); }
        /* 💡 KORJAUS: Lisätty [type="email"] tyylittelyyn, jotta sähköpostikenttä ei näy erikokoisena */
        input[type="text"], input[type="password"], input[type="email"] { width: 100%; padding: 8px; margin: 8px 0; box-sizing: border-box; border: 1px solid #ccc; border-radius: 4px; }
        button { width: 100%; padding: 10px; background-color: #28a745; color: white; border: none; border-radius: 3px; cursor: pointer; font-weight: bold; }
        button:hover { background-color: #218838; }
        .error { color: red; margin-top: 10px; font-weight: bold; }
        p { text-align: left; margin: 10px 0 2px 0; font-size: 0.9rem; color: #555; }
        h2 { color: #212529; }
        h3 { margin-top: 0; color: #333; }
    </style>
</head>
<body>

    <h2>Uuden käyttäjän luonti</h2>
    
    <div class="box">
        <h3>Rekisteröidy</h3>
        <!-- 💡 KORJAUS: Muutettu dynaaminen Context Path sovelluksen siirrettävyyden varmistamiseksi -->
        <form action="${pageContext.request.contextPath}/rekisteroidy" method="post">
        
            <p>Etunimi:</p>
            <input type="text" name="etunimi" required>
            
            <p>Sukunimi:</p>
            <input type="text" name="sukunimi" required>
            
            <p>Sähköposti:</p>
            <input type="email" name="sahkoposti" required>
            
            <p>Puhelinnumero:</p>
            <input type="text" name="puhelin" required>
            
            <hr style="border: 0; border-top: 1px solid #eee; margin: 15px 0;">
        
            <p>Käyttäjätunnus:</p>
            <input type="text" name="tunnus" required>
            
            <p>Salasana:</p>
            <input type="password" name="salasana" required>
            
            <button type="submit">Rekisteröidy</button>
        </form>
        
        <c:if test="${not empty virhe}">
            <p class="error text-center" style="text-align: center;">${virhe}</p>
        </c:if>
        
        <hr style="border: 0; border-top: 1px solid #eee; margin: 15px 0;">
        <!-- 💡 KORJAUS: Kontekstipolku dynaamiseksi myös kirjautumislinkkiin -->
        <p style="text-align: center;"><a href="${pageContext.request.contextPath}/login" style="color: #0d6efd; text-decoration: none;">Takaisin kirjautumiseen</a></p>
    </div>

</body>
</html>
