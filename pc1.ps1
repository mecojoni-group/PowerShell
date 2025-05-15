set-executionpolicy remotesigned

#Chrome Install
    $Path = $env:TEMP;
    $Installer = "chrome_installer.exe";
    Invoke-WebRequest "http://dl.google.com/chrome/install/375.126/chrome_installer.exe" -OutFile $Path\$Installer;
    Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait;
    Remove-Item $Path\$Installer

#Java Install
    $URL=(Invoke-WebRequest -UseBasicParsing https://www.java.com/en/download/manual.jsp).Content | %{[regex]::matches($_, '(?:<a title="Download Java software for Windows Online" href=")(.*)(?:">)').Groups[1].Value}
    Invoke-WebRequest -UseBasicParsing -OutFile jre8.exe $URL
    Start-Process .\jre8.exe '/s REBOOT=0 SPONSORS=0 AUTO_UPDATE=0' -wait
    echo $?

#Adobe Reader DC Install
    # Check if Software is installed already in registry.
    $CheckADCReg = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.DisplayName -like "Adobe Acrobat Reader DC*"}
    # If Adobe Reader is not installed continue with script. If it's istalled already script will exit.
    If ($CheckADCReg -eq $null) {
    # Path for the temporary downloadfolder. Script will run as system so no issues here
    $Installdir = "c:\temp\install_adobe"
    New-Item -Path $Installdir  -ItemType directory
    # Download the installer from the Adobe website. Always check for new versions!!
    $source = "ftp://ftp.adobe.com/pub/adobe/reader/win/AcrobatDC/2001220041/AcroRdrDC2001220041_en_US.exe"
    $destination = "$Installdir\AcroRdrDC2001220041_en_US.exe"
    Invoke-WebRequest $source -OutFile $destination
    # Start the installation when download is finished
    Start-Process -FilePath "$Installdir\AcroRdrDC2001220041_en_US.exe" -ArgumentList "/sAll /rs /rps /msi /norestart /quiet EULA_ACCEPT=YES"
    # Wait for the installation to finish. Test the installation and time it yourself. I've set it to 240 seconds.
    Start-Sleep -s 240
    # Finish by cleaning up the download. I choose to leave c:\temp\ for future installations.
    rm -Force $Installdir\AcroRdrDC*
    }

#Install Firefox
    $Path = $env:TEMP;
    $Installer = "firefox_installer.exe";
    Invoke-WebRequest "https://download.mozilla.org/?product=firefox-stub" -OutFile $Path\$Installer;
    Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait;
    Remove-Item $Path\$Installer

#Install 7zip
    $Path = $env:TEMP;
    $Installer = "7zip_installer.exe";
    Invoke-WebRequest "https://www.7-zip.org/a/7z1900-x64.exe" -OutFile $Path\$Installer;
    Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait;
    Remove-Item $Path\$Installer

#Kaseya Install

    function Get-FTPFile ($Source,$Target,$UserName,$Password)  
    {   
    $ftprequest = [System.Net.FtpWebRequest]::create($Source)  
    $ftprequest.Credentials =  
        New-Object System.Net.NetworkCredential($username,$password)  
    $ftprequest.Method = [System.Net.WebRequestMethods+Ftp]::DownloadFile  
    $ftprequest.UseBinary = $true  
    $ftprequest.KeepAlive = $false  
    $ftpresponse = $ftprequest.GetResponse()  
    $responsestream = $ftpresponse.GetResponseStream()  
    $targetfile = New-Object IO.FileStream ($Target,[IO.FileMode]::Create)  
    [byte[]]$readbuffer = New-Object byte[] 1024   
    do{  
        $readlength = $responsestream.Read($readbuffer,0,1024)  
        $targetfile.Write($readbuffer,0,$readlength)  
    }  
    while ($readlength -ne 0)  
    $targetfile.close()  
    }  
    $sourceuri = "ftp://95.110.173.163/powershell\KcsSetup.exe"  
    $targetpath = "C:\temp\KcsSetup.exe"  
    $user = "tecnici"  
    $pass = "T3cn1c1!"  
    Get-FTPFile $sourceuri $targetpath $user $pass

    Start-Process -FilePath $targetpath -Args "/silent /install" -Verb RunAs -Wait;
    Remove-Item $targetpath

#Webroot Install

    function Get-FTPFile ($Source,$Target,$UserName,$Password)  
    {   
    $ftprequest = [System.Net.FtpWebRequest]::create($Source)  
    $ftprequest.Credentials =  
        New-Object System.Net.NetworkCredential($username,$password)  
    $ftprequest.Method = [System.Net.WebRequestMethods+Ftp]::DownloadFile  
    $ftprequest.UseBinary = $true  
    $ftprequest.KeepAlive = $false  
    $ftpresponse = $ftprequest.GetResponse()  
    $responsestream = $ftpresponse.GetResponseStream()  
    $targetfile = New-Object IO.FileStream ($Target,[IO.FileMode]::Create)  
    [byte[]]$readbuffer = New-Object byte[] 1024   
    do{  
        $readlength = $responsestream.Read($readbuffer,0,1024)  
        $targetfile.Write($readbuffer,0,$readlength)  
    }  
    while ($readlength -ne 0)  
    $targetfile.close()  
    }  
    $sourceuri = "ftp://95.110.173.163/powershell\wsasme.exe"  
    $targetpath = "C:\temp\wsasme.exe"  
    $user = "tecnici"  
    $pass = "T3cn1c1!"  
    Get-FTPFile $sourceuri $targetpath $user $pass

    Start-Process -FilePath $targetpath -Args "/silent /install" -Verb RunAs -Wait;
    Remove-Item $targetpath

