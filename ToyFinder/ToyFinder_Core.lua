--[[
    ToyFinder - Core Engine
    Varredura de Brinquedos, Extração de Fontes, Categorização e Integração WoWhead
]]

local addonName, ns = ...
ns.ToyFinder = ns.ToyFinder or {}
local ToyFinder = ns.ToyFinder
local ToyFinderDatabase = ns.Database
local L = ns.L
local Data = ns.Data

-- Hot globals localized (perf rule from the guide: localize frequently used globals)
local string, table, math, ipairs, pairs, tostring, pcall = string, table, math, ipairs, pairs, tostring, pcall

-- Estrutura de dados interna
ToyFinder.toys = {}            -- Array indexado com todas as toys encontradas
ToyFinder.toysByID = {}        -- Lookup rápido [itemID] = toyObject
ToyFinder.filteredToys = {}    -- Lista atual filtrada e ordenada para a UI
ToyFinder.stats = {
    total = 0,
    collected = 0,
    missing = 0,
    percent = "0.0"
}

-- Filtros e opções padrão
ToyFinder.activeFilter = "MISSING"       -- ALL, MISSING, COLLECTED, FAVORITES
ToyFinder.activeSource = "ALL"           -- ALL, VENDOR, LOOT, TREASURE, QUEST, etc.
ToyFinder.activeContinent = "ALL"        -- ALL, KHAZ_ALGAR, DRAGON_ISLES, SHADOWLANDS, etc.
ToyFinder.activeZone = "ALL"             -- ALL ou nome específico de zona
ToyFinder.activeDifficulty = "ALL"       -- ALL, EASY, QUEST, EXPLORE, FARM, EVENT, OTHER
ToyFinder.searchQuery = ""
ToyFinder.sortBy = "NEWEST"              -- NEWEST, NAME, QUALITY, STATUS
ToyFinder.preferredWoWhead = "pt"        -- pt ou en
ToyFinder.selectedToy = nil

-- Criar tooltip invisível para leitura de dados quando C_TooltipInfo não estiver disponível
local scanTooltip = CreateFrame("GameTooltip", "ToyFinderScanTooltip", UIParent, "GameTooltipTemplate")
scanTooltip:SetOwner(UIParent, "ANCHOR_NONE")

-- Função auxiliar de remoção de espaços
local function trim(s)
    if not s then return "" end
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- Limpa códigos de cor e formatação de texto do WoW
local function stripColors(text)
    if not text then return "" end
    return text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|T.-|t", ""):gsub("|H.-|h", ""):gsub("|h", "")
end

-- 12.0+: textos de tooltip (C_TooltipInfo line.leftText / FontString:GetText) podem ser
-- Secret Values — nunca fazer operações de string sobre eles; devolver nil nesse caso
local function SafeText(value)
    if value == nil then return nil end
    if issecretvalue and issecretvalue(value) then return nil end
    return value
end

--------------------------------------------------------------------------------
-- INICIALIZAÇÃO E BANCO DE DADOS (SAVED VARIABLES)
--------------------------------------------------------------------------------
function ToyFinder:InitializeDB()
    ToyFinderDB = ToyFinderDB or {}
    ToyFinderDB.favorites = ToyFinderDB.favorites or {}
    ToyFinderDB.wishlist = ToyFinderDB.wishlist or {}
    ToyFinderDB.sourceCache = ToyFinderDB.sourceCache or {}
    ToyFinderDB.settings = ToyFinderDB.settings or {
        preferredWoWhead = "pt",
        defaultFilter = "MISSING",
        minimap = { hide = false, angle = 45 },
        windowPos = nil
    }
    
    self.preferredWoWhead = ToyFinderDB.settings.preferredWoWhead or "pt"
    self.activeFilter = ToyFinderDB.settings.defaultFilter or "MISSING"
end

