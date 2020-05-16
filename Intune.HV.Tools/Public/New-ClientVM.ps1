function New-ClientVM {
    [CmdletBinding()]
    param (
        [parameter(
            Position = 1,
            Mandatory = $true
        )]
        [string]$Client,

        [parameter(
            Position = 2,
            Mandatory = $true
        )]
        [ValidateRange(1, 999)]
        [string]$NumberOfVMs,

        [parameter(
            Position = 3,
            Mandatory = $true
        )]
        [ValidateRange(1, 999)]
        [string]$CPUsPerVM,

        [parameter(
            Position = 4,
            Mandatory = $true
        )]
        [ValidateRange(2gb, 20gb)]
        [string]$VMMemory
    )

    #region Config
    $clientDetails = $script:hvConfig.tenantConfig | Where-Object { $_.TenantName -eq $Client }
    $imageDetails = $script:hvConfig.images | Where-Object { $_.imageName -eq $clientDetails.Win10Ver }
    $clientPath = "$($script:hvConfig.vmPath)\$($Client)"
    $vSwitchName = $script:hvConfig.vSwitchName
    $vLanId = $script:hvConfig.vLanId
    if (!(Test-Path $clientPath)) {
        New-Item -ItemType Directory -Force -Path $clientPath | Out-Null
    }
    $script:logfile = "$clientPath\Build.log"

    Write-LogEntry -Type Information -Message "Path to AutoPilot Reference VHDX is: $($imageDetails.refImagePath)"
    Write-LogEntry -Type Information -Message "Client name is: $client"
    Write-LogEntry -Type Information -Message "Win10 ISO is located: $($imageDetails.imagePath)"
    Write-LogEntry -Type Information -Message "Path to client VMs will be: $clientPath"
    Write-LogEntry -Type Information -Message "Number of VMs to create: $NumberOfVMs"
    Write-LogEntry -type Information -Message "Admin user for tenant: $clientName is: $($clientDetails.adminUpn)"
    #endregion

    #region Check for ref image - if it's not there, build it
    if (!(Test-Path -path $imageDetails.refImagePath -ErrorAction SilentlyContinue)) {
        Write-LogEntry -Type Information -Message "Creating Reference AutoPilot VHDX"
        new-ClientVHDX -vhdxpath $imageDetails.refImagePath -winiso $imageDetails.imagePath
        Write-LogEntry -Type Information -Message "Reference AutoPilot VHDX has been created"
    }
    #endregion
    #region Get Autopilot policy
    Get-AutopilotPolicy -FileDestination "$clientPath\AutopilotConfigurationFile.json"
    #endregion
    #region Build the client VMs
    $apOut = @()
    if (!(Test-Path -Path $clientPath -ErrorAction SilentlyContinue)) {
        New-Item -Path $clientPath -ItemType Directory -Force | Out-Null
    }
    $vmParams = @{
        ClientPath  = $clientPath
        RefVHDX     = $imageDetails.refImagePath
        VSwitchName = $script:hvConfig.vSwitchName
        CPUCount    = $CPUsPerVM
        VMMMemory   = $VMMemory
    }
    if ($script:hvConfig.vLanId) {
        $vmParams.VLanId = $script:hvConfig.vLanId
    }
    if ($numberOfVMs -eq 1) {
        $vmParams.VMName = "$($clientName)_$numberOfVMs"
        $vm = New-ClientDevice @vmParams
        $vm | Out-File -FilePath "$clientPath\ap$numberOfVMs.csv"
        $apOut += $vm
    }
    else {
        $vNum = 1
        $existingVMs = (Get-VM -Name "$($clientName)*").name -replace "$($clientName)"
        while ($vNum -ne ($NumberOfVMs + 1 + $existingVMs.Count)) {
            if (!($vNum -in $existingVMs)) {
                $vmParams.VMName = "$($clientName)_$vNum"
                $apOut += New-ClientDevice @vmParams
            }
            $vNum++
        }
    }
    #endregion
}