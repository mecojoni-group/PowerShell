# VARIABILI
$InstallationFolder = 'C:\Jenkins_test'

# CREO LA DIRECTORY PRINCIPALE DI DESTINAZIONE SE NON ESISTE
If (!(test-path "$InstallationFolder"))
{
    md $InstallationFolder
}

# CREO LA CARTELLA DEL JOB SE NON ESISTE
If (!(test-path "$InstallationFolder\$env:JOB_NAME"))
{
	md $InstallationFolder\$env:JOB_NAME
}
else
{
  	Remove-Item "$InstallationFolder\$env:JOB_NAME\*" -Recurse -Force
}

# SPOSTO IL FILE CREATO NELLA DESTINAZIONE
Copy-Item -Path "C:\Windows\System32\config\systemprofile\AppData\Local\Jenkins\.jenkins\workspace\$env:JOB_NAME\*" -Destination "$InstallationFolder\$env:JOB_NAME\" -Recurse
Expand-Archive -LiteralPath "$InstallationFolder\$env:JOB_NAME\file.zip" -DestinationPath $InstallationFolder\$env:JOB_NAME
rm "$InstallationFolder\$env:JOB_NAME\file.zip"