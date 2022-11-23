$folder = 'D:\This Computer\Documents\LAVORO' # Enter the root path you want to monitor. 
$filter = '*'  # You can enter a wildcard filter here. 
$log = 'D:\This Computer\Documents\outlog.txt'

# In the following line, you can change 'IncludeSubdirectories to $true if required.                           
$fsw = New-Object IO.FileSystemWatcher $folder, $filter -Property @{IncludeSubdirectories = $true;NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite'} 

# Here, all three events are registerd.  You need only subscribe to events that you need: 

Register-ObjectEvent $fsw Created -SourceIdentifier FileCreated -Action { 
$name = $Event.SourceEventArgs.Name 
$changeType = $Event.SourceEventArgs.ChangeType 
$timeStamp = $Event.TimeGenerated 
Write-Host "The file '$name' was $changeType at $timeStamp" -fore green 
Out-File -FilePath $log -Append -InputObject "The file '$name' was $changeType at $timeStamp"} 