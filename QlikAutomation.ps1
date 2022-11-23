Set-ExecutionPolicy Bypass

#VARIABLES
$SourcePath = "F:\ZZ_Source"
$DestinationPath = "F:\ZZZ_Destination"
$HistoryPath = "F:\ZZZZ_History"
$Projects = Get-ChildItem $SourcePath -Directory -Name -Recurse
$ZipDeployDati = ""
$ZipDeployExternalData = ""
$ZipDeployQvw = ""

foreach ($Project in $Projects)
{
    #DEPLOYDATI
    #<#

    #VARIABLES
    $DeployDatiPath = "$SourcePath\$Project\Dati"
    $ImpostazioniPath = "$DestinationPath\$Project"
    #$ZipDeployDati = ""
    $Zip = @()

    #CHECK IF THE ROOT FOLDER EXISTS
    if (Test-Path "$DeployDatiPath")
    {
        #CHECK IF FILEOK IS IN THE FOLDER
        if (Test-Path "$DeployDatiPath\FileOK.txt" -PathType leaf)
        {
            #CHECK IF IMPOSTAZIONI FOLDER IS IN THE DESTINATION PATH
            If (!(test-path $ImpostazioniPath))
            {
                md $ImpostazioniPath
            }

            #RECURSIVELY COPY ALL FOLDERS AND THEIR FILES IN THE ROOT
            Get-ChildItem -Path "$DeployDatiPath\" -Directory  | Copy-Item -Recurse -Destination "$ImpostazioniPath" -Force
            

            #Remove-Item "$ImpostazioniPath\FileOK.txt"
            
            #CHECK FOR ZIPPING TO THE HISTORY
            $Zip += ,"$DeployDatiPath"

            #Write-Host "FileOK.txt presente"
        }
        #Write-Host "DeployDati presente"
    }
    #>

    #DEPLOYEXTERNALDATA
    #<#

    #VARIABLES
    $DeployExternalDatiPath = "$SourcePath\$Project\DatiEsterni"
    $DatiEsterniPath = "$DestinationPath\$Project\DatiEsterni"
    #$ZipDeployExternalData = ""
    
    #CHECK IF THE ROOT FOLDER EXISTS
    if (Test-Path "$DeployExternalDatiPath")
    {
        #CHECK IF FILEOK IS IN THE FOLDER
        if (Test-Path "$DeployExternalDatiPath\FileOK.txt" -PathType leaf)
        {
            #CHECK IF DATIESTERNI FOLDER IS IN THE DESTINATION PATH
            If (!(test-path $DatiEsterniPath))
            {
                md $DatiEsterniPath
            }

            #RECURSIVELY COPY ALL TO THE DESTINATION
            Get-ChildItem -Path "$DeployExternalDatiPath\*" -Recurse -File | Copy-Item -Destination "$DatiEsterniPath" -Force
            Remove-Item "$DatiEsterniPath\FileOK.txt"

            #CHECK FOR ZIPPING TO THE HISTORY
            $Zip += ,"$DeployExternalDatiPath"

            #Write-Host "FileOK.txt presente"
        }
        #Write-Host "DeployExternalDati presente"
    }
    #>

    #DEPLOYQVW
    #<#

    #VARIABLES
    $SourceQvwPath = "$SourcePath\$Project\Qvw"
    $DestinationQvwPath = "$DestinationPath\$Project\Qvw"
    $ZipDeployQvw = ""

    #CHECK IF THE ROOT FOLDER EXISTS
    if (Test-Path $SourceQvwPath)
    {
        #CHECK IF ANY .QVW FILE IS IN THE FOLDER
        if(Test-Path "$SourceQvwPath\*.qvw" -PathType Leaf)
        {
            #CHECK IF FILEOK IS IN THE FOLDER
            if (Test-Path "$SourceQvwPath\FileOK.txt" -PathType leaf)
            {
                #CHECK IF QVW FOLDER IS IN THE DESTINATION PATH
                If (!(test-path $DestinationQvwPath))
                {
                    md $DestinationQvwPath
                }

                #RECURSIVELY COPY ALL TO THE DESTINATION
                Get-ChildItem -Path "$SourceQvwPath\*" -Recurse | Copy-Item -Destination "$DestinationQvwPath" -Force
                Remove-Item "$DestinationQvwPath\FileOK.txt"


                #((Get-Content -path "$SourceQvwPath\FileOK.txt" -Raw) -replace '.qvw','') | Set-Content -Path "$SourceQvwPath\FileOK.txt"
                #foreach ($Line in Get-Content "$SourceQvwPath\FileOK.txt")
                #{
                #    Write-Host $Line
                #}

                #CHECK FOR ZIPPING TO THE HISTORY
                $Zip +=  ,"$SourceQvwPath"

                #Write-Host "FileOK.txt presente"
            }
            #Write-Host "Almeno un file .qvw presente"
        }
        #Write-Host "$SourceQvwPath presente"
    }
    #>

    #HISTORY
    #<#
    
    #VARIABLES
    $Now = Get-Date -format "yyyy.MM.dd.hhmmss"

    #ZIP MARKED FOLDERS TO THE HISTORY 
    if ( $Zip.Length -gt 0 )
    {
        $History = @{
            Path = $Zip
            CompressionLevel = "Fastest"
            DestinationPath = "$HistoryPath\$Project" + "_" + "$Now" + ".zip"
        }
        Compress-Archive @History
    }
    #>
}