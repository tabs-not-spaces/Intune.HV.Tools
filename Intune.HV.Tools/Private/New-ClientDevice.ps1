function New-ClientDevice {
    [cmdletBinding(SupportsShouldProcess)]
    param (
        [parameter(Position = 1, Mandatory = $true)]
        [string]$VMName,

        [parameter(Position = 2, Mandatory = $true)]
        [string]$ClientPath,

        [parameter(Position = 3, Mandatory = $true)]
        [string]$RefVHDX,

        [parameter(Position = 4, Mandatory = $true)]
        [string]$VSwitchName,

        [parameter(Position = 5, Mandatory = $false)]
        [string]$VLanId,

        [parameter(Position = 6, Mandatory = $true)]
        [string]$CPUCount,

        [parameter(Position = 7, Mandatory = $true)]
        [string]$VMMMemory,

        [parameter(Position = 8, Mandatory = $false)]
        [switch]$skipAutoPilot
    )
    Copy-Item -path $RefVHDX -Destination "$ClientPath\$VMName.vhdx"
    if (!($skipAutoPilot)) {
        Publish-AutoPilotConfig -vmName $VMName -clientPath $ClientPath
    }

    New-VM -Name $VMName -MemoryStartupBytes $VMMMemory -VHDPath "$ClientPath\$VMName.vhdx" -Generation 2 | Out-Null
    Get-VMIntegrationService -vmName $VMName | ? Name -match 'Interface' | Enable-VMIntegrationService
    Set-VM -name $VMName -CheckpointType Disabled
    Set-VMProcessor -VMName $VMName -Count $CPUCount
    Set-VMFirmware -VMName $VMName -EnableSecureBoot On
    Get-VMNetworkAdapter -vmName $VMName | Connect-VMNetworkAdapter -SwitchName $VSwitchName | Set-VMNetworkAdapter -Name $VSwitchName -DeviceNaming On
    if ($VLanId) {
        Set-VMNetworkAdapterVlan -Access -VMName $VMName -VlanId $VLanId
    }
    $owner = Get-HgsGuardian UntrustedGuardian -ErrorAction SilentlyContinue
    If (!$owner) {
        # Creating new UntrustedGuardian since it did not exist
        $owner = New-HgsGuardian -Name UntrustedGuardian -GenerateCertificates
    }
    $kp = New-HgsKeyProtector -Owner $owner -AllowUntrustedRoot
    Set-VMKeyProtector -VMName $VMName -KeyProtector $kp.RawData
    Enable-VMTPM -VMName $VMName
    Start-VM -Name $VMName
    #Set VM Info with Serial number
    $vmSerial = (Get-CimInstance -Namespace root\virtualization\v2 -class Msvm_VirtualSystemSettingData | Where-Object { ($_.VirtualSystemType -eq "Microsoft:Hyper-V:System:Realized") -and ($_.elementname -eq $VMName )}).BIOSSerialNumber
    Get-VM -Name $VMname | Set-VM -Notes "Serial# $vmSerial"
}