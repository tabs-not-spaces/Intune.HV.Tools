function Add-TenantToConfig {
    [cmdletbinding()]
    param (
        [parameter(Position = 1, Mandatory = $true)]
        $TenantName,

        [parameter(Position = 2, Mandatory = $true)]
        $ImageName,

        [parameter(Position = 3, Mandatory = $true)]
        $AdminUpn
    )
    try {
        Write-Host "Adding $TenantName to config.. " -ForegroundColor Cyan -NoNewline
        $newTenant = [pscustomobject]@{
            TenantName = $TenantName
            ImageName   = $ImageName
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