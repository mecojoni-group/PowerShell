Install-Module -Name AzureAD,MSOnline -Force

Connect-AzureAD
Connect-MsolService

Get-AzureADSubscribedSku | Select -Property SkuPartNumber,ConsumedUnits
Get-AzureADSubscribedSku | Select -Property Sku*,ConsumedUnits -ExpandProperty PrepaidUnits

Get-AzureADUser -ObjectID "e.beltramo@cairocommunication.it" | Select DisplayName, UsageLocation

Get-MsolUser -UserPrincipalName "e.beltramo@cairocommunication.it" | Format-List DisplayName,Licenses

Get-MsolUser -All "e.beltramo@cairocommunication.it"



#$Users = Get-MsolUser -DomainName "cairoeditore.it" #-UnlicensedUsersOnly
$Users = Import-Csv "C:\Temp\test.csv"
foreach ($User in $Users){
    Set-MsolUserLicense -UserPrincipalName $User.NAME -AddLicenses $User.LICENSE
}

EXCHANGESTANDARD -> P1
STANDARDPACK -> E1
SPE_E3 -> E3