--------------------------------------------------------------------------------
-- PARSER DE FONTES & TOOLTIP (Vendedores, Loot, Tesouros, Missões)
--------------------------------------------------------------------------------
-- Rótulos que o cliente usa na linha "Fonte:/Source:" — parsing determinístico
-- antes de qualquer scan de palavras-chave (evita classificações erradas quando o
-- texto contém várias palavras-chave, ex.: "Evento mundial com missões diárias")
local SOURCE_LABELS = {
    { "posto de trocas", "TRADING_POST" }, { "trading post", "TRADING_POST" }, { "puesto comercial", "TRADING_POST" },
    { "evento mundial", "EVENT" }, { "world event", "EVENT" }, { "evento del mundo", "EVENT" }, { "weltereignis", "EVENT" }, { "evento", "EVENT" },
    { "tesouro", "TREASURE" }, { "treasure", "TREASURE" }, { "tesoro", "TREASURE" }, { "schatz", "TREASURE" }, { "trésor", "TREASURE" },
    { "conquista", "ACHIEVEMENT" }, { "achievement", "ACHIEVEMENT" }, { "logro", "ACHIEVEMENT" }, { "erfolg", "ACHIEVEMENT" }, { "haut fait", "ACHIEVEMENT" },
    { "profissão", "PROFESSION" }, { "profissao", "PROFESSION" }, { "profession", "PROFESSION" }, { "beruf", "PROFESSION" }, { "profesión", "PROFESSION" },
    { "missão", "QUEST" }, { "missao", "QUEST" }, { "quest", "QUEST" }, { "misión", "QUEST" }, { "mision", "QUEST" }, { "quête", "QUEST" }, { "aufgabe", "QUEST" },
    { "vendedor", "VENDOR" }, { "vendido", "VENDOR" }, { "sold by", "VENDOR" }, { "vendor", "VENDOR" }, { "verkäufer", "VENDOR" }, { "vendeur", "VENDOR" },
    { "saque", "LOOT" }, { "despojado", "LOOT" }, { "dropped", "LOOT" }, { "drop", "LOOT" }, { "loot", "LOOT" }, { "butin", "LOOT" }, { "beute", "LOOT" }, { "botín", "LOOT" },
    { "loja", "STORE" }, { "store", "STORE" }, { "tienda", "STORE" }, { "shop", "STORE" },
}

function ToyFinder:ClassifySourceType(text)
    if not text or text == "" then
        return "OTHER"
    end
    
    local lowerText = string.lower(text)
    
    -- 1) Tenta o rótulo explícito depois de "Fonte:"/"Source:" (mais fiável)
    local afterColon = lowerText:match(":%s*(.+)$")
    if afterColon then
        for _, entry in ipairs(SOURCE_LABELS) do
            local label = entry[1]
            if afterColon:sub(1, #label) == label then
                return entry[2]
            end
        end
    end
    
    -- 2) Fallback: scan de palavras-chave por ordem de prioridade fixa
    local priority = Data.SourcePriority or { "TREASURE", "QUEST", "ACHIEVEMENT", "EVENT", "PROFESSION", "TRADING_POST", "STORE", "VENDOR", "LOOT" }
    for _, typeKey in ipairs(priority) do
        local patterns = Data.SourcePatterns[typeKey]
        if patterns then
            for _, pattern in ipairs(patterns) do
                if string.find(lowerText, pattern, 1, true) then
                    return typeKey
                end
            end
        end
    end
    
    return "OTHER"
end

