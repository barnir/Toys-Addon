--[[
    ToyFinder - Modern User Interface (Midnight & Retail Ready)
    Interface visual completa com lista virtualizada, filtros, detalhes de fontes e modal WoWhead
]]

local addonName, ns = ...
ns.UI = ns.UI or {}
local ToyFinderUI = ns.UI
local ToyFinder = ns.ToyFinder
local L = ns.L
local Data = ns.Data

local mainFrame = nil
local rowFrames = {}
local VISIBLE_ROWS = 9
local ROW_HEIGHT = 46

-- Paleta de cores temática Midnight
local COLORS = {
    bg = { r = 0.08, g = 0.05, b = 0.14, a = 0.95 },
    panelBg = { r = 0.05, g = 0.03, b = 0.09, a = 0.85 },
    border = { r = 0.62, g = 0.31, b = 0.87, a = 0.8 },
    accentPurple = { r = 0.62, g = 0.31, b = 0.87 },
    accentCyan = { r = 0.0, g = 0.90, b = 1.0 },
    gold = { r = 1.0, g = 0.82, b = 0.0 },
    green = { r = 0.23, g = 0.89, b = 0.45 },
    red = { r = 1.0, g = 0.32, b = 0.32 },
    rowHover = { r = 0.25, g = 0.15, b = 0.38, a = 0.4 },
    rowSelected = { r = 0.35, g = 0.20, b = 0.55, a = 0.6 }
}

--------------------------------------------------------------------------------
-- SISTEMA DE DROPDOWN CUSTOMIZADO (MIDNIGHT STYLE)
--------------------------------------------------------------------------------
local dropdownMenu = nil
local DROPDOWN_VISIBLE = 11
local DROPDOWN_ITEM_HEIGHT = 24

function ToyFinderUI:GetOrCreateDropdown()
    if dropdownMenu then return dropdownMenu end
    
    local d = CreateFrame("Frame", "ToyFinderDropdownFrame", UIParent, "BackdropTemplate")
    d:SetSize(230, 280)
    d:SetFrameStrata("FULLSCREEN_DIALOG")
    d:SetClampedToScreen(true)
    d:EnableMouse(true)
    d:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 2,
    })
    d:SetBackdropColor(0.06, 0.04, 0.12, 0.98)
    d:SetBackdropBorderColor(COLORS.accentCyan.r, COLORS.accentCyan.g, COLORS.accentCyan.b, 1)
    d:Hide()

    local title = d:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    title:SetPoint("TOPLEFT", d, "TOPLEFT", 10, -8)
    title:SetPoint("TOPRIGHT", d, "TOPRIGHT", -10, -8)
    title:SetJustifyH("LEFT")
    title:SetText("Selecionar Filtro")
    d.title = title

    local line = d:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
    line:SetPoint("TOPRIGHT", title, "BOTTOMRIGHT", 0, -4)
    line:SetHeight(1)
    line:SetTexture("Interface\\Buttons\\WHITE8X8")
    line:SetVertexColor(0.35, 0.22, 0.5, 0.8)

    local scrollBar = CreateFrame("Slider", "ToyFinderDropdownScrollBar", d, "UIPanelScrollBarTemplate")
    scrollBar:SetPoint("TOPRIGHT", d, "TOPRIGHT", -4, -28)
    scrollBar:SetPoint("BOTTOMRIGHT", d, "BOTTOMRIGHT", -4, 14)
    scrollBar:SetWidth(14)
    scrollBar:SetMinMaxValues(1, 1)
    scrollBar:SetValue(1)
    scrollBar:SetValueStep(1)
    d.scrollBar = scrollBar

    scrollBar:SetScript("OnValueChanged", function(self, value)
        ToyFinderUI:UpdateDropdownItems(math.floor(value))
    end)

    d:EnableMouseWheel(true)
    d:SetScript("OnMouseWheel", function(self, delta)
        local cur = scrollBar:GetValue()
        local minVal, maxVal = scrollBar:GetMinMaxValues()
        local newVal = cur - delta
        if newVal < minVal then newVal = minVal end
        if newVal > maxVal then newVal = maxVal end
        scrollBar:SetValue(newVal)
    end)

    d.itemButtons = {}
    for i = 1, DROPDOWN_VISIBLE do
        local btn = CreateFrame("Button", nil, d, "BackdropTemplate")
        btn:SetSize(205, DROPDOWN_ITEM_HEIGHT)
        btn:SetPoint("TOPLEFT", d, "TOPLEFT", 6, -28 - ((i - 1) * DROPDOWN_ITEM_HEIGHT))
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
        })
        btn:SetBackdropColor(0, 0, 0, 0)

        local check = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        check:SetPoint("LEFT", btn, "LEFT", 4, 0)
        check:SetWidth(14)
        check:SetText("")
        btn.check = check

        local label = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        label:SetPoint("LEFT", check, "RIGHT", 4, 0)
        label:SetPoint("RIGHT", btn, "RIGHT", -4, 0)
        label:SetJustifyH("LEFT")
        label:SetWordWrap(false)
        btn.label = label

        btn:SetScript("OnEnter", function(self)
            self:SetBackdropColor(0.28, 0.16, 0.45, 0.9)
        end)
        btn:SetScript("OnLeave", function(self)
            self:SetBackdropColor(0, 0, 0, 0)
        end)
        btn:SetScript("OnClick", function(self)
            if self.data and d.onSelect then
                d.onSelect(self.data)
                d:Hide()
                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
            end
        end)

        d.itemButtons[i] = btn
    end

    local catcher = CreateFrame("Button", nil, UIParent)
    catcher:SetAllPoints(UIParent)
    catcher:SetFrameStrata("FULLSCREEN")
    catcher:Hide()
    d.catcher = catcher

    catcher:SetScript("OnClick", function()
        d:Hide()
        catcher:Hide()
    end)

    d:SetScript("OnHide", function()
        catcher:Hide()
    end)

    dropdownMenu = d
    return d
end

function ToyFinderUI:ToggleDropdown(anchorBtn, titleText, items, selectedID, onSelectCallback)
    local d = self:GetOrCreateDropdown()
    
    if d:IsShown() and d.currentAnchor == anchorBtn then
        d:Hide()
        return
    end

    d.currentAnchor = anchorBtn
    d.title:SetText(titleText or "Filtro")
    d.items = items or {}
    d.selectedID = selectedID
    d.onSelect = onSelectCallback

    d:ClearAllPoints()
    d:SetPoint("TOPLEFT", anchorBtn, "BOTTOMLEFT", 0, -2)

    local total = #d.items
    local height = math.min(DROPDOWN_VISIBLE, total) * DROPDOWN_ITEM_HEIGHT + 38
    d:SetHeight(height)

    local maxOffset = math.max(1, total - DROPDOWN_VISIBLE + 1)
    d.scrollBar:SetMinMaxValues(1, maxOffset)
    d.scrollBar:SetValue(1)
    if total <= DROPDOWN_VISIBLE then
        d.scrollBar:Hide()
    else
        d.scrollBar:Show()
    end

    self:UpdateDropdownItems(1)

    d.catcher:Show()
    d:Show()
end

function ToyFinderUI:UpdateDropdownItems(offset)
    local d = dropdownMenu
    if not d or not d.items then return end
    
    offset = offset or 1
    local total = #d.items

    for i = 1, DROPDOWN_VISIBLE do
        local btn = d.itemButtons[i]
        local idx = offset + i - 1
        if idx <= total then
            local item = d.items[idx]
            btn.data = item
            btn:Show()

            local isSelected = (item.id == d.selectedID or item.name == d.selectedID)
            btn.check:SetText(isSelected and "|cff00e5ff✓|r" or "  ")
            
            local colorHex = item.color or "ffffff"
            btn.label:SetText(string.format("|cff%s%s|r", colorHex, item.name or item.text or ""))
        else
            btn.data = nil
            btn:Hide()
        end
    end
end

