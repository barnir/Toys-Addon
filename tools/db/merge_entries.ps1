# ToyFinder DB pipeline — append full-guide Lua blocks (from research agents) to the Entries table.
# Usage: pwsh -File tools/db/merge_entries.ps1 -Files "agent_a.lua,agent_b.lua"   (from repo root)
param([Parameter(Mandatory = $true)][string]$Files)
$ErrorActionPreference = 'Stop'
$root = (Get-Location).Path
$dbPath = Join-Path $root 'ToyFinder/ToyFinder_Database.lua'
$cur = (Get-Content -Raw $dbPath) -replace "`r`n", "`n"
$blocks = @()
foreach ($f in ($Files -split ',')) {
    $p = Join-Path $root $f.Trim()
    $blocks += (Get-Content -Raw $p) -replace "`r`n", "`n"
}
$merged = ($blocks -join "`n")
# safety: no double commas introduced
$merged = $merged -replace '\},\s*,', '},'
$fi = $cur.IndexOf('ToyFinderDatabase.Entries = DB')
$ei = $cur.LastIndexOf("`n}`n", $fi)
if ($ei -lt 0) { throw 'Entries closing brace not found' }
$new = $cur.Substring(0, $ei) + ",`n`n" + $merged + $cur.Substring($ei)
[System.IO.File]::WriteAllText($dbPath, $new, [System.Text.UTF8Encoding]::new($false))
"Merged into $dbPath ($($new.Length) bytes)"
