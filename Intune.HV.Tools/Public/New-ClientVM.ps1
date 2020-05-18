#requires -Modules "Hyper-V"
function New-ClientVM {
    [CmdletBinding()]
    param (
        [parameter(Position = 1, Mandatory = $true)]
        [string]$Client,

        [parameter(Position = 2, Mandatory = $true)]
        [ValidateRange(1, 999)]
        [string]$NumberOfVMs,

        [parameter(Position = 3, Mandatory = $true)]
        [ValidateRange(1, 999)]
        [string]$CPUsPerVM,

        [parameter(Position = 4, Mandatory = $true)]
        [ValidateRange(2gb, 20gb)]
        [int64]$VMMemory,

        [parameter(Position = 5, Mandatory = $false)]
        [switch]$SkipAutoPilot
    )

    #region Config
    $clientDetails = $script:hvConfig.tenantConfig | Where-Object { $_.TenantName -eq $Client }
    $imageDetails = $script:hvConfig.images | Where-Object { $_.imageName -eq $clientDetails.Win10Ver }
    $clientPath = "$($script:hvConfig.vmPath)\$($Client)"
    if (!(Test-Path $clientPath)) {
        New-Item -ItemType Directory -Force -Path $clientPath | Out-Null
    }

    Write-Verbose "Autopilot Reference VHDX: $($imageDetails.refImagePath)"
    Write-Verbose "Client name: $Client"
    Write-Verbose "Win10 ISO is located:  $($imageDetails.imagePath)"
    Write-Verbose "Path to client VMs will be: $clientPath"
    Write-Verbose "Number of VMs to create:  $NumberOfVMs"
    Write-Verbose "Admin user for $Client is:  $($clientDetails.adminUpn)`n"
    #endregion

    #region Check for ref image - if it's not there, build it
    if (!(Test-Path -path $imageDetails.refImagePath -ErrorAction SilentlyContinue)) {
        Write-Host "Creating reference Autopilot VHDX - this may take some time.." -ForegroundColor Yellow -NoNewline
        New-ClientVHDX -vhdxpath $imageDetails.refImagePath -winiso $imageDetails.imagePath
        Write-Host "Reference Autopilot VHDX has been created.." -ForegroundColor Yellow
    }
    #endregion
    #region Get Autopilot policy
    if (!($SkipAutoPilot)) {
        Write-Host "Grabbing Autopilot config.." -ForegroundColor Yellow
        Get-AutopilotPolicy -FileDestination "$clientPath"
    }
    #endregion
    #region Build the client VMs
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
    if ($SkipAutoPilot) {
        $vmParams.skipAutoPilot = $true
    }
    if ($script:hvConfig.vLanId) {
        $vmParams.VLanId = $script:hvConfig.vLanId
    }
    Get-VM -Name "$Client*" | Out-Null
    if ($numberOfVMs -eq 1) {
        $max = ((Get-VM -Name "$Client*").name -replace "$client`_" | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum) + 1
        $vmParams.VMName = "$($Client)_$max"
        Write-Host "Creating VM: $($vmParams.VMName).." -ForegroundColor Yellow
        New-ClientDevice @vmParams
    }
    else {
        (1..$NumberOfVMs) | ForEach-Object {
            $max = ((Get-VM -Name "$Client*").name -replace "$client`_" | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum) + 1
            $vmParams.VMName = "$($Client)_$max"
            Write-Host "Creating VM: $($vmParams.VMName).." -ForegroundColor Yellow
            New-ClientDevice @vmParams
        }
    }
    #endregion
}