$servers = Get-ADComputer -filter { Enabled -eq $True } -SearchBase "OU=Admin,DC=cairo,DC=group" -Properties * | 
		   where { $_.OperatingSystem -like "*Server*" } | select Name

$onesync = (Get-ChildItem 'HKLM:\System\CurrentControlSet\Services' | ?{$_.PSChildName -like "OneSync*"}).Name
$here = Get-Location

foreach ( $server in $servers ) {
	$testCon = Test-Connection $server.name -count 1 -erroraction 'silentlycontinue' 
	if ( $testCon -ne $null ) {
		Invoke-Command  -ComputerName $server.name -ScriptBlock { 
            hostname
            gpupdate /force
            start-service sppsvc
            start-service WbioSrvc
            start-service RemoteRegistry
            get-service sppsvc,WbioSrvc,RemoteRegistry
		}
	}
    else { echo "$($server.name) non raggiungibile" }
}
