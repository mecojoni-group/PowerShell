<#
    .Example
    Atempt to create OU that not exists in the desired path
    $OUs = @(
    $(New-Object PSObject -Property @{Name = "Desktops"; ParentOU = "ou=Workstations" }),
    $(New-Object PSObject -Property @{Name = "Kiosks"; ParentOU = "ou=Workstations" }),
    $(New-Object PSObject -Property @{Name = "Laptops"; ParentOU = "ou=Workstations" }),
    $(New-Object PSObject -Property @{Name = "Staging"; ParentOU = "ou=Workstations" })
    )
    .\Create-OU.ps1 -OUs $OUs -Verbose
    PS C:\Tools> .\Create-OU.ps1 -OUs $OUs -Verbose
    VERBOSE: Creating new OU 'OU=Desktops,ou=Workstations,DC=azureblog,DC=pl'
    VERBOSE: Creating new OU 'OU=Kiosks,ou=Workstations,DC=azureblog,DC=pl'
    VERBOSE: Creating new OU 'OU=Laptops,ou=Workstations,DC=azureblog,DC=pl'
    VERBOSE: Creating new OU 'OU=Staging,ou=Workstations,DC=azureblog,DC=pl'
    .Example
    Atempt to create OU that already exists in the desired path
    $OUs = @(
    $(New-Object PSObject -Property @{Name = "Desktops"; ParentOU = "ou=Workstations" }),
    $(New-Object PSObject -Property @{Name = "Kiosks"; ParentOU = "ou=Workstations" }),
    $(New-Object PSObject -Property @{Name = "Laptops"; ParentOU = "ou=Workstations" }),
    $(New-Object PSObject -Property @{Name = "Staging"; ParentOU = "ou=Workstations" })
    )
    .\Create-OU.ps1 -OUs $OUs -Verbose
    PS C:\Tools> .\Create-OU.ps1 -OUs $OUs -Verbose
    VERBOSE: OU 'Desktops' already exists under 'ou=Workstations,DC=azureblog,DC=pl'
    VERBOSE: OU 'Kiosks' already exists under 'ou=Workstations,DC=azureblog,DC=pl'
    VERBOSE: OU 'Laptops' already exists under 'ou=Workstations,DC=azureblog,DC=pl'
    VERBOSE: OU 'Staging' already exists under 'ou=Workstations,DC=azureblog,DC=pl
#>

[CmdletBinding()]
param(
    [PSObject] $OUs
)
$dNC = (Get-ADRootDSE).defaultNamingContext
$OUs | ForEach-Object {
    $name = $_.Name
    $parentOU = $_.ParentOU
    
    if ($ParentOU -eq '') {
        $ouPath = "$dNC"
        $testOUpath = "OU=$name,$dNC"
    }
    else {
        $ouPath = "$parentOU,$dNC"
        $testOUPath = "OU=$name,$parentOU,$dNC"
    }
    
    $OUTest = (Get-ADOrganizationalUnit -Filter 'DistinguishedName -like $testOUpath' | Measure-Object).Count
    if ($OUtest -eq 0) {
        Write-Verbose "Creating new OU '$testOUPath'"
        New-ADOrganizationalUnit -Name $name -Path $OUPath -ProtectedFromAccidentalDeletion:$true
    }
    else {
        Write-Verbose "OU '$name' already exists under '$ouPath'"
    }
}
