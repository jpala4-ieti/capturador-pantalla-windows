<?php
function netejarNom($string) {
    // Mapeig de caràcters amb accents a caràcters sense accents
    $map = array(
        'á' => 'a', 'Á' => 'A', 'à' => 'a', 'À' => 'A',
        'é' => 'e', 'É' => 'E', 'è' => 'e', 'È' => 'E',
        'í' => 'i', 'Í' => 'I', 'ì' => 'i', 'Ì' => 'I',
        'ó' => 'o', 'Ó' => 'O', 'ò' => 'o', 'Ò' => 'O',
        'ú' => 'u', 'Ú' => 'U', 'ù' => 'u', 'Ù' => 'U',
        'ñ' => 'n', 'Ñ' => 'N', 'ç' => 'c', 'Ç' => 'C'
    );
    $string = strtr($string, $map);

    // Eliminar caràcters que no siguin lletres, números, punts, guions baixos i guions
    // I reemplaçar-los amb guions
    $string = preg_replace('/[^A-Za-z0-9\-\_\.]/', '-', $string);

    // Substituir múltiples guions seguits per un sol guion
    $string = preg_replace('/\-+/', '-', $string);

    // Convertir a minúscules i substituir espais per guions baixos
    $string = strtolower($string);
    $string = preg_replace('/\s+/', '_', $string);

    return $string;
}


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
$nomCarpeta = netejarNom($prova);

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
$nomFitxer = $rutaCompleta . '/' . netejarNom("{$prova}__{$cognom}-{$nom}") . '.json';

// Guardar les dades en un fitxer
file_put_contents($nomFitxer, $dadesJsonUtf8);
?>