function ToyFinder:ExtractToySource(itemID)
    if not itemID then return "Unknown source", "OTHER", nil end
    
    -- 0. Verificar Base de Dados Integrada (guias completos primeiro, depois MassDB com fonte)
    if ToyFinderDatabase and ToyFinderDatabase.GetToyData then
        local dbEntry = ToyFinderDatabase:GetToyData(itemID)
        if dbEntry and dbEntry.guide and dbEntry.guide ~= "" then
            return dbEntry.guide, dbEntry.sourceType, dbEntry
        elseif dbEntry and dbEntry.sourceText and dbEntry.sourceText ~= "" then
            return dbEntry.sourceText, dbEntry.sourceType, dbEntry
        end
    end
    
    -- 1. Verificar cache salvo
    if ToyFinderDB and ToyFinderDB.sourceCache and ToyFinderDB.sourceCache[itemID] then
        local cached = ToyFinderDB.sourceCache[itemID]
        if cached.source and cached.source ~= "" and cached.type then
            return cached.source, cached.type, nil
        end
    end
    
    -- 2. Verificar base pré-carregada
    if Data.PreloadedSources and Data.PreloadedSources[itemID] then
        local pre = Data.PreloadedSources[itemID]
        return pre.source, pre.type, nil
    end
    
    local rawSourceText = nil
    
    -- 3. Utilizar moderna C_TooltipInfo (Dragonflight / The War Within / Midnight)
    if C_TooltipInfo and C_TooltipInfo.GetToyByItemID then
        local data = C_TooltipInfo.GetToyByItemID(itemID)
        if data and data.lines then
            for _, line in ipairs(data.lines) do
                local text = SafeText(line.leftText)
                if text and text ~= "" then
                    local clean = trim(stripColors(text))
                    -- Padrões comuns de fonte na tooltip do WoW
                    if clean:find("^Source:") or clean:find("^Fonte:") or clean:find("^Fuente:") or clean:find("^Quelle:") or clean:find("^Source%s*:") then
                        rawSourceText = clean
                        break
                    end
                end
            end
        end
    end
    
    -- 4. Fallback: Scanning GameTooltip
    if not rawSourceText then
        scanTooltip:ClearLines()
        scanTooltip:SetToyByItemID(itemID)
        for i = 1, scanTooltip:NumLines() do
            local left = _G["ToyFinderScanTooltipTextLeft" .. i]
            if left then
                local text = SafeText(left:GetText())
                if text and text ~= "" then
                    local clean = trim(stripColors(text))
                    if clean:find("^Source:") or clean:find("^Fonte:") or clean:find("^Fuente:") or clean:find("^Quelle:") or clean:find("^Source%s*:") then
                        rawSourceText = clean
                        break
                    end
                end
            end
        end
    end
    
    local finalSource = rawSourceText or "See on WoWhead (Drop, Vendor or Treasure)"
    local sourceType = self:ClassifySourceType(finalSource)
    
    -- Salvar no cache
    if ToyFinderDB and ToyFinderDB.sourceCache then
        ToyFinderDB.sourceCache[itemID] = {
            source = finalSource,
            type = sourceType
        }
    end
    
    return finalSource, sourceType
end

--------------------------------------------------------------------------------
-- GERAÇÃO DE LINKS DO WOWHEAD
--------------------------------------------------------------------------------
function ToyFinder:GetWoWheadURL(itemID, lang)
    if not itemID then return "" end
    lang = lang or self.preferredWoWhead or "pt"
    
    if lang == "pt" then
        return string.format("https://pt.wowhead.com/item=%d", itemID)
    else
        return string.format("https://www.wowhead.com/item=%d", itemID)
    end
end

--------------------------------------------------------------------------------
-- GERAÇÃO E ADIÇÃO DE WAYPOINTS (TomTom / Coordenadas no Mapa)
--------------------------------------------------------------------------------
function ToyFinder:AddWaypoint(toy)
    if not toy then return false, "No toy selected" end
    
    local cmd = toy.waypoint
    if not cmd and toy.zone and toy.coords then
        cmd = string.format("/way %s %s %s", toy.zone, toy.coords, toy.name or "")
    end
    
    if not cmd or cmd == "" then
        return false, "This toy has no fixed map coordinates (it may be a world drop or achievement)."
    end

    -- Se o TomTom estiver carregado, define a seta de navegação imediatamente!
    local cleanArgs = cmd:gsub("^/way%s+", "")
    if SlashCmdList["TOMTOM_WAY"] then
        SlashCmdList["TOMTOM_WAY"](cleanArgs)
        print("|cff00e5ffToyFinder [TomTom]:|r Waypoint created on the map for |cffffd200" .. (toy.name or "") .. "|r! (" .. cleanArgs .. ")")
        PlaySound(SOUNDKIT.MAP_PING)
        return true, "Waypoint added to TomTom successfully!"
    end

    -- Se o TomTom não estiver instalado, mostra a instrução no chat
    print("|cff9d4eddToyFinder Coordinates:|r |cffffd200" .. cmd .. "|r")
    print("|cffaaaaaaTip: If you install the TomTom addon, this coordinate automatically creates an on-screen arrow!|r")
    return true, cmd
