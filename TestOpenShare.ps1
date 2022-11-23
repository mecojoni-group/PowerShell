Invoke-Item -Path "D:\This Computer\Documents\LAVORO\ZZZ_Script\Powershell"


$server = "10.221.35.123"
$source_dir = "\\10.221.35.123\qlik_svl$\DataServices\DistributionData\1\Log\20210127"
$user = 'CORP.RCS.GROUP\z.edoardo.beltramo'
$Password = 'Pippo1234!'
$SecurePassword = $Password | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $User, $SecurePassword

Invoke-Command -ComputerName $server -Credential $cred -ScriptBlock {
  Invoke-Item $source_dir
  }