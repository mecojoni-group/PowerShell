Import-Module ActiveDirectory
$searchBase='OU=Editore-Test,OU=New Users,DC=EDO,DC=LOCAL'
Get-ADUser -Filter * -SearchBase $searchBase | `
    ForEach-Object { Set-ADUser -EmailAddress ($_.givenName + '.' + $_.surname + '@test.it') -Identity $_ }