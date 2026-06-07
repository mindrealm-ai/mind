# Mindrealm `mind` CLI installer for Windows (PowerShell).
#   iwr -useb https://mindrealm.ai/install.ps1 | iex
# Detects your architecture, downloads the matching release archive from the
# public CLI repo, and installs `mind.exe` onto your PATH. Then run `mind login`.

$ErrorActionPreference = 'Stop'

$repo = 'mindrealm-ai/mind'
$base = "https://github.com/$repo/releases/latest/download"
$releases = "https://github.com/$repo/releases/latest"

# Detect architecture.
$arch = switch ($env:PROCESSOR_ARCHITECTURE) {
  'AMD64' { 'amd64' }
  'ARM64' { 'arm64' }
  default {
    Write-Error "mind: unsupported architecture '$($env:PROCESSOR_ARCHITECTURE)'. Download a binary from $releases"
    return
  }
}

$asset = "mind-windows-$arch.zip"
$dest = Join-Path $env:LOCALAPPDATA 'Programs\mind'
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("mind-" + [System.Guid]::NewGuid().ToString())

New-Item -ItemType Directory -Force -Path $dest, $tmp | Out-Null
try {
  $zip = Join-Path $tmp 'mind.zip'
  Write-Host "Downloading $asset ..."
  Invoke-WebRequest -Uri "$base/$asset" -OutFile $zip -UseBasicParsing
  Expand-Archive -Path $zip -DestinationPath $tmp -Force
  Move-Item -Path (Join-Path $tmp 'mind.exe') -Destination (Join-Path $dest 'mind.exe') -Force
}
finally {
  Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
}

Write-Host "Installed mind to $dest\mind.exe"

# Add the install dir to the user PATH if it is not already there.
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (-not ($userPath -split ';' | Where-Object { $_ -eq $dest })) {
  [Environment]::SetEnvironmentVariable('Path', "$userPath;$dest", 'User')
  $env:Path = "$env:Path;$dest"
  Write-Host "Added $dest to your PATH. Restart your terminal for it to take effect in new sessions."
}

Write-Host "Next: run 'mind login' to authenticate."