#Windows Firewall    
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

#Windows Update
    Install-Module PSWindowsUpdate
    Get-WindowsUpdate
    Install-WindowsUpdate

#Disable UAC
    New-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA -PropertyType DWord -Value 0 -Force

#Enable RDP
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0

#Enable net share win 10
    New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name "EnableLinkedConnections" -Value "00000001" ` -PropertyType DWORD -Force | Out-Null

#Disable ipv6
    Get-NetAdapter | foreach { Disable-NetAdapterBinding -InterfaceAlias $_.Name -ComponentID ms_tcpip6 }
    #Get-NetAdapter | foreach { Get-NetAdapterBinding -InterfaceAlias $_.Name -ComponentID ms_tcpip6 } #check if disabled

#Enable System Protection 5%
    Enable-ComputerRestore -Drive "C:\"


#Disable Power Saving on Ethernet and Wi-fi interfaces
function Use-RunAs 
{    
    # Check if script is running as Adminstrator and if not use RunAs 
    # Use Check Switch to check if admin 
	# https://gallery.technet.microsoft.com/scriptcenter/63fd1c0d-da57-4fb4-9645-ea52fc4f1dfb
    param([Switch]$Check) 
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")     
    if ($Check) { return $IsAdmin }     
    if ($MyInvocation.ScriptName -ne "") 
    {  
        if (-not $IsAdmin)  
        {  
            try 
            {  
                $arg = "-file `"$($MyInvocation.ScriptName)`"" 
                Start-Process "$psHome\powershell.exe" -Verb Runas -ArgumentList $arg -ErrorAction 'stop'  
            } 
            catch 
            { 
                Write-Warning "Error - Failed to restart script with runas"  
                break               
            } 
            exit # Quit this session of powershell 
        }  
    }  
    else  
    {  
        Write-Warning "Error - Script must be saved as a .ps1 file first"  
        break  
    }  
} 
# -------------------------------------------------------------------------------
# Lo script verrÃ  eseguito con i privilegi di amministratore
Use-RunAs
# -
# Avvio creazione log
Start-Transcript -Path ($MyInvocation.MyCommand.Definition -replace 'ps1','log') -Append | out-null
# -
# Avvio verifica schede di rete installate
Write-Host -ForegroundColor White "Verifica delle schede di rete installate"
Write-Host ""
$RegKeys = Get-ChildItem -Path "Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}"  -ErrorAction SilentlyContinue
foreach ($SubKey in $RegKeys){
	$idNIC=Split-Path -Path $SubKey.PSPath -Leaf -Resolve
	# ProprietÃ  scheda di rete
    $objNICproperties = (Get-ItemProperty $SubKey.PSPath -ErrorAction SilentlyContinue)
	If ($objNICproperties){
		# http://www.iana.org/assignments/ianaiftype-mib/ianaiftype-mib
	    # *ifType = ieee80211(71)	 Schede Wi-Fi
		# *ifType = ethernetCsmacd(6) Schede Ethernet
		If ((($objNICproperties."*ifType" -eq 71) -or ($objNICproperties."*ifType" -eq 6)) -and ($objNICproperties.DeviceInstanceID -notlike "ROOT\*") -and ($objNICproperties.DeviceInstanceID -notlike "SW\*")){
				# Verifica proprietÃ  hardware
				$objHWProperties = (Get-ItemProperty -Path ("HKLM:\SYSTEM\CurrentControlSet\Enum\{0}" -f $objNICproperties.DeviceInstanceID) -ErrorAction SilentlyContinue)
				If ($objHWProperties.FriendlyName){
					$strNICDisplayName = $objHWProperties.FriendlyName 
				}
				else {
					$strNICDisplayName = $objNICproperties.DriverDesc 
				}
				# Verifica proprietÃ  rete
				$objNetworkProperties = (Get-ItemProperty -Path ("HKLM:\SYSTEM\CurrentControlSet\Control\Network\{0}\{1}\Connection" -f "{4D36E972-E325-11CE-BFC1-08002BE10318}", $objNICproperties.NetCfgInstanceId) -ErrorAction SilentlyContinue) 
				# Visualzzazione dettagli
				Write-Host -NoNewline -ForegroundColor White "   ID     : "; Write-Host -ForegroundColor Yellow $idNIC
				Write-Host -NoNewline -ForegroundColor White "   Rete   : "; Write-Host $objNetworkProperties.Name
				Write-Host -NoNewline -ForegroundColor White "   NIC    : "; Write-Host $strNICDisplayName
				# Disabilitazione risparmio energetico
				Set-ItemProperty -Path ("HKLM:\SYSTEM\CurrentControlSet\Control\Class\{0}\{1}" -f "{4D36E972-E325-11CE-BFC1-08002BE10318}", $idNIC) -Name "PnPCapabilities" -Value "24" -Type DWord
				Write-Host -NoNewline -ForegroundColor White "   Azione :";Write-Host -ForegroundColor Green (" Risparmio energetico disabilitato")
				Write-Host "------------------------------------------------------------"
		}
	}
}
# Stop log
Stop-Transcript | out-null

# Riavvio necessario
#Write-Host -ForegroundColor Magenta "Riavviare il sistema per rendere effettive le modifiche."