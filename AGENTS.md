# AGENTS.md — ToyFinder (WoW Addon, Patch 12.0+ / Midnight)

Regras permanentes de desenvolvimento deste addon (definidas pelo autor do projeto).
Qualquer agente/IA a trabalhar neste repositório deve cumpri-las. Documentação do
addon em `ToyFinder/README.md` e `COMO-INSTALAR.txt` — manter sincronizada.

## WoW environment

- Interface version: **120001**. WoW uses **Lua 5.1**: no `goto`, no bitwise operators
  (`&`, `|`, `<<`), no `_ENV`, no integer division `//`, no `load()` with env arg —
  use `loadstring()`. Bitwise ops via `bit.band()`, `bit.bor()`, `bit.lshift()`.
- Unavailable in WoW Lua: `require()`, `dfile()`/`dofile()`, `loadfile()`, `os.*`,
  `io.*`, `debug.*` (mostly), `package.*`, `coroutine.*` (limited), `string.dump()`.

## Critical rules

1. Every `.lua` file starts with: `local addonName, ns = ...`
2. No global variables except SavedVariables declared in the `.toc`
   (engine-required exceptions: `SLASH_*`/`SlashCmdList` and the `.toc`
   `AddonCompartmentFunc*` global functions).
3. Use event-driven table dispatch (`local handlers = { EVENT = function(...) end }`
   + loop `RegisterEvent`), never `if/elseif` chains for events.
4. SavedVariables are ONLY safe after `ADDON_LOADED` fires for this addon.
5. Always check `InCombatLockdown()` before modifying protected/secure frames.
6. Queue combat-blocked operations for `PLAYER_REGEN_ENABLED`.
7. Never use `OnUpdate` for what an event can do (exception: drag handling).
8. Always generate complete `.toc` + `.lua` files, not snippets.

## Midnight (12.0) mandatory changes

- `COMBAT_LOG_EVENT_UNFILTERED` does NOT fire for addons (removed).
- `CombatLogGetCurrentEventInfo()` is REMOVED with no replacement.
- Use `UNIT_HEALTH`, `UNIT_AURA`, `UNIT_SPELLCAST_START/SUCCEEDED/FAILED` instead.
- Combat numbers are Secret Values — opaque, cannot be read/compared/stored.
- Addon chat in instances is restricted; messages become Secret Values.
- Skin and enhance Blizzard frames, do not replace them.

## Deprecated functions — DO NOT USE

- `GetSpellInfo()` → `C_Spell.GetSpellInfo()` (returns TABLE: `.name`, `.iconID`, `.castTime`)
- `GetSpellCooldown()` → `C_Spell.GetSpellCooldown()` (TABLE)
- `GetSpellCharges()` → `C_Spell.GetSpellCharges()` (TABLE)
- `GetSpellTexture()` → `C_Spell.GetSpellTexture()`
- `GetSpellDescription()` → `C_Spell.GetSpellDescription()`
- `GetItemInfo()` → `C_Item.GetItemInfo()` (async, may return nil)
- `GetItemIcon()` → `C_Item.GetItemIconByID()`
- `GetContainerNumSlots()` → `C_Container.GetContainerNumSlots()`
- `GetContainerItemInfo()` → `C_Container.GetContainerItemInfo()` (TABLE)
- `GetContainerItemLink()` → `C_Container.GetContainerItemLink()`
- `PickupContainerItem()` → `C_Container.PickupContainerItem()`
- `UseContainerItem()` → `C_Container.UseContainerItem()`
- `GetAddOnInfo()` → `C_AddOns.GetAddOnInfo()`
- `GetNumAddOns()` → `C_AddOns.GetNumAddOns()`
- `IsAddOnLoaded()` → `C_AddOns.IsAddOnLoaded()`
- `GetSpecialization()` → `PlayerUtil.GetCurrentSpecID()`
- `GetAchievementInfo()` → `C_AchievementInfo.GetAchievementInfo()`
- `GetCurrencyInfo()` → `C_CurrencyInfo.GetCurrencyInfo()` (TABLE)
- `UnitAura()` → `C_UnitAuras.GetAuraDataByIndex()` (AuraData TABLE)
- `UnitBuff()` → `C_UnitAuras.GetBuffDataByIndex()` (AuraData TABLE)
- `UnitDebuff()` → `C_UnitAuras.GetDebuffDataByIndex()` (AuraData TABLE)
- `IsSpellKnown(id)` → `C_Spell.IsSpellDataCached(id)` (behavior changed)
- `GetSpecializationInfo(id)` → `C_SpecializationInfo.GetSpecializationInfo(id)`
- `GetTalentInfo(tier, col, group)` → `C_ClassTalents` + talent tree APIs (reworked)
- `SendChatMessage()` in instances → **restricted** (messages become Secret Values in 12.0)
- `CombatLogGetCurrentEventInfo()` → **REMOVED, no replacement** (no CLEU for addons)

