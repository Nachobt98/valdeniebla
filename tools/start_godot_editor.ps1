$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$godot = Join-Path $repoRoot ".godot-local\Godot_v4.6.2-stable_win64_console.exe"

if (-not (Test-Path $godot)) {
    throw "Local Godot executable not found: $godot"
}

Start-Process -FilePath $godot -ArgumentList @("--editor", "--path", $repoRoot)