end

--------------------------------------------------------------------------------
-- DETERMINAR CONTINENTE E ZONA DO BRINQUEDO
--------------------------------------------------------------------------------
function ToyFinder:DetermineContinent(toy)
    if not toy then return "OTHER", "Various Zones" end
    
    local textToSearch = ""
    if toy.dbData and toy.dbData.zone then
        textToSearch = textToSearch .. " " .. toy.dbData.zone
    end
    if toy.zone then
        textToSearch = textToSearch .. " " .. toy.zone
    end
    if toy.sourceText then
        textToSearch = textToSearch .. " " .. toy.sourceText
    end
    if toy.name then
        textToSearch = textToSearch .. " " .. toy.name
    end
    
    local lower = string.lower(textToSearch)
    
    if Data.Continents then
        for _, cont in ipairs(Data.Continents) do
            if cont.id ~= "ALL" and cont.patterns then
                for _, pat in ipairs(cont.patterns) do
                    if string.find(lower, pat, 1, true) then
                        local zone = (toy.dbData and toy.dbData.zone) or toy.zone or cont.short
                        return cont.id, zone
                    end
                end
            end
        end
    end
    
    return "OTHER", (toy.dbData and toy.dbData.zone) or toy.zone or "Various Zones"
end

--------------------------------------------------------------------------------
-- LIMPAR TODOS OS FILTROS
--------------------------------------------------------------------------------
function ToyFinder:ResetAllFilters()
    self.activeFilter = "ALL"
    self.activeSource = "ALL"
    self.activeContinent = "ALL"
    self.activeZone = "ALL"
    self.activeDifficulty = "ALL"
    self.searchQuery = ""
    self.sortBy = "NEWEST"
    self:ApplyFilters()
    if ns.UI and ns.UI.UpdateView then
        ns.UI:UpdateView()
        if ns.UI.UpdateFilterButtonLabels then
            ns.UI:UpdateFilterButtonLabels()
        end
    end
end