When a `C_*` function returns a table, access fields: `local info = C_Spell.GetSpellInfo(id)`
then `info.name`, `info.iconID`. Do NOT unpack multiple returns from table-returning APIs.

## .toc format (standard: https://warcraft.wiki.gg/wiki/TOC_format)

Syntax: directives are `## Directive: Value`; `#` starts a comment; after the directives
comes the file list (load order matters; per-file inline conditions like
`Mainline\File.lua` / `# [AllowLoadGameType classic] File.lua` are supported).

```
## Interface: 120001                      # single value = latest retail (Standard); or list: 120105, 16001, 50504, 11509
## Title: My AddOn Name                    # locale variants: ## Title-frFR: ...
## Notes: Brief description               # locale variants: ## Notes-ptBR: ..., color codes allowed
## Category: Miscellaneous                 # locale variants supported
## Group: MyAddonSuite                     # group related addons
## Author: My Name
## Version: 1.0.0
## X-Website: https://github.com/me/myaddon  # any ## X-___ metadata
## IconTexture: Interface\Icons\TEMP       # or ## IconAtlas: TaskPOI-Icon
## AddonCompartmentFunc: MyAddon_OnAddonCompartmentClick
## AddonCompartmentFuncOnEnter: MyAddon_OnAddonCompartmentEnter
## AddonCompartmentFuncOnLeave: MyAddon_OnAddonCompartmentLeave
## SavedVariables: MyAddonDB                # multiple allowed, comma-separated; also SavedVariablesPerCharacter / SavedVariablesMachine
## LoadSavedVariablesFirst: 1               # load SVs before code runs
## AllowAddOnTableAccess: 1                # let other addons read the namespace table
## OptionalDeps: SomeLib                    # loaded before us if present
## Dependencies: RequiredAddOn             # hard requirement
## DefaultState: enabled                     # enabled/disabled
## OnlyBetaAndPTR: 1                        # load only on beta/PTR
Core.lua
Modules/Module1.lua
```

Directive groups (wiki.gg): display text/organization (Title, Notes, Category, Group),
icons (IconTexture, IconAtlas), addon compartment (3 funcs), loading conditions
(LoadOnDemand, Dependencies/Dep, OptionalDeps, LoadWith, LoadManagers, AllowLoadGameType,
ExcludeLoadGameType, OnlyBetaAndPTR, DefaultState), saved variables (LoadSavedVariablesFirst,
SavedVariables, SavedVariablesPerCharacter, SavedVariablesMachine), metadata (Author, Version,
X-___), uncategorized (AllowAddOnTableAccess). Restricted (Blizzard use): AllowLoad,
EscalateErrorDuringLoad, LoadFirst, UseSecureEnvironment.

## Common patterns

- Slash commands: `SLASH_NAME1 = "/cmd"; SlashCmdList["NAME"] = function(msg) end`
- Timers: `C_Timer.After(s, cb)` (not cancellable); `C_Timer.NewTimer(s, cb)` → handle with `:Cancel()`; `C_Timer.NewTicker(s, cb, n)`
- Frame pools: `CreateFramePool("Frame", parent, template)`
- Hooks: `hooksecurefunc("Func", postHook)` / `hooksecurefunc(object, "Method", postHook)`

## API reference & verification

