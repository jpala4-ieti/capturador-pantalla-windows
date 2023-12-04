<?php
// Rebre dades JSON de la petició POST
$dadesJson = file_get_contents('php://input');
$dadesJsonUtf8 = mb_convert_encoding($dadesJson, 'UTF-8', 'UTF-8');

$dades = json_decode($dadesJsonUtf8, true);

// Verificar que tots els camps necessaris estan presents
$campRequerits = ['cognom', 'nom', 'prova', 'imatge'];
foreach ($campRequerits as $camp) {
    if (!isset($dades[$camp]) || empty($dades[$camp])) {
        header('HTTP/1.1 400 Bad Request');
        echo "Error: Falta el camp '$camp' o està buit.";
        exit;
    }
}

// Extreure la informació necessària
$cognom = $dades['cognom'];
$nom = $dades['nom'];
$prova = $dades['prova'];
$imatgeBase64 = $dades['imatge'];

// Netejar i preparar el nom de la carpeta
$nomCarpeta = strtolower(preg_replace('/\s+/', '_', $prova));
$nomCarpeta = preg_replace('/[Áá]/', 'a', $nomCarpeta);
$nomCarpeta = preg_replace('/[Éé]/', 'e', $nomCarpeta);
$nomCarpeta = preg_replace('/[Íí]/', 'i', $nomCarpeta);
$nomCarpeta = preg_replace('/[Óó]/', 'o', $nomCarpeta);
$nomCarpeta = preg_replace('/[Úú]/', 'u', $nomCarpeta);

// Crear la carpeta "captures" si no existeix
if (!file_exists('captures')) {
    mkdir('captures', 0777, true);
}

// Crear la carpeta de la prova dins de "captures" si no existeix
$rutaCompleta = 'captures/' . $nomCarpeta;
if (!file_exists($rutaCompleta)) {
    mkdir($rutaCompleta, 0777, true);
}

// Preparar el nom del fitxer
$nomFitxer = $rutaCompleta . '/' . strtolower(str_replace(' ', '-', "{$prova}__{$cognom}-{$nom}.json"));
$nomFitxer = preg_replace('/[Áá]/', 'a', $nomFitxer);
$nomFitxer = preg_replace('/[Éé]/', 'e', $nomFitxer);
$nomFitxer = preg_replace('/[Íí]/', 'i', $nomFitxer);
$nomFitxer = preg_replace('/[Óó]/', 'o', $nomFitxer);
$nomFitxer = preg_replace('/[Úú]/', 'u', $nomFitxer);

// Guardar les dades en un fitxer
file_put_contents($nomFitxer, $dadesJsonUtf8);
?>