--------------------------------------------------------------------------------
-- VARREDURA COMPLETA DA COLEÇÃO (SCANNER)
--------------------------------------------------------------------------------
function ToyFinder:ScanAllToys()
    if not C_ToyBox then
        print("|cffff0000ToyFinder Error:|r C_ToyBox API not found.")
        return
    end
    if self._scanning then return end

    -- Save native filter state
    local savedFilterString = C_ToyBox.GetFilterString and C_ToyBox.GetFilterString() or ""
    local savedCollected = C_ToyBox.GetCollectedShown and C_ToyBox.GetCollectedShown()
    local savedUncollected = C_ToyBox.GetUncollectedShown and C_ToyBox.GetUncollectedShown()
    local savedUnusable = C_ToyBox.GetUnusableShown and C_ToyBox.GetUnusableShown()

    -- Temporarily enable all native filters to get the full list
    if C_ToyBox.SetFilterString then C_ToyBox.SetFilterString("") end
    if C_ToyBox.SetAllExpansionTypeFilters then pcall(C_ToyBox.SetAllExpansionTypeFilters, true) end
    if C_ToyBox.SetAllSourceTypeFilters then pcall(C_ToyBox.SetAllSourceTypeFilters, true) end
    if C_ToyBox.SetCollectedShown then pcall(C_ToyBox.SetCollectedShown, true) end
    if C_ToyBox.SetUncollectedShown then pcall(C_ToyBox.SetUncollectedShown, true) end
    if C_ToyBox.SetUnusableShown then pcall(C_ToyBox.SetUnusableShown, true) end

    local totalToysCount = C_ToyBox.GetNumFilteredToys() or 0

    -- Phase 1 (fast, synchronous): only IDs + base info; restore native filters
    -- IMMEDIATELY so the game's Toy Collection state is not held during the scan
    local raw = {}
    for i = 1, totalToysCount do
        local itemID = C_ToyBox.GetToyFromIndex(i)
        if itemID and itemID > 0 then
            local _, toyName, icon, isFav, hasFanfare, quality = C_ToyBox.GetToyInfo(itemID)
            if not toyName or toyName == "" then
                if C_Item and C_Item.RequestLoadItemDataByID then
                    C_Item.RequestLoadItemDataByID(itemID)
                end
                toyName = "Toy #" .. itemID
            end
            raw[#raw + 1] = {
                itemID = itemID,
                name = toyName,
                icon = icon or "Interface\\Icons\\INV_Misc_Toy_01",
                quality = quality or 1,
                isWowFavorite = isFav,
                isCollected = PlayerHasToy(itemID),
            }
        end
    end

    if C_ToyBox.SetFilterString then C_ToyBox.SetFilterString(savedFilterString) end
    if savedCollected ~= nil and C_ToyBox.SetCollectedShown then pcall(C_ToyBox.SetCollectedShown, savedCollected) end
    if savedUncollected ~= nil and C_ToyBox.SetUncollectedShown then pcall(C_ToyBox.SetUncollectedShown, savedUncollected) end
    if savedUnusable ~= nil and C_ToyBox.SetUnusableShown then pcall(C_ToyBox.SetUnusableShown, savedUnusable) end

    -- Phase 2 (chunked via ticker so login never freezes): source + DB + continent
    self._scanning = true
    self.toys = {}
    self.toysByID = {}
    local collectedCount = 0
    local missingCount = 0
    local idx = 0
    local CHUNK = 150
    local ticker
    ticker = C_Timer.NewTicker(0, function()
        local processed = 0
        while processed < CHUNK and idx < #raw do
            idx = idx + 1
            processed = processed + 1
            local r = raw[idx]
            local itemID = r.itemID
            if r.isCollected then
                collectedCount = collectedCount + 1
            else
                missingCount = missingCount + 1
            end

            local sourceText, sourceType, dbEntry = self:ExtractToySource(itemID)

            local toyObj = {
                index = idx,
                itemID = itemID,
                name = r.name,
                icon = r.icon,
                quality = r.quality,
                isCollected = r.isCollected,
                isWowFavorite = r.isWowFavorite,
                isFavorite = ToyFinderDB.favorites[itemID] or r.isWowFavorite,
                sourceText = sourceText,
                sourceType = sourceType,
                dbData = dbEntry,
                zone = dbEntry and dbEntry.zone,
                coords = dbEntry and dbEntry.coords,
                target = dbEntry and dbEntry.target,
                cost = dbEntry and dbEntry.cost,
                difficulty = dbEntry and dbEntry.difficulty,
                waypoint = dbEntry and dbEntry.waypoint,
            }

            local continent, detectedZone = self:DetermineContinent(toyObj)
            toyObj.continent = continent
            if not toyObj.zone or toyObj.zone == "" then
                toyObj.zone = detectedZone
            end

            -- Precomputed lowercase search fields (avoids string.lower per toy per keystroke)
            toyObj.searchName = string.lower(r.name)
            toyObj.searchSource = sourceText and string.lower(sourceText) or ""
            toyObj.searchZone = toyObj.zone and string.lower(toyObj.zone) or ""
            toyObj.searchTarget = toyObj.target and string.lower(toyObj.target) or ""
            toyObj.searchCoords = toyObj.coords and string.lower(toyObj.coords) or ""
            toyObj.searchGuide = (dbEntry and dbEntry.guide) and string.lower(dbEntry.guide) or ""

            table.insert(self.toys, toyObj)
            self.toysByID[itemID] = toyObj
        end

        if idx >= #raw then
            ticker:Cancel()
            self._scanning = false
            self.stats.total = #self.toys
            self.stats.collected = collectedCount
            self.stats.missing = missingCount
            if self.stats.total > 0 then
                self.stats.percent = string.format("%.1f", (collectedCount / self.stats.total) * 100)
            else
                self.stats.percent = "0.0"
            end
            self:ApplyFilters()
            if ns.UI and ns.UI.UpdateView then
                ns.UI:UpdateView()
            end
        end
    end)
