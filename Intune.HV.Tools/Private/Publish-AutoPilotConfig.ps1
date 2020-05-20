function Publish-AutoPilotConfig {
    [cmdletBinding()]
    param (
        [parameter(Position = 1, Mandatory = $true)]
        [string]$VMName,

        [parameter(Position = 2, Mandatory = $true)]
        [string]$ClientPath
    )
    try {
        Write-Host "Mounting $VMName.vhdx.. " -ForegroundColor Cyan -NoNewline
        $disk = (Mount-VHD -Path "$ClientPath\$VMName.vhdx" -Passthru | Get-Disk | Get-Partition | Where-Object { $_.type -eq 'Basic' }).DriveLetter
        if ($disk) {
            Write-Host $script:tick -ForegroundColor Green
            Write-Host "Publishing Autopilot config to $VMName`.vhdx.. " -ForegroundColor Cyan -NoNewline
            $AutopilotFolder = "$disk`:\Windows\Provisioning\Autopilot"
            IF(!(Test-path -Path $AutopilotFolder -PathType Container)){
                New-Item -Path $AutopilotFolder -ItemType Directory -Force
            }
            Copy-Item -path "$ClientPath\AutopilotConfigurationFile.json" -Destination "$AutopilotFolder\AutopilotConfigurationFile.json" -Force
            Write-Host $script:tick -ForegroundColor Green
            Write-Host "Config published successfully to $ClientPath\$VMName.vhdx..`n" -ForegroundColor Green
        }
    }
    catch {
        throw "Error occurred during config publish.."
    }
    Finally{
        Write-Host $script:tick -ForegroundColor Green
        Write-Host "Dismounting $VMName.vhdx " -ForegroundColor Cyan -NoNewline
        Dismount-VHD "$ClientPath\$VMName.vhdx"
    }
}