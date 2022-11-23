$folder = 'E:\Qlik12.SVL.Release' # Enter the root path you want to monitor. 
$filter = '*'  # You can enter a wildcard filter here. 
$SmtpServer  = 'smtpappl.corp.rcs.group'

# In the following line, you can change 'IncludeSubdirectories to $true if required.                           
$fsw = New-Object IO.FileSystemWatcher $folder, $filter -Property @{IncludeSubdirectories = $true;NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite'} 

# Here, all three events are registerd.  You need only subscribe to events that you need: 

Register-ObjectEvent $fsw Created -SourceIdentifier FileCreated -Action { 
$name = $Event.SourceEventArgs.Name 
$timeStamp = $Event.TimeGenerated 
$Message = "Il file: '$name' e' stato creato alle: $timeStamp"

#
Send-MailMessage `
    -from       edoardo.beltramo@guest.rcs.it `
    -smtpserver $SmtpServer     `
    -to         edoardo.beltramo@guest.rcs.it `
    -subject    "Sono stati aggiunti dei file nel percorso: $folder"    `
    -body       $Message
#
} 

#Unregister-Event FileCreated