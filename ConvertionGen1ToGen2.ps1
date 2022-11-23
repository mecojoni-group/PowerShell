# Mauro Solidoro - Francesco Frisani - 20220824
# Hyper-v Gen1 to Gen2 VM Conversion
# Old VM must be shut off

$vmName        = "sjdedbt01.cairo.group"
$vmNameNew     = "$vmName" + '_GEN2'
$vmOwnerNode   = $( (Get-ClusterGroup -name $vmName | select OwnerNode | ft -HideTableHeaders | Out-String).Trim() )
$CPU           = $( (Get-VM               -ComputerName $vmOwnerNode   -name $vmName | select ProcessorCount | ft -HideTableHeaders | Out-String).Trim() )
$vmDisksPath   = $(  Get-VMHardDiskDrive  -ComputerName $vmOwnerNode -VMName $vmName | select Path -ExpandProperty Path )
$RAM           = $( (Get-VM               -ComputerName $vmOwnerNode   -name $vmName | select MemoryStartup  | ft -HideTableHeaders | Out-String).Trim() )
$virtualSwitch = $( (Get-VMNetworkAdapter -ComputerName $vmOwnerNode -VMName $vmName | select SwitchName     | ft -HideTableHeaders | Out-String).Trim() )
$storagePath   = "C:\ClusterStorage\Volume1"
$isoFile       = "C:\ClusterStorage\Volume1\ISO\CentOS-7-x86_64-Minimal-2009.iso"

# New VM Creation 
New-VM -ComputerName $vmOwnerNode -name $vmNameNew -generation 2 -memorystartupbytes $RAM -SwitchName $virtualSwitch

# Disable secure boot to new VM (only for Linux machine!)
Set-VMFirmware -ComputerName $vmOwnerNode -VMName $vmNameNew -EnableSecureBoot Off

# Set processor number to new VM
Set-VM -ComputerName $vmOwnerNode -Name $vmNameNew -ProcessorCount $CPU

# Dismount disk from old VM
Get-VMHardDiskDrive -ComputerName $vmOwnerNode -VMName $vmName | Remove-VMHardDiskDrive

# Attach disk to new VM
$vmDiskPathNew=$("$storagePath\$vmNameNew\Virtual Hard Disks\")
New-Item -ItemType Directory -Path $vmDiskPathNew -Force
foreach ( $vmDiskPath in $vmDisksPath ) {
    $vmDiskName=$( $vmDiskPath.Replace("$storagePath\$vmName\Virtual Hard Disks\","") )
    Move-Item -Path $vmDiskPath -Destination $vmDiskPathNew
    Add-VMHardDiskDrive -ComputerName $vmOwnerNode -VMName $vmNameNew -Path $vmDiskPathNew\$vmDiskName
}

# Attach ISO to VM
Add-VMDvdDrive -ComputerName $vmOwnerNode -VMName $vmNameNew -Path $isoFile

# Set boot to DVD
$dvd = Get-VMDvdDrive -ComputerName $vmOwnerNode -VMName $vmNameNew
Set-VMFirmware        -ComputerName $vmOwnerNode -VMName $vmNameNew -FirstBootDevice $dvd

## Add Vm to Cluster
Add-ClusterVirtualMachineRole -VirtualMachine $vmNameNew -Name $vmNameNew
 
