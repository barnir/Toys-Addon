--[[
    ToyFinder - Data & Constants
    Definições de Expansões, Fontes (Vendedores, Loot, Tesouros), Cores e Metadados
]]

local addonName, ns = ...
ns.Data = ns.Data or {}
local ToyFinderData = ns.Data
local L = ns.L

-- Expansões de World of Warcraft (incluindo The War Within e Midnight 12.0)
ToyFinderData.Expansions = {
    [11] = { name = "Midnight", shortName = "12.0", color = "9d4edd", order = 1 },
    [10] = { name = "The War Within", shortName = "11.0", color = "ffaa00", order = 2 },
    [9]  = { name = "Dragonflight", shortName = "10.0", color = "e55039", order = 3 },
    [8]  = { name = "Shadowlands", shortName = "9.0", color = "4a69bd", order = 4 },
    [7]  = { name = "Battle for Azeroth", shortName = "8.0", color = "0a3d62", order = 5 },
    [6]  = { name = "Legion", shortName = "7.0", color = "78e08f", order = 6 },
    [5]  = { name = "Warlords of Draenor", shortName = "6.0", color = "b71540", order = 7 },
    [4]  = { name = "Mists of Pandaria", shortName = "5.0", color = "079992", order = 8 },
    [3]  = { name = "Cataclysm", shortName = "4.0", color = "e58e26", order = 9 },
    [2]  = { name = "Wrath of the Lich King", shortName = "3.0", color = "82ccdd", order = 10 },
    [1]  = { name = "The Burning Crusade", shortName = "2.0", color = "38ada9", order = 11 },
    [0]  = { name = "Classic", shortName = "1.0", color = "f6b93b", order = 12 },
}

-- Categorias de Obtenção com cores vibrantes e identificadores
ToyFinderData.SourceTypes = {
    ["VENDOR"] = {
        id = "VENDOR",
        tag = ns.L.TAG_VENDOR,
        name = ns.L.SOURCE_VENDOR,
        color = "ffd200",     -- Amarelo Ouro
        r = 1.0, g = 0.82, b = 0.0,
        icon = "Interface\\Icons\\INV_Misc_Coin_01",
    },
    ["LOOT"] = {
        id = "LOOT",
        tag = ns.L.TAG_LOOT,
        name = ns.L.SOURCE_LOOT,
        color = "ff5252",     -- Vermelho Coral
        r = 1.0, g = 0.32, b = 0.32,
        icon = "Interface\\Icons\\INV_Sword_04",
    },
    ["TREASURE"] = {
        id = "TREASURE",
        tag = ns.L.TAG_TREASURE,
        name = ns.L.SOURCE_TREASURE,
        color = "00e5ff",     -- Ciano Elétrico
        r = 0.0, g = 0.90, b = 1.0,
        icon = "Interface\\Icons\\INV_Box_01",
    },
    ["QUEST"] = {
        id = "QUEST",
        tag = ns.L.TAG_QUEST,
        name = ns.L.SOURCE_QUEST,
        color = "ffb142",     -- Laranja Dourado
        r = 1.0, g = 0.69, b = 0.26,
        icon = "Interface\\Icons\\QuestLegendaryTurnin",
    },
    ["ACHIEVEMENT"] = {
        id = "ACHIEVEMENT",
        tag = ns.L.TAG_ACHIEVEMENT,
        name = ns.L.SOURCE_ACHIEVEMENT,
        color = "c56cf0",     -- Roxo / Violeta
        r = 0.77, g = 0.42, b = 0.94,
        icon = "Interface\\Icons\\ACHIEVEMENT_GUILDPERK_LADIESANDGENTS",
    },
    ["EVENT"] = {
        id = "EVENT",
        tag = ns.L.TAG_EVENT,
        name = ns.L.SOURCE_EVENT,
        color = "3ae374",     -- Verde Primavera
        r = 0.23, g = 0.89, b = 0.45,
        icon = "Interface\\Icons\\INV_Misc_Ribbon_01",
    },
    ["PROFESSION"] = {
        id = "PROFESSION",
        tag = ns.L.TAG_PROFESSION,
        name = ns.L.SOURCE_PROFESSION,
        color = "17c0eb",     -- Azul Céu
        r = 0.09, g = 0.75, b = 0.92,
        icon = "Interface\\Icons\\Trade_Engineering",
    },
    ["TRADING_POST"] = {
        id = "TRADING_POST",
        tag = ns.L.TAG_TRADING_POST,
        name = ns.L.SOURCE_TRADING_POST,
        color = "e15f41",     -- Terracota
        r = 0.88, g = 0.37, b = 0.25,
        icon = "Interface\\Icons\\INV_Misc_Coin_17",
    },
    ["STORE"] = {
        id = "STORE",
        tag = ns.L.TAG_STORE,
        name = ns.L.SOURCE_STORE,
        color = "7158e2",     -- Púrpura Profundo
        r = 0.44, g = 0.35, b = 0.89,
        icon = "Interface\\Icons\\INV_Misc_Bag_07",
    },
    ["OTHER"] = {
        id = "OTHER",
        tag = ns.L.TAG_OTHER,
        name = ns.L.SOURCE_OTHER,
        color = "a4b0be",     -- Cinza Metálico
        r = 0.64, g = 0.69, b = 0.75,
        icon = "Interface\\Icons\\INV_Misc_QuestionMark",
    },
}