--------------------------------------------------------------------------------
-- CRIAÇÃO DO PAINEL PRINCIPAL
--------------------------------------------------------------------------------
function ToyFinderUI:CreateMainFrame()
    if mainFrame then return mainFrame end

    local f = CreateFrame("Frame", "ToyFinderMainFrame", UIParent, "BackdropTemplate")
    f:SetSize(960, 670)
    f:SetClampedToScreen(true)
    
    -- Restaurar posição salva da janela se existir
    if ToyFinderDB and ToyFinderDB.settings and ToyFinderDB.settings.windowPos then
        local pos = ToyFinderDB.settings.windowPos
        f:SetPoint(pos.point or "CENTER", UIParent, pos.point or "CENTER", pos.x or 0, pos.y or 0)
    else
        f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
    
    f:SetFrameStrata("HIGH")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, _, x, y = self:GetPoint()
        if ToyFinderDB and ToyFinderDB.settings then
            ToyFinderDB.settings.windowPos = { point = point, x = x, y = y }
        end
    end)
    
    -- Fechar com tecla ESC
    table.insert(UISpecialFrames, "ToyFinderMainFrame")
    
    -- Fundo e bordas temáticas Midnight
    f:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 2,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    f:SetBackdropColor(COLORS.bg.r, COLORS.bg.g, COLORS.bg.b, COLORS.bg.a)
    f:SetBackdropBorderColor(COLORS.border.r, COLORS.border.g, COLORS.border.b, COLORS.border.a)

    -- Cabeçalho / Barra de Título
    local header = CreateFrame("Frame", nil, f, "BackdropTemplate")
    header:SetPoint("TOPLEFT", f, "TOPLEFT", 4, -4)
    header:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)
    header:SetHeight(48)
    header:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    header:SetBackdropColor(0.12, 0.08, 0.22, 0.9)

    -- Ícone no título
    local titleIcon = header:CreateTexture(nil, "ARTWORK")
    titleIcon:SetSize(30, 30)
    titleIcon:SetPoint("LEFT", header, "LEFT", 12, 0)
    titleIcon:SetTexture("Interface\\Icons\\INV_Misc_Toy_01")
    titleIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    -- Título
    local titleText = header:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    titleText:SetPoint("LEFT", titleIcon, "RIGHT", 10, 4)
    titleText:SetText("|cff9d4eddToy|r|cff00e5ffFinder|r |cffffd200Midnight|r")

    -- Subtítulo
    local subText = header:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    subText:SetPoint("LEFT", titleIcon, "RIGHT", 10, -10)
    subText:SetText(L.SUBTITLE)

    -- Botão Fechar [X]
    local closeBtn = CreateFrame("Button", nil, header, "UIPanelCloseButton")
    closeBtn:SetPoint("RIGHT", header, "RIGHT", -6, 0)
    closeBtn:SetScript("OnClick", function()
        f:Hide()
        PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
    end)

    -- Botão Atualizar [🔄]
    local refreshBtn = CreateFrame("Button", nil, header, "BackdropTemplate")
    refreshBtn:SetSize(110, 26)
    refreshBtn:SetPoint("RIGHT", closeBtn, "LEFT", -8, 0)
    refreshBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    refreshBtn:SetBackdropColor(0.2, 0.15, 0.35, 0.9)
    refreshBtn:SetBackdropBorderColor(0.5, 0.3, 0.8, 1)
    
    local refreshText = refreshBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    refreshText:SetPoint("CENTER", refreshBtn, "CENTER", 0, 0)
    refreshText:SetText(L.REFRESH_BTN)
    
    refreshBtn:SetScript("OnClick", function()
        ToyFinder:ScanAllToys()
        PlaySound(SOUNDKIT.IG_QUEST_LOG_OPEN)
    end)
    refreshBtn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.35, 0.25, 0.6, 1)
    end)
    refreshBtn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.2, 0.15, 0.35, 0.9)
    end)

    ----------------------------------------------------------------------------
    -- BARRA DE PROGRESSO & ESTATÍSTICAS
    ----------------------------------------------------------------------------
    local progressContainer = CreateFrame("Frame", nil, f, "BackdropTemplate")
    progressContainer:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 8, -6)
    progressContainer:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", -8, -6)
    progressContainer:SetHeight(30)
    progressContainer:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    progressContainer:SetBackdropColor(0.04, 0.03, 0.08, 0.9)
    progressContainer:SetBackdropBorderColor(0.25, 0.18, 0.35, 1)

    local progressBar = CreateFrame("StatusBar", nil, progressContainer)
    progressBar:SetPoint("TOPLEFT", progressContainer, "TOPLEFT", 2, -2)
    progressBar:SetPoint("BOTTOMRIGHT", progressContainer, "BOTTOMRIGHT", -2, 2)
    progressBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    progressBar:SetStatusBarColor(0.55, 0.25, 0.85, 0.9)
    progressBar:SetMinMaxValues(0, 100)
    progressBar:SetValue(0)
    f.progressBar = progressBar

    local progressText = progressContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightMedium")
    progressText:SetPoint("CENTER", progressContainer, "CENTER", 0, 0)
    progressText:SetText("A carregar coleção de brinquedos...")
    f.progressText = progressText

    ----------------------------------------------------------------------------
    -- BARRA DE FILTROS (Todas, Em Falta, Obtidas, Favoritas)
    ----------------------------------------------------------------------------
    local filterBar = CreateFrame("Frame", nil, f)
    filterBar:SetPoint("TOPLEFT", progressContainer, "BOTTOMLEFT", 0, -8)
    filterBar:SetPoint("TOPRIGHT", progressContainer, "BOTTOMRIGHT", 0, -8)
    filterBar:SetHeight(34)

    local function CreateTabButton(parent, label, filterType, width)
        local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
        btn:SetSize(width or 120, 30)
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
        })
        btn.filterType = filterType
        
        local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("CENTER", btn, "CENTER", 0, 0)
        text:SetText(label)
        btn.label = text
        btn.baseLabel = label

        btn:SetScript("OnClick", function(self)
            ToyFinder.activeFilter = self.filterType
            ToyFinderUI:UpdateTabHighlight()
            ToyFinder:ApplyFilters()
            ToyFinderUI:UpdateView()
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        end)
        
        return btn
    end

    f.tabAll = CreateTabButton(filterBar, L.FILTER_ALL, "ALL", 110)
    f.tabAll:SetPoint("LEFT", filterBar, "LEFT", 0, 0)

    f.tabMissing = CreateTabButton(filterBar, "|cffff5252" .. L.FILTER_MISSING .. "|r", "MISSING", 130)
    f.tabMissing:SetPoint("LEFT", f.tabAll, "RIGHT", 6, 0)

    f.tabCollected = CreateTabButton(filterBar, "|cff3ae374" .. L.FILTER_COLLECTED .. "|r", "COLLECTED", 120)
    f.tabCollected:SetPoint("LEFT", f.tabMissing, "RIGHT", 6, 0)

    f.tabFavorites = CreateTabButton(filterBar, "|cffffd200" .. L.FILTER_FAVORITES .. "|r", "FAVORITES", 110)
    f.tabFavorites:SetPoint("LEFT", f.tabCollected, "RIGHT", 6, 0)

    -- Contador de resultados da filtragem atual
    local resultsLabel = filterBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    resultsLabel:SetPoint("LEFT", f.tabFavorites, "RIGHT", 14, 0)
    f.resultsLabel = resultsLabel

    -- Botão Limpar Filtros
    local resetBtn = CreateFrame("Button", nil, filterBar, "BackdropTemplate")
    resetBtn:SetSize(115, 30)
    resetBtn:SetPoint("RIGHT", filterBar, "RIGHT", -110, 0)
    resetBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    resetBtn:SetBackdropColor(0.22, 0.08, 0.12, 0.9)
    resetBtn:SetBackdropBorderColor(0.7, 0.2, 0.3, 1)

    local resetText = resetBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    resetText:SetPoint("CENTER", resetBtn, "CENTER", 0, 0)
    resetText:SetText("|cffff5252✕ Limpar Filtros|r")

    resetBtn:SetScript("OnClick", function()
        ToyFinder:ResetAllFilters()
        if f.searchBox then f.searchBox:SetText("") end
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
    end)
    resetBtn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.35, 0.12, 0.18, 1)
    end)
    resetBtn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.22, 0.08, 0.12, 0.9)
    end)

    -- Toggle de Idioma do WoWhead (PT / EN)
    local langBtn = CreateFrame("Button", nil, filterBar, "BackdropTemplate")
    langBtn:SetSize(100, 30)
    langBtn:SetPoint("RIGHT", filterBar, "RIGHT", 0, 0)
    langBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    langBtn:SetBackdropColor(0.18, 0.12, 0.28, 0.9)
    langBtn:SetBackdropBorderColor(0.4, 0.25, 0.6, 1)

    local langText = langBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    langText:SetPoint("CENTER", langBtn, "CENTER", 0, 0)
    langText:SetText(ToyFinder.preferredWoWhead == "pt" and "🌐 WoWhead PT" or "🌐 WoWhead EN")
    f.langText = langText

    langBtn:SetScript("OnClick", function()
        if ToyFinder.preferredWoWhead == "pt" then
            ToyFinder.preferredWoWhead = "en"
            langText:SetText("🌐 WoWhead EN")
        else
            ToyFinder.preferredWoWhead = "pt"
            langText:SetText("🌐 WoWhead PT")
        end
        if ToyFinderDB and ToyFinderDB.settings then
            ToyFinderDB.settings.preferredWoWhead = ToyFinder.preferredWoWhead
        end
        ToyFinderUI:UpdateSelectedToyDetails()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end)

    ----------------------------------------------------------------------------
    -- SEGUNDA LINHA DE CONTROLOS: FILTROS AVANÇADOS (Obtenção, Continente, Zona, Dificuldade)
    ----------------------------------------------------------------------------
    local subControls = CreateFrame("Frame", nil, f)
    subControls:SetPoint("TOPLEFT", filterBar, "BOTTOMLEFT", 0, -6)
    subControls:SetPoint("TOPRIGHT", filterBar, "BOTTOMRIGHT", 0, -6)
    subControls:SetHeight(32)

    local function CreateFilterDropdownBtn(parent, defaultText, width, pointLeft, offsetX)
        local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
        btn:SetSize(width, 30)
        btn:SetPoint("LEFT", pointLeft, pointLeft == parent and "LEFT" or "RIGHT", offsetX, 0)
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
        })
        btn:SetBackdropColor(0.14, 0.10, 0.22, 0.9)
        btn:SetBackdropBorderColor(0.4, 0.25, 0.6, 1)

        local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        btnText:SetPoint("LEFT", btn, "LEFT", 8, 0)
        btnText:SetPoint("RIGHT", btn, "RIGHT", -8, 0)
        btnText:SetJustifyH("LEFT")
        btnText:SetWordWrap(false)
        btnText:SetText(defaultText)
        btn.btnText = btnText

        btn:SetScript("OnEnter", function(self)
            self:SetBackdropColor(0.24, 0.16, 0.38, 1)
        end)
        btn:SetScript("OnLeave", function(self)
            self:SetBackdropColor(0.14, 0.10, 0.22, 0.9)
        end)

        return btn
    end

    -- 1. Botão Forma de Obtenção (Vendedores, Loot, Tesouros, Missões, etc.)
    local sourceBtn = CreateFilterDropdownBtn(subControls, "📦 Obtenção: Todas ▼", 145, subControls, 0)
    f.sourceBtn = sourceBtn
    f.sourceBtnText = sourceBtn.btnText

    local sourceItems = {
        { id = "ALL", name = "Todas as Formas de Obtenção", color = "ffffff" },
        { id = "VENDOR", name = "💰 Vendedores (Compra Direta)", color = "ffd200" },
        { id = "TREASURE", name = "📦 Tesouros (Baús e Puzzles)", color = "00e5ff" },
        { id = "LOOT", name = "⚔️ Saques / Loot (Chefes e Raros)", color = "ff5252" },
        { id = "QUEST", name = "📜 Missões e Campanhas", color = "ffb142" },
        { id = "ACHIEVEMENT", name = "🏆 Conquistas", color = "c56cf0" },
        { id = "EVENT", name = "🎪 Eventos Mundiais e Feriados", color = "3ae374" },
        { id = "PROFESSION", name = "⚙️ Profissões (Criação)", color = "17c0eb" },
        { id = "TRADING_POST", name = "🏛️ Posto de Trocas", color = "e15f41" },
        { id = "STORE", name = "🏪 Loja / Promoções (Blizzard)", color = "7158e2" },
        { id = "OTHER", name = "⚪ Outros / Diversos", color = "a4b0be" },
    }

    sourceBtn:SetScript("OnClick", function(self)
        local counts = ToyFinderUI:GetFilterCounts()
        local items = ToyFinderUI:AddCountsToItems(sourceItems, counts.source, counts.total)
        ToyFinderUI:ToggleDropdown(self, "Forma de Obtenção", items, ToyFinder.activeSource, function(item)
            ToyFinder.activeSource = item.id
            ToyFinderUI:UpdateFilterButtonLabels()
            ToyFinder:ApplyFilters()
            ToyFinderUI:UpdateView()
        end)
    end)

    -- 2. Botão Continente / Expansão
    local continentBtn = CreateFilterDropdownBtn(subControls, "🌍 Continente: Todos ▼", 150, sourceBtn, 5)
    f.continentBtn = continentBtn
    f.continentBtnText = continentBtn.btnText

    continentBtn:SetScript("OnClick", function(self)
        local counts = ToyFinderUI:GetFilterCounts()
        local items = ToyFinderUI:AddCountsToItems(Data.Continents, counts.continent, counts.total)
        ToyFinderUI:ToggleDropdown(self, "Continente / Expansão", items, ToyFinder.activeContinent, function(item)
            ToyFinder.activeContinent = item.id
            -- Reset zona ao trocar de continente
            ToyFinder.activeZone = "ALL"
            ToyFinderUI:UpdateFilterButtonLabels()
            ToyFinder:ApplyFilters()
            ToyFinderUI:UpdateView()
        end)
    end)

    -- 3. Botão Zona
    local zoneBtn = CreateFilterDropdownBtn(subControls, "📍 Zona: Todas ▼", 135, continentBtn, 5)
    f.zoneBtn = zoneBtn
    f.zoneBtnText = zoneBtn.btnText

    local function GetCurrentZoneList()
        local list = { { id = "ALL", name = "Todas as Zonas", color = "ffffff" } }
        if ToyFinder.activeContinent ~= "ALL" then
            for _, c in ipairs(Data.Continents) do
                if c.id == ToyFinder.activeContinent and c.zones then
                    for _, z in ipairs(c.zones) do
                        if z ~= "Todas as Zonas" then
                            table.insert(list, { id = z, name = z, color = c.color or "ffffff" })
                        end
                    end
                end
            end
        else
            local popularZones = {
                "Dornogal", "Ilha de Dorn", "Hallowfall", "Azj-Kahet", "O Fosso Profundo",
                "Valdrakken", "Costas Despertas", "Planícies de Ohn'ahra", "Vastalguém",
                "Oribos", "Revendreth", "Ardenweald", "Maldraxxus", "Bastião",
                "Zuldazar", "Dazar'alor", "Mechagon", "Nazjatar",
                "Dalaran", "Suramar", "Alta Montanha",
                "Gorgrond", "Selva de Tanaan", "Guarnição",
                "Monte Kun-Lai", "Ilha Perene", "Vale das Flores Eternas",
                "Coroa de Gelo", "Ulduar", "Tundra Boreana",
                "Shattrath", "Ilha de Quel'Danas",
                "Ventobravo", "Orgrimmar", "Tol Barad"
            }
            for _, z in ipairs(popularZones) do
                table.insert(list, { id = z, name = z, color = "00e5ff" })
            end
        end
        return list
    end

    zoneBtn:SetScript("OnClick", function(self)
        ToyFinderUI:ToggleDropdown(self, "Zona no Mundo", GetCurrentZoneList(), ToyFinder.activeZone, function(item)
            ToyFinder.activeZone = item.id
            ToyFinderUI:UpdateFilterButtonLabels()
            ToyFinder:ApplyFilters()
            ToyFinderUI:UpdateView()
        end)
    end)

    -- 4. Botão Dificuldade
    local difficultyBtn = CreateFilterDropdownBtn(subControls, "⚡ Dificuldade: Todas ▼", 135, zoneBtn, 5)
    f.difficultyBtn = difficultyBtn
    f.difficultyBtnText = difficultyBtn.btnText

    difficultyBtn:SetScript("OnClick", function(self)
        local counts = ToyFinderUI:GetFilterCounts()
        local items = ToyFinderUI:AddCountsToItems(Data.Difficulties, counts.difficulty, counts.total)
        ToyFinderUI:ToggleDropdown(self, "Dificuldade de Obtenção", items, ToyFinder.activeDifficulty, function(item)
            ToyFinder.activeDifficulty = item.id
            ToyFinderUI:UpdateFilterButtonLabels()
            ToyFinder:ApplyFilters()
            ToyFinderUI:UpdateView()
        end)
    end)

    -- 5. Botão Ordenar
    local sortBtn = CreateFilterDropdownBtn(subControls, "🔃 Recentes ▼", 105, difficultyBtn, 5)
    f.sortBtn = sortBtn
    f.sortBtnText = sortBtn.btnText

    local sortItems = {
        { id = "NEWEST", name = "Mais Recentes (Midnight / TWW)", color = "9d4edd" },
        { id = "NAME", name = "Nome (A-Z)", color = "ffffff" },
        { id = "QUALITY", name = "Qualidade (Raridade)", color = "ffd200" },
        { id = "STATUS", name = "Em Falta Primeiro", color = "ff5252" },
    }

    sortBtn:SetScript("OnClick", function(self)
        ToyFinderUI:ToggleDropdown(self, "Ordenar Brinquedos", sortItems, ToyFinder.sortBy, function(item)
            ToyFinder.sortBy = item.id
            ToyFinderUI:UpdateFilterButtonLabels()
            ToyFinder:ApplyFilters()
            ToyFinderUI:UpdateView()
        end)
    end)

    -- Caixa de Pesquisa em Tempo Real
    local searchBox = CreateFrame("EditBox", nil, subControls, "BackdropTemplate")
    searchBox:SetPoint("LEFT", sortBtn, "RIGHT", 6, 0)
    searchBox:SetPoint("RIGHT", subControls, "RIGHT", 0, 0)
    searchBox:SetHeight(30)
    f.searchBox = searchBox
    searchBox:SetAutoFocus(false)
    searchBox:SetFontObject("GameFontHighlight")
    searchBox:SetTextInsets(8, 24, 0, 0)
    searchBox:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    searchBox:SetBackdropColor(0.04, 0.03, 0.08, 0.9)
    searchBox:SetBackdropBorderColor(0.35, 0.22, 0.5, 1)

    local searchPlaceholder = searchBox:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    searchPlaceholder:SetPoint("LEFT", searchBox, "LEFT", 8, 0)
    searchPlaceholder:SetText(L.SEARCH_PLACEHOLDER)
    f.searchPlaceholder = searchPlaceholder

    local clearSearchBtn = CreateFrame("Button", nil, searchBox)
    clearSearchBtn:SetSize(18, 18)
    clearSearchBtn:SetPoint("RIGHT", searchBox, "RIGHT", -4, 0)
    local clearText = clearSearchBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    clearText:SetPoint("CENTER", clearSearchBtn, "CENTER", 0, 0)
    clearText:SetText("|cffaaaaaa✕|r")
    clearSearchBtn:Hide()

    clearSearchBtn:SetScript("OnClick", function()
        searchBox:SetText("")
        searchBox:ClearFocus()
        ToyFinder.searchQuery = ""
        searchPlaceholder:Show()
        clearSearchBtn:Hide()
        ToyFinder:ApplyFilters()
        ToyFinderUI:UpdateView()
    end)

    searchBox:SetScript("OnTextChanged", function(self)
        local text = self:GetText()
        ToyFinder.searchQuery = text
        if text and text ~= "" then
            searchPlaceholder:Hide()
            clearSearchBtn:Show()
        else
            searchPlaceholder:Show()
            clearSearchBtn:Hide()
        end
        ToyFinder:ApplyFilters()
        ToyFinderUI:UpdateView()
    end)

    searchBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)

    ----------------------------------------------------------------------------
    -- ÁREA PRINCIPAL: LISTA DE BRINQUEDOS (ESQUERDA) E DETALHES (DIREITA)
    ----------------------------------------------------------------------------
    local contentArea = CreateFrame("Frame", nil, f)
    contentArea:SetPoint("TOPLEFT", subControls, "BOTTOMLEFT", 0, -8)
    contentArea:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -8, 28)

    -- Rodapé com Dica para Iniciantes
    local footer = CreateFrame("Frame", nil, f)
    footer:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 12, 6)
    footer:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -12, 6)
    footer:SetHeight(18)

    local footerText = footer:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    footerText:SetPoint("LEFT", footer, "LEFT", 0, 0)
    footerText:SetText("|cff00e5ff💡 Dica para Iniciantes:|r Clica num brinquedo para ver o guia passo a passo. Filtra por |cffffd200'Vendedores'|r para brinquedos de compra direta com ouro!")

    -- Painel da Lista (Esquerda)
    local listContainer = CreateFrame("Frame", nil, contentArea, "BackdropTemplate")
    listContainer:SetPoint("TOPLEFT", contentArea, "TOPLEFT", 0, 0)
    listContainer:SetPoint("BOTTOMLEFT", contentArea, "BOTTOMLEFT", 0, 0)
    listContainer:SetWidth(590)
    listContainer:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    listContainer:SetBackdropColor(COLORS.panelBg.r, COLORS.panelBg.g, COLORS.panelBg.b, COLORS.panelBg.a)
    listContainer:SetBackdropBorderColor(0.25, 0.18, 0.35, 0.8)
    f.listContainer = listContainer

    -- Scrollbar da Lista
    local scrollBar = CreateFrame("Slider", "ToyFinderScrollBar", listContainer, "UIPanelScrollBarTemplate")
    scrollBar:SetPoint("TOPRIGHT", listContainer, "TOPRIGHT", -4, -20)
    scrollBar:SetPoint("BOTTOMRIGHT", listContainer, "BOTTOMRIGHT", -4, 20)
    scrollBar:SetWidth(16)
    scrollBar:SetMinMaxValues(1, 1)
    scrollBar:SetValue(1)
    scrollBar:SetValueStep(1)
    f.scrollBar = scrollBar

    scrollBar:SetScript("OnValueChanged", function(self, value)
        ToyFinderUI:UpdateRowContent(math.floor(value))
    end)

    -- Suporte à roda do rato na lista
    listContainer:EnableMouseWheel(true)
    listContainer:SetScript("OnMouseWheel", function(self, delta)
        local cur = scrollBar:GetValue()
        local minVal, maxVal = scrollBar:GetMinMaxValues()
        local newVal = cur - (delta * 2)
        if newVal < minVal then newVal = minVal end
        if newVal > maxVal then newVal = maxVal end
        scrollBar:SetValue(newVal)
    end)

    -- Estado Vazio: mostrado quando a combinação de filtros não devolve resultados
    local emptyState = CreateFrame("Frame", nil, listContainer)
    emptyState:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 6, -6)
    emptyState:SetPoint("BOTTOMRIGHT", listContainer, "BOTTOMRIGHT", -6, 6)
    emptyState:Hide()
    f.emptyState = emptyState

    local emptyIcon = emptyState:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    emptyIcon:SetPoint("CENTER", emptyState, "CENTER", 0, 52)
    emptyIcon:SetText("|cff9d4edd🔍|r")

    local emptyTitle = emptyState:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    emptyTitle:SetPoint("TOP", emptyIcon, "BOTTOM", 0, -12)
    emptyTitle:SetText("|cffff5252" .. L.EMPTY_STATE_TITLE .. "|r")

    local emptyDesc = emptyState:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    emptyDesc:SetPoint("TOP", emptyTitle, "BOTTOM", 0, -6)
    emptyDesc:SetPoint("LEFT", emptyState, "LEFT", 40, 0)
    emptyDesc:SetPoint("RIGHT", emptyState, "RIGHT", -40, 0)
    emptyDesc:SetJustifyH("CENTER")
    emptyDesc:SetWordWrap(true)
    emptyDesc:SetText("|cffaaaaaa" .. L.EMPTY_STATE_DESC .. "|r")

    local emptyClearBtn = CreateFrame("Button", nil, emptyState, "BackdropTemplate")
    emptyClearBtn:SetSize(180, 32)
    emptyClearBtn:SetPoint("TOP", emptyDesc, "BOTTOM", 0, -14)
    emptyClearBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    emptyClearBtn:SetBackdropColor(0.22, 0.08, 0.12, 0.9)
    emptyClearBtn:SetBackdropBorderColor(0.7, 0.2, 0.3, 1)
    local emptyClearText = emptyClearBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    emptyClearText:SetPoint("CENTER", emptyClearBtn, "CENTER", 0, 0)
    emptyClearText:SetText("|cffff5252" .. L.EMPTY_STATE_CLEAR .. "|r")
    emptyClearBtn:SetScript("OnClick", function()
        ToyFinder:ResetAllFilters()
        if f.searchBox then f.searchBox:SetText("") end
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
    end)
    emptyClearBtn:SetScript("OnEnter", function(self) self:SetBackdropColor(0.35, 0.12, 0.18, 1) end)
    emptyClearBtn:SetScript("OnLeave", function(self) self:SetBackdropColor(0.22, 0.08, 0.12, 0.9) end)

    -- Criar Linhas da Lista Virtualizada
    for i = 1, VISIBLE_ROWS do
        local row = CreateFrame("Button", nil, listContainer, "BackdropTemplate")
        row:SetSize(560, ROW_HEIGHT)
        row:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 6, -((i - 1) * (ROW_HEIGHT + 2) + 6))
        row:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
        })
        row:SetBackdropColor(0.10, 0.07, 0.16, 0.8)
        row:SetBackdropBorderColor(0.25, 0.18, 0.35, 0.5)
        row.baseColor = { 0.10, 0.07, 0.16, 0.8 }

        -- Barra de destaque lateral na linha selecionada
        local accent = row:CreateTexture(nil, "OVERLAY")
        accent:SetSize(3, ROW_HEIGHT)
        accent:SetPoint("LEFT", row, "LEFT", 0, 0)
        accent:SetTexture("Interface\\Buttons\\WHITE8X8")
        accent:SetVertexColor(0.0, 0.90, 1.0, 1)
        accent:Hide()
        row.accent = accent

        -- Ícone do Brinquedo
        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetSize(36, 36)
        icon:SetPoint("LEFT", row, "LEFT", 5, 0)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        row.icon = icon

        -- Borda do Ícone (qualidade)
        local iconBorder = row:CreateTexture(nil, "OVERLAY")
        iconBorder:SetSize(40, 40)
        iconBorder:SetPoint("CENTER", icon, "CENTER", 0, 0)
        iconBorder:SetTexture("Interface\\Common\\WhiteIconFrame")
        row.iconBorder = iconBorder

        -- Nome do Brinquedo
        local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        nameText:SetPoint("TOPLEFT", icon, "TOPRIGHT", 8, -2)
        nameText:SetPoint("TOPRIGHT", row, "TOPRIGHT", -120, -2)
        nameText:SetJustifyH("LEFT")
        nameText:SetWordWrap(false)
        row.nameText = nameText

        -- Badge de Status (Obtido / Em Falta)
        local statusBadge = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        statusBadge:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 8, 4)
        row.statusBadge = statusBadge

        -- Tag da Fonte (ex: [Vendedor], [Drop], [Tesouro])
        local sourceTag = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        sourceTag:SetPoint("LEFT", statusBadge, "RIGHT", 6, 0)
        sourceTag:SetPoint("RIGHT", row, "RIGHT", -106, 0)
        sourceTag:SetJustifyH("LEFT")
        sourceTag:SetWordWrap(false)
        row.sourceTag = sourceTag

        -- Botão WoWhead no item
        local wowheadRowBtn = CreateFrame("Button", nil, row, "BackdropTemplate")
        wowheadRowBtn:SetSize(72, 22)
        wowheadRowBtn:SetPoint("RIGHT", row, "RIGHT", -28, 0)
        wowheadRowBtn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
        })
        wowheadRowBtn:SetBackdropColor(0.2, 0.12, 0.35, 0.9)
        wowheadRowBtn:SetBackdropBorderColor(0.6, 0.3, 0.9, 0.8)
        
        local whBtnText = wowheadRowBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        whBtnText:SetPoint("CENTER", wowheadRowBtn, "CENTER", 0, 0)
        whBtnText:SetText("|cff00e5ffWoWhead|r")

        wowheadRowBtn:SetScript("OnClick", function(self)
            if row.toyData then
                ToyFinderUI:OpenWoWheadModal(row.toyData)
                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
            end
        end)

        -- Badge de Guia Completo (📖 com GPS) ao lado do botão WoWhead
        local guideBadge = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        guideBadge:SetPoint("RIGHT", wowheadRowBtn, "LEFT", -3, 0)
        guideBadge:SetText("|cffffd200📖|r")
        guideBadge:Hide()
        row.guideBadge = guideBadge

        -- Botão de Favorito (Estrela)
        local favBtn = CreateFrame("Button", nil, row)
        favBtn:SetSize(22, 22)
        favBtn:SetPoint("RIGHT", row, "RIGHT", -4, 0)
        local favText = favBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        favText:SetPoint("CENTER", favBtn, "CENTER", 0, 0)
        favText:SetText("|cff555555★|r")
        row.favText = favText

        favBtn:SetScript("OnClick", function()
            if row.toyData then
                local id = row.toyData.itemID
                ToyFinderDB.favorites[id] = not ToyFinderDB.favorites[id]
                row.toyData.isFavorite = ToyFinderDB.favorites[id]
                favText:SetText(row.toyData.isFavorite and "|cffffd200★|r" or "|cff555555★|r")
                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
            end
        end)

        -- Cliques e Hover da Linha
        row:SetScript("OnClick", function(self)
            if self.toyData then
                ToyFinder.selectedToy = self.toyData
                ToyFinderUI:UpdateSelectedToyDetails()
                ToyFinderUI:UpdateRowContent(math.floor(scrollBar:GetValue()))
                PlaySound(SOUNDKIT.IG_CHAT_EMOTE_BUTTON)
            end
        end)

        row:SetScript("OnEnter", function(self)
            self:SetBackdropColor(COLORS.rowHover.r, COLORS.rowHover.g, COLORS.rowHover.b, COLORS.rowHover.a)
            if self.toyData then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetToyByItemID(self.toyData.itemID)
                if self.toyData.dbData then
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine("|cff00e5ff" .. L.GUIDE_BADGE_TIP .. "|r")
                end
                GameTooltip:Show()
            end
        end)

        row:SetScript("OnLeave", function(self)
            local isSel = (ToyFinder.selectedToy and self.toyData and ToyFinder.selectedToy.itemID == self.toyData.itemID)
            if isSel then
                self:SetBackdropColor(COLORS.rowSelected.r, COLORS.rowSelected.g, COLORS.rowSelected.b, COLORS.rowSelected.a)
            else
                local bc = self.baseColor or { 0.10, 0.07, 0.16, 0.8 }
                self:SetBackdropColor(bc[1], bc[2], bc[3], bc[4])
            end
            GameTooltip:Hide()
        end)

        rowFrames[i] = row
    end

    ----------------------------------------------------------------------------
    -- PAINEL DE INSPEÇÃO & DETALHES DE OBTENÇÃO (DIREITA)
    ----------------------------------------------------------------------------
    local detailContainer = CreateFrame("Frame", nil, contentArea, "BackdropTemplate")
    detailContainer:SetPoint("TOPLEFT", listContainer, "TOPRIGHT", 8, 0)
    detailContainer:SetPoint("BOTTOMRIGHT", contentArea, "BOTTOMRIGHT", 0, 0)
    detailContainer:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    detailContainer:SetBackdropColor(COLORS.panelBg.r, COLORS.panelBg.g, COLORS.panelBg.b, COLORS.panelBg.a)
    detailContainer:SetBackdropBorderColor(0.25, 0.18, 0.35, 0.8)
    f.detailContainer = detailContainer

    -- Ícone grande
    local dIcon = detailContainer:CreateTexture(nil, "ARTWORK")
    dIcon:SetSize(52, 52)
    dIcon:SetPoint("TOPLEFT", detailContainer, "TOPLEFT", 14, -14)
    dIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    f.dIcon = dIcon

    local dIconBorder = detailContainer:CreateTexture(nil, "OVERLAY")
    dIconBorder:SetSize(58, 58)
    dIconBorder:SetPoint("CENTER", dIcon, "CENTER", 0, 0)
    dIconBorder:SetTexture("Interface\\Common\\WhiteIconFrame")
    f.dIconBorder = dIconBorder

    -- Nome grande
    local dName = detailContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    dName:SetPoint("TOPLEFT", dIcon, "TOPRIGHT", 12, -2)
    dName:SetPoint("TOPRIGHT", detailContainer, "TOPRIGHT", -12, -2)
    dName:SetJustifyH("LEFT")
    f.dName = dName

    -- Item ID e Expansão
    local dMeta = detailContainer:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    dMeta:SetPoint("TOPLEFT", dName, "BOTTOMLEFT", 0, -4)
    f.dMeta = dMeta

    -- Banner de Status (Grande e nítido)
    local statusBanner = CreateFrame("Frame", nil, detailContainer, "BackdropTemplate")
    statusBanner:SetPoint("TOPLEFT", dIcon, "BOTTOMLEFT", 0, -12)
    statusBanner:SetPoint("TOPRIGHT", detailContainer, "TOPRIGHT", -14, -12)
    statusBanner:SetHeight(28)
    statusBanner:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    f.statusBanner = statusBanner

    local statusBannerText = statusBanner:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    statusBannerText:SetPoint("CENTER", statusBanner, "CENTER", 0, 0)
    f.statusBannerText = statusBannerText

    -- Secção: Como Obter / Fonte (Vendedor, Loot, Tesouro, etc.)
    local sourceBoxHeader = detailContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sourceBoxHeader:SetPoint("TOPLEFT", statusBanner, "BOTTOMLEFT", 0, -8)
    sourceBoxHeader:SetText("|cffffd200" .. L.SOURCE_LABEL .. "|r")

    local sourceBox = CreateFrame("Frame", nil, detailContainer, "BackdropTemplate")
    sourceBox:SetPoint("TOPLEFT", sourceBoxHeader, "BOTTOMLEFT", 0, -4)
    sourceBox:SetPoint("TOPRIGHT", detailContainer, "TOPRIGHT", -14, -4)
    sourceBox:SetHeight(180)
    sourceBox:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    sourceBox:SetBackdropColor(0.08, 0.05, 0.14, 0.9)
    sourceBox:SetBackdropBorderColor(0.3, 0.2, 0.45, 0.7)

    -- ScrollFrame: o guia passo a passo nunca fica cortado, mesmo em guias longos
    local sourceScroll = CreateFrame("ScrollFrame", "ToyFinderSourceScroll", sourceBox, "UIPanelScrollFrameTemplate")
    sourceScroll:SetPoint("TOPLEFT", sourceBox, "TOPLEFT", 2, -2)
    sourceScroll:SetPoint("BOTTOMRIGHT", sourceBox, "BOTTOMRIGHT", -24, 2)

    local sourceContent = CreateFrame("Frame", nil, sourceScroll)
    sourceContent:SetPoint("TOPLEFT", sourceScroll, "TOPLEFT", 0, 0)
    sourceContent:SetWidth(sourceScroll:GetWidth() - 6)
    sourceContent:SetHeight(1)
    sourceScroll:SetScrollChild(sourceContent)

    local sourceDesc = sourceContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sourceDesc:SetPoint("TOPLEFT", sourceContent, "TOPLEFT", 6, -6)
    sourceDesc:SetPoint("TOPRIGHT", sourceContent, "TOPRIGHT", -6, -6)
    sourceDesc:SetJustifyH("LEFT")
    sourceDesc:SetJustifyV("TOP")
    sourceDesc:SetWordWrap(true)
    f.sourceDesc = sourceDesc
    f.sourceScroll = sourceScroll
    f.sourceContent = sourceContent

    local function ScrollSourceBy(delta)
        local bar = _G["ToyFinderSourceScrollScrollBar"]
        if not bar then return end
        local cur = bar:GetValue()
        local minV, maxV = bar:GetMinMaxValues()
        local newV = cur - (delta * 3)
        if newV < minV then newV = minV end
        if newV > maxV then newV = maxV end
        bar:SetValue(newV)
    end
    f.ScrollSourceBy = ScrollSourceBy
    sourceBox:EnableMouseWheel(true)
    sourceBox:SetScript("OnMouseWheel", function(self, delta) ScrollSourceBy(delta) end)
    sourceScroll:EnableMouseWheel(true)
    sourceScroll:SetScript("OnMouseWheel", function(self, delta) ScrollSourceBy(delta) end)

    -- Secção: Efeito do Brinquedo
    local effectHeader = detailContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    effectHeader:SetPoint("TOPLEFT", sourceBox, "BOTTOMLEFT", 0, -6)
    effectHeader:SetText("|cff00e5ff" .. L.EFFECT_LABEL .. "|r")

    local effectBox = CreateFrame("Frame", nil, detailContainer, "BackdropTemplate")
    effectBox:SetPoint("TOPLEFT", effectHeader, "BOTTOMLEFT", 0, -4)
    effectBox:SetPoint("TOPRIGHT", detailContainer, "TOPRIGHT", -14, -4)
    effectBox:SetHeight(48)
    effectBox:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    effectBox:SetBackdropColor(0.08, 0.05, 0.14, 0.9)
    effectBox:SetBackdropBorderColor(0.3, 0.2, 0.45, 0.7)

    local effectDesc = effectBox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    effectDesc:SetPoint("TOPLEFT", effectBox, "TOPLEFT", 8, -5)
    effectDesc:SetPoint("BOTTOMRIGHT", effectBox, "BOTTOMRIGHT", -8, 5)
    effectDesc:SetJustifyH("LEFT")
    effectDesc:SetJustifyV("TOP")
    effectDesc:SetWordWrap(true)
    f.effectDesc = effectDesc

    -- BOTÃO PRINCIPAL 1: PONTO NO MAPA /WAY (TOMTOM)
    local waypointBtn = CreateFrame("Button", nil, detailContainer, "BackdropTemplate")
    waypointBtn:SetPoint("BOTTOMLEFT", detailContainer, "BOTTOMLEFT", 14, 66)
    waypointBtn:SetPoint("BOTTOMRIGHT", detailContainer, "BOTTOMRIGHT", -14, 66)
    waypointBtn:SetHeight(32)
    waypointBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    waypointBtn:SetBackdropColor(0.12, 0.32, 0.22, 0.95)
    waypointBtn:SetBackdropBorderColor(0.23, 0.89, 0.45, 1)

    local waypointText = waypointBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    waypointText:SetPoint("CENTER", waypointBtn, "CENTER", 0, 0)
    waypointText:SetText("|cffffd200📍 Ponto no Mapa /way|r  |cffffffff(TomTom)|r")
    f.waypointBtn = waypointBtn
    f.waypointText = waypointText

    waypointBtn:SetScript("OnClick", function()
        if ToyFinder.selectedToy then
            ToyFinder:AddWaypoint(ToyFinder.selectedToy)
        end
    end)
    waypointBtn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.20, 0.48, 0.32, 1)
    end)
    waypointBtn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.12, 0.32, 0.22, 0.95)
    end)

    -- BOTÃO PRINCIPAL 2: ABRIR LINK WOWHEAD (Opcional)
    local whBigBtn = CreateFrame("Button", nil, detailContainer, "BackdropTemplate")
    whBigBtn:SetPoint("BOTTOMLEFT", detailContainer, "BOTTOMLEFT", 14, 38)
    whBigBtn:SetPoint("BOTTOMRIGHT", detailContainer, "BOTTOMRIGHT", -14, 38)
    whBigBtn:SetHeight(24)
    whBigBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    whBigBtn:SetBackdropColor(0.16, 0.10, 0.25, 0.9)
    whBigBtn:SetBackdropBorderColor(0.4, 0.25, 0.6, 1)

    local whBigText = whBigBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    whBigText:SetPoint("CENTER", whBigBtn, "CENTER", 0, 0)
    whBigText:SetText("|cff00e5ff🌐 Ver no WoWhead (Guia Web / Vídeo)|r")

    whBigBtn:SetScript("OnClick", function()
        if ToyFinder.selectedToy then
            ToyFinderUI:OpenWoWheadModal(ToyFinder.selectedToy)
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        end
    end)
    whBigBtn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.25, 0.16, 0.38, 1)
    end)
    whBigBtn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.16, 0.10, 0.25, 0.9)
    end)

    -- Botão Secundário: Linkar no Chat
    local chatShareBtn = CreateFrame("Button", nil, detailContainer, "BackdropTemplate")
    chatShareBtn:SetPoint("BOTTOMLEFT", detailContainer, "BOTTOMLEFT", 14, 8)
    chatShareBtn:SetSize(145, 24)
    chatShareBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    chatShareBtn:SetBackdropColor(0.14, 0.09, 0.22, 0.9)
    chatShareBtn:SetBackdropBorderColor(0.35, 0.20, 0.5, 1)
    
    local chatText = chatShareBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    chatText:SetPoint("CENTER", chatShareBtn, "CENTER", 0, 0)
    chatText:SetText("💬 " .. L.SHARE_CHAT)

    chatShareBtn:SetScript("OnClick", function()
        if ToyFinder.selectedToy then
            local toyLink = C_ToyBox and C_ToyBox.GetToyLink and C_ToyBox.GetToyLink(ToyFinder.selectedToy.itemID)
            if toyLink then
                if not ChatEdit_InsertLink(toyLink) then
                    ChatFrame_OpenChat(toyLink)
                end
            end
        end
    end)

    -- Botão Secundário: Favoritar
    local toggleFavBtn = CreateFrame("Button", nil, detailContainer, "BackdropTemplate")
    toggleFavBtn:SetPoint("BOTTOMRIGHT", detailContainer, "BOTTOMRIGHT", -14, 8)
    toggleFavBtn:SetSize(145, 24)
    toggleFavBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    toggleFavBtn:SetBackdropColor(0.14, 0.09, 0.22, 0.9)
    toggleFavBtn:SetBackdropBorderColor(0.35, 0.20, 0.5, 1)

    local favDetailText = toggleFavBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    favDetailText:SetPoint("CENTER", toggleFavBtn, "CENTER", 0, 0)
    favDetailText:SetText("★ Favorita")
    f.favDetailText = favDetailText

    toggleFavBtn:SetScript("OnClick", function()
        if ToyFinder.selectedToy then
            local id = ToyFinder.selectedToy.itemID
            ToyFinderDB.favorites[id] = not ToyFinderDB.favorites[id]
            ToyFinder.selectedToy.isFavorite = ToyFinderDB.favorites[id]
            favDetailText:SetText(ToyFinder.selectedToy.isFavorite and "|cffffd200★ Nas Favoritas|r" or "★ Favorita")
            ToyFinderUI:UpdateRowContent(math.floor(scrollBar:GetValue()))
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        end
    end)

    ----------------------------------------------------------------------------
    -- MODAL DE LINK DO WOWHEAD (POPOVER COM CTRL+C)
    ----------------------------------------------------------------------------
    local modal = CreateFrame("Frame", "ToyFinderWoWheadModal", f, "BackdropTemplate")
    modal:SetSize(520, 220)
    modal:SetPoint("CENTER", f, "CENTER", 0, 20)
    modal:SetFrameStrata("DIALOG")
    modal:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 2,
    })
    modal:SetBackdropColor(0.06, 0.04, 0.11, 0.98)
    modal:SetBackdropBorderColor(0.0, 0.85, 1.0, 1)
    modal:Hide()
    f.modal = modal

    local modalTitle = modal:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    modalTitle:SetPoint("TOP", modal, "TOP", 0, -16)
    modalTitle:SetText("|cff00e5ffWoWhead - Guia & Localização|r")

    local modalDesc = modal:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    modalDesc:SetPoint("TOPLEFT", modal, "TOPLEFT", 20, -48)
    modalDesc:SetPoint("TOPRIGHT", modal, "TOPRIGHT", -20, -48)
    modalDesc:SetJustifyH("CENTER")
    modalDesc:SetText(L.WOWHEAD_MODAL_DESC)

    -- EditBox com o Link pré-selecionado
    local urlBox = CreateFrame("EditBox", nil, modal, "BackdropTemplate")
    urlBox:SetSize(460, 36)
    urlBox:SetPoint("CENTER", modal, "CENTER", 0, -10)
    urlBox:SetFontObject("GameFontHighlightMedium")
    urlBox:SetAutoFocus(true)
    urlBox:SetTextInsets(10, 10, 0, 0)
    urlBox:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    urlBox:SetBackdropColor(0.12, 0.08, 0.20, 1)
    urlBox:SetBackdropBorderColor(0.9, 0.7, 0.1, 1)
    f.modalUrlBox = urlBox

    urlBox:SetScript("OnEscapePressed", function(self)
        modal:Hide()
    end)
    urlBox:SetScript("OnTextChanged", function(self, userInput)
        if userInput then
            -- Se o usuário tentar editar, restaura o link original do brinquedo
            if modal.currentToy then
                self:SetText(ToyFinder:GetWoWheadURL(modal.currentToy.itemID, ToyFinder.preferredWoWhead))
                self:HighlightText()
            end
        end
    end)

    -- Botão Concluído / Fechar Modal
    local modalCloseBtn = CreateFrame("Button", nil, modal, "BackdropTemplate")
    modalCloseBtn:SetSize(120, 30)
    modalCloseBtn:SetPoint("BOTTOM", modal, "BOTTOM", 0, 16)
    modalCloseBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    modalCloseBtn:SetBackdropColor(0.2, 0.15, 0.35, 1)
    modalCloseBtn:SetBackdropBorderColor(0.5, 0.3, 0.8, 1)

    local modalCloseText = modalCloseBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    modalCloseText:SetPoint("CENTER", modalCloseBtn, "CENTER", 0, 0)
    modalCloseText:SetText(L.CLOSE)

    modalCloseBtn:SetScript("OnClick", function()
        modal:Hide()
        PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
    end)

    mainFrame = f
    return f
