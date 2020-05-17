#region Get public and private function definition files.
$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)
$cfg = Get-Content "$env:USERPROFILE\.hvtoolscfgpath" -ErrorAction SilentlyContinue
if ($cfg) {
    $script:hvConfig = if (Get-Content -Path $cfg -raw -ErrorAction SilentlyContinue) {
        Get-Content -Path $cfg -raw -ErrorAction SilentlyContinue | ConvertFrom-Json
    }
    else {
        $script:hvConfig = $null
    }
}
#endregion
#region Dot source the files
foreach ($import in @($Public + $Private)) {
    try {
        . $import.FullName
    }
    catch {
        Write-Error -Message "Failed to import function $($import.FullName): $_"
    }
}

$clientFinder = {
    param(
        $commandName,
        $parameterName,
        $stringMatch
    )
    if ($script:hvConfig) {
        $script:hvConfig.tenantConfig | Where-Object { $_.TenantName -like "$stringMatch*" } | Select-Object -ExpandProperty TenantName
    }
}
Register-ArgumentCompleter -CommandName New-ClientVM -ParameterName client -ScriptBlock $clientFinder

$vLan = {
    param (
        $commandName,
        $parameterName,
        $stringMatch
    )

    $result = Get-VMSwitch | Where-Object { $_.Name -like "$stringMatch*" } | Select-Object -ExpandProperty Name
    if ($result -match " ") {
        '"{0}"' -f $result
    }
    else {
        $result
    }
}
Register-ArgumentCompleter -CommandName Add-VLanToConfig -ParameterName VSwitchName -ScriptBlock $vLan
#endregion