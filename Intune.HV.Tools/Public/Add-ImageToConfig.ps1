function Add-ImageToConfig {
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true)]
        $ImageName,
        [parameter(Mandatory = $true)]
        $IsoPath
    )
    $script:tick = [char]0x221a
    try {
        Write-Host "Adding $ImageName to config.. " -ForegroundColor Cyan -NoNewline
        $newTenant = [pscustomobject]@{
            imageName    = $ImageName
            imagePath    = $IsoPath
            refImagePath = "$($script:hvConfig.vmPath)\wks$($ImageName)ref.vhdx"
        }
        $script:hvConfig.images += $newTenant
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