end

--------------------------------------------------------------------------------
-- ABRIR MODAL DO WOWHEAD
--------------------------------------------------------------------------------
function ToyFinderUI:OpenWoWheadModal(toy)
    if not toy or not mainFrame then return end
    
    local modal = mainFrame.modal
    modal.currentToy = toy
    
    local url = ToyFinder:GetWoWheadURL(toy.itemID, ToyFinder.preferredWoWhead)
    mainFrame.modalUrlBox:SetText(url)
    modal:Show()
    mainFrame.modalUrlBox:SetFocus()
    mainFrame.modalUrlBox:HighlightText()
end

--------------------------------------------------------------------------------
-- ATUALIZAÇÃO DA SELEÇÃO DE ABAS
--------------------------------------------------------------------------------
function ToyFinderUI:UpdateTabHighlight()
    if not mainFrame then return end
    local nAll, nMissing, nCollected, nFav = 0, 0, 0, 0
    for _, toy in ipairs(ToyFinder.toys or {}) do
        nAll = nAll + 1
        if toy.isCollected then
            nCollected = nCollected + 1
        else
            nMissing = nMissing + 1
        end
        if toy.isFavorite then nFav = nFav + 1 end
    end
    local tabs = {
        { btn = mainFrame.tabAll, type = "ALL", count = nAll },
        { btn = mainFrame.tabMissing, type = "MISSING", count = nMissing },
        { btn = mainFrame.tabCollected, type = "COLLECTED", count = nCollected },
        { btn = mainFrame.tabFavorites, type = "FAVORITES", count = nFav },
    }
    for _, tab in ipairs(tabs) do
        if tab.btn.label and tab.btn.baseLabel then
            tab.btn.label:SetText(string.format("%s |cff888888(%d)|r", tab.btn.baseLabel, tab.count))
        end
        if ToyFinder.activeFilter == tab.type then
            tab.btn:SetBackdropColor(0.35, 0.22, 0.55, 1)
            tab.btn:SetBackdropBorderColor(COLORS.accentCyan.r, COLORS.accentCyan.g, COLORS.accentCyan.b, 1)
        else
            tab.btn:SetBackdropColor(0.12, 0.08, 0.20, 0.9)
            tab.btn:SetBackdropBorderColor(0.3, 0.2, 0.45, 0.8)
        end
    end
