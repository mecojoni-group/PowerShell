$Path = "C:\Temp\"
$User = "cairo\bkp.copy"
$Pass = "rfftTkSjEQ8YZ9SCXKah"
$Files = Get-ChildItem -Path $Path -Filter "*.xml"


foreach ($File in $Files)
{
    $NameFile = ($File).BaseName
    Register-ScheduledTask -xml (Get-Content "$Path\$File" | Out-String) -TaskName $NameFile -TaskPath "\" -User $User -Password $Pass –Force
}
