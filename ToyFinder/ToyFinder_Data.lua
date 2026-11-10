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
    [0] = { hex = "9d9d9d", r = 0.62, g = 0.62, b = 0.62, name = "Pobre" },
    [1] = { hex = "ffffff", r = 1.00, g = 1.00, b = 1.00, name = "Comum" },
    [2] = { hex = "1eff00", r = 0.12, g = 1.00, b = 0.00, name = "Incomum" },
    [3] = { hex = "0070dd", r = 0.00, g = 0.44, b = 0.87, name = "Raro" },
    [4] = { hex = "a335ee", r = 0.64, g = 0.21, b = 0.93, name = "Épico" },
    [5] = { hex = "ff8000", r = 1.00, g = 0.50, b = 0.00, name = "Lendário" },
    [6] = { hex = "e6cc80", r = 0.90, g = 0.80, b = 0.50, name = "Artefato" },
    [7] = { hex = "00ccff", r = 0.00, g = 0.80, b = 1.00, name = "Herança" },
}

-- Base de dados inicial de referência (para carregamento instantâneo de Toys famosas e recentes)
ToyFinderData.PreloadedSources = {
    -- Midnight / The War Within / Dragonflight / Clássicos
    [224449] = { source = "Vendedor: Alunira / Dornogal", type = "VENDOR", zone = "Ilha de Dorn" },
    [221966] = { source = "Tesouro: Baú de Joias em Azj-Kahet", type = "TREASURE", zone = "Azj-Kahet" },
    [219387] = { source = "Saque: Chefe de Raide / Palácio Nerub-ar", type = "LOOT", zone = "Palácio Nerub-ar" },
    [219302] = { source = "Missão: A Convocação da Guarda", type = "QUEST", zone = "Hallowfall" },
    [194885] = { source = "Tesouro: Baú Arcano de Valdrakken", type = "TREASURE", zone = "Valdrakken" },
    [198267] = { source = "Vendedor: Catalogador Jakes", type = "VENDOR", zone = "Costas Despertas" },
    [129149] = { source = "Vendedor: Jepetto Joybuzz (Dalaran)", type = "VENDOR", zone = "Dalaran" },
    [133543] = { source = "Vendedor: Lavador de Iaque Portátil", type = "VENDOR", zone = "Pandária" },
    [128807] = { source = "Saque: Moeda da Fortuna / Chefe Raro", type = "LOOT", zone = "Tanaan" },
    [118938] = { source = "Tesouro: Cofre Perdido de Draenor", type = "TREASURE", zone = "Gorgrond" },
}