end

--------------------------------------------------------------------------------
-- ATUALIZAÇÃO DOS RÓTULOS DOS BOTÕES DE FILTRO AVANÇADO
--------------------------------------------------------------------------------
function ToyFinderUI:UpdateFilterButtonLabels()
    if not mainFrame then return end

    -- 1. Obtenção
    local srcName = "Todas"
    if ToyFinder.activeSource ~= "ALL" then
        local meta = Data.SourceTypes[ToyFinder.activeSource]
        srcName = meta and meta.tag or ToyFinder.activeSource
        mainFrame.sourceBtn:SetBackdropBorderColor(COLORS.accentCyan.r, COLORS.accentCyan.g, COLORS.accentCyan.b, 1)
        mainFrame.sourceBtn:SetBackdropColor(0.20, 0.12, 0.32, 1)
    else
        mainFrame.sourceBtn:SetBackdropBorderColor(0.4, 0.25, 0.6, 1)
        mainFrame.sourceBtn:SetBackdropColor(0.14, 0.10, 0.22, 0.9)
    end
    mainFrame.sourceBtnText:SetText(string.format("📦 %s ▼", srcName))

    -- 2. Continente
    local contName = "Todos"
    if ToyFinder.activeContinent ~= "ALL" then
        for _, c in ipairs(Data.Continents) do
            if c.id == ToyFinder.activeContinent then
                contName = c.short or c.name
                break
            end
        end
        mainFrame.continentBtn:SetBackdropBorderColor(COLORS.accentCyan.r, COLORS.accentCyan.g, COLORS.accentCyan.b, 1)
        mainFrame.continentBtn:SetBackdropColor(0.20, 0.12, 0.32, 1)
    else
        mainFrame.continentBtn:SetBackdropBorderColor(0.4, 0.25, 0.6, 1)
        mainFrame.continentBtn:SetBackdropColor(0.14, 0.10, 0.22, 0.9)
    end
    mainFrame.continentBtnText:SetText(string.format("🌍 %s ▼", contName))

    -- 3. Zona
    local zoneName = "Todas"
    if ToyFinder.activeZone ~= "ALL" and ToyFinder.activeZone ~= "Todas as Zonas" and ToyFinder.activeZone ~= "" then
        zoneName = ToyFinder.activeZone
        mainFrame.zoneBtn:SetBackdropBorderColor(COLORS.accentCyan.r, COLORS.accentCyan.g, COLORS.accentCyan.b, 1)
        mainFrame.zoneBtn:SetBackdropColor(0.20, 0.12, 0.32, 1)
    else
        mainFrame.zoneBtn:SetBackdropBorderColor(0.4, 0.25, 0.6, 1)
        mainFrame.zoneBtn:SetBackdropColor(0.14, 0.10, 0.22, 0.9)
    end
    mainFrame.zoneBtnText:SetText(string.format("📍 %s ▼", zoneName))

    -- 4. Dificuldade
    local diffName = "Todas"
    if ToyFinder.activeDifficulty ~= "ALL" then
        for _, d in ipairs(Data.Difficulties) do
            if d.id == ToyFinder.activeDifficulty then
                diffName = d.short or d.name
                break
            end
        end
        mainFrame.difficultyBtn:SetBackdropBorderColor(COLORS.accentCyan.r, COLORS.accentCyan.g, COLORS.accentCyan.b, 1)
        mainFrame.difficultyBtn:SetBackdropColor(0.20, 0.12, 0.32, 1)
    else
        mainFrame.difficultyBtn:SetBackdropBorderColor(0.4, 0.25, 0.6, 1)
        mainFrame.difficultyBtn:SetBackdropColor(0.14, 0.10, 0.22, 0.9)
    end
    mainFrame.difficultyBtnText:SetText(string.format("⚡ %s ▼", diffName))

    -- 5. Ordenar
    local sortName = "Recentes"
    if ToyFinder.sortBy == "NAME" then sortName = "Nome A-Z"
    elseif ToyFinder.sortBy == "QUALITY" then sortName = "Qualidade"
    elseif ToyFinder.sortBy == "STATUS" then sortName = "Em Falta"
    end
    mainFrame.sortBtnText:SetText(string.format("🔃 %s ▼", sortName))
