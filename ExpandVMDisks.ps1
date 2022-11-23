# Mauro Solidoro 20220824
# Expand every disks attached to VM - Hyper-V   
$vmName="sjdedbt01GEN2.cairo.group"
$vmDisks=$(Get-VM -Name $vmName | Get-VMHardDiskDrive | select Path -ExpandProperty Path)

foreach ( $disk in $vmDisks ) {
    $diskSize=$(Get-VHD -Path $disk | select Size -ExpandProperty Size)
    Resize-VHD -Path $disk -SizeBytes ($diskSize +512000)
}
