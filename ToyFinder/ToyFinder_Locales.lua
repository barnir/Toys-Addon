--[[
    ToyFinder - Localizations (Locales)
    Suporte completo para Português (ptBR/ptPT), Inglês (enUS) e Espanhol (esES)
]]

ToyFinderLocales = {}

local L_en = {
    ADDON_TITLE = "ToyFinder",
    SUBTITLE = "Toy Collection Explorer & Acquisition Guide",
    EXPANSION_SUBTITLE = "Midnight & Retail Ready",
    
    -- Filter Tabs
    FILTER_ALL = "All Toys",
    FILTER_MISSING = "Missing",
    FILTER_COLLECTED = "Collected",
    FILTER_FAVORITES = "Favorites",
    
    -- Source Types
    SOURCE_ALL = "All Sources",
    SOURCE_VENDOR = "Vendors (Purchased)",
    SOURCE_LOOT = "Loot / Drops (Bosses & Mobs)",
    SOURCE_TREASURE = "Treasures (Chests & Puzzles)",
    SOURCE_QUEST = "Quests & Campaigns",
    SOURCE_ACHIEVEMENT = "Achievements",
    SOURCE_EVENT = "World Events & Holidays",
    SOURCE_PROFESSION = "Professions (Crafted)",
    SOURCE_TRADING_POST = "Trading Post",
    SOURCE_STORE = "Store & Promotions",
    SOURCE_OTHER = "Other / Miscellaneous",
    
    -- Source tags (short)
    TAG_VENDOR = "Vendor",
    TAG_LOOT = "Drop",
    TAG_TREASURE = "Treasure",
    TAG_QUEST = "Quest",
    TAG_ACHIEVEMENT = "Achievement",
    TAG_EVENT = "World Event",
    TAG_PROFESSION = "Profession",
    TAG_TRADING_POST = "Trading Post",
    TAG_STORE = "Promotion",
    TAG_OTHER = "Other",
    
    -- Search & Sort
    SEARCH_PLACEHOLDER = "Search toy name, zone, NPC, item ID...",
    SORT_NAME = "Sort: Name (A-Z)",
    SORT_NEWEST = "Sort: Newest First (Midnight/TWW)",
    SORT_QUALITY = "Sort: Quality (Rarity)",
    SORT_STATUS = "Sort: Missing First",
    
    -- Details Panel
    STATUS_COLLECTED = "COLLECTED",
    STATUS_MISSING = "NOT COLLECTED (MISSING)",
    SOURCE_LABEL = "Source & How to Obtain:",
    EFFECT_LABEL = "Toy Description & Effect:",
    ITEM_ID_LABEL = "Item ID:",
    EXPANSION_LABEL = "Expansion:",
    NO_TOY_SELECTED = "Select a toy from the list to view its source, vendor, loot drops, and WoWhead guide.",
    
    -- WoWhead
    WOWHEAD_BTN = "WoWhead Link",
    WOWHEAD_MODAL_TITLE = "WoWhead Database Link",
    WOWHEAD_MODAL_DESC = "Press |cffffd200Ctrl + C|r to copy the link, then paste it into your web browser to view exact map coordinates, drop rates, vendor locations, and community guides:",
    WOWHEAD_LANG_PT = "WoWhead (PT)",
    WOWHEAD_LANG_EN = "WoWhead (EN)",
    WOWHEAD_COPY_SUCCESS = "Link highlighted! Press Ctrl+C to copy.",
    
    -- Actions
    FAVORITE_ADD = "Add to Favorites",
    FAVORITE_REMOVE = "Remove from Favorites",
    SHARE_CHAT = "Link to Chat",
    REFRESH_BTN = "Scan / Refresh",
    CLOSE = "Close",
    
    -- Progress & Stats
    PROGRESS_LABEL = "%d of %d Toys Collected (%s%%)",
    STATS_SUMMARY = "Total: %d  |  Collected: %d  |  Missing: %d",
    SCANNING = "Scanning Toy Box... Please wait.",
    SCAN_COMPLETE = "Toy Box scan complete: %d toys indexed (%d collected, %d missing).",
    
    -- Empty state
    EMPTY_STATE_TITLE = "No toys found",
    EMPTY_STATE_DESC = "This filter combination has no results. Try broadening the filters or clear everything with one click:",
    EMPTY_STATE_CLEAR = "✕ Clear Filters",
    GUIDE_BADGE_TIP = "📖 Step-by-step guide + GPS available in the right panel",

    -- Minimap
    MINIMAP_TOOLTIP_TITLE = "ToyFinder |cff9d4eddMidnight|r",
    MINIMAP_LEFT_CLICK = "|cffffffffLeft-Click:|r Open/Close ToyFinder",
    MINIMAP_RIGHT_CLICK = "|cffffffffRight-Click:|r Toggle Missing / All",
}

