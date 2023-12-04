# Establir la codificació a UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Llegir opcions des de config.json
$config = Get-Content -Path "..\etc\config.json" -Raw -Encoding UTF8 | ConvertFrom-Json
$urlServeiCaptures = $config.url_servei_captures

# GUI para captura de pantalla
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "Capturar pantalla"
$form.Width = 300
$form.Height = 380

# Funció per validar els camps
function Validate-Fields {
    $valid = $true
    if ([string]::IsNullOrWhiteSpace($textBoxCognom.Text)) {
        $textBoxCognom.BackColor = [System.Drawing.Color]::LightCoral
        $valid = $false
    } else {
        $textBoxCognom.BackColor = [System.Drawing.Color]::White
    }

    if ([string]::IsNullOrWhiteSpace($textBoxNom.Text)) {
        $textBoxNom.BackColor = [System.Drawing.Color]::LightCoral
        $valid = $false
    } else {
        $textBoxNom.BackColor = [System.Drawing.Color]::White
    }

    if ($comboBox.SelectedIndex -lt 0) {
        $comboBox.BackColor = [System.Drawing.Color]::LightCoral
        $valid = $false
    } else {
        $comboBox.BackColor = [System.Drawing.Color]::White
    }

    return $valid
}

# Campos para Cognom i Nom
$labelCognom = New-Object System.Windows.Forms.Label
$labelCognom.Location = New-Object System.Drawing.Point(10,20)
$labelCognom.Size = New-Object System.Drawing.Size(280,20)
$labelCognom.Text = "Cognom:"
$form.Controls.Add($labelCognom)

$textBoxCognom = New-Object System.Windows.Forms.TextBox
$textBoxCognom.Location = New-Object System.Drawing.Point(10,40)
$textBoxCognom.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($textBoxCognom)

$labelNom = New-Object System.Windows.Forms.Label
$labelNom.Location = New-Object System.Drawing.Point(10,70)
$labelNom.Size = New-Object System.Drawing.Size(280,20)
$labelNom.Text = "Nom:"
$form.Controls.Add($labelNom)

$textBoxNom = New-Object System.Windows.Forms.TextBox
$textBoxNom.Location = New-Object System.Drawing.Point(10,90)
$textBoxNom.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($textBoxNom)

# Text "Executar prova"
$labelExecutarProva = New-Object System.Windows.Forms.Label
$labelExecutarProva.Location = New-Object System.Drawing.Point(10,120)
$labelExecutarProva.Size = New-Object System.Drawing.Size(280,20)
$labelExecutarProva.Text = "Executar prova"
$form.Controls.Add($labelExecutarProva)

# Selector d'opcions
$comboBox = New-Object System.Windows.Forms.ComboBox
$comboBox.Location = New-Object System.Drawing.Point(10,140)
$comboBox.Size = New-Object System.Drawing.Size(260,20)
$comboBox.Items.AddRange($config.opcions_desplegable)
$comboBox.SelectedIndex = 0  # Això selecciona automàticament la primera opció
$form.Controls.Add($comboBox)

# PictureBox per mostrar la miniatura
$pictureBox = New-Object System.Windows.Forms.PictureBox
$pictureBox.Location = New-Object System.Drawing.Point(10,200)
$pictureBox.Size = New-Object System.Drawing.Size(260,100)
$pictureBox.SizeMode = "Zoom"
$form.Controls.Add($pictureBox)

# Etiqueta d'estat (Status Label)
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(10,310)
$statusLabel.Size = New-Object System.Drawing.Size(280,20)
$form.Controls.Add($statusLabel)

# Botón para captura de pantalla
$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(10,170)
$button.Size = New-Object System.Drawing.Size(260,20)
$button.Text = "Captura pantalla"
$button.Add_Click({
	try{
		# Clear the status label and the screenshot icon at the start of the process
		$statusLabel.Text = ""
		$pictureBox.Image = $null	

		# Wait for 1 second
		Start-Sleep -Seconds 1
		
		if (Validate-Fields) {
			$nombreArchivo = ($comboBox.SelectedItem -replace ' ', '-') + "__" + ($textBoxCognom.Text -replace ' ', '-') + "-" + ($textBoxNom.Text -replace ' ', '-')
			$nombreArchivo = $nombreArchivo -replace '[Áá]', 'a' -replace '[Éé]', 'e' -replace '[Íí]', 'i' -replace '[Óó]', 'o' -replace '[Úú]', 'u'
			$nombreArchivo = $nombreArchivo.ToLower() + ".png"
			$rutaArchivo = "..\captures\$nombreArchivo"
			
			# Captura de pantalla
			$bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
			$bitmap = New-Object System.Drawing.Bitmap $bounds.width, $bounds.height
			$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
			$graphics.CopyFromScreen($bounds.Location, [System.Drawing.Point]::Empty, $bounds.Size)

			# Desallotjar el gràfic abans de guardar
			$graphics.Dispose()

			# Guardar la imatge i alliberar el bitmap
			if (!(Test-Path -Path "..\captures")) {
				New-Item -ItemType Directory -Force -Path "..\captures"
			}

			$bitmap.Save($rutaArchivo, [System.Drawing.Imaging.ImageFormat]::Png)
			$bitmap.Dispose()

			# Actualitzar l'estat
			$statusLabel.Text = "Captura realitzada, processant..."

			# Alliberar la imatge actual del PictureBox abans de carregar-ne una de nova
			if ($pictureBox.Image -ne $null) {
				$pictureBox.Image.Dispose()
			}

			# Mostrar la miniatura
			$imageFromFile = [System.Drawing.Image]::FromFile($rutaArchivo)
			$pictureBox.Image = New-Object System.Drawing.Bitmap $imageFromFile
			$imageFromFile.Dispose()
			
			try {
				# Codificar la captura en base64
				$fileStream = [System.IO.File]::OpenRead($rutaArchivo)
				$byteArray = New-Object Byte[] $fileStream.Length
				$fileStream.Read($byteArray, 0, $byteArray.Length)
				$base64 = [System.Convert]::ToBase64String($byteArray)
				# Preparar diccionari JSON
				$datos = @{
					cognom = $textBoxCognom.Text
					nom = $textBoxNom.Text
					prova = $comboBox.SelectedItem
					imatge = $base64
				}
				$json = $datos | ConvertTo-Json -Depth 10

				# Convertir el JSON a un array de bytes UTF-8
				$utf8 = New-Object System.Text.UTF8Encoding
				$byteArray = $utf8.GetBytes($json)

				# Enviar la captura
				try {
					$statusLabel.Text = "Enviant captura..."
					$headers = @{ "Content-Type" = "application/json;charset=utf-8" }
					Invoke-RestMethod -Method Post -Uri $urlServeiCaptures -Body $byteArray -Headers $headers
					$statusLabel.Text = "Captura enviada correctament"
				} catch {
					$statusLabel.Text = "Error en enviar la captura"
				}
			} finally {
				if ($fileStream -ne $null) {
					$fileStream.Dispose()
				}
				if ($byteArray -ne $null) {
					$byteArray = $null
				}
				if ($base64 -ne $null) {
					$base64 = $null
				}
				if ($datos -ne $null) {
					$datos = $null
				}
			}			
		} else {
			$statusLabel.Text = "Omple tots els camps i selecciona una opció"
		}
	} catch {
		$statusLabel.Text = "Error: " + $_.Exception.Message
	}
})
$form.Controls.Add($button)

# Mostrar el formulario
$form.ShowDialog()
