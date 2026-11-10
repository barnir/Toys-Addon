# ToyFinder DB pipeline — regenerate MassDB from WoWDB (thewowdb.com/toys/, datamined retail build).
# Primary source: wowdb_obtain.tsv (id, name, srctype, target, zone, cost) parsed from per-toy pages.
# Fallback/extra: egl_toys.json (expansion, longer source text) joined by item ID.
# Usage: pwsh -File tools/db/gen_massdb_wowdb.ps1   (from repo root)
$ErrorActionPreference = 'Stop'
$root = (Get-Location).Path
$src = Join-Path $root 'tools/db/sources'
$dbPath = Join-Path $root 'ToyFinder/ToyFinder_Database.lua'

function Map-SrcType([string]$s) {
    switch -Regex ($s) {
        '^(Vendor)$' { 'VENDOR' }
        '^(Drop)$' { 'LOOT' }
        '^(Treasure|Discovery)$' { 'TREASURE' }
        '^(Quest|World Quest|Relic Quest|Given By|Reward)$' { 'QUEST' }
        '^Profession$' { 'PROFESSION' }
        '^(World Event|Event|Holiday)$' { 'EVENT' }
        '^Achievement$' { 'ACHIEVEMENT' }
        '^Trading Post$' { 'TRADING_POST' }
        '^(Promotion|Trading Card Game|Wow Esports)$' { 'STORE' }
        default { 'OTHER' }
    }
}
function Clean-Text([string]$s) {
    if (-not $s) { return '' }
    $s = $s -replace '&amp;', '&' -replace '&#39;', "'" -replace '&#x27;', "'" -replace '&quot;', '"'
    $s = [regex]::Replace($s, '<[^>]+>', ' ')
    return ($s -replace '\s+', ' ').Trim()
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
"Existing full guides: " + $existing.Count

# egl por id (para expansão e texto de fonte extra)
$eglById = @{}
$eglPath = Join-Path $src 'egl_toys.json'
if (Test-Path $eglPath) {
    $j = Get-Content -Raw $eglPath | ConvertFrom-Json
    # Precisamos de id: o egl tem slug, não id. Usar o mapa nome->id do toys.db.lua
    $tdb = Get-Content -Raw (Join-Path $src 'toys.db.lua')
    $nameToId = @{}
    foreach ($m in [regex]::Matches($tdb, '(?m)^\[(\d+)\]\s*=\s*false,\s*--\s*(.+?)\s*$')) {
        $key = ($m.Groups[2].Value.ToLowerInvariant() -replace '[^a-z0-9 ]', '' -replace '\s+', ' ').Trim()
        if ($key -and -not $nameToId.ContainsKey($key)) { $nameToId[$key] = $m.Groups[1].Value }
    }
    foreach ($row in $j.rows) {
        $key = (([string]$row[1]).ToLowerInvariant() -replace '[^a-z0-9 ]', '' -replace '\s+', ' ').Trim()
        $id = $nameToId[$key]
        if ($id) { $eglById[$id] = $row }
    }
}

$wdb = Import-Csv -Delimiter "`t" -Path (Join-Path $src 'wowdb_obtain.tsv') -Header @('id','name','srctype','target','zone','cost')
$lines = New-Object System.Collections.Generic.List[string]
$count = 0
foreach ($w in $wdb) {
    $id = $w.id
    if ($existing.ContainsKey($id)) { continue }
    $count++
    $t = Map-SrcType $w.srctype
    $name = Clean-Text $w.name
    $target = Clean-Text $w.target
    $zone = Clean-Text $w.zone
    $cost = Clean-Text $w.cost
    # texto da fonte: compoe a partir dos campos; se houver egl, anexa o detail do egl
    $s = @()
    if ($w.srctype) { $s += $w.srctype }
    if ($target) { $s += $target }
    if ($zone) { $s += "Zone: $zone" }
    if ($cost) { $s += "Cost: $cost" }
    $srcText = ($s -join ' - ')
    $e = ''
    if ($eglById[$id]) { $e = Clean-Text ([string]$eglById[$id][5]) }
    $entry = "[$id] = { n = `"$(Escape-Lua $name)`", t = `"$t`", s = `"$(Escape-Lua $srcText)`""
    if ($zone) { $entry += ", z = `"$(Escape-Lua $zone)`"" }
    if ($target) { $entry += ", g = `"$(Escape-Lua $target)`"" }
    if ($e) { $entry += ", e = `"$(Escape-Lua $e)`"" }
    if ($cost) { $entry += ", c = `"$(Escape-Lua $cost)`"" }
    $entry += " },"
    $lines.Add($entry)
}
"MassDB entries from WoWDB: $count"
$massNew = "-- MASS DB: auto-generated from WoWDB (thewowdb.com/toys, datamined retail build) + EliteGrindLab — ENGLISH ONLY (AGENTS.md)`n-- n=name, t=sourceType, s=source text, z=zone, g=NPC/target, e=expansion, c=cost`nToyFinderDatabase.MassDB = {`n" + ($lines -join "`n") + "`n}"

$ci = $cur.LastIndexOf("-- ===", $cur.IndexOf("ToyFinderDatabase.MassDB = {"))
$fi = $cur.IndexOf("-- Função de consulta rápida")
$ei = $cur.LastIndexOf("`n}`n", $fi)
if ($ci -lt 0 -or $ei -lt 0) { throw 'markers not found' }
$newDb = $cur.Substring(0, $ci) + $massNew + "`n`n" + $cur.Substring($ei + 3)
[System.IO.File]::WriteAllText($dbPath, $newDb, [System.Text.UTF8Encoding]::new($false))
"WROTE $dbPath ($($newDb.Length) bytes)"
