function autoGen(prenom, inits, nom){
    var prenom = document.getElementById("givenName").value;
    var nom = document.getElementById("sn").value;
        var inits = document.getElementById("initials").value;
    uidGen(prenom, inits, nom);
    cnGen(prenom, inits, nom);
}

function uidGen(prenom, inits, nom){
    var sAMAccountName = prenom.toLowerCase() + '.' + inits.toLowerCase() + '.' + nom.toLowerCase();
    document.getElementById("sAMAccountName").value = sAMAccountName;
}

function cnGen(prenom, inits, nom){
    var cn = prenom.toLowerCase() + '.' + inits.toLowerCase() + '.' + nom.toLowerCase();
    document.getElementById("cn").value = cn;
}
