function Add-NetworkToConfig {
    [cmdletbinding()]
    param (
        [parameter(Position = 1, Mandatory = $true)]
        $VSwitchName,

        [parameter(Position = 2, Mandatory = $false)]
        $VLanId
    )
    try {
        Write-Host "Adding virtual switch details to config.. " -ForegroundColor Cyan -NoNewline
        $script:hvConfig.vSwitchName = $VSwitchName
        if ($VLanId) {
            $script:hvConfig.vLanId = $VLanId
        }
        $script:hvConfig | ConvertTo-Json -Depth 20 | Out-File -FilePath $hvConfig.hvConfigPath -Encoding ascii -Force
    }
    catch {
        $errorMsg = $_
    }
    finally {
        if ($errorMsg) {
            Write-Warning $errorMsg
        }
        else {
            Write-Host $script:tick -ForegroundColor Green
        }
    }
}