end

--------------------------------------------------------------------------------
-- CONTADORES NOS DROPDOWNS (quantos brinquedos existem em cada categoria)
--------------------------------------------------------------------------------
function ToyFinderUI:GetFilterCounts()
    local counts = {
        source = {},
        continent = {},
        difficulty = { EASY = 0, QUEST = 0, EXPLORE = 0, FARM = 0, EVENT = 0, OTHER = 0 }
    }
    local toys = ToyFinder.toys or {}
    for _, toy in ipairs(toys) do
        counts.source[toy.sourceType] = (counts.source[toy.sourceType] or 0) + 1
        counts.continent[toy.continent] = (counts.continent[toy.continent] or 0) + 1
        local st = toy.sourceType
        if st == "VENDOR" or st == "STORE" or st == "TRADING_POST" then
            counts.difficulty.EASY = counts.difficulty.EASY + 1
        elseif st == "QUEST" then
            counts.difficulty.QUEST = counts.difficulty.QUEST + 1
        elseif st == "TREASURE" then
            counts.difficulty.EXPLORE = counts.difficulty.EXPLORE + 1
        elseif st == "LOOT" then
            counts.difficulty.FARM = counts.difficulty.FARM + 1
        elseif st == "EVENT" then
            counts.difficulty.EVENT = counts.difficulty.EVENT + 1
        else
            counts.difficulty.OTHER = counts.difficulty.OTHER + 1
        end
    end
    counts.total = #toys
    return counts
