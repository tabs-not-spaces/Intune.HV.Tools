function Add-TenantToConfig {
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true)]
        $TenantName,
        [parameter(Mandatory = $true)]
        $Win10Ver,
        [parameter(Mandatory = $true)]
        $AdminUpn
    )
    $script:tick = [char]0x221a
    try {
        Write-Host "Adding $TenantName to config.. " -ForegroundColor Cyan -NoNewline
        $newTenant = [pscustomobject]@{
            TenantName = $TenantName
            Win10Ver   = $Win10Ver
            AdminUpn   = $AdminUpn
        }
        $script:hvConfig.tenantConfig += $newTenant
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