-- Continentes e Expansões para Filtro Avançado
ToyFinderData.Continents = {
    { id = "ALL", name = "Todos os Continentes", short = "Todos", color = "ffffff" },
    {
        id = "KHAZ_ALGAR",
        name = "Khaz Algar (Midnight / TWW)",
        short = "Khaz Algar",
        color = "9d4edd",
        zones = { "Todas as Zonas", "Dornogal", "Ilha de Dorn", "Hallowfall", "Azj-Kahet", "O Fosso Profundo", "Palácio Nerub-ar" },
        patterns = { "khaz algar", "dornogal", "dorn", "hallowfall", "azj-kahet", "azj kahet", "fosso profundo", "ringing deeps", "nerub-ar", "alunira", "midnight", "lamplighter" }
    },
    {
        id = "DRAGON_ISLES",
        name = "Ilhas do Dragão (Dragonflight)",
        short = "Ilhas Dragão",
        color = "e55039",
        zones = { "Todas as Zonas", "Valdrakken", "Costas Despertas", "Planícies de Ohn'ahra", "Vastalguém", "Thaldraszus", "Caverna Zaralek", "Sonho Esmeralda" },
        patterns = { "dragon isles", "ilhas do dragão", "valdrakken", "costas despertas", "waking shores", "ohn'ahra", "vastalguém", "azure span", "thaldraszus", "zaralek", "emerald dream", "sonho esmeralda", "iskaara", "maruukai" }
    },
    {
        id = "SHADOWLANDS",
        name = "Terras Sombrias (Shadowlands)",
        short = "Shadowlands",
        color = "4a69bd",
        zones = { "Todas as Zonas", "Oribos", "Bastião", "Maldraxxus", "Ardenweald", "Revendreth", "A Gorja", "Korthia", "Zereth Mortis" },
        patterns = { "shadowlands", "terras sombrias", "oribos", "bastião", "bastion", "maldraxxus", "ardenweald", "revendreth", "gorja", "maw", "korthia", "zereth mortis", "torghast" }
    },
    {
        id = "BFA",
        name = "Zandalar & Kul Tiras (BfA)",
        short = "BfA",
        color = "0a3d62",
        zones = { "Todas as Zonas", "Dazar'alor", "Zuldazar", "Nazmir", "Vol'dun", "Tiragarde", "Drustvar", "Vale Cantonegrante", "Nazjatar", "Mechagon" },
        patterns = { "zandalar", "kul tiras", "dazar'alor", "zuldazar", "nazmir", "vol'dun", "tiragarde", "drustvar", "stormsong", "cantonegrante", "nazjatar", "mechagon", "boralus" }
    },
    {
        id = "BROKEN_ISLES",
        name = "Ilhas Partidas (Legion)",
        short = "Legion",
        color = "78e08f",
        zones = { "Todas as Zonas", "Dalaran (Legion)", "Azsuna", "Val'sharah", "Alta Montanha", "Trommheim", "Suramar", "Costa Partida", "Argus" },
        patterns = { "ilhas partidas", "broken isles", "dalaran:legion", "dalaran (legion)", "dalaran – legion", "azsuna", "val'sharah", "highmountain", "altamontanha", "stormheim", "trommheim", "suramar", "broken shore", "costa partida", "argus", "mac'aree" }
    },
    {
        id = "DRAENOR",
        name = "Draenor (Warlords)",
        short = "Draenor",
        color = "b71540",
        zones = { "Todas as Zonas", "Guarnição", "Selva de Tanaan", "Gorgrond", "Talador", "Picos de Arak", "Serra Fogofrio", "Vale da Lua Negra" },
        patterns = { "draenor", "guarnição", "garrison", "tanaan", "gorgrond", "talador", "spires of arak", "picos de arak", "frostfire", "fogofrio", "shadowmoon valley", "lua negra" }
    },
    {
        id = "PANDARIA",
        name = "Pandária (Mists of Pandaria)",
        short = "Pandária",
        color = "079992",
        zones = { "Todas as Zonas", "Floresta de Jade", "Vale dos Quatro Ventos", "Monte Kun-Lai", "Estepes de Taulong", "Ermos do Medo", "Vale das Flores Eternas", "Ilha Perene" },
        patterns = { "pandária", "pandaria", "floresta de jade", "jade forest", "four winds", "quatro ventos", "kun-lai", "townlong", "taulong", "dread wastes", "ermos do medo", "eternal blossoms", "flores eternas", "timeless isle", "ilha perene" }
    },
    {
        id = "NORTHREND",
        name = "Nortúndria (WotLK)",
        short = "Nortúndria",
        color = "82ccdd",
        zones = { "Todas as Zonas", "Dalaran (Northrend)", "Tundra Boreana", "Fiorde Uivante", "Colinas Pardas", "Zul'Drak", "Bacia Sholazar", "Picos Tempestuosos", "Coroa de Gelo", "Ulduar" },
        patterns = { "nortúndria", "northrend", "dalaran", "borean tundra", "tundra boreana", "howling fjord", "fiorde uivante", "grizzly hills", "colinas pardas", "zul'drak", "sholazar", "storm peaks", "coroa de gelo", "icecrown", "ulduar", "cristálgida" }
    },
    {
        id = "OUTLAND",
        name = "Terralém (The Burning Crusade)",
        short = "Terralém",
        color = "38ada9",
        zones = { "Todas as Zonas", "Shattrath", "Península do Fogo do Inferno", "Pântano Zangar", "Floresta Terokkar", "Nagrand", "Montanhas da Lâmina Afiada", "Ilha de Quel'Danas" },
        patterns = { "terralém", "outland", "shattrath", "hellfire", "fogo do inferno", "zangarmarsh", "terokkar", "nagrand", "blade's edge", "lâmina afiada", "netherstorm", "quel'danas", "quel danas" }
    },
    {
        id = "EASTERN_KINGDOMS",
        name = "Reinos do Leste (Classic / Cata)",
        short = "Reinos do Leste",
        color = "f6b93b",
        zones = { "Todas as Zonas", "Ventobravo", "Altaforja", "Garganta de Fogo", "Selva do Espinhaço", "Terras Pestilentas", "Tol Barad", "Pântano Vulpino", "Stratholme" },
        patterns = { "reinos do leste", "eastern kingdoms", "stormwind", "ventobravo", "ironforge", "altaforja", "stranglethorn", "espinhaço", "plaguelands", "pestilentas", "tol barad", "stratholme", "scholomance", "shadowfang", "theramore" }
    },
    {
        id = "KALIMDOR",
        name = "Kalimdor (Classic / Cata)",
        short = "Kalimdor",
        color = "e58e26",
        zones = { "Todas as Zonas", "Orgrimmar", "Valesfíngie", "Baldios", "Tanaris", "Feralas", "Silithus", "Monte Hyjal", "Cratera de Un'Goro", "Dire Maul" },
        patterns = { "kalimdor", "orgrimmar", "durotar", "barrens", "baldios", "tanaris", "feralas", "silithus", "hyjal", "un'goro", "dire maul", "mulgore", "teldrassil", "dustwallow" }
    },
    {
        id = "OTHER",
        name = "Outras / Várias Zonas",
        short = "Outras",
        color = "a4b0be"
    }
}

-- Filtros de Dificuldade de Obtenção
ToyFinderData.Difficulties = {
    { id = "ALL", name = "Todas as Dificuldades", short = "Dificuldade: Todas", color = "ffffff" },
    { id = "EASY", name = "🟢 Fácil / Compra Direta (Vendedor)", short = "🟢 Fácil", color = "3ae374" },
    { id = "QUEST", name = "🟢 Garantido (Missão / História)", short = "🟢 Missão", color = "ffb142" },
    { id = "EXPLORE", name = "🟡 Exploração (Tesouro / Baú)", short = "🟡 Tesouro", color = "00e5ff" },
    { id = "FARM", name = "🟠 Sorte / Farm (Saque / Chefe)", short = "🟠 Drop/Chefe", color = "ff5252" },
    { id = "EVENT", name = "🔵 Evento Mundial / Feriado", short = "🔵 Evento", color = "c56cf0" },
    { id = "OTHER", name = "⚪ Outros / Conquistas / Profissões", short = "⚪ Outros", color = "a4b0be" },
}
