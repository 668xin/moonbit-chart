param(
  [Parameter(Mandatory=$true)][string]$InputFile,
  [Parameter(Mandatory=$false)][string]$OutputFile = "output.html"
)

$MoonBin = "$env:USERPROFILE\.moon\bin"
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$MoonRun = "$MoonBin\moonrun.exe"
$CliWasm = "$ProjectRoot\_build\wasm-gc\debug\build\src\cli\cli.wasm"

if (-not (Test-Path $InputFile)) {
  Write-Error "Input file not found: $InputFile"
  exit 1
}

if (-not (Test-Path $CliWasm)) {
  Write-Host "Building CLI..."
  & "$MoonBin\moon.exe" build
  if (-not (Test-Path $CliWasm)) {
    Write-Error "Build failed!"
    exit 1
  }
}

Write-Host "Converting: $InputFile -> $OutputFile"
try {
  $Content = Get-Content -Path $InputFile -Raw -Encoding UTF8
  $Html = & $MoonRun $CliWasm $Content
  [System.IO.File]::WriteAllText($OutputFile, $Html, [System.Text.UTF8Encoding]::new($false))
  Write-Host "Done! Generated: $OutputFile"
} catch {
  Write-Error "Failed: $_"
  exit 1
}