end
function ToyFinder:RefreshToyStatuses()
    local collectedCount = 0
    local missingCount = 0
    
    for _, toy in ipairs(self.toys) do
        toy.isCollected = PlayerHasToy(toy.itemID)
        toy.isFavorite = ToyFinderDB.favorites[toy.itemID] or toy.isWowFavorite or false
        if toy.isCollected then
            collectedCount = collectedCount + 1
        else
            missingCount = missingCount + 1
        end
    end
    
    self.stats.collected = collectedCount
    self.stats.missing = missingCount
    if self.stats.total > 0 then
        self.stats.percent = string.format("%.1f", (collectedCount / self.stats.total) * 100)
    end
    
    self:ApplyFilters()
    if ns.UI and ns.UI.UpdateView then
        ns.UI:UpdateView(true)
    end
end

--------------------------------------------------------------------------------
-- FILTRAGEM E ORDENAÇÃO
--------------------------------------------------------------------------------
function ToyFinder:ApplyFilters()
    self.filteredToys = {}
    local query = string.lower(trim(self.searchQuery or ""))
    
    for _, toy in ipairs(self.toys) do
        local passStatus = false
        if self.activeFilter == "ALL" then
            passStatus = true
        elseif self.activeFilter == "MISSING" then
            passStatus = (not toy.isCollected)
        elseif self.activeFilter == "COLLECTED" then
            passStatus = toy.isCollected
        elseif self.activeFilter == "FAVORITES" then
            passStatus = toy.isFavorite
        end
        
        local passSource = false
        if self.activeSource == "ALL" then
            passSource = true
        else
            passSource = (toy.sourceType == self.activeSource)
        end

        local passContinent = false
        if self.activeContinent == "ALL" then
            passContinent = true
        else
            passContinent = (toy.continent == self.activeContinent)
        end
        
        local passZone = false
        if self.activeZone == "ALL" or self.activeZone == "All Zones" or self.activeZone == "" then
            passZone = true
        else
            local targetZone = string.lower(self.activeZone)
            local toyZone = string.lower(toy.zone or "")
            local toySrc = string.lower(toy.sourceText or "")
            passZone = (string.find(toyZone, targetZone, 1, true) ~= nil) or (string.find(toySrc, targetZone, 1, true) ~= nil)
        end
        
        local passDifficulty = false
        if self.activeDifficulty == "ALL" then
            passDifficulty = true
        elseif self.activeDifficulty == "EASY" then
            passDifficulty = (toy.sourceType == "VENDOR" or toy.sourceType == "STORE" or toy.sourceType == "TRADING_POST")
        elseif self.activeDifficulty == "QUEST" then
            passDifficulty = (toy.sourceType == "QUEST")
        elseif self.activeDifficulty == "EXPLORE" then
            passDifficulty = (toy.sourceType == "TREASURE")
        elseif self.activeDifficulty == "FARM" then
            passDifficulty = (toy.sourceType == "LOOT")
        elseif self.activeDifficulty == "EVENT" then
            passDifficulty = (toy.sourceType == "EVENT")
        elseif self.activeDifficulty == "OTHER" then
            passDifficulty = (toy.sourceType == "ACHIEVEMENT" or toy.sourceType == "PROFESSION" or toy.sourceType == "OTHER")
        else
            passDifficulty = true
        end
        
        local passSearch = true
        if query ~= "" then
            -- usa os campos precomputados em minúsculas (search*), sem alocar strings novas
            local nameMatch = string.find(toy.searchName or "", query, 1, true)
            local idMatch = string.find(tostring(toy.itemID), query, 1, true)
            local sourceMatch = string.find(toy.searchSource or "", query, 1, true)
            local zoneMatch = string.find(toy.searchZone or "", query, 1, true)
            local targetMatch = string.find(toy.searchTarget or "", query, 1, true)
            local coordsMatch = string.find(toy.searchCoords or "", query, 1, true)
            local guideMatch = string.find(toy.searchGuide or "", query, 1, true)
            passSearch = (nameMatch or idMatch or sourceMatch or zoneMatch or targetMatch or coordsMatch or guideMatch)
        end
        
        if passStatus and passSource and passContinent and passZone and passDifficulty and passSearch then
            table.insert(self.filteredToys, toy)
        end
    end
    
    -- Ordenação
    if self.sortBy == "NAME" then
        table.sort(self.filteredToys, function(a, b)
            return (a.name or "") < (b.name or "")
        end)
    elseif self.sortBy == "NEWEST" then
        -- IDs mais altos correspondem aos itens adicionados mais recentemente (Midnight e The War Within)
        table.sort(self.filteredToys, function(a, b)
            return (a.itemID or 0) > (b.itemID or 0)
        end)
    elseif self.sortBy == "QUALITY" then
        table.sort(self.filteredToys, function(a, b)
            if a.quality ~= b.quality then
                return (a.quality or 0) > (b.quality or 0)
            end
            return (a.name or "") < (b.name or "")
        end)
    elseif self.sortBy == "STATUS" then
        table.sort(self.filteredToys, function(a, b)
            if a.isCollected ~= b.isCollected then
                return not a.isCollected -- Missing primeiro
            end
            return (a.name or "") < (b.name or "")
        end)
    end
