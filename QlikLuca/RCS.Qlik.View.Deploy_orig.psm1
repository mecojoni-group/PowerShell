###
#
#[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#Install-Module -Name SqlServer
#
Import-Module -Name SqlServer

function Get-Parameters
{   #
    param (
        [ string ]$SqlServerInstance ,
        [ string ]$ProjectName
    )   #
    $MParameters = Get-MainParameters    -SqlServerInstance $SqlServerInstance
    $PParameters = Get-ProjectParameters -SqlServerInstance $SqlServerInstance -ProjectName $ProjectName
    #
    if ( $PParameters -eq $null )
    {   #
        [ PSCustomObject ]$Parameters = @{
            #
            PProjectNotNull = $false ;
            #
            PMailFrom       = $MParameters.MailSender     ;
            PMailSubject    = $MParameters.MailSubject    ;
            PMailTo         = $MParameters.MailRecipients ;
        }   #
    }   #
    else
    {   #
        $ProjectSubPath = ( "{0}\{1}" -f $PParameters.Category , $PParameters.QvProjectName )
        #
        $ProjectPath_Deploy  = Join-Path -Path $MParameters.RootPathDeploy  -ChildPath $ProjectSubPath
        $ProjectPath_History = Join-Path -Path $MParameters.RootPathHistory -ChildPath $ProjectSubPath
        $ProjectPath_QvDocs  = Join-Path -Path $MParameters.RootPathQvDocs  -ChildPath $ProjectSubPath
        #
        [ PSCustomObject ]$Parameters = @{
            #
            PProjectNotNull = $true ;
            #
            PCategory       = $PParameters.Category    ;
            PMailFrom       = $MParameters.MailSender  ;
            PMailSubject    = $MParameters.MailSubject ;
            PMailTo         = ( "{0},{1}" -f $MParameters.MailRecipients , $PParameters.MailRecipients ) ;
            #
            PPathDeploy        = $ProjectPath_Deploy   ;
            PPathDeployData    = ( Join-Path -Path $ProjectPath_Deploy -ChildPath $PParameters.DataDeploy    ) ;
            PPathDeployExtData = ( Join-Path -Path $ProjectPath_Deploy -ChildPath $PParameters.ExtDataDeploy ) ;
            PPathDeployQvw     = ( Join-Path -Path $ProjectPath_Deploy -ChildPath $PParameters.QvwDeploy     ) ;
            PPathHistory       = $ProjectPath_History  ;
            PPathQvDocs        = $ProjectPath_QvDocs   ;
            PPathQvDocsData    = ( Join-Path -Path $ProjectPath_QvDocs -ChildPath $PParameters.DataQvDocs    ) ;
            PPathQvDocsExtData = ( Join-Path -Path $ProjectPath_QvDocs -ChildPath $PParameters.ExtDataQvDocs ) ;
            PPathQvDocsQvw     = ( Join-Path -Path $ProjectPath_QvDocs -ChildPath $PParameters.QvwQvDocs     ) ;
            #
            PQmsServer      = $MParameters.QmsServer   ;
            PTaskPrefix     = ( "{0}_" -f $PParameters.Category )
        }  #
    }   #
    return $Parameters
}   #
function Get-MainParameters
{   #
    param (
        [ string ]$SqlServerInstance
    )   #
    $QueryMainParameters = "SELECT * FROM QvUtility"
    $MainParameters      = Invoke-Sqlcmd -Query $QueryMainParameters -Database QVTOOL -ServerInstance $SqlServerInstance
    #
    return $MainParameters
}   #
function Get-ProjectParameters
{   #
    param (
        [ string ]$SqlServerInstance ,
        [ string ]$ProjectName
    )   #
    $QueryProjectParameters = "SELECT " `
        + "qvc.CategoriesName      AS  Category        ," `
        + "qvp.QvProjectName       AS  QvProjectName   ," `
        + "qvp.PathDeployData      AS  DataDeploy      ," `
        + "qvp.PathDeployExtData   AS  ExtDataDeploy   ," `
        + "qvp.PathDeployQvw       AS  QvwDeploy       ," `
        + "qvp.PathQvDocsData      AS  DataQvDocs      ," `
        + "qvp.PathQvDocsExtData   AS  ExtDataQvDocs   ," `
        + "qvp.PathQvDocsQvw       AS  QvwQvDocs       ," `
        + "qvp.MailRecipients      AS  MailRecipients "   `
        + "FROM QvProjects as qvp "                       `
        + "LEFT JOIN QvCategories as qvc "                `
        + "ON qvp.id_Category = qvc.id_Categories "       `
        + "WHERE qvp.QvProjectName = '{0}'" -f $ProjectName
    #
    $ProjectParameters = Invoke-Sqlcmd -Query $QueryProjectParameters -Database QVTOOL -ServerInstance $SqlServerInstance
    #
    return $ProjectParameters
}   #

function Update-ProjectData
{   #
    param (
        [ string ]$LogFileName ,
        [ string ]$Sorce       ,
        [ string ]$Destination ,
        [ string ]$FileOK
    )   #
    $Updated = $false
    #
    Write-Log -FileName $LogFileName -Message ( "Update Project Data" )
    #
    if ( Test-Path $Sorce -PathType Container )
    {   #
        if ( Test-Path ( Join-Path -Path $Sorce -ChildPath $FileOK ) -PathType Leaf )
        {   #
            if ( Test-Path $Destination -PathType Container )
            {   
                #per ogni cartella presente nella cartella di origine
                foreach ( $DataFolder in Get-ChildItem -Path $Sorce -Directory )
                {   
                    #scrive log
                    Write-Log -FileName $LogFileName -Message ( "- Deploy Data Folder : {0}" -f $DataFolder )
                    #rimuove la cartella nella destinazione
                    Remove-Item ( Join-Path -Path $Destination -ChildPath $DataFolder.Name ) -Recurse -Force -ErrorAction Continue 
                    #copia la cartella nella destinazione 
                    Copy-Item -Path $DataFolder.FullName -Destination $Destination -Recurse -Force
                    #
                    $Updated = $true
                }   #
            }   #
        }   #
        else
        {   #
            Write-Log -FileName $LogFileName -Message ( "- {0} Not Found" -f $FileOK )
        }   #
    }   #
    else
    {   #
        Write-Log -FileName $LogFileName -Message ( "- No Data To Deploy")
    }   #
    #
    Write-Log -FileName $LogFileName -Message ""
    #
    return $Updated
}   #

function Update-ProjectExtData
{   #
    param (
        [ string ]$LogFileName ,
        [ string ]$Sorce       ,
        [ string ]$Destination ,
        [ string ]$FileOK
    )   #
    $Updated = $false
    #
    Write-Log -FileName $LogFileName -Message ( "Update Project External Data" )
    #
    if ( Test-Path $Sorce -PathType Container )
    {   #
        if ( Test-Path ( Join-Path -Path $Sorce -ChildPath $FileOK ) -PathType leaf )
        {   #
            if ( !( Test-Path $Destination -PathType Container ) )
            {   #
                Write-Log -FileName $LogFileName -Message ( "- Creating External Data Folder : {0}" -f $Destination )
                #
                New-Item -Path $Destination -ItemType "Directory"
            }   #
            foreach ( $DataFile in Get-ChildItem -Path $Sorce -File )
            {   #
                if ( $DataFile.Name -ne $FileOK )
                {   #
                    Write-Log -FileName $LogFileName -Message ( "- Deploy External Data File : {0}" -f $DataFile )
                    #
                    Copy-Item $DataFile.FullName -Destination $Destination -Force
                    #
                    $Updated = $true
                }   #
            }   #
        }   #
        else
        {   #
            Write-Log -FileName $LogFileName -Message ( "- {0} Not Found" -f $FileOK )
        }   #
    }   #
    else
    {   #
        Write-Log -FileName $LogFileName -Message ( "- No External Data To Deploy")
    }   #
    #
    Write-Log -FileName $LogFileName -Message ""
    #
    return $Updated
}   #

function Update-ProjectQvw
{   #
    param (
        [ string ]$LogFileName ,
        [ string ]$Sorce       ,
        [ string ]$Destination ,
        [ string ]$FileOK      ,
        [ string ]$TaskPrefix  ,
        [ string ]$QmsServer
    )   #
    $Updated = $false
    #
    Write-Log -FileName $LogFileName -Message ( "Update Project Qvw Files" )
    #
    if ( Test-Path $Sorce -PathType Container )
    {   #
        $PathFileOK = ( Join-Path -Path $Sorce -ChildPath $FileOK )
        #
        if ( Test-Path $PathFileOK -PathType leaf )
        {   #
            if ( Test-Path $Destination -PathType Container )
            {   #
                foreach ( $DataFile in Get-ChildItem -Path $Sorce -File -Filter "*.qvw" )
                {   #
                    Write-Log -FileName $LogFileName -Message ( "- Deploy Qvw File : {0}" -f $DataFile )
                    #
                    Copy-Item $DataFile.FullName -Destination $Destination -Force
                    #
                    $Updated = $true
                }   #
            }   #
            foreach ( $Line in Get-Content $PathFileOK )
            {   #
                if ( $Line -ne "" )
                {   #
                    
                    if ( $Line.Substring( $Line.Length - 4 , 4 ) -eq ".qvw" )
                    {   #
                        $Line = $Line.Substring( 0 , $Line.Length - 4 )
                    }   #
                    $TaskName = ( "{0}{1}" -f $TaskPrefix , $Line )
                    #
                    Run-Task -LogFile $LogFileName -QmsServer $QmsServer -TaskName $TaskName
                }   #
            }   #
        }   #
        else
        {   #
            Write-Log -FileName $LogFileName -Message ( "{0} Not Found" -f $FileOK )
        }   #
    }   #
    else
    {   #
        Write-Log -FileName $LogFileName -Message ( "No Qvw Files To Deploy")
    }   #
    #
    Write-Log -FileName $LogFileName -Message ""
    #
    return $Updated
}   #

function Run-Task
{   #
    param (
        [ string ]$LogFileName ,
        [ string ]$QmsServer ,
        [ string ]$TaskName
    )   #
    $Path_Qv12DLL = "D:\QlikViewSCRIPTS\RCS.Qlik.Viev.Library\RCS.Qlik.View.QV12.dll"
    #
    [ System.Reflection.Assembly ]::LoadFile( $Path_Qv12DLL )
    #
    Write-Log -FileName $LogFileName -Message ( "Execute Task : {0}" -f $TaskName )
    #Write-Log -FileName $LogFileName -Message ""
    #
    $Qv12Qms = New-Object -TypeName RCS.Qlik.View.QvQMS -ArgumentList $QmsServer
    $Qv12Qms.RunTask( $TaskName )
    #
    #Write-Log -FileName $LogFileName -Message ""
}   #

function Write-Log
{   #
    param (
        [ string ]$Message ,
        [ string ]$FileName
    )   #
    $Message = ( "### {0}" -f $Message )
    $Message | Write-Host
    $Message | Out-File -FilePath $FileName -Append
}   #
