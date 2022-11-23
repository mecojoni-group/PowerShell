Import-Module ActiveDirectory

#SET USER OU DESTINATION
$UserOu="OU=New Users,DC=EDO,DC=LOCAL"
#IMPORT DATA FROM
$NewUsersList=Import-CSV "C:\Users\Administrator\Desktop\utenti cairo su gruppi cairo 2021 01 11.csv"

ForEach ($User in $NewUsersList)
{
    #CREATE NEW USERS
    $givenName = $User.NAME
    $surName = $User.SURNAME
    $AccountName = $User.NAME.ToLower() + " " + $User.SURNAME.ToLower()
    $Name = (($User.NAME.ToLower()).Substring(0,1) + "." +  $User.SURNAME.ToLower()) #FORMAT CREATED USER LIKE n.surname
    $userPrincipalName = $AccountName+$User.DOMAIN
    $email = $User.NAME+$User.DOMAIN

    New-ADUser -Path $UserOu `
               -GivenName $givenName `
               -Surname $surName `
               -Name $Name `
               -DisplayName $AccountName `
               -UserPrincipalName $Name `
               -AccountPassword (ConvertTo-SecureString $User.PASSWORD -AsPlainText -Force) `
               -PasswordNeverExpires $false `
               -Enabled $true `
               -Email $email

    #ADD USERS TO SPECIFIED GROUP
    Add-ADGroupMember -Identity $User.GROUPS -Members $Name
}