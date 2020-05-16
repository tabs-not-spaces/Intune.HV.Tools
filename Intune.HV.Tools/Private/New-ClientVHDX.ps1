function New-ClientVHDX {
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$vhdxPath,

        [Parameter(Mandatory = $true)]
        [string]$winIso,

        [Parameter(Mandatory = $false)]
        [switch]$unattend

    )
    $module = Get-Module -ListAvailable -Name 'Convert-WindowsImage'
    if ($module.count -ne 1) {
        Install-Module -name 'Convert-WindowsImage'
    }
    else {
        Update-Module -Name 'Convert-WindowsImage'
    }
    Import-Module -name 'Convert-Windowsimage'
    if ($unattend) {
        Convert-WindowsImage -SourcePath $winIso -Edition 3 -VhdType Dynamic -VhdFormat VHDX -VhdPath $vhdxPath -DiskLayout UEFI -SizeBytes 127gb -UnattendPath $unattend
    }
    else {
        Convert-WindowsImage -SourcePath $winIso -Edition 3 -VhdType Dynamic -VhdFormat VHDX -VhdPath $vhdxPath -DiskLayout UEFI -SizeBytes 127gb
    }
}