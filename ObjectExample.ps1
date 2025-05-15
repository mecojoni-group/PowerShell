$Destination = "F:\ZZ_Source"
$DataFolder = New-Object -Type PSObject -Property @{
    'Name'   = "Project2"
}

if (Test-Path -Path (Join-Path -Path $Destination -ChildPath $DataFolder.Name) )
{
    Write-Host "SI"
}
else
{
    Write-Host "NO"
}