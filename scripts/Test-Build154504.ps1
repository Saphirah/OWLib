[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$DataToolPath,
    [Parameter(Mandatory)][string]$OverwatchPath
)

$ErrorActionPreference = 'Stop'
$tool = (Resolve-Path -LiteralPath $DataToolPath).Path
$game = (Resolve-Path -LiteralPath $OverwatchPath).Path
$output = Join-Path ([IO.Path]::GetTempPath()) ('owlib-154504-' + [guid]::NewGuid() + '.json')
try {
    & $tool $game list-maps --json "--out=$output"
    if ($LASTEXITCODE -ne 0) { throw "DataTool failed with exit code $LASTEXITCODE" }
    if (-not (Test-Path -LiteralPath $output)) { throw 'DataTool did not produce a map catalog.' }
    $catalog = Get-Content -LiteralPath $output -Raw | ConvertFrom-Json
    $maps = @($catalog.PSObject.Properties)
    if ($maps.Count -eq 0) { throw 'The map catalog is empty.' }
    if (-not ($maps | Where-Object { $_.Value.Name -eq 'Dorado' })) {
        throw 'The map catalog does not contain Dorado.'
    }
    Write-Host "PASS: $($maps.Count) map headers read, including Dorado."
} finally {
    if (Test-Path -LiteralPath $output) { Remove-Item -LiteralPath $output }
}
