Import-Module ActiveDirectory

$SearchBase='OU=Users,OU=Enabled Users,OU=User accounts,DC=EDITORE,DC=GROUP'
$Users = Get-ADUser -Filter * -Properties * -SearchBase $SearchBase

#$Users = Get-ADUser -Filter 'Name -like "Antonio Fortichiari"' -Properties * -SearchBase $SearchBase

foreach ($User in $Users)
{
    $GivenName = $User.GivenName.ToLower()
    $GivenName = $GivenName -replace '\s',''

    $Surname = ($User.Surname.ToLower()).Trim()
    $Surname = $Surname -replace '\s',''

    $Domain = "@cairoeditore.it"
    $Alias = $GivenName + $Surname + $Domain                  #nomecognome@dominio.it
    #$Alias = $GivenName.SubString(0,1) + "." + $Surname + $Domain #n.cognome@dominio.it
    #Write-Host $Surname
    #Set-ADUser $user -add @{ProxyAddresses="SMTP:adrienne.williams.mail.onmicrosoft.com,SMTP:adrienne.williams.mail.onmicrosoft.com" -split ","}
    Set-ADUser $User -replace @{ProxyAddresses="SMTP:$Alias"}
    #Set-ADUser $User -Remove @{ProxyAddresses="SMTP:$Alias"}
}

#Get-ADUser -Filter * -Properties ProxyAddresses -SearchBase $searchBase | Format-List GivenName,Surname,ProxyAddresses