--[[
    ToyFinder - Localizations (Locales)
    English only (see AGENTS.md language rule)
]]

local addonName, ns = ...
ns.L = ns.L or {}

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
    RESULTS_COUNT = "|cff00e5ff%d|r toys shown",
    
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



-- LANGUAGE RULE (AGENTS.md): the addon is 100% English — always use L_en,
-- regardless of the client locale. The metatable below still falls back to L_en.
ns.L = L_en

-- Allow lookup with fallback to English if key missing
setmetatable(ns.L, {
    __index = function(t, k)
        return L_en[k] or k
    end
})