end

function ToyFinderUI:AddCountsToItems(items, countMap, allCount)
    local out = {}
    for _, it in ipairs(items or {}) do
        local n = (it.id == "ALL") and (allCount or 0) or (countMap[it.id] or 0)
        table.insert(out, {
            id = it.id,
            name = string.format("%s |cff888888(%d)|r", it.name, n),
            color = it.color
        })
    end
    return out
end

--------------------------------------------------------------------------------
-- ATUALIZAÇÃO DO CONTEÚDO DAS LINHAS
--------------------------------------------------------------------------------
function ToyFinderUI:UpdateRowContent(offset)
    offset = offset or 1
    local toys = ToyFinder.filteredToys or {}
    local totalFiltered = #toys
    
    for i = 1, VISIBLE_ROWS do
        local row = rowFrames[i]
        local toyIndex = offset + i - 1
        
        if toyIndex <= totalFiltered then
            local toy = toys[toyIndex]
            row.toyData = toy
            row:Show()

            -- Ícone
            row.icon:SetTexture(toy.icon)

            -- Cor de qualidade
            local qColor = Data.QualityColors[toy.quality] or Data.QualityColors[1]
            row.nameText:SetText(string.format("|cff%s%s|r", qColor.hex, toy.name or "Brinquedo"))
            row.iconBorder:SetVertexColor(qColor.r, qColor.g, qColor.b)

            -- Badge de Status (Obtido / Em Falta)
            if toy.isCollected then
                row.statusBadge:SetText("|cff3ae374[✓ " .. L.FILTER_COLLECTED .. "]|r")
            else
                row.statusBadge:SetText("|cffff5252[✕ " .. L.FILTER_MISSING .. "]|r")
            end

            -- Tag de Fonte (com cor de categoria)
            local srcMeta = Data.SourceTypes[toy.sourceType] or Data.SourceTypes["OTHER"]
            row.sourceTag:SetText(string.format("|cff%s[%s]|r |cffaaaaaa%s|r", srcMeta.color, srcMeta.tag, toy.sourceText or ""))

            -- Estrela de Favorito
            row.favText:SetText(toy.isFavorite and "|cffffd200★|r" or "|cff555555★|r")

            -- Badge de Guia Completo (📖 GPS) na lista
            if toy.dbData and (toy.dbData.guide or toy.coords or toy.waypoint) then
                row.guideBadge:SetText("|cffffd200📖|r")
                row.guideBadge:Show()
            else
                row.guideBadge:Hide()
            end

            -- Destaque de Seleção
            local base = (toyIndex % 2 == 0) and { 0.13, 0.09, 0.20, 0.8 } or { 0.10, 0.07, 0.16, 0.8 }
            row.baseColor = base
            if ToyFinder.selectedToy and ToyFinder.selectedToy.itemID == toy.itemID then
                row:SetBackdropColor(COLORS.rowSelected.r, COLORS.rowSelected.g, COLORS.rowSelected.b, COLORS.rowSelected.a)
                row:SetBackdropBorderColor(COLORS.accentCyan.r, COLORS.accentCyan.g, COLORS.accentCyan.b, 1)
                row.accent:Show()
            else
                row:SetBackdropColor(base[1], base[2], base[3], base[4])
                row:SetBackdropBorderColor(0.25, 0.18, 0.35, 0.5)
                row.accent:Hide()
            end
        else
            row.toyData = nil
            row.accent:Hide()
            row:Hide()
        end
    end
