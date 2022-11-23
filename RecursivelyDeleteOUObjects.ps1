Get-Command -Module ActiveDirectory

$ou = 'OU=Workstations,DC=EDO,DC=LOCAL'
Get-ADObject -Filter * -SearchBase $ou |
ForEach-Object -Process {
    Set-ADObject -ProtectedFromAccidentalDeletion $false -Identity $_
    Remove-ADOrganizationalUnit -Identity $_ -Confirm:$false
    Remove-ADObject -Identity $_ -Recursive -Confirm:$false
}
Remove-ADOrganizationalUnit -Identity $ou -Confirm:$false
