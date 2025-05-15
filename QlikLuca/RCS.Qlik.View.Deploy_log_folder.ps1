###
#
$ScriptPath  = (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)
$ScriptName  = [System.IO.Path]::GetFileNameWithoutExtension( $MyInvocation.MyCommand.Name )
$LogPath     = Join-Path -Path $ScriptPath  -ChildPath "Logs\"
$SqlServer   = "ECMISRSQL19X\SQL2019X1"
$SmtpServer  = "smtpappl.corp.rcs.group"
#
if ( !( Test-Path $LogPath -PathType Container ) ){ New-Item -Path $LogPath -ItemType "Directory" | Out-Null }
Import-Module ( Join-Path -Path $ScriptPath -ChildPath ( "{0}.psm1" -f $ScriptName ) ) -DisableNameChecking
#
###

if ( $args.Count -ne 2 )
{   #
    Write-Host "Sintax: .\RCS.Qlik.View.Deploy.ps1 < ProjectName > < DeployZipFile >"
    Return
}
$ProjectName   = $args[ 0 ]
$DeployZipFile = $args[ 1 ]
#
$Now         = Get-Date -format "yyyy.MM.dd.hhmmss"
$NowLog      = Get-Date -format "yyyyMMdd"
$QlikLogPath = "\\qlikstore02\qlik_svl$\DataServices\DistributionData\1\Log\" + $NowLog
$LogFileName = ( Join-Path -Path $LogPath -ChildPath  ( "{0}_{1}.log" -f $ProjectName , $Now ) )
$prms        = Get-Parameters -SqlServerInstance $SqlServer -ProjectName $ProjectName
$ToZip       = @()
$OkFileName  = "CopiaOK.dat"
$Exit        = 0

<#
Clear-Host
#

"PProjectNotNull    : {0}" -f $prms.PProjectNotNull
"PCategory          : {0}" -f $prms.PCategory
"PMailFrom          : {0}" -f $prms.PMailFrom
"PMailSubject       : {0}" -f $prms.PMailSubject
"PMailTo            : {0}" -f $prms.PMailTo
"PPathDeploy        : {0}" -f $prms.PPathDeploy
"PPathDeployData    : {0}" -f $prms.PPathDeployData
"PPathDeployExtData : {0}" -f $prms.PPathDeployExtData
"PPathDeployQvw     : {0}" -f $prms.PPathDeployQvw
"PPathHistory       : {0}" -f $prms.PPathHistory
"PPathQvDocs        : {0}" -f $prms.PPathQvDocs
"PPathQvDocsData    : {0}" -f $prms.PPathQvDocsData
"PPathQvDocsExtData : {0}" -f $prms.PPathQvDocsExtData
"PPathQvDocsQvw     : {0}" -f $prms.PPathQvDocsQvw
"PQmsServer         : {0}" -f $prms.PQmsServer
"PTaskPrefix        : {0}" -f $prms.PTaskPrefix
#>

Write-Log -FileName $LogFileName -Message ( Get-Date -format "yyyy.MM.dd. hh:mm:ss" )
Write-Log -FileName $LogFileName -Message ( "Start Deploy Project [ {0} ]" -f $ProjectName )
Write-Log -FileName $LogFileName -Message ""

#if ( $prms -ne $null )
if ( $prms.PProjectNotNull )
{   #
    if (  Test-Path -Path $prms.PPathQvDocs -PathType Container )
    {   # E:\QlikViewDEPLOY\<categoria>\<progetto>
        if ( !( Test-Path $prms.PPathDeploy  -PathType Container ) ){ New-Item -Path $prms.PPathDeploy  -ItemType "Directory" | Out-Null }
        if ( !( Test-Path $prms.PPathHistory -PathType Container ) ){ New-Item -Path $prms.PPathHistory -ItemType "Directory" | Out-Null }
        #
        if ( Test-Path $DeployZipFile -PathType Leaf )
        {   #
            Write-Log -FileName $LogFileName -Message ( "Expand-Archive" )
            #
            Expand-Archive -LiteralPath $DeployZipFile -DestinationPath $prms.PPathDeploy -Verbose
            #
            Write-Log -FileName $LogFileName -Message ""
            #
            if ( Update-ProjectData -LogFile $LogFileName -Sorce $prms.PPathDeployData -Destination $prms.PPathQvDocsData -FileOK $OkFileName )
            {   #
                $ToZip += $prms.PPathDeployData
            }   #
            if ( Update-ProjectExtData -LogFile $LogFileName -Sorce $prms.PPathDeployExtData -Destination $prms.PPathQvDocsExtData -FileOK $OkFileName )
            {   #
                $ToZip += $prms.PPathDeployExtData
            }   #
            if ( Update-ProjectQvw -LogFile $LogFileName -Sorce $prms.PPathDeployQvw -Destination $prms.PPathQvDocsQvw -FileOK $OkFileName -TaskPrefix $prms.PTaskPrefix -QmsServer $prms.PQmsServer )
            {   #
                $ToZip += $prms.PPathDeployQvw
            }   #
            #
            if ( $ToZip.Length -gt 0 )
            {   #
                $History = @{
                    Path             = $ToZip
                    CompressionLevel = "Optimal"
                    DestinationPath  = Join-Path -Path $prms.PPathHistory -ChildPath ( "{0}_{1}.zip" -f $ProjectName , $Now )
                }   #
                Write-Log -FileName $LogFileName -Message ( "Compress-Archive To : {0}" -f $History.DestinationPath )
                #
                Compress-Archive @History -Verbose
                #
                Write-Log -FileName $LogFileName -Message ""
            }   #
            #
            $Message = ( "Eseguito Deploy Del Progetto : {0}." -f $ProjectName )
        }   #
        else
        {   #
            $Exit    = 1
            $Message = ( "[ Error ] Zip File To Deploy Not Found." )
            #
            Write-Log -FileName $LogFileName -Message $Message
        }   #
        #
        foreach ( $FileOrFolder in Get-ChildItem $prms.PPathDeploy )
        {   #
            Remove-Item $FileOrFolder.FullName -Recurse -Force -ErrorAction Continue
        }   #
    }   #
    else
    {   #
        $Exit    = 1
        $Message = ( "[ Error ] The Project Folder [ {0} ] Not Found." -f $prms.PPathQvDocs )
        Write-Log -FileName $LogFileName -Message $Message
    }   #
}   #
else 
{   #
    $Exit    = 1
    $Message = ( "[ Error ] The Project [ {0} ] Not Found On Database." -f $ProjectName ) 
    Write-Log -FileName $LogFileName -Message $Message
}   #

Write-Log -FileName $LogFileName -Message ( "Send Mail Message" )
Write-Log -FileName $LogFileName -Message ( "To : {0}" -f $prms.PMailTo )
#
Send-MailMessage `
    -from       $prms.PMailFrom `
    -smtpserver $SmtpServer     `
    -to         @( foreach ( $Mail in $prms.PMailTo.Split( ',' ) ){ $Mail } ) `
    -subject    ( "{0} - Deploy {1}" -f $prms.PMailSubject , $ProjectName )    `
    -body       $Message
#
Write-Log -FileName $LogFileName -Message ""
Write-Log -FileName $LogFileName -Message ( "End Deploy Project [ {0} ]" -f $ProjectName )
Write-Log -FileName $LogFileName -Message ( Get-Date -format "yyyy.MM.dd. hh:mm:ss" )
Write-Log -FileName $LogFileName -Message ""
Write-Log -FileName $LogFileName -Message ( "Qlik View Log Path :" + $QlikLogPath )
Write-Log -FileName $LogFileName -Message ""

exit $Exit