function Publish-AutoPilotConfig {
    [cmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [string]$VMName,

        [parameter(Mandatory = $true)]
        [string]$ClientPath
    )
    try {
        $disk = (Mount-VHD -Path "$ClientPath\$VMName.vhdx" -Passthru | Get-Disk | Get-Partition | Where-Object { $_.type -eq 'Basic' }).DriveLetter
        if ($disk) {
            Write-Host "Found $ClientPath\$VMName.vhdx`n ++ mouted to system.`n ++ Will now publish AP Config file.."
            Copy-Item -path "$ClientPath\AutopilotConfigurationFile.json" -Destination "$disk`:\Windows\Provisioning\Autopilot\AutopilotConfigurationFile.json" -Force
            Write-Host "Dismounting $ClientPath\$VMName.vhdx"
            Dismount-VHD "$ClientPath\$VMName.vhdx"
            Write-Host "Config published successfully to $ClientPath\$VMName.vhdx.."
        }
    }
    catch {
        throw "Error occurred during config publish.."
    }
}