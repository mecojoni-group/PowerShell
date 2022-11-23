#VARIABLES
$Log4JSite = "https://github.com/logpresso/CVE-2021-44228-Scanner/releases/download/v1.6.3/logpresso-log4j2-scan-1.6.3-win64.7z"
$Log4JFolder = "C:\log4j-scan"
$Log4JZip = "log4j2-scan.7z"

$7zipSite = "https://www.7-zip.org/a/7z2106-x64.msi"
$7zipDownload = "7z2106-x64.msi"
$7zipFilePath = 'C:\Program Files\7-Zip\7z.exe'

If(!(test-path $Log4JFolder))
{
  New-Item -ItemType Directory -Force -Path $Log4JFolder
  Invoke-WebRequest -Uri "$7zipSite" -OutFile "$Log4JFolder\$7zipDownload"
  Invoke-WebRequest -Uri "$Log4JSite" -OutFile "$Log4JFolder\$Log4JZip"
  cd $Log4JFolder
  cmd.exe /c "MsiExec.exe /i $7zipDownload /qn"
  cmd.exe /c '"C:\Program Files\7-Zip\7z.exe" x C:\log4j-scan\log4j2-scan.7z -oC:\log4j-scan\'
  $Log4JReport = cmd.exe /c "log4j2-scan.exe --all-drives --silent"
  Write-Output $Log4JReport
  
  #Remove-Item –path $Log4JFolder -Force
}
  else
{
  #ALREADY RAN
}
