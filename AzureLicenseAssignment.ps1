#Install-Module -Name AzureAD,MSOnline -Force
Connect-AzureAD
Connect-MsolService

#Assign licenses
$Users = Import-Csv "C:\Temp\LicenzeUtenzeAZ.csv"

foreach ($User in $Users)
{
    $userUPN = "$User.NAME"
    $planName = "$User.LICENSE"
    Write-Host $userUPN
    $License = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense 
    $License.SkuId = (Get-AzureADSubscribedSku | Where-Object -Property SkuPartNumber -Value $planName -EQ).SkuID
    $LicensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
    $LicensesToAssign.AddLicenses = $License
    $Location = "IT"
    sleep 1
    Set-MsolUser -UserPrincipalName $userUPN -UsageLocation $Location
    Set-AzureADUserLicense -ObjectId $userUPN -AssignedLicenses $LicensesToAssign
}