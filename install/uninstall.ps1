param(
  [string]$RepoPath = "",
  [string]$InstallRoot = "~/.cursor-bootstrap",
  [string]$BinDir = "~/.local/bin",
  [switch]$RemoveAll
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
  $scriptWsl = "$repoWsl/install/uninstall.sh"

  $argsList = @("--install-root", $InstallRoot, "--bin-dir", $BinDir)
  if ($RemoveAll.IsPresent) {
    $argsList += "--remove-all"
  }

  $quoted = $argsList | ForEach-Object { "'$_'" }
  $cmd = "bash '$scriptWsl' " + ($quoted -join " ")

  Write-Host "[uninstall.ps1] Running in WSL: $cmd"
  wsl bash -lc $cmd
  Write-Host "[uninstall.ps1] Done."
}
catch {
  Write-Error $_
  exit 1
}
