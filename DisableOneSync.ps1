$servers = Get-ADComputer -filter { Enabled -eq $True } -SearchBase "OU=Admin,DC=cairo,DC=group" -Properties * | 
		   where { $_.OperatingSystem -like "*Server*" } | select Name

$here = Get-Location

foreach ( $server in $servers ) {
	$testCon = Test-Connection $server.name -count 1 -erroraction 'silentlycontinue' 
	if ( $testCon -ne $null ) {
		Invoke-Command  -ComputerName $server.name -ScriptBlock { 
			get-Service OneSync* | Stop-Service -Force; `
			Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Services\MapsBroker' -Name Start -Value 4; `
			$onesync = (Get-ChildItem 'HKLM:\System\CurrentControlSet\Services' | ?{$_.PSChildName -like "OneSync*"}).Name; `
			cd HKLM:\ `
			#ForEach( $sync in $onesync ) { Set-ItemProperty -Path $sync -Name Start -Value 4 } `
		}
		echo $onesync
		
	}
    else { echo $server.name + " non raggiungibile" }
}