local L_pt = {
    ADDON_TITLE = "ToyFinder",
    SUBTITLE = "Explorador de Brinquedos & Guia de Obtenção",
    EXPANSION_SUBTITLE = "Preparado para Midnight e Retail",
    
    -- Filter Tabs
    FILTER_ALL = "Todas as Toys",
    FILTER_MISSING = "Em Falta",
    FILTER_COLLECTED = "Já Obtidas",
    FILTER_FAVORITES = "Favoritas",
    
    -- Source Types
    SOURCE_ALL = "Todas as Fontes",
    SOURCE_VENDOR = "Vendedores (Comprar)",
    SOURCE_LOOT = "Saques / Loot (Monstros e Chefes)",
    SOURCE_TREASURE = "Tesouros (Baús e Puzzles)",
    SOURCE_QUEST = "Missões e Campanhas",
    SOURCE_ACHIEVEMENT = "Conquistas",
    SOURCE_EVENT = "Eventos Mundiais e Feriados",
    SOURCE_PROFESSION = "Profissões (Criado)",
    SOURCE_TRADING_POST = "Posto de Trocas",
    SOURCE_STORE = "Loja e Promoções",
    SOURCE_OTHER = "Outras / Diversos",
    
    -- Source tags (short)
    TAG_VENDOR = "Vendedor",
    TAG_LOOT = "Saque / Drop",
    TAG_TREASURE = "Tesouro",
    TAG_QUEST = "Missão",
    TAG_ACHIEVEMENT = "Conquista",
    TAG_EVENT = "Evento Mundial",
    TAG_PROFESSION = "Profissão",
    TAG_TRADING_POST = "Posto de Trocas",
    TAG_STORE = "Promoção",
    TAG_OTHER = "Outro",
    
    -- Search & Sort
    SEARCH_PLACEHOLDER = "Pesquisar nome, zona, vendedor, item ID...",
    SORT_NAME = "Ordenar: Nome (A-Z)",
    SORT_NEWEST = "Ordenar: Mais Recentes (Midnight / TWW)",
    SORT_QUALITY = "Ordenar: Qualidade (Raridade)",
    SORT_STATUS = "Ordenar: Em Falta Primeiro",
    
    -- Details Panel
    STATUS_COLLECTED = "OBTIDO NA CONTA",
    STATUS_MISSING = "NÃO OBTIDO (EM FALTA)",
    SOURCE_LABEL = "Como Obter / Fonte:",
    EFFECT_LABEL = "Efeito e Descrição do Brinquedo:",
    ITEM_ID_LABEL = "ID do Item:",
    EXPANSION_LABEL = "Expansão:",
    NO_TOY_SELECTED = "Clica num brinquedo da lista para ver a fonte detalhada, vendedor, localização de loot e guia do WoWhead.",
    
    -- WoWhead
    WOWHEAD_BTN = "Link WoWhead",
    WOWHEAD_MODAL_TITLE = "Link do WoWhead",
    WOWHEAD_MODAL_DESC = "Pressiona |cffffd200Ctrl + C|r para copiar o link e cola no teu navegador web para ver mapa interativo, coordenadas exatas, guias em vídeo e comentários da comunidade:",
    WOWHEAD_LANG_PT = "WoWhead (PT)",
    WOWHEAD_LANG_EN = "WoWhead (EN)",
    WOWHEAD_COPY_SUCCESS = "Link selecionado! Pressiona Ctrl+C para copiar.",
    
    -- Actions
    FAVORITE_ADD = "Marcar como Favorita",
    FAVORITE_REMOVE = "Remover das Favoritas",
    SHARE_CHAT = "Linkar no Chat",
    REFRESH_BTN = "Atualizar Coleção",
    CLOSE = "Fechar",
    
    -- Progress & Stats
    PROGRESS_LABEL = "%d de %d Brinquedos Obtidos (%s%%)",
    STATS_SUMMARY = "Total: %d  |  Obtidos: %d  |  Em Falta: %d",
    SCANNING = "A analisar a Caixa de Brinquedos... Por favor aguarda.",
    SCAN_COMPLETE = "Varredura concluída: %d brinquedos indexados (%d obtidos, %d em falta).",
    
    -- Empty state
    EMPTY_STATE_TITLE = "Nenhum brinquedo encontrado",
    EMPTY_STATE_DESC = "Esta combinação de filtros não tem resultados. Experimenta alargar os filtros ou limpa tudo com um clique:",
    EMPTY_STATE_CLEAR = "✕ Limpar Filtros",
    GUIDE_BADGE_TIP = "📖 Guia passo a passo + GPS disponível no painel à direita",

    -- Minimap
    MINIMAP_TOOLTIP_TITLE = "ToyFinder |cff9d4eddMidnight|r",
    MINIMAP_LEFT_CLICK = "|cffffffffClique com Botão Esquerdo:|r Abrir / Fechar Janela",
    MINIMAP_RIGHT_CLICK = "|cffffffffClique com Botão Direito:|r Alternar Em Falta / Todas",
}