Primary reference (official): **[World of Warcraft API](https://warcraft.wiki.gg/wiki/World_of_Warcraft_API)**
— index of all API systems (`Category:API_systems/<Name>`), per-function pages
`API_<FunctionName>`, `Global functions` list, `Widget API` (frames/tooltips/widgets),
`Events`, and `Patch X/API changes` pages. Always check the relevant
`Patch 12.0.x/API changes` page before using an API. Secondary mirror:
https://www.better-addons.com/api-cheatsheet (also hosts the AI coding guide).

Rule: before using any API, verify it exists in Patch 12.0.1 at
warcraft.wiki.gg/wiki/API_FunctionName; if unsure, flag it for verification.

### APIs used by ToyFinder (verified against warcraft.wiki.gg, 12.0.1)

| API | Notes |
|---|---|
| `C_ToyBox.GetToyInfo(itemID)` | multiple returns: `_, name, icon, isFav, hasFanfare, quality` (NOT a table) |
| `C_ToyBox.GetToyFromIndex`, `GetNumFilteredToys`, `SetFilterString`/`GetFilterString`, `SetCollectedShown`/`SetUncollectedShown`/`SetUnusableShown`, `SetAllExpansionTypeFilters`, `SetAllSourceTypeFilters`, `GetToyLink` | ToyBox system |
| `C_TooltipInfo.GetToyByItemID(itemID)` | returns TooltipData table with `.lines[].leftText` (may be Secret Values — guard with `issecretvalue`) |
| `C_Item.RequestLoadItemDataByID(itemID)` | async; pair with `ITEM_DATA_LOAD_RESULT` |
| `PlayerHasToy(itemID)` | still exists in 12.0.1 |
| `GameTooltip:SetToyByItemID(itemID)` | Widget API |
| `C_Timer.After` / `NewTimer` / `NewTicker` | timers |
| `PlaySound(SOUNDKIT.*)` | still exists in 12.0 (`PlaySoundKitID` alternative) |
| `hooksecurefunc`, `CreateFrame`, `CreateFramePool`, `SlashCmdList` | engine patterns |


### Additional rules adopted from the agent (WoWAddon-Expert.md)

- **No semicolons in Lua** — write `print("x")` not `print("x");` (WoW convention).
- **NEVER `print()` for debug output** — debug goes to a scrollable, copy-pasteable
  EditBox debug window (saved-variable log + `/addondebug` slash command). Current
  `print()` calls in ToyFinder are user-facing status messages, not debug output.
- **Secret Values (12.0+)**: guard with `issecretvalue()` BEFORE any string operation
  on tooltip text (`C_TooltipInfo` `line.leftText`, `FontString:GetText()`); secrets
  appear in ANY tainted context, not just combat. `FontString:SetText()` accepts
  secrets natively. Use `UnitHealthPercent`/`UnitPowerPercent` for arithmetic.
- Check APIs exist before using (`C_SomeAPI.SomeFunction ~= nil`); prefer `C_*`
  namespaces (`C_ActionBar`, `C_CombatLog`, `C_DamageMeter` — never parse combat log).
- Localize global lookups at file top (`local string = string` etc.).
- Never create global frame names that conflict with Blizzard UI; never name frames
  parented to secure Blizzard containers.
- Markdown files: use clickable links for cross-file refs (`[file.md](file.md)`) and
  `[Section](#section)` for intra-file refs.
- Paths in guides must be relative; only agent config files hold absolute paths
  (user config: AddOns at `D:\Games\World of Warcraft\_retail_\Interface\AddOns`).

## Local WoW resources (Guide Directory / Blizzard UI Source)

The guide repo's optional Claude files pointed at two folders inside `Interface/` on the
WoW machine (user config: `D:\Games\World of Warcraft\_retail_\Interface\`); we use the
same locations without Claude Code:

- **Guide Directory** — `+++WoW Addon Development Guide+++/`: the knowledge base agents
  read before answering. Source: [Amadeus-/WoWAddonDevGuide](https://github.com/Amadeus-/WoWAddonDevGuide/tree/master)
  (put the guide files there). Contents:
  `00_MASTER_GUIDE.md` (overview + 5-min tutorial), `01_API_Reference.md`, `02_Event_System.md`,
  `03_UI_Framework.md`, `04_Addon_Structure.md`, `05_Patterns_And_Best_Practices.md`,
  `06_Data_Persistence.md`, `07_Blizzard_UI_Examples.md`, `08_Community_Addon_Patterns.md`,
  `09_Addon_Libraries_Guide.md`, `09a_Ace3_Library_Guide.md`, `10_Advanced_Techniques.md`,
  `11_Housing_System_Guide.md`, `12_API_Migration_Guide.md`, `12a_Secret_Safe_APIs.md`,
  `13_Cooldown_Viewer_Guide.md`, plus `README.md` (index + version history).
  **When reading these files, ignore everything between `<!-- CLAUDE_SKIP_START -->` and
  `<!-- CLAUDE_SKIP_END -->`** (human-oriented content).
- **Blizzard UI Source** — `+wow-ui-source+ (12.0.5)/`: Blizzard's official UI source code
  (FrameXML/SharedXML/AddOns) used as reference for official patterns.
  Source: [Gethe/wow-ui-source](https://github.com/Gethe/wow-ui-source) (git mirror, branch
  per client, e.g. 12.0.x); alternatives: [Ketho/BlizzardInterfaceResources](https://github.com/Ketho/BlizzardInterfaceResources).
  Clone/download into that folder.
- Folders named `+...+`/`+++...+++` inside `Interface/` are NOT loaded as addons — only
  `Interface/AddOns/*` loads. That's why the resources live there and not in `AddOns/`.
- Mixin pattern (`MyAddonMixin` with `OnLoad`/`OnEvent` dispatch via `self[event]`)
  is the modern Blizzard style; this repo's `ns` namespace pattern is equivalent.
- Indentation: keep consistent within each file (existing ToyFinder files use 4 spaces).
- Patterns to prefer (guide `05_Patterns_And_Best_Practices.md`): CallbackRegistry-style
  event registration with handle containers (12.0+), mixins via `CreateFromMixins()`,
  safe/nil-safe table access, table builders, filtered iterators, localize hot globals,
  table preallocation, table recycling, `CreateFramePool` for repeated widgets,
  input validation + `pcall` around external calls, never assume async APIs returned data.
