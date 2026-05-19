$ErrorActionPreference = "Continue"

function Show-CommandStatus {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Name,
        [Parameter(Mandatory = $true)]
        [string] $Command
    )

    $resolved = Get-Command $Command -ErrorAction SilentlyContinue
    if ($resolved) {
        Write-Output ("[ok] {0}: {1}" -f $Name, $resolved.Source)
        return
    }

    Write-Output ("[missing] {0}: {1} not found in PATH" -f $Name, $Command)
}

Show-CommandStatus -Name "Node.js" -Command "node"
Show-CommandStatus -Name "npm" -Command "npm.cmd"
Show-CommandStatus -Name "npx" -Command "npx.cmd"
Show-CommandStatus -Name "Godot" -Command "godot"
Show-CommandStatus -Name "Python" -Command "python"
Show-CommandStatus -Name "Python launcher" -Command "py"
Show-CommandStatus -Name "uv" -Command "uv"

$localUv = Join-Path (Get-Location) ".godot-local\uv\uv.exe"
if (Test-Path $localUv) {
    Write-Output ("[ok] Local uv: {0}" -f $localUv)
    & $localUv --version
} else {
    Write-Output "[missing] Local uv not found under .godot-local"
}

$localGodot = Join-Path (Get-Location) ".godot-local\Godot_v4.6.2-stable_win64_console.exe"
if (Test-Path $localGodot) {
    Write-Output ("[ok] Local Godot: {0}" -f $localGodot)
    & $localGodot --version
} else {
    Write-Output "[missing] Local Godot not found under .godot-local"
}

$localMcp = Join-Path (Get-Location) ".godot-local\slangwald-godot-mcp\mcp\godot_mcp_server.py"
if (Test-Path $localMcp) {
    Write-Output ("[ok] Godot editor/runtime MCP server: {0}" -f $localMcp)
} else {
    Write-Output "[missing] Godot editor/runtime MCP server not found under .godot-local"
}

Write-Output ""
Write-Output "Run this from the repo root after installing Godot/Python/uv to confirm the AI-Godot toolchain."