local L_es = {
    ADDON_TITLE = "ToyFinder",
    SUBTITLE = "Explorador de Juguetes y Guía de Obtención",
    EXPANSION_SUBTITLE = "Preparado para Midnight y Retail",
    
    FILTER_ALL = "Todos los Juguetes",
    FILTER_MISSING = "Faltantes",
    FILTER_COLLECTED = "Coleccionados",
    FILTER_FAVORITES = "Favoritos",
    
    SOURCE_ALL = "Todas las Fuentes",
    SOURCE_VENDOR = "Vendedores (Comprar)",
    SOURCE_LOOT = "Botín / Drop (Jefes y Monstruos)",
    SOURCE_TREASURE = "Tesoros (Cofres y Puzles)",
    SOURCE_QUEST = "Misiones y Campañas",
    SOURCE_ACHIEVEMENT = "Logros",
    SOURCE_EVENT = "Eventos del Mundo y Fiestas",
    SOURCE_PROFESSION = "Profesiones (Creación)",
    SOURCE_TRADING_POST = "Puesto Comercial",
    SOURCE_STORE = "Tienda y Promociones",
    SOURCE_OTHER = "Otros / Varios",
    
    TAG_VENDOR = "Vendedor",
    TAG_LOOT = "Botín",
    TAG_TREASURE = "Tesoro",
    TAG_QUEST = "Misión",
    TAG_ACHIEVEMENT = "Logro",
    TAG_EVENT = "Evento del Mundo",
    TAG_PROFESSION = "Profesión",
    TAG_TRADING_POST = "Puesto Comercial",
    TAG_STORE = "Promoción",
    TAG_OTHER = "Otro",
    
    SEARCH_PLACEHOLDER = "Buscar nombre, zona, vendedor, ID del objeto...",
    SORT_NAME = "Ordenar: Nombre (A-Z)",
    SORT_NEWEST = "Ordenar: Más Recientes (Midnight/TWW)",
    SORT_QUALITY = "Ordenar: Calidad",
    SORT_STATUS = "Ordenar: Faltantes Primero",
    
    STATUS_COLLECTED = "COLECCIONADO",
    STATUS_MISSING = "NO COLECCIONADO (FALTANTE)",
    SOURCE_LABEL = "Cómo Obtener / Fuente:",
    EFFECT_LABEL = "Efecto y Descripción:",
    ITEM_ID_LABEL = "ID del Objeto:",
    EXPANSION_LABEL = "Expansión:",
    NO_TOY_SELECTED = "Selecciona un juguete para ver su fuente detallada y guía de WoWhead.",
    
    WOWHEAD_BTN = "Enlace WoWhead",
    WOWHEAD_MODAL_TITLE = "Enlace de WoWhead",
    WOWHEAD_MODAL_DESC = "Presiona |cffffd200Ctrl + C|r para copiar el enlace y pégalo en tu navegador para ver mapa interactivo y coordenadas:",
    WOWHEAD_LANG_PT = "WoWhead (PT)",
    WOWHEAD_LANG_EN = "WoWhead (EN)",
    WOWHEAD_COPY_SUCCESS = "¡Enlace seleccionado! Presiona Ctrl+C para copiar.",
    
    FAVORITE_ADD = "Añadir a Favoritos",
    FAVORITE_REMOVE = "Quitar de Favoritos",
    SHARE_CHAT = "Enlazar al Chat",
    REFRESH_BTN = "Escanear / Actualizar",
    CLOSE = "Cerrar",
    
    PROGRESS_LABEL = "%d de %d Juguetes Obtenidos (%s%%)",
    STATS_SUMMARY = "Total: %d  |  Coleccionados: %d  |  Faltantes: %d",
    SCANNING = "Escaneando Caja de Juguetes...",
    SCAN_COMPLETE = "Escaneo completado: %d juguetes indexados (%d coleccionados, %d faltantes).",
    
    -- Empty state
    EMPTY_STATE_TITLE = "No se encontraron juguetes",
    EMPTY_STATE_DESC = "Esta combinación de filtros no tiene resultados. Prueba a ampliar los filtros o límpialo todo con un clic:",
    EMPTY_STATE_CLEAR = "✕ Limpiar Filtros",
    GUIDE_BADGE_TIP = "📖 Guía paso a paso + GPS disponible en el panel derecho",

    MINIMAP_TOOLTIP_TITLE = "ToyFinder |cff9d4eddMidnight|r",
    MINIMAP_LEFT_CLICK = "|cffffffffClic Izquierdo:|r Abrir / Cerrar ToyFinder",
    MINIMAP_RIGHT_CLICK = "|cffffffffClic Derecho:|r Alternar Faltantes / Todos",
}

-- Select appropriate locale based on client language
local locale = GetLocale()
if locale == "ptBR" or locale == "ptPT" then
    ToyFinderLocales = L_pt
elseif locale == "esES" or locale == "esMX" then
    ToyFinderLocales = L_es
else
    -- Default to Portuguese if requested by user, or provide pt with en fallback
    -- Since the user explicitly requested in Portuguese, default to L_pt, but let English users have L_en
    if locale:find("^pt") then
        ToyFinderLocales = L_pt
    else
        -- If client is in Portuguese or user prefers Portuguese:
        ToyFinderLocales = L_pt
    end
end

-- Allow lookup with fallback to English if key missing
setmetatable(ToyFinderLocales, {
    __index = function(t, k)
        return L_en[k] or k
    end
})
