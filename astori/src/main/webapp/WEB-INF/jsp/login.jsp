<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Kirjaudu sisään</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 50px; text-align: center; background-color: #f9f9f9; }
        .box { max-width: 320px; margin: 0 auto; padding: 25px; background: #ffffff; border: 1px solid #ccc; border-radius: 5px; box-shadow: 0px 0px 10px rgba(0,0,0,0.1); }
        input[type="text"], input[type="password"] { width: 100%; padding: 8px; margin: 8px 0; box-sizing: border-box; }
        button { width: 100%; padding: 10px; background-color: #007bff; color: white; border: none; border-radius: 3px; cursor: pointer; }
        button:hover { background-color: #0056b3; }
        .error { color: red; margin-top: 10px; }
    </style>
</head>
<body>

    <h2>Asiakastietojärjestelmä</h2>
    
    <div class="box">
        <h3>Kirjaudu sisään</h3>
        <!-- action osoittaa Tomcat-kontekstin mukaan LoginControllerille -->
        <form action="/astori/login" method="post">
            <p>Käyttäjätunnus:<br>
            <input type="text" name="tunnus" required></p>
            
            <p>Salasana:<br>
            <input type="password" name="salasana" required></p>
            
            <button type="submit">Kirjaudu</button>
        </form>
        
        <!-- Näyttää virheilmoituksen jos tunnus tai salasana oli väärä -->
        <p class="error">${virhe}</p>
        
        <hr>
        <p><a href="/astori/rekisteroidy">Luo uusi käyttäjätunnus</a></p>
    </div>

</body>
</html>