end

--------------------------------------------------------------------------------
-- AJUSTE DO SCROLL DO GUIA (após mudar o texto do painel de detalhes)
--------------------------------------------------------------------------------
function ToyFinderUI:UpdateSourceScroll()
    if not mainFrame or not mainFrame.sourceScroll then return end
    local desc = mainFrame.sourceDesc
    local viewH = mainFrame.sourceScroll:GetHeight()
    local contentH = desc:GetStringHeight() + 12
    mainFrame.sourceContent:SetHeight(math.max(contentH, viewH))
    local bar = _G["ToyFinderSourceScrollScrollBar"]
    if bar then
        local maxV = math.max(0, mainFrame.sourceContent:GetHeight() - viewH)
        bar:SetMinMaxValues(0, maxV)
        bar:SetValue(0)
    end
end

--------------------------------------------------------------------------------
-- ATUALIZAÇÃO DO PAINEL DE DETALHES (DIREITA)
--------------------------------------------------------------------------------
function ToyFinderUI:UpdateSelectedToyDetails()
    if not mainFrame then return end
    local toy = ToyFinder.selectedToy

    if not toy then
        mainFrame.dIcon:SetTexture("Interface\\Icons\\INV_Misc_Toy_01")
        mainFrame.dIconBorder:SetVertexColor(1, 1, 1)
        mainFrame.dName:SetText("Nenhum Brinquedo Selecionado")
        mainFrame.dMeta:SetText("Clica num brinquedo à esquerda para ver o guia passo a passo e coordenadas.")
        mainFrame.statusBanner:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
        mainFrame.statusBannerText:SetText("-")
        mainFrame.sourceDesc:SetText(L.NO_TOY_SELECTED)
        mainFrame.effectDesc:SetText("-")
        self:UpdateSourceScroll()
        if mainFrame.waypointBtn and mainFrame.waypointText then
            mainFrame.waypointText:SetText("|cff888888📍 Sem Coordenadas Fixas|r")
            mainFrame.waypointBtn:Disable()
        end
        return
    end

    -- Ícone e Nome
    mainFrame.dIcon:SetTexture(toy.icon)
    local qColor = Data.QualityColors[toy.quality] or Data.QualityColors[1]
    mainFrame.dIconBorder:SetVertexColor(qColor.r, qColor.g, qColor.b)
    mainFrame.dName:SetText(string.format("|cff%s%s|r", qColor.hex, toy.name))
    mainFrame.dMeta:SetText(string.format("Item ID: |cffffd200%d|r  |  Qualidade: |cff%s%s|r", toy.itemID, qColor.hex, qColor.name))

    -- Banner de Status
    if toy.isCollected then
        mainFrame.statusBanner:SetBackdropColor(0.1, 0.45, 0.2, 0.95)
        mainFrame.statusBanner:SetBackdropBorderColor(0.23, 0.89, 0.45, 1)
        mainFrame.statusBannerText:SetText("|cffffffff✓ " .. L.STATUS_COLLECTED .. "|r")
    else
        mainFrame.statusBanner:SetBackdropColor(0.45, 0.1, 0.1, 0.95)
        mainFrame.statusBanner:SetBackdropBorderColor(1.0, 0.32, 0.32, 1)
        mainFrame.statusBannerText:SetText("|cffffffff✕ " .. L.STATUS_MISSING .. "|r")
    end

    -- Fonte Detalhada - Guia Passo a Passo para Iniciantes
    local srcMeta = Data.SourceTypes[toy.sourceType] or Data.SourceTypes["OTHER"]
    local difficulty = "|cff3ae374[FÁCIL / IMEDIATO]|r"
    local actionGuide = ""

    if toy.sourceType == "VENDOR" then
        difficulty = "|cff3ae374[FÁCIL - COMPRA DIRETA]|r"
        actionGuide = "Basta viajares até ao vendedor e comprar com ouro ou moedas da expansão. Não requer combates difíceis!"
    elseif toy.sourceType == "TREASURE" then
        difficulty = "|cff00e5ff[MÉDIO - EXPLORAÇÃO]|r"
        actionGuide = "O brinquedo está num baú escondido ou puzzle no mapa aberto. Clica no botão /way para marcar no mapa!"
    elseif toy.sourceType == "LOOT" then
        difficulty = "|cffffb142[SORTE - DROP DE CHEFE/MONSTRO]|r"
        actionGuide = "Tens de derrotar a criatura indicada. Pode não cair à primeira (pode exigir várias tentativas de farm)."
    elseif toy.sourceType == "QUEST" then
        difficulty = "|cff3ae374[GARANTIDO - MISSÃO / CAMPANHA]|r"
        actionGuide = "Recompensa garantida a 100% ao completar a missão indicada no jogo."
    elseif toy.sourceType == "ACHIEVEMENT" then
        difficulty = "|cffc56cf0[DESAFIO - CONQUISTA]|r"
        actionGuide = "Obtido ao completar os critérios da conquista correspondente."
    elseif toy.sourceType == "EVENT" then
        difficulty = "|cff3ae374[EVENTO TEMPORÁRIO / FERIADO]|r"
        actionGuide = "Só pode ser obtido enquanto este evento ou feriado estiver ativo no calendário do jogo."
    elseif toy.sourceType == "PROFESSION" then
        difficulty = "|cff17c0eb[CRIAÇÃO - PROFISSÃO]|r"
        actionGuide = "Criado através de uma profissão (ou podes encomendar na Casa de Leilões / Ordem de Serviço)."
    elseif toy.sourceType == "TRADING_POST" then
        difficulty = "|cffe15f41[POSTO DE TROCAS]|r"
        actionGuide = "Comprado com Moedas do Posto de Trocas (Trader's Tender) em Ventobravo ou Orgrimmar."
    else
        difficulty = "|cffa4b0be[OUTRO / ESPECIAL]|r"
        actionGuide = "Consulta as informações detalhadas abaixo."
    end

    local sourceExplanation = ""
    if toy.dbData and toy.dbData.guide and toy.dbData.guide ~= "" then
        local db = toy.dbData
        local coordStr = db.coords and string.format(" |cff00e5ff[📍 %s]|r", db.coords) or ""
        local costStr = db.cost and string.format("\n|cffffffffCusto / Moeda:|r |cffffd200%s|r", db.cost) or ""
        local targetStr = db.target and string.format("\n|cffffffffAlvo / NPC / Baú:|r |cffffffff%s|r", db.target) or ""
        
        sourceExplanation = string.format(
            "|cffffffffDificuldade:|r %s\n" ..
            "|cffffffffZona:|r |cffffd200%s|r%s%s%s\n\n" ..
            "|cffffd200Guia Passo a Passo (WoWhead Integrado):|r\n|cffffffff%s|r",
            db.difficulty or difficulty,
            db.zone or "Várias Zonas",
            coordStr,
            targetStr,
            costStr,
            db.guide or ""
        )
    else
        local cleanSource = toy.sourceText or "Fonte em verificação..."
        local zoneStr = ""
        if toy.dbData and toy.dbData.zone and toy.dbData.zone ~= "" then
            zoneStr = string.format("\n|cffffffffZona:|r |cffffd200%s|r", toy.dbData.zone)
        end
        if toy.dbData and toy.dbData.target and toy.dbData.target ~= "" then
            zoneStr = zoneStr .. string.format("\n|cffffffffAlvo / NPC:|r |cffffffff%s|r", toy.dbData.target)
        end
        sourceExplanation = string.format(
            "|cffffffffDificuldade:|r %s%s\n" ..
            "|cffffffffO que fazer:|r |cffffffff%s|r\n\n" ..
            "|cffffd200Fonte:|r %s\n" ..
            "|cff888888Dica: Abre o WoWhead para coordenadas exatas e comentários, ou marca no mapa com o botão verde abaixo (se houver coordenadas).|r",
            difficulty, zoneStr, actionGuide, cleanSource
        )
    end
    mainFrame.sourceDesc:SetText(sourceExplanation)

    -- Atualizar Botão de Waypoint / TomTom
    if mainFrame.waypointBtn and mainFrame.waypointText then
        if toy.coords or toy.waypoint then
            mainFrame.waypointText:SetText(string.format("|cffffd200📍 Ponto no Mapa /way|r  |cff00e5ff(%s)|r", toy.coords or "Marcar"))
            mainFrame.waypointBtn:SetBackdropColor(0.12, 0.32, 0.22, 0.95)
            mainFrame.waypointBtn:SetBackdropBorderColor(0.23, 0.89, 0.45, 1)
            mainFrame.waypointBtn:Enable()
        else
            mainFrame.waypointText:SetText("|cff888888📍 Sem Coordenadas Fixas|r")
            mainFrame.waypointBtn:SetBackdropColor(0.1, 0.1, 0.1, 0.6)
            mainFrame.waypointBtn:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.5)
            mainFrame.waypointBtn:Disable()
        end
    end

    -- Efeito / Descrição (Obter do Tooltip)
    local effectText = "Informação de efeito em cache..."
    if C_TooltipInfo and C_TooltipInfo.GetToyByItemID then
        local data = C_TooltipInfo.GetToyByItemID(toy.itemID)
        if data and data.lines then
            local linesFound = {}
            for _, line in ipairs(data.lines) do
                -- 12.0+: line.leftText pode ser Secret Value — guardar antes de qualquer operação de string
                local txt = line.leftText
                if txt ~= nil and issecretvalue and issecretvalue(txt) then txt = nil end
                if txt and txt ~= "" and not txt:find("^Fonte:") and not txt:find("^Source:") and not txt:find(toy.name or "") then
                    table.insert(linesFound, txt)
                end
            end
            if #linesFound > 0 then
                effectText = table.concat(linesFound, "\n")
            end
        end
    end
    mainFrame.effectDesc:SetText(effectText)

    -- Botão Favorita
    mainFrame.favDetailText:SetText(toy.isFavorite and "|cffffd200★ Nas Favoritas|r" or "★ Favorita")

    -- Ajusta o scroll do guia ao novo conteúdo
    self:UpdateSourceScroll()
