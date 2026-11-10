--[[
    ToyFinder - Minimap Button
    Botão no Minimapa com suporte para arrastar, estatísticas rápidas no tooltip e atalhos
]]

local addonName, ns = ...
ns.Minimap = ns.Minimap or {}
local ToyFinderMinimap = ns.Minimap
local ToyFinder = ns.ToyFinder
local ToyFinderUI = ns.UI
local L = ns.L

local minimapButton = nil

function ToyFinderMinimap:CreateButton()
    if minimapButton then return minimapButton end

    local btn = CreateFrame("Button", "ToyFinderMinimapBtn", Minimap)
    btn:SetSize(32, 32)
    btn:SetFrameStrata("MEDIUM")
    btn:SetFrameLevel(8)
    btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    -- Fundo circular do botão
    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetSize(22, 22)
    bg:SetPoint("CENTER", btn, "CENTER", 0, 0)
    bg:SetTexture("Interface\\Buttons\\WHITE8X8")
    bg:SetVertexColor(0.12, 0.08, 0.22, 1)

    -- Ícone do brinquedo
    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetSize(18, 18)
    icon:SetPoint("CENTER", btn, "CENTER", 0, 0)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Toy_01")
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    -- Borda oficial redonda de minimapa do WoW
    local border = btn:CreateTexture(nil, "OVERLAY")
    border:SetSize(54, 54)
    border:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

    -- Posicionamento angular em volta do Minimap
    local function UpdatePosition(angle)
        local rad = math.rad(angle)
        local cos = math.cos(rad)
        local sin = math.sin(rad)
        local radius = 80 -- Distância padrão do centro do minimapa
        btn:SetPoint("CENTER", Minimap, "CENTER", cos * radius, sin * radius)
    end

    btn:RegisterForDrag("LeftButton")
    btn:SetScript("OnDragStart", function(self)
        self.isDragging = true
        self:SetScript("OnUpdate", function(self)
            local mx, my = Minimap:GetCenter()
            local px, py = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            px, py = px / scale, py / scale
            local angle = math.deg(math.atan2(py - my, px - mx))
            if angle < 0 then angle = 360 + angle end
            if ToyFinderDB and ToyFinderDB.settings and ToyFinderDB.settings.minimap then
                ToyFinderDB.settings.minimap.angle = angle
            end
            UpdatePosition(angle)
        end)
    end)

    btn:SetScript("OnDragStop", function(self)
        self.isDragging = false
        self:SetScript("OnUpdate", nil)
    end)

    local clickHandlers = {
        LeftButton = function()
            if ToyFinderUI then
                ToyFinderUI:Toggle()
            end
        end,
        RightButton = function()
            -- Alternar rapidamente entre Em Falta e Todas
            if ToyFinder.activeFilter == "MISSING" then
                ToyFinder.activeFilter = "ALL"
            else
                ToyFinder.activeFilter = "MISSING"
            end
            ToyFinder:ApplyFilters()
            if ToyFinderUI and ToyFinderUI.UpdateView then
                ToyFinderUI:UpdateView()
            end
            print("|cff9d4eddToyFinder:|r Filter: " .. (ToyFinder.activeFilter == "MISSING" and "|cffff5252Missing|r" or "|cff3ae374All|r"))
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        end,
    }
    btn:SetScript("OnClick", function(self, button)
        local handler = clickHandlers[button]
        if handler then
            handler()
        end
    end)

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L.MINIMAP_TOOLTIP_TITLE, 0.62, 0.31, 0.94)
        GameTooltip:AddLine(" ")
        
        local stats = ToyFinder.stats
        GameTooltip:AddDoubleLine("Total Toys:", stats.total or 0, 1, 1, 1, 1, 0.82, 0)
        GameTooltip:AddDoubleLine("Collected:", string.format("%d (%s%%)", stats.collected or 0, stats.percent or "0"), 1, 1, 1, 0.23, 0.89, 0.45)
        GameTooltip:AddDoubleLine("Missing:", stats.missing or 0, 1, 1, 1, 1.0, 0.32, 0.32)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L.MINIMAP_LEFT_CLICK, 0.8, 0.8, 0.8)
        GameTooltip:AddLine(L.MINIMAP_RIGHT_CLICK, 0.8, 0.8, 0.8)
        GameTooltip:AddLine("|cffaaaaaaDrag to move the minimap button.|r", 0.6, 0.6, 0.6)
        GameTooltip:Show()
    end)

    btn:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Carregar posição salva
    local savedAngle = 45
    if ToyFinderDB and ToyFinderDB.settings and ToyFinderDB.settings.minimap then
        savedAngle = ToyFinderDB.settings.minimap.angle or 45
    end
    UpdatePosition(savedAngle)

    minimapButton = btn
    return btn
end

--------------------------------------------------------------------------------
-- INTEGRAÇÃO COM O COMPARTIMENTO DE ADDONS OFICIAL DO WOW (AddonCompartment)
--------------------------------------------------------------------------------
_G["ToyFinder_OnAddonCompartmentClick"] = function()
    if ToyFinderUI then
        ToyFinderUI:Toggle()
    end
end

_G["ToyFinder_OnAddonCompartmentEnter"] = function(button)
    GameTooltip:SetOwner(button, "ANCHOR_LEFT")
    GameTooltip:ClearLines()
    GameTooltip:AddLine(L.MINIMAP_TOOLTIP_TITLE, 0.62, 0.31, 0.94)
    GameTooltip:AddLine(" ")
    local stats = ToyFinder.stats
    GameTooltip:AddDoubleLine("Total Toys:", stats.total or 0, 1, 1, 1, 1, 0.82, 0)
    GameTooltip:AddDoubleLine("Collected:", string.format("%d (%s%%)", stats.collected or 0, stats.percent or "0"), 1, 1, 1, 0.23, 0.89, 0.45)
    GameTooltip:AddDoubleLine("Missing:", stats.missing or 0, 1, 1, 1, 1.0, 0.32, 0.32)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("|cffffffffClique:|r Abrir / Fechar ToyFinder", 0.8, 0.8, 0.8)
    GameTooltip:Show()
end

_G["ToyFinder_OnAddonCompartmentLeave"] = function()
    GameTooltip:Hide()
end

-- Inicializa o botão no login (despacho por tabela)
local minimapEvents = {
    PLAYER_LOGIN = function()
        ToyFinderMinimap:CreateButton()
    end,
}
local f = CreateFrame("Frame")
for eventName in pairs(minimapEvents) do
    f:RegisterEvent(eventName)
end
f:SetScript("OnEvent", function(self, event, ...)
    local handler = minimapEvents[event]
    if handler then
        handler(...)
    end
end)
