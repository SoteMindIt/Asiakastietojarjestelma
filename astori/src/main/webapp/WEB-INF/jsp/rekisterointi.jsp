<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Luo uusi kayttaja</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 50px; text-align: center; background-color: #f9f9f9; }
        .box { max-width: 320px; margin: 0 auto; padding: 25px; background: #ffffff; border: 1px solid #ccc; border-radius: 5px; box-shadow: 0px 0px 10px rgba(0,0,0,0.1); }
        input[type="text"], input[type="password"] { width: 100%; padding: 8px; margin: 8px 0; box-sizing: border-box; }
        button { width: 100%; padding: 10px; background-color: #28a745; color: white; border: none; border-radius: 3px; cursor: pointer; }
        button:hover { background-color: #218838; }
        .error { color: red; margin-top: 10px; }
    </style>
</head>
<body>

    <h2>Uuden kayttajan luonti</h2>
    
    <div class="box">
        <h3>Rekisteröidy</h3>
        <form action="/astori/rekisteroidy" method="post">
        
         <p>Etunimi:<br>
            <input type="text" name="etunimi" required></p>
            
            <p>Sukunimi:<br>
            <input type="text" name="sukunimi" required></p>
            
            <p>Sähköposti:<br>
            <input type="email" name="sahkoposti" required></p>
            
            <p>Puhelinnumero:<br>
            <input type="text" name="puhelin" required></p>
            
            <hr>
        
            <p>Käyttäjätunnus:<br>
            <input type="text" name="tunnus" required></p>
            
            <p>Salasana:<br>
            <input type="password" name="salasana" required></p>
            
            <button type="submit">Rekisteröidy</button>
        </form>
        
        <p class="error">${virhe}</p>
        
        <hr>
        <p><a href="/astori/login">Takaisin kirjautumiseen</a></p>
    </div>

</body>
</html>