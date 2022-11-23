# Connect to MS365 with 2FA
Connect-ExchangeOnline -UserPrincipalName "a.e.beltramo@cairocommunication.it" -ShowProgress $true

# Fetch the list of mailboxes filtering by needed fields
$MailboxesEditore = Get-MailBox | where {$_.emailAddresses -like "*@cairoeditore.it" } | where {$_.RecipientTypeDetails -like "UserMailbox" } | Get-User | Select Firstname, Lastname, UserPrincipalName

# Set aliases for each mailbox
foreach($MailboxEditore in $MailboxesEditore)
{
    $Name = $MailboxEditore.Firstname.ToLower().replace(' ','')
    $Lastname = $MailboxEditore.Lastname.ToLower().replace(' ','')
    $Domain = "@cairoeditore.it"
    $Mail = $MailboxEditore.UserPrincipalName
    $Alias = $Name + $Lastname + $Domain
    Set-Mailbox $Mail -EmailAddresses @{Add="$Alias"}
}