end

--------------------------------------------------------------------------------
-- ATUALIZAÇÃO GERAL DA VIEW (Progresso, Scrollbar e Linhas)
--------------------------------------------------------------------------------
function ToyFinderUI:UpdateView(keepScroll)
    if not mainFrame or not mainFrame:IsShown() then return end

    -- Atualiza Barra de Progresso
    local stats = ToyFinder.stats
    mainFrame.progressBar:SetValue(tonumber(stats.percent) or 0)
    mainFrame.progressText:SetText(string.format(
        "|cffffffff%d|r de |cffffffff%d|r Brinquedos Obtidos (|cff00e5ff%s%%|r)   -   |cffff5252%d em Falta|r",
        stats.collected, stats.total, stats.percent, stats.missing
    ))

    -- Atualiza Abas e Rótulos de Filtro
    self:UpdateTabHighlight()
    self:UpdateFilterButtonLabels()

    -- Estado vazio quando a combinação de filtros não devolve resultados
    local totalFiltered = #ToyFinder.filteredToys

    -- Contador de resultados visíveis
    if mainFrame.resultsLabel then
        mainFrame.resultsLabel:SetText(string.format(L.RESULTS_COUNT, totalFiltered))
    end

    if totalFiltered == 0 then
        mainFrame.emptyState:Show()
        mainFrame.scrollBar:Hide()
    else
        mainFrame.emptyState:Hide()
        mainFrame.scrollBar:Show()
    end

    -- Atualiza Scrollbar (volta ao topo quando os filtros mudam, a menos que keepScroll)
    local maxOffset = math.max(1, totalFiltered - VISIBLE_ROWS + 1)
    mainFrame.scrollBar:SetMinMaxValues(1, maxOffset)
    if not keepScroll then
        mainFrame.scrollBar:SetValue(1)
    end

    local currentOffset = math.floor(mainFrame.scrollBar:GetValue())
    if currentOffset > maxOffset then
        currentOffset = maxOffset
        mainFrame.scrollBar:SetValue(currentOffset)
    end

    -- Atualiza Linhas
    self:UpdateRowContent(currentOffset)

    -- Se não houver brinquedo selecionado ou o selecionado saiu do filtro, seleciona o primeiro
    if not ToyFinder.selectedToy or not ToyFinder.toysByID[ToyFinder.selectedToy.itemID] then
        if totalFiltered > 0 then
            ToyFinder.selectedToy = ToyFinder.filteredToys[1]
        else
            ToyFinder.selectedToy = nil
        end
    end
    self:UpdateSelectedToyDetails()
end

--------------------------------------------------------------------------------
-- ABRIR / FECHAR JANELA (TOGGLE)
--------------------------------------------------------------------------------
function ToyFinderUI:Toggle()
    local f = self:CreateMainFrame()
    if f:IsShown() then
        f:Hide()
        PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
    else
        f:Show()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
        if #ToyFinder.toys == 0 then
            ToyFinder:ScanAllToys()
        else
            self:UpdateView()
        end
    end
end
