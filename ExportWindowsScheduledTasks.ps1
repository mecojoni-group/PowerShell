$BackupPath = "C:\Temp\TaskScheduler"
$TaskFolders = (Get-ScheduledTask).TaskPath | Where { ($_ -notmatch "Microsoft") -and ($_ -notmatch "OfficeSoftware") } | Select -Unique

If(Test-Path -Path $BackupPath)
{
    Remove-Item -Path $BackupPath -Recurse -Force
}

md $BackupPath | Out-Null

Foreach ($TaskFolder in $TaskFolders)
{
    If($TaskFolder -ne "\") { md $BackupPath$TaskFolder | Out-Null }
    $Tasks = Get-ScheduledTask -TaskPath $TaskFolder -ErrorAction SilentlyContinue
    Foreach ($Task in $Tasks)
    {
        $TaskName = $Task.TaskName
        If(($TaskName -match "User_Feed_Synchronization") -or ($TaskName -match "Optimize Start Menu Cache Files"))
        {
        }
        Else
        {
            $TaskInfo = Export-ScheduledTask -TaskName $TaskName -TaskPath $TaskFolder
            $TaskInfo | Out-File "$BackupPath$TaskFolder$TaskName.xml"
        }
    }
}
