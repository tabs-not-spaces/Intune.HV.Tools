#region Get public and private function definition files.
$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)
$cfg = Get-Content "$env:USERPROFILE\.hvtoolscfgpath" -ErrorAction SilentlyContinue
$script:tick = [char]0x221a

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

$tenantFinder = {
    param(
        $commandName,
        $parameterName,
        $stringMatch,
        $commandAst,
        $fakeBoundParameters
    )
    if ($script:hvConfig) {
        $script:hvConfig.tenantConfig | Where-Object { $_.TenantName -like "$stringMatch*" } | Select-Object -ExpandProperty TenantName | ForEach-Object {
            New-Object System.Management.Automation.CompletionResult (
                "'$_'",
                $_,
                'ParameterValue',
                $_
            )
        }
    }
}
Register-ArgumentCompleter -CommandName New-ClientVM -ParameterName TenantName -ScriptBlock $tenantFinder

$vLan = {
    param (
        $commandName,
        $parameterName,
        $stringMatch,
        $commandAst,
        $fakeBoundParameters
    )

    Get-VMSwitch | Where-Object { $_.Name -like "$stringMatch*" } | Select-Object -ExpandProperty Name | ForEach-Object {
        New-Object System.Management.Automation.CompletionResult (
            "'$_'",
            $_,
            'ParameterValue',
            $_
        )
    }
}
Register-ArgumentCompleter -CommandName Add-NetworkToConfig -ParameterName VSwitchName -ScriptBlock $vLan

$win10Builds = {
    param (
        $commandName,
        $parameterName,
        $stringMatch,
        $commandAst,
        $fakeBoundParameters
    )

    (Get-HVToolsConfig).Images | Where-Object { $_.imageName -like "$stringMatch*" } | Select-Object -ExpandProperty imageName | ForEach-Object {
        New-Object System.Management.Automation.CompletionResult (
            $_,
            $_,
            'ParameterValue',
            $_
        )
    }
}
Register-ArgumentCompleter -CommandName Add-TenantToConfig -ParameterName ImageName -ScriptBlock $win10Builds
Register-ArgumentCompleter -CommandName New-ClientVM -ParameterName OSBuild -ScriptBlock $win10Builds
#endregion