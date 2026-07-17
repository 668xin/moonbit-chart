param(
  [Parameter(Mandatory=$false)][string]$InputFile,
  [Parameter(Mandatory=$false)][string]$OutputFile = "output.html",
  [Parameter(Mandatory=$false)][string]$Format = "html",
  [Parameter(Mandatory=$false)][string]$Theme = "light",
  [Parameter(Mandatory=$false)][string]$Title = "",
  [Parameter(Mandatory=$false)][switch]$Batch,
  [Parameter(Mandatory=$false)][switch]$Help
)

$MoonBin = "$env:USERPROFILE\.moon\bin"
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$MoonRun = "$MoonBin\moonrun.exe"
$CliWasm = "$ProjectRoot\_build\wasm-gc\debug\build\src\cli\cli.wasm"

# Help
if ($Help) {
  Write-Host "moonbit-chart.ps1 - MoonBit SVG Chart CLI Wrapper"
  Write-Host ""
  Write-Host "Usage:"
  Write-Host "  .\scripts\moonbit-chart.ps1 [-InputFile] <path> [-OutputFile <path>]"
  Write-Host "                               [-Format html|svg] [-Theme light|dark]"
  Write-Host "                               [-Title <text>] [-Batch] [-Help]"
  Write-Host ""
  Write-Host "Examples:"
  Write-Host "  Convert MD to HTML:"
  Write-Host "    .\scripts\moonbit-chart.ps1 charts.md report.html"
  Write-Host "  Export SVG only:"
  Write-Host "    .\scripts\moonbit-chart.ps1 charts.md output.svg -Format svg"
  Write-Host "  Dark theme:"
  Write-Host "    .\scripts\moonbit-chart.ps1 charts.md report.html -Theme dark"
  Write-Host "  Custom title:"
  Write-Host "    .\scripts\moonbit-chart.ps1 charts.md report.html -Title 'Sales Report'"
  exit 0
}

# Validate input
if (-not $InputFile) {
  Write-Error "Input file is required. Use -Help for usage."
  exit 1
}
if (-not (Test-Path $InputFile)) {
  Write-Error "Input file not found: $InputFile"
  exit 1
}

# Build CLI if not exists
if (-not (Test-Path $CliWasm)) {
  Write-Host "Building CLI..."
  & "$MoonBin\moon.exe" build
  if (-not (Test-Path $CliWasm)) {
    Write-Error "Build failed!"
    exit 1
  }
}

# Build arguments
$CliArgs = @()
if ($Format -eq "svg") { $CliArgs += "--format"; $CliArgs += "svg" }
if ($Theme -eq "dark") { $CliArgs += "--theme"; $CliArgs += "dark" }
if ($Title) { $CliArgs += "--title"; $CliArgs += $Title }
if ($Batch) { $CliArgs += "--batch" }
if ($OutputFile -and $OutputFile -ne "") {
  $CliArgs += "--output"; $CliArgs += $OutputFile
}

Write-Host "Converting: $InputFile -> $OutputFile (format: $Format, theme: $Theme)"

try {
  $Content = Get-Content -Path $InputFile -Raw -Encoding UTF8
  
  # Build full command line
  $AllArgs = $CliArgs + @($Content)
  $Result = & $MoonRun $CliWasm $AllArgs *>&1
  
  if ($Format -eq "svg") {
    # SVG mode: output multiple SVGs or single SVG
    if ($OutputFile -match '\.svg$') {
      # Collect all SVG content and write to file
      [System.IO.File]::WriteAllText($OutputFile, $Result, [System.Text.UTF8Encoding]::new($false))
      Write-Host "Done! Generated: $OutputFile"
    } else {
      Write-Host "Done! SVG output:"
      Write-Host $Result
    }
  } else {
    # HTML mode
    [System.IO.File]::WriteAllText($OutputFile, $Result, [System.Text.UTF8Encoding]::new($false))
    Write-Host "Done! Generated: $OutputFile"
  }
} catch {
  Write-Error "Failed: $_"
  exit 1
}
