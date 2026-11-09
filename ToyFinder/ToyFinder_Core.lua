--[[
    ToyFinder - Core Engine
    Varredura de Brinquedos, Extração de Fontes, Categorização e Integração WoWhead
]]

ToyFinder = ToyFinder or {}
local L = ToyFinderLocales
local Data = ToyFinderData

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
function ToyFinder:ClassifySourceType(text)
    if not text or text == "" then
        return "OTHER"
    end
    
    local lowerText = string.lower(text)
    
    -- Testa primeiro os tipos mais específicos, por ordem de prioridade fixa
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
    if not itemID then return "Fonte desconhecida", "OTHER", nil end
    
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
                local text = line.leftText
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
                local text = left:GetText()
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
    
    local finalSource = rawSourceText or "Ver no WoWhead (Drop, Vendedor ou Tesouro)"
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
    if not toy then return false, "Nenhum brinquedo selecionado" end
    
    local cmd = toy.waypoint
    if not cmd and toy.zone and toy.coords then
        cmd = string.format("/way %s %s %s", toy.zone, toy.coords, toy.name or "")
    end
    
    if not cmd or cmd == "" then
        return false, "Este brinquedo não tem coordenadas de mapa específicas (pode ser drop mundial ou conquista)."
    end

    -- Se o TomTom estiver carregado, define a seta de navegação imediatamente!
    local cleanArgs = cmd:gsub("^/way%s+", "")
    if SlashCmdList["TOMTOM_WAY"] then
        SlashCmdList["TOMTOM_WAY"](cleanArgs)
        print("|cff00e5ffToyFinder [TomTom]:|r Seta criada no mapa para |cffffd200" .. (toy.name or "") .. "|r! (" .. cleanArgs .. ")")
        PlaySound(SOUNDKIT.MAP_PING)
        return true, "Ponto adicionado ao TomTom com sucesso!"
    end

    -- Se o TomTom não estiver instalado, mostra a instrução no chat
    print("|cff9d4eddToyFinder Coordenadas:|r |cffffd200" .. cmd .. "|r")
    print("|cffaaaaaaDica: Se instalares o addon TomTom, esta coordenada cria automaticamente uma seta no teu ecrã!|r")
    return true, cmd
end

--------------------------------------------------------------------------------
-- DETERMINAR CONTINENTE E ZONA DO BRINQUEDO
--------------------------------------------------------------------------------
function ToyFinder:DetermineContinent(toy)
    if not toy then return "OTHER", "Várias Zonas" end
    
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
    
    return "OTHER", (toy.dbData and toy.dbData.zone) or toy.zone or "Várias Zonas"
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
    if ToyFinderUI and ToyFinderUI.UpdateView then
        ToyFinderUI:UpdateView()
        if ToyFinderUI.UpdateFilterButtonLabels then
            ToyFinderUI:UpdateFilterButtonLabels()
        end
    end
end

