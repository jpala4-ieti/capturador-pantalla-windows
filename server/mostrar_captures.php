<!DOCTYPE html>
<html lang="ca">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="refresh" content="5">
    <title>Captures</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <style>
        .container { margin-top: 20px; }
        .capture-card { margin-bottom: 20px; }
        .capture-image { width: 100px; height: auto; }
    </style>
</head>
<body>
<div class="container">
<?php
$directoriCaptures = './captures';

if (file_exists($directoriCaptures) && is_dir($directoriCaptures)) {
    $dirHandle = opendir($directoriCaptures);

    if ($dirHandle) {
        while (($subdir = readdir($dirHandle)) !== false) {
            if ($subdir != '.' && $subdir != '..') {
                echo "<h1 class='mt-4'>" . htmlspecialchars($subdir) . "</h1>";
                echo "<div class='row'>"; // Iniciar una nova fila

                $subdirPath = $directoriCaptures . '/' . $subdir;
                $subdirHandle = opendir($subdirPath);

                if ($subdirHandle) {
                    while (($file = readdir($subdirHandle)) !== false) {
                        if (pathinfo($file, PATHINFO_EXTENSION) == 'json') {
                            $jsonData = json_decode(file_get_contents($subdirPath . '/' . $file), true);
                            $imatgeBase64 = $jsonData['imatge'];
                            $prova = htmlspecialchars($jsonData['prova']);
                            $cognom = htmlspecialchars($jsonData['cognom']);
                            $nom = htmlspecialchars($jsonData['nom']);

                            echo "<div class='col-md-4'>"; // Iniciar una columna
                            echo "<div class='card capture-card'>";
                            echo "<div class='card-body'>";
                            echo "<img src='data:image/png;base64," . $imatgeBase64 . "' class='capture-image float-left mr-3'>";
                            echo "<p><strong>Prova:</strong> $prova</p>";
                            echo "<p><strong>Nom:</strong> $cognom, $nom</p>";
                            echo "</div>";
                            echo "</div>";
                            echo "</div>"; // Tancar columna
                        }
                    }
                    closedir($subdirHandle);
                }
                echo "</div>"; // Tancar fila
            }
        }
        closedir($dirHandle);
    }
} else {
    echo "<p>Directori 'captures' no trobat.</p>";
}
?>
</div>

<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
