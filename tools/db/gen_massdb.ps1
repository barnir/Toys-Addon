# ToyFinder DB pipeline — regenerate the MassDB table (ENGLISH) from community sources.
# Usage: pwsh -File tools/db/gen_massdb.ps1   (run from the repo root)
# Sources (download if missing, see tools/db/README.md):
#   tools/db/sources/toys.db.lua   — itemID -> EN name map (ToyBoxEnhanced)
#   tools/db/sources/egl_toys.json — EliteGrindLab rows (name, source, detail, expansion, npc, zone, profession, cost, href)
$ErrorActionPreference = 'Stop'
$root = (Get-Location).Path
$src = Join-Path $root 'tools/db/sources'
$dbPath = Join-Path $root 'ToyFinder/ToyFinder_Database.lua'

function Normalize-Name([string]$n) {
    if (-not $n) { return '' }
    $n = $n.ToLowerInvariant() -replace '&#39;', "'" -replace '&amp;', '&' -replace '&quot;', '"'
    $n = $n -replace '[^a-z0-9 ]', ''
    return ($n -replace '\s+', ' ').Trim()
}
function Get-SourceType([string]$group, [string]$detail) {
    $d = $detail.ToLowerInvariant()
    if ($d.StartsWith('treasure:')) { return 'TREASURE' }
    if ($d.StartsWith('garrison')) { return 'OTHER' }
    switch ($group) {
        'Drop' { 'LOOT' } 'Vendor' { 'VENDOR' } 'World Event' { 'EVENT' } 'Quest' { 'QUEST' }
        'Profession' { 'PROFESSION' } 'Achievement' { 'ACHIEVEMENT' } 'Promotion' { 'STORE' }
        'In-Game Shop' { 'STORE' } 'Trading Post' { 'TRADING_POST' } 'Discovery' { 'TREASURE' }
        'Pet Battle' { 'OTHER' } default { 'OTHER' }
    }
}
function Clean-Text([string]$s) {
    if (-not $s) { return '' }
    $s = $s -replace '&amp;', '&' -replace '&#39;', "'" -replace '&quot;', '"' -replace '&lt;', '<' -replace '&gt;', '>'
    $s = [regex]::Replace($s, '<[^>]+>', ' ')
    $s = ($s -replace '\s+', ' ').Trim()
    return $s
}
function Escape-Lua([string]$s) {
    if (-not $s) { return '' }
    $s = $s -replace '\\', '\\\\'
    $s = $s -replace '"', '\"'
    $s = $s -replace "`r", ''
    $s = $s -replace "`n", '\n'
    return $s
}

$cur = (Get-Content -Raw $dbPath) -replace "`r`n", "`n"
$existing = @{}
foreach ($m in [regex]::Matches($cur, '(?m)^\s{4}\[(\d+)\] = \{')) { $existing[$m.Groups[1].Value] = $true }
"Existing full guides (Entries): " + $existing.Count

$tdb = Get-Content -Raw (Join-Path $src 'toys.db.lua')
$nameToId = @{}
foreach ($m in [regex]::Matches($tdb, '(?m)^\[(\d+)\]\s*=\s*false,\s*--\s*(.+?)\s*$')) {
    $key = Normalize-Name $m.Groups[2].Value
    if ($key -and -not $nameToId.ContainsKey($key)) { $nameToId[$key] = $m.Groups[1].Value }
}
$j = Get-Content -Raw (Join-Path $src 'egl_toys.json') | ConvertFrom-Json

$lines = New-Object System.Collections.Generic.List[string]
$matched = 0
foreach ($row in $j.rows) {
    $key = Normalize-Name ([string]$row[1])
    $id = $nameToId[$key]
    if (-not $id) { continue }
    if ($existing.ContainsKey($id)) { continue }
    $matched++
    $t = Get-SourceType ([string]$row[2]) ([string]$row[4])
    $entry = "[$id] = { n = `"$(Escape-Lua ([string]$row[1]))`", t = `"$t`", s = `"$(Escape-Lua (Clean-Text ([string]$row[4])))`""
    if ([string]$row[7]) { $entry += ", z = `"$(Escape-Lua (([string]$row[7]) -replace ';', ', '))`"" }
    if ([string]$row[6]) { $entry += ", g = `"$(Escape-Lua ([string]$row[6]))`"" }
    if ([string]$row[5]) { $entry += ", e = `"$(Escape-Lua ([string]$row[5]))`"" }
    if ([string]$row[9]) { $entry += ", c = `"$(Escape-Lua ([string]$row[9]))`"" }
    if ([string]$row[8]) { $entry += ", p = `"$(Escape-Lua ([string]$row[8]))`"" }
    $entry += " },"
    $lines.Add($entry)
}
"MassDB entries: $matched"
$massNew = "-- MASS DB: auto-generated (ToyBoxEnhanced + EliteGrindLab) — ENGLISH ONLY (AGENTS.md)`n-- n=name, t=sourceType, s=source text, z=zone, g=NPC/target, e=expansion, c=cost, p=profession`nToyFinderDatabase.MassDB = {`n" + ($lines -join "`n") + "`n}"

$ci = $cur.LastIndexOf("-- ===", $cur.IndexOf("ToyFinderDatabase.MassDB = {"))
$fi = $cur.IndexOf("ToyFinderDatabase.GetToyData")
$ei = $cur.LastIndexOf("`n}`n", $cur.IndexOf("-- ", $fi))
if ($ci -lt 0 -or $ei -lt 0) { throw 'markers not found' }
$newDb = $cur.Substring(0, $ci) + $massNew + "`n`n" + $cur.Substring($ei + 3)
[System.IO.File]::WriteAllText($dbPath, $newDb, [System.Text.UTF8Encoding]::new($false))
"WROTE $dbPath ($($newDb.Length) bytes)"
