function New-ClientVHDX {
    [cmdletbinding(SupportsShouldProcess)]
    param
    (
        [Parameter(Position = 1, Mandatory = $true)]
        [string]$vhdxPath,

        [Parameter(Position = 2, Mandatory = $true)]
        [string]$winIso,

        [Parameter(Position = 3, Mandatory = $false)]
        [switch]$unattend

    )
    try {
        $module = Get-Module -ListAvailable -Name 'Hyper-ConvertImage'
        if ($module.count -lt 1) {
            Install-Module -name 'Hyper-ConvertImage'
        }
        if ($PSVersionTable.PSVersion.Major -eq 7) {
            Import-Module -name 'Hyper-ConvertImage' -UseWindowsPowerShell -ErrorAction SilentlyContinue 3>$null
        }
        else {
            Import-Module -name 'Hyper-ConvertImage'
        }
        if ($unattend) {
            Convert-WindowsImage -SourcePath $winIso -Edition 3 -VhdType Dynamic -VhdFormat VHDX -VhdPath $vhdxPath -DiskLayout UEFI -SizeBytes 127gb -UnattendPath $unattend
        }
        else {
            Convert-WindowsImage -SourcePath $winIso -Edition 3 -VhdType Dynamic -VhdFormat VHDX -VhdPath $vhdxPath -DiskLayout UEFI -SizeBytes 127gb
        }
    }
    catch {
        Write-Warning = $_
    }
    finally {
        if ($PSVersionTable.PSVersion.Major -eq 7) {
            Remove-Module -Name 'Hyper-ConvertImage' -Force
        }
    }
}