function Add-VLanToConfig {
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true)]
        $VSwitchName,

        [parameter(Mandatory = $false)]
        $VLanId
    )
    $script:tick = [char]0x221a
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