[CmdletBinding()]
param(
  [switch]$Uninstall,
  [switch]$Inplace          # register this repo's own antigravity/ dir instead of copying
)

$ErrorActionPreference = 'Stop'
# Antigravity customization roots, per agy-customizations/docs/plugins.md and
# json_configs.md: a plugin must live under a plugins/ folder inside a root.
# The global root is ~/.gemini/config; the project root is <repo>/.agents.
$Root      = Join-Path $HOME '.gemini/config'
$Plugins   = Join-Path $Root 'plugins'
$Target    = Join-Path $Plugins 'repo-flow-plugin'
$Reg       = Join-Path $Root 'plugins.json'
$Source    = Join-Path $PSScriptRoot 'repo-flow-plugin'

if ($Uninstall) {
  if (Test-Path $Target) {
    $bak = "$Target.removed-$(Get-Date -Format yyyyMMddHHmmss)"
    Move-Item $Target $bak
    "removed plugin folder (kept at $bak)"
  } else {
    "plugin folder not present"
  }
  if (Test-Path $Reg) {
    $cfg = Get-Content $Reg -Raw | ConvertFrom-Json
    $keep = @($cfg.entries | Where-Object {
      ($_.path -notlike '*repo-flow*') -and
      -not (@($_.include_only) | Where-Object { $_ -like '*repo-flow*' })
    })
    if ($keep.Count -ne @($cfg.entries).Count) {
      $cfg.entries = $keep
      [IO.File]::WriteAllText($Reg, ($cfg | ConvertTo-Json -Depth 6), (New-Object System.Text.UTF8Encoding($false)))
      "dropped the repo-flow entry from plugins.json"
    } else {
      "plugins.json has no repo-flow entry"
    }
  }
  return
}

if (-not (Test-Path (Join-Path $Source 'plugin.json'))) {
  throw "source plugin not found: $Source"
}

New-Item -ItemType Directory -Force -Path $Plugins | Out-Null

if ($Inplace) {
  # Register wherever this repo sits; paths starting with / or ~/ are absolute
  # or home-relative, everything else resolves against a workspace root.
  $src = ($Source -replace '\\', '/')
  "registering in place: $src"
} else {
  if (Test-Path $Target) {
    Remove-Item $Target -Recurse -Force
  }
  Copy-Item $Source $Target -Recurse -Force
  $src = ($Target -replace '\\', '/')
  "copied plugin to: $src"
}

# Register through plugins.json, the documented user-facing file. Deliberately
# not editing ~/.gemini/config/config.json, which the app owns for gallery
# installs and rewrites itself.
$cfg = $null
if (Test-Path $Reg) {
  $cfg = Get-Content $Reg -Raw | ConvertFrom-Json
}
if (-not $cfg) {
  $cfg = [pscustomobject]@{ entries = @() }
}
if (-not $cfg.entries) {
  $cfg.entries = @()
}

# A path entry names a directory whose SUBDIRECTORIES are plugins: include_only
# and exclude are documented as matching "directory names", so pointing at the
# plugin folder itself would scan one level too deep. Home-relative ~/ paths are
# used because the docs resolve them against the user home, which keeps this
# file portable across machines.
$entryPath = if ($Inplace) { ($Source -replace '\\', '/') } else { '~/.gemini/config/plugins' }
$already = @($cfg.entries | Where-Object { $_.path -like '*repo-flow*' -or $_.path -eq $entryPath })
if ($already.Count -eq 0) {
  $cfg.entries += [pscustomobject]@{
    path         = $entryPath
    include_only = @('^repo-flow-plugin$')
  }
  $json = $cfg | ConvertTo-Json -Depth 6
  # PowerShell 5.1 Set-Content -Encoding utf8 writes a BOM, and a BOM breaks
  # strict JSON parsers. Write bytes without it.
  [IO.File]::WriteAllText($Reg, $json, (New-Object System.Text.UTF8Encoding($false)))
  "added entry to $Reg -> $entryPath"
} else {
  "plugins.json already registers repo-flow"
}

$localPath = if ($Inplace) { $Source } else { $Target }
"skills this plugin exposes:"
Get-ChildItem (Join-Path $localPath 'skills') -Directory | ForEach-Object { "  " + $_.Name }
""
"Restart Antigravity to load it. Roll back with: install-antigravity.ps1 -Uninstall"
