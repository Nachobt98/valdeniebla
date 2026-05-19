$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$uv = Join-Path $repoRoot ".godot-local\uv\uv.exe"
$mcpDir = Join-Path $repoRoot ".godot-local\slangwald-godot-mcp\mcp"

if (-not (Test-Path $uv)) {
    throw "Local uv executable not found: $uv"
}

if (-not (Test-Path $mcpDir)) {
    throw "slangwald godot-mcp server directory not found: $mcpDir"
}

$env:UV_CACHE_DIR = Join-Path $repoRoot ".godot-local\uv-cache"
$env:UV_PYTHON_INSTALL_DIR = Join-Path $repoRoot ".godot-local\uv-python"

& $uv run --directory $mcpDir python godot_mcp_server.py
