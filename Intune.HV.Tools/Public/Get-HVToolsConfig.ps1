function Get-HVToolsConfig {
    [cmdletbinding()]
    param (

    )
    try {
        if ($script:hvConfig) {
            $script:hvConfig = (get-content -Path "$(get-content "$env:USERPROFILE\.hvtoolscfgpath" -ErrorAction SilentlyContinue)" -raw -ErrorAction SilentlyContinue | ConvertFrom-Json)
            return $script:hvConfig
        }
        else {
            throw "Couldnt find HVTools configuration file - please run Initialize-HVTools to create the configuration file."
        }
    }
    catch {
        Write-Warning $_.Exception.Message
    }
}