-- Padrões de deteção para parsing de tooltips em múltiplas línguas
ToyFinderData.SourcePatterns = {
    -- Vendedor
    VENDOR = {
        "vendedor", "vendor", "verkäufer", "vendeur", "vendedora",
        "custo:", "cost:", "kosten:", "coût:", "precio:", "vendido por",
        "sold by", "comprado de", "purchased from", "marchand"
    },
    -- Saque / Drop
    LOOT = {
        "saque", "drop", "botín", "beute", "butin",
        "chefe", "boss", "monstro", "creature", "criatura", "mob",
        "saqueado de", "dropped by", "despojado de", "dépouillé sur",
        "masmorra", "dungeon", "raide", "raid", "raro", "rare"
    },
    -- Tesouro
    TREASURE = {
        "tesouro", "treasure", "tesoro", "schatz", "trésor",
        "baú", "chest", "cofre", "truhe", "coffre", "container",
        "objeto", "puzzle", "escondido", "hidden", "gilded chest",
        "reliquary", "relicário", "relicario", "puzle", "enigma"
    },
    -- Missão
    QUEST = {
        "missão", "missao", "quest", "misión", "mision", "quête", "aufgabe",
        "recompensa de missão", "quest reward", "recompensa de misión",
        "campanha", "campaign", "campaña"
    },
    -- Conquista
    ACHIEVEMENT = {
        "conquista", "achievement", "logro", "erfolg", "haut fait",
        "recompensa de conquista", "achievement reward"
    },
    -- Eventos Mundiais
    EVENT = {
        "evento mundial", "world event", "evento del mundo", "weltereignis",
        "véu de inverno", "winter veil", "noturnália", "hallow's end",
        "festival da cerveja", "brewfest", "feira de negraluna", "darkmoon faire",
        "feriado", "holiday", "festival lunar", "lunar festival", "solstício",
        "midsummer", "amor no ar", "love is in the air", "páscoa", "noblegarden"
    },
    -- Profissões
    PROFESSION = {
        "profissão", "profissao", "profession", "profesión", "beruf",
        "engenharia", "engineering", "ingeniería",
        "alfaiataria", "tailoring", "sastrería",
        "joalheria", "jewelcrafting", "joyería",
        "inscrição", "inscription", "inscripción",
        "ferraria", "blacksmithing", "herrería",
        "couraria", "leatherworking", "peletería",
        "culinária", "cooking", "cocina",
        "pesca", "fishing", "pesca",
        "arqueologia", "archaeology", "arqueología"
    },
    -- Posto de Trocas
    TRADING_POST = {
        "posto de trocas", "trading post", "puesto comercial", "comptoir", "handelsposten"
    },
    -- Loja / Promoções
    STORE = {
        "loja", "store", "shop", "tienda", "boutique", "promoção", "promocao",
        "promotion", "promoción", "blizzard shop", "tcg"
    }
}

-- Ordem de prioridade para classificação de fontes (mais específico primeiro).
-- Evita que o resultado dependa da ordem aleatória do pairs().
ToyFinderData.SourcePriority = {
    "TREASURE", "QUEST", "ACHIEVEMENT", "EVENT", "PROFESSION", "TRADING_POST", "STORE", "VENDOR", "LOOT",
}

-- Cores de Qualidade de Item Padrão (WoW Standard)
ToyFinderData.QualityColors = {
    [0] = { hex = "9d9d9d", r = 0.62, g = 0.62, b = 0.62, name = "Poor" },
    [1] = { hex = "ffffff", r = 1.00, g = 1.00, b = 1.00, name = "Common" },
    [2] = { hex = "1eff00", r = 0.12, g = 1.00, b = 0.00, name = "Uncommon" },
    [3] = { hex = "0070dd", r = 0.00, g = 0.44, b = 0.87, name = "Rare" },
    [4] = { hex = "a335ee", r = 0.64, g = 0.21, b = 0.93, name = "Epic" },
    [5] = { hex = "ff8000", r = 1.00, g = 0.50, b = 0.00, name = "Legendary" },
    [6] = { hex = "e6cc80", r = 0.90, g = 0.80, b = 0.50, name = "Artifact" },
    [7] = { hex = "00ccff", r = 0.00, g = 0.80, b = 1.00, name = "Heirloom" },
}

-- Base de dados inicial de referência (para carregamento instantâneo de Toys famosas e recentes)
ToyFinderData.PreloadedSources = {
    -- Midnight / The War Within / Dragonflight / Clássicos
    [224449] = { source = "Vendedor: Alunira / Dornogal", type = "VENDOR", zone = "Isle of Dorn" },
    [221966] = { source = "Treasure: Jewel Chest in Azj-Kahet", type = "TREASURE", zone = "Azj-Kahet" },
    [219387] = { source = "Loot: Raid Boss / Nerub-ar Palace", type = "LOOT", zone = "Nerub-ar Palace" },
    [219302] = { source = "Quest: The Call of the Guard", type = "QUEST", zone = "Hallowfall" },
    [194885] = { source = "Treasure: Arcane Chest in Valdrakken", type = "TREASURE", zone = "Valdrakken" },
    [198267] = { source = "Vendedor: Catalogador Jakes", type = "VENDOR", zone = "The Waking Shores" },
    [129149] = { source = "Vendedor: Jepetto Joybuzz (Dalaran)", type = "VENDOR", zone = "Dalaran" },
    [133543] = { source = "Vendor: Portable Yak Washer", type = "VENDOR", zone = "Pandaria" },
    [128807] = { source = "Loot: Coin of Many Faces / Rare Boss", type = "LOOT", zone = "Tanaan" },
    [118938] = { source = "Treasure: Lost Cache of Draenor", type = "TREASURE", zone = "Gorgrond" },
}

-- Continentes e Expansões para Filtro Avançado
ToyFinderData.Continents = {
    { id = "ALL", name = "Todos os Continentes", short = "Todos", color = "ffffff" },
    {
        id = "KHAZ_ALGAR",
        name = "Khaz Algar (Midnight / TWW)",
        short = "Khaz Algar",
        color = "9d4edd",
        zones = { "All Zones", "Dornogal", "Isle of Dorn", "Hallowfall", "Azj-Kahet", "The Ringing Deeps", "Nerub-ar Palace" },
        patterns = { "khaz algar", "dornogal", "dorn", "hallowfall", "azj-kahet", "azj kahet", "fosso profundo", "ringing deeps", "nerub-ar", "alunira", "midnight", "lamplighter" }
    },
    {
        id = "DRAGON_ISLES",
        name = "Dragon Isles (Dragonflight)",
        short = "Dragon Isles",
        color = "e55039",
        zones = { "All Zones", "Valdrakken", "The Waking Shores", "Ohn'ahran Plains", "The Azure Span", "Thaldraszus", "Zaralek Cavern", "Emerald Dream" },
        patterns = { "dragon isles", "ilhas do dragão", "valdrakken", "costas despertas", "waking shores", "ohn'ahra", "vastalguém", "azure span", "thaldraszus", "zaralek", "emerald dream", "sonho esmeralda", "iskaara", "maruukai" }
    },
    {
        id = "SHADOWLANDS",
        name = "Shadowlands",
        short = "Shadowlands",
        color = "4a69bd",
        zones = { "All Zones", "Oribos", "Bastion", "Maldraxxus", "Ardenweald", "Revendreth", "The Maw", "Korthia", "Zereth Mortis" },
        patterns = { "shadowlands", "terras sombrias", "oribos", "bastião", "bastion", "maldraxxus", "ardenweald", "revendreth", "gorja", "maw", "korthia", "zereth mortis", "torghast" }
    },
    {
        id = "BFA",
        name = "Zandalar & Kul Tiras (BfA)",
        short = "BfA",
        color = "0a3d62",
        zones = { "All Zones", "Dazar'alor", "Zuldazar", "Nazmir", "Vol'dun", "Tiragarde Sound", "Drustvar", "Stormsong Valley", "Nazjatar", "Mechagon" },
        patterns = { "zandalar", "kul tiras", "dazar'alor", "zuldazar", "nazmir", "vol'dun", "tiragarde", "drustvar", "stormsong", "cantonegrante", "nazjatar", "mechagon", "boralus" }
    },
    {
        id = "BROKEN_ISLES",
        name = "Broken Isles (Legion)",
        short = "Legion",
        color = "78e08f",
        zones = { "All Zones", "Dalaran (Legion)", "Azsuna", "Val'sharah", "Highmountain", "Stormheim", "Suramar", "Broken Shore", "Argus" },
        patterns = { "ilhas partidas", "broken isles", "dalaran:legion", "dalaran (legion)", "dalaran – legion", "azsuna", "val'sharah", "highmountain", "altamontanha", "stormheim", "trommheim", "suramar", "broken shore", "costa partida", "argus", "mac'aree" }
    },
    {
        id = "DRAENOR",
        name = "Draenor (Warlords)",
        short = "Draenor",
        color = "b71540",
        zones = { "All Zones", "Garrison", "Tanaan Jungle", "Gorgrond", "Talador", "Spires of Arak", "Frostfire Ridge", "Shadowmoon Valley" },
        patterns = { "draenor", "guarnição", "garrison", "tanaan", "gorgrond", "talador", "spires of arak", "picos de arak", "frostfire", "fogofrio", "shadowmoon valley", "lua negra" }
    },
    {
        id = "PANDARIA",
        name = "Pandaria (Mists of Pandaria)",
        short = "Pandaria",
        color = "079992",
        zones = { "All Zones", "The Jade Forest", "Valley of the Four Winds", "Kun-Lai Summit", "Townlong Steppes", "Dread Wastes", "Vale of Eternal Blossoms", "Timeless Isle" },
        patterns = { "pandária", "pandaria", "floresta de jade", "jade forest", "four winds", "quatro ventos", "kun-lai", "townlong", "taulong", "dread wastes", "ermos do medo", "eternal blossoms", "flores eternas", "timeless isle", "ilha perene" }
    },
    {
        id = "NORTHREND",
        name = "Northrend (WotLK)",
        short = "Northrend",
        color = "82ccdd",
        zones = { "All Zones", "Dalaran (Northrend)", "Borean Tundra", "Howling Fjord", "Grizzly Hills", "Zul'Drak", "Sholazar Basin", "The Storm Peaks", "Icecrown", "Ulduar" },
        patterns = { "nortúndria", "northrend", "dalaran", "borean tundra", "tundra boreana", "howling fjord", "fiorde uivante", "grizzly hills", "colinas pardas", "zul'drak", "sholazar", "storm peaks", "coroa de gelo", "icecrown", "ulduar", "cristálgida" }
    },
    {
        id = "OUTLAND",
        name = "Outland (The Burning Crusade)",
        short = "Outland",
        color = "38ada9",
        zones = { "All Zones", "Shattrath", "Hellfire Peninsula", "Zangarmarsh", "Terokkar Forest", "Nagrand", "Blade's Edge Mountains", "Isle of Quel'Danas" },
        patterns = { "terralém", "outland", "shattrath", "hellfire", "fogo do inferno", "zangarmarsh", "terokkar", "nagrand", "blade's edge", "lâmina afiada", "netherstorm", "quel'danas", "quel danas" }
    },
    {
        id = "EASTERN_KINGDOMS",
        name = "Eastern Kingdoms (Classic / Cata)",
        short = "Eastern Kingdoms",
        color = "f6b93b",
        zones = { "All Zones", "Stormwind City", "Ironforge", "Searing Gorge", "Stranglethorn Vale", "Plaguelands", "Tol Barad", "Dustwallow Marsh", "Stratholme" },
        patterns = { "reinos do leste", "eastern kingdoms", "stormwind", "ventobravo", "ironforge", "altaforja", "stranglethorn", "espinhaço", "plaguelands", "pestilentas", "tol barad", "stratholme", "scholomance", "shadowfang", "theramore" }
    },
    {
        id = "KALIMDOR",
        name = "Kalimdor (Classic / Cata)",
        short = "Kalimdor",
        color = "e58e26",
        zones = { "All Zones", "Orgrimmar", "Ashenvale", "The Barrens", "Tanaris", "Feralas", "Silithus", "Mount Hyjal", "Un'Goro Crater", "Dire Maul" },
        patterns = { "kalimdor", "orgrimmar", "durotar", "barrens", "baldios", "tanaris", "feralas", "silithus", "hyjal", "un'goro", "dire maul", "mulgore", "teldrassil", "dustwallow" }
    },
    {
        id = "OTHER",
        name = "Outras / Various Zones",
        short = "Outras",
        color = "a4b0be"
    }
}

-- Filtros de Acquisition Difficulty
ToyFinderData.Difficulties = {
    { id = "ALL", name = "All Difficulties", short = "Difficulty: All", color = "ffffff" },
    { id = "EASY", name = "🟢 Easy / Direct Purchase (Vendor)", short = "🟢 Easy", color = "3ae374" },
    { id = "QUEST", name = "🟢 Guaranteed (Quest / Story)", short = "🟢 Quest", color = "ffb142" },
    { id = "EXPLORE", name = "🟡 Exploration (Treasure / Chest)", short = "🟡 Treasure", color = "00e5ff" },
    { id = "FARM", name = "🟠 RNG / Farm (Loot / Boss)", short = "🟠 Drop/Boss", color = "ff5252" },
    { id = "EVENT", name = "🔵 World Event / Holiday", short = "🔵 Event", color = "c56cf0" },
    { id = "OTHER", name = "⚪ Other / Achievements / Professions", short = "⚪ Other", color = "a4b0be" },
}