end

--------------------------------------------------------------------------------
-- EVENTOS DO WOW (despacho por tabela, sem cadeias if/elseif)
--------------------------------------------------------------------------------
local eventHandlers = {
    ADDON_LOADED = function(addon)
        -- SavedVariables só são seguras depois deste evento
        if addon == addonName then
            ToyFinder:InitializeDB()
        end
    end,
    PLAYER_LOGIN = function()
        -- Pequeno delay para garantir que o cliente carregou a base de itens
        C_Timer.After(1.5, function()
            ToyFinder:ScanAllToys()
        end)
    end,
    TOYS_UPDATED = function()
        ToyFinder:RefreshToyStatuses()
    end,
}

local eventFrame = CreateFrame("Frame")
for eventName in pairs(eventHandlers) do
    eventFrame:RegisterEvent(eventName)
end
eventFrame:SetScript("OnEvent", function(self, event, ...)
    local handler = eventHandlers[event]
    if handler then
        handler(...)
    end
end)

--------------------------------------------------------------------------------
-- COMANDOS SLASH (/toyfinder, /tf, /toys)
--------------------------------------------------------------------------------
SLASH_TOYFINDER1 = "/toyfinder"
SLASH_TOYFINDER2 = "/tf"
SLASH_TOYFINDER3 = "/toys"

SlashCmdList["TOYFINDER"] = function(msg)
    local cmd = string.lower(trim(msg or ""))
    
    if cmd == "scan" or cmd == "atualizar" then
        print("|cff9d4eddToyFinder:|r " .. L.SCANNING)
        ToyFinder:ScanAllToys()
        print("|cff9d4eddToyFinder:|r " .. string.format(L.SCAN_COMPLETE, ToyFinder.stats.total, ToyFinder.stats.collected, ToyFinder.stats.missing))
    elseif cmd == "missing" or cmd == "falta" then
        ToyFinder.activeFilter = "MISSING"
        ToyFinder:ApplyFilters()
        if ns.UI then
            local f = ns.UI:CreateMainFrame()
            if f and not f:IsShown() then
                ns.UI:Toggle()
            else
                ns.UI:UpdateView()
            end
        end
    elseif cmd == "help" or cmd == "ajuda" then
        print("|cff9d4edd--- ToyFinder Commands ---|r")
        print("|cff00e5ff/tf|r or |cff00e5ff/toyfinder|r - Opens or closes the main window.")
        print("|cff00e5ff/tf scan|r - Force a re-scan of the Toy Collection.")
        print("|cff00e5ff/tf missing|r - Opens the window filtered to Missing toys.")
    else
        if ns.UI then
            ns.UI:Toggle()
        end
    end
end