--------------------------------------------------------------------------------
-- VARREDURA COMPLETA DA COLEÇÃO (SCANNER)
--------------------------------------------------------------------------------
function ToyFinder:ScanAllToys()
    if not C_ToyBox then
        print("|cffff0000ToyFinder Erro:|r C_ToyBox API não encontrada.")
        return
    end

    -- Salva o estado dos filtros nativos do jogador na Coleção do WoW
    local savedFilterString = C_ToyBox.GetFilterString and C_ToyBox.GetFilterString() or ""
    local savedCollected = C_ToyBox.GetCollectedShown and C_ToyBox.GetCollectedShown()
    local savedUncollected = C_ToyBox.GetUncollectedShown and C_ToyBox.GetUncollectedShown()
    local savedUnusable = C_ToyBox.GetUnusableShown and C_ToyBox.GetUnusableShown()
    
    -- Habilita temporariamente todos os filtros para obter a lista total
    if C_ToyBox.SetFilterString then C_ToyBox.SetFilterString("") end
    if C_ToyBox.SetAllExpansionTypeFilters then pcall(C_ToyBox.SetAllExpansionTypeFilters, true) end
    if C_ToyBox.SetAllSourceTypeFilters then pcall(C_ToyBox.SetAllSourceTypeFilters, true) end
    if C_ToyBox.SetCollectedShown then pcall(C_ToyBox.SetCollectedShown, true) end
    if C_ToyBox.SetUncollectedShown then pcall(C_ToyBox.SetUncollectedShown, true) end
    if C_ToyBox.SetUnusableShown then pcall(C_ToyBox.SetUnusableShown, true) end
    
    local totalToysCount = C_ToyBox.GetNumFilteredToys() or 0
    
    self.toys = {}
    self.toysByID = {}
    local collectedCount = 0
    local missingCount = 0
    
    for i = 1, totalToysCount do
        local itemID = C_ToyBox.GetToyFromIndex(i)
        if itemID and itemID > 0 then
            local _, toyName, icon, isFav, hasFanfare, quality = C_ToyBox.GetToyInfo(itemID)
            local isCollected = PlayerHasToy(itemID)
            
            if isCollected then
                collectedCount = collectedCount + 1
            else
                missingCount = missingCount + 1
            end
            
            -- Se o nome ou ícone ainda não vieram do servidor, tenta pedir preload
            if not toyName or toyName == "" then
                if C_Item and C_Item.RequestLoadItemDataByID then
                    C_Item.RequestLoadItemDataByID(itemID)
                end
                toyName = "Brinquedo #" .. itemID
            end
            
            icon = icon or "Interface\\Icons\\INV_Misc_Toy_01"
            quality = quality or 1
            
            -- Extração rápida da fonte
            local sourceText, sourceType, dbEntry = self:ExtractToySource(itemID)
            
            -- Verifica se está nas favoritas do addon
            local isCustomFav = ToyFinderDB.favorites[itemID] or isFav
            
            local toyObj = {
                index = i,
                itemID = itemID,
                name = toyName,
                icon = icon,
                quality = quality,
                isCollected = isCollected,
                isWowFavorite = isFav,
                isFavorite = isCustomFav,
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
            
            -- Deteção automática de Continente e Zona
            local continent, detectedZone = self:DetermineContinent(toyObj)
            toyObj.continent = continent
            if not toyObj.zone or toyObj.zone == "" then
                toyObj.zone = detectedZone
            end
            
            table.insert(self.toys, toyObj)
            self.toysByID[itemID] = toyObj
        end
    end
    
    -- Restaura os filtros nativos do jogador com segurança
    if C_ToyBox.SetFilterString then C_ToyBox.SetFilterString(savedFilterString) end
    if savedCollected ~= nil and C_ToyBox.SetCollectedShown then pcall(C_ToyBox.SetCollectedShown, savedCollected) end
    if savedUncollected ~= nil and C_ToyBox.SetUncollectedShown then pcall(C_ToyBox.SetUncollectedShown, savedUncollected) end
    if savedUnusable ~= nil and C_ToyBox.SetUnusableShown then pcall(C_ToyBox.SetUnusableShown, savedUnusable) end
    
    -- Atualiza estatísticas
    self.stats.total = #self.toys
    self.stats.collected = collectedCount
    self.stats.missing = missingCount
    if self.stats.total > 0 then
        self.stats.percent = string.format("%.1f", (collectedCount / self.stats.total) * 100)
    else
        self.stats.percent = "0.0"
    end
    
    -- Aplica filtros atuais e atualiza interface
    self:ApplyFilters()
    if ToyFinderUI and ToyFinderUI.UpdateView then
        ToyFinderUI:UpdateView()
    end
end

--------------------------------------------------------------------------------
-- ATUALIZAÇÃO RÁPIDA DE STATUS (Sem recarregar tudo)
--------------------------------------------------------------------------------
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
    if ToyFinderUI and ToyFinderUI.UpdateView then
        ToyFinderUI:UpdateView(true)
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
        if self.activeZone == "ALL" or self.activeZone == "Todas as Zonas" or self.activeZone == "" then
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
            local nameMatch = toy.name and string.find(string.lower(toy.name), query, 1, true)
            local idMatch = tostring(toy.itemID) == query or string.find(tostring(toy.itemID), query, 1, true)
            local sourceMatch = toy.sourceText and string.find(string.lower(toy.sourceText), query, 1, true)
            local zoneMatch = toy.zone and string.find(string.lower(toy.zone), query, 1, true)
            local targetMatch = toy.target and string.find(string.lower(toy.target), query, 1, true)
            local coordsMatch = toy.coords and string.find(string.lower(toy.coords), query, 1, true)
            local guideMatch = toy.dbData and toy.dbData.guide and string.find(string.lower(toy.dbData.guide), query, 1, true)
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
-- EVENTOS DO WOW
--------------------------------------------------------------------------------
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("TOYS_UPDATED")

eventFrame:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "ADDON_LOADED" and arg1 == "ToyFinder" then
        ToyFinder:InitializeDB()
    elseif event == "PLAYER_LOGIN" then
        -- Pequeno delay para garantir que o cliente carregou a base de itens
        C_Timer.After(1.5, function()
            ToyFinder:ScanAllToys()
        end)
    elseif event == "TOYS_UPDATED" then
        ToyFinder:RefreshToyStatuses()
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
        if ToyFinderUI then
            local f = ToyFinderUI:CreateMainFrame()
            if f and not f:IsShown() then
                ToyFinderUI:Toggle()
            else
                ToyFinderUI:UpdateView()
            end
        end
    elseif cmd == "help" or cmd == "ajuda" then
        print("|cff9d4edd--- ToyFinder Comandos ---|r")
        print("|cff00e5ff/tf|r ou |cff00e5ff/toyfinder|r - Abre ou fecha a janela principal.")
        print("|cff00e5ff/tf scan|r - Força uma re-varredura da Coleção de Brinquedos.")
        print("|cff00e5ff/tf missing|r - Abre diretamente filtrado nos Brinquedos em falta.")
    else
        if ToyFinderUI then
            ToyFinderUI:Toggle()
        end
    end
end
