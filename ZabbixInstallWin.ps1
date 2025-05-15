$ServerHostname = "$ENV:COMPUTERNAME"
$ServerIP = 172.20.0.81
$InstallationFolder = "C:\Zabbix"
#
If (!(test-path $InstallationFolder))
{
    md C:\Zabbix
}
#
wget "https://cdn.zabbix.com/zabbix/binaries/stable/5.0/5.0.6/zabbix_agent-5.0.6-windows-amd64-openssl.msi" -outfile "$InstallationFolder\zabbix_agent-5.0.6-windows-amd64-openssl.msi"
#
cmd /c '\\172.20.0.240\appoggio$\openssl-1.1.1i-win64\openssl.exe rand -hex 32 > C:\zabbix\zabbix_agentd.psk'
#
$psk = Get-Content -Path $InstallationFolder\zabbix_agentd.psk
#
#INSTALL
msiexec.exe /l*v "$InstallationFolder\installation.log" /i "$InstallationFolder\zabbix_agent-5.0.6-windows-amd64-openssl.msi" /qn SERVER=172.20.0.81 SERVERACTIVE=172.20.0.81 TIMEOUT=10 INSTALLFOLDER=$InstallationFolder
sleep 5
#
(Get-Content -Path $InstallationFolder\zabbix_agentd.conf) | ForEach-Object {$_ -replace '# LogFileSize=1','LogFileSize=0'} | Set-Content -Path $InstallationFolder\zabbix_agentd.conf
(Get-Content -Path $InstallationFolder\zabbix_agentd.conf) | ForEach-Object {$_ -replace 'Hostname='+$ServerHostname,'# Hostname=$ServerHostname'} | Set-Content -Path $InstallationFolder\zabbix_agentd.conf
(Get-Content -Path $InstallationFolder\zabbix_agentd.conf) | ForEach-Object {$_ -replace '# HostnameItem=system.hostname','HostnameItem=system.hostname'} | Set-Content -Path $InstallationFolder\zabbix_agentd.conf
(Get-Content -Path $InstallationFolder\zabbix_agentd.conf) | ForEach-Object {$_ -replace '# HostMetadataItem=','HostMetadataItem=system.uname'} | Set-Content -Path $InstallationFolder\zabbix_agentd.conf
#
Restart-Service "Zabbix Agent"
#
Add-Content -Path $InstallationFolder\zabbix_agentd.conf -Value ""
Add-Content -Path $InstallationFolder\zabbix_agentd.conf -Value "# TLS Parametri"
Add-Content -Path $InstallationFolder\zabbix_agentd.conf -Value "TLSConnect=psk"
Add-Content -Path $InstallationFolder\zabbix_agentd.conf -Value "TLSAccept=psk"
Add-Content -Path $InstallationFolder\zabbix_agentd.conf -Value "TLSPSKIdentity=PSK-$ServerHostname"
Add-Content -Path $InstallationFolder\zabbix_agentd.conf -Value "TLSPSKFile=$InstallationFolder\zabbix_agentd.psk"
#
Restart-Service "Zabbix Agent"
#>

#STATO SERVIZIO
echo ""
echo "######STATO SERVIZIO ZABBIX######"
Get-Service "Zabbix Agent" | select Status
echo ""

#INSTRUZIONI POST INSTALLAZIONE
echo "######ISTRUZIONI POST INSTALLAZIONE######"
echo ""
echo "- Inserisci i seguenti parametri nella GUI del server zabbix:"
echo "- Loggati su 'https://172.20.0.81/zabbix' con il tuo utente"
echo "- Nei tab a sinistra scegli Configuration -> Hosts"
echo "- In Name inserisci: '$ServerHostname' e clicca su Apply"
echo "- Seleziona l'host visualizzato cliccandolo"
echo "- Dal tab 'Host' alla voce 'Groups' rimuovere: 'Discovered hosts'"
echo "- Spostati nel tab Encryption"
echo "- In 'Connections to host' seleziona: 'PSK'"
echo "- In 'Connections from host' seleziona SOLO: 'PSK'"
echo "- In 'PSK identity' inserisci: PSK-$ServerHostname"
echo "- In 'PSK' inserisci la stringa sottostante: "
echo ""
echo $psk

#INSTRUZIONI DISINSTALLAZIONE
echo ""
echo "######ISTRUZIONI DISINSTALLAZIONE######"
echo ""
echo "- Per disinstallare Zabbix eseguire SINGOLARMENTE i comandi sottostanti:"
echo ""
echo '  msiexec.exe /uninstall "C:\Zabbix\zabbix_agent-5.0.6-windows-amd64-openssl.msi" /qn '
echo '  Remove-Item "C:\Zabbix\*" -Recurse -Force '
