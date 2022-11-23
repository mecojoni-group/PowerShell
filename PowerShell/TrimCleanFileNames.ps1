# Variables
$Folder = "E:\tes\"
$Files = Get-ChildItem -Path $Folder

foreach($File in $Files){

    # Get file name without extension
    $Name = [System.IO.Path]::GetFileNameWithoutExtension($File)

    # Get extension without filename
    $Extension = ""
    $Extension = [System.IO.Path]::GetExtension($File)

    # Remove pre and after spaces from the file name
    $TrimmedName = $Name.Trim()

    # Remove unsupported characters
    $CleanName = $TrimmedName -replace '[{},<,?,>,*,|,",:,\\,/]',''

    # Re-create the filename with the new trimmed name and the file extension
    $NewFileName = $CleanName+$Extension

    # Utilize the newly created name to rename the file
    Rename-Item -Path $Folder$File -NewName $NewFileName
}
