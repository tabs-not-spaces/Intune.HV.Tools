#region Get public and private function definition files.
$Public  = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)
$cfg = get-content "$env:USERPROFILE\.hvtoolscfgpath" -ErrorAction SilentlyContinue
if ($cfg) {
    $script:hvConfig = (get-content -Path  -raw -ErrorAction SilentlyContinue | ConvertFrom-Json -Depth 20) ?? $null
}
#endregion
#region Dot source the files
foreach ($import in @($Public + $Private))
{
    try
    {
        . $import.FullName
    }
    catch
    {
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
        $script:hvConfig.tenantConfig | Where-Object {$_.TenantName -like "$stringMatch*"} | Select-Object -ExpandProperty TenantName
    }
}
Register-ArgumentCompleter -CommandName New-ClientVM -ParameterName client -ScriptBlock $clientFinder
#endregion