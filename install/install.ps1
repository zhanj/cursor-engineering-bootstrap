param(
  [string]$RepoPath = "",
  [string]$Version = "",
  [string]$InstallRoot = "~/.cursor-bootstrap",
  [string]$BinDir = "~/.local/bin",
  [switch]$Force
)

$ErrorActionPreference = "Stop"

function Resolve-WslPath([string]$PathValue) {
  $resolved = $PathValue
  if ([string]::IsNullOrWhiteSpace($resolved)) {
    $resolved = (Resolve-Path "..").Path
  }
  $wslPath = wsl wslpath -a "$resolved"
  if ([string]::IsNullOrWhiteSpace($wslPath)) {
    throw "Failed to convert path to WSL: $resolved"
  }
  return $wslPath.Trim()
}

try {
  $repoWsl = Resolve-WslPath $RepoPath
  $scriptWsl = "$repoWsl/install/install.sh"

  $argsList = @("--repo", $repoWsl, "--install-root", $InstallRoot, "--bin-dir", $BinDir)
  if (-not [string]::IsNullOrWhiteSpace($Version)) {
    $argsList += @("--version", $Version)
  }
  if ($Force.IsPresent) {
    $argsList += "--force"
  }

  $quoted = $argsList | ForEach-Object { "'$_'" }
  $cmd = "bash '$scriptWsl' " + ($quoted -join " ")

  Write-Host "[install.ps1] Running in WSL: $cmd"
  wsl bash -lc $cmd
  Write-Host "[install.ps1] Done."
  Write-Host "[install.ps1] WSL2-first mode: run tools via WSL shell."
}
catch {
  Write-Error $_
  exit 1
}
