function Add-ImageToConfig {
    [cmdletbinding()]
    param (
        [parameter(Position = 1, Mandatory = $true)]
        $ImageName,
        [parameter(Mandatory = $true, ParameterSetName = 'ISO')]
        $IsoPath,
        [Parameter(Mandatory = $true, ParameterSetName = 'RefVHDX')]
        $ReferenceVHDX
    )
    try {
        Write-Host "Adding $ImageName to config.. " -ForegroundColor Cyan -NoNewline
        if(!$PSBoundParameters.ContainsKey('ReferenceVHDX')){
            $ReferenceVHDX = "$($script:hvConfig.vmPath)\wks$($ImageName)ref.vhdx"
        }
        $newTenant = [pscustomobject]@{
            imageName    = $ImageName
            imagePath    = $IsoPath
            refImagePath = $ReferenceVHDX
        }
        $script:hvConfig.images += $newTenant
        $script:hvConfig | ConvertTo-Json -Depth 20 | Out-File -FilePath $hvConfig.hvConfigPath -Encoding ascii -Force
        Write-Host $script:tick -ForegroundColor Green
        #region Check for ref image - if it's not there, build it
        if (!(Test-Path -Path $newTenant.refImagePath -ErrorAction SilentlyContinue)) {
            Write-Host "Creating reference Autopilot VHDX - this may take some time.." -ForegroundColor Yellow
            New-ClientVHDX -vhdxPath $newTenant.refImagePath -winIso $newTenant.imagePath
        }
        #endregion
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