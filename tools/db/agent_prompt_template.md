# Prompt template para agentes de guias completos (ToyFinder DB)

Copia este texto como prompt da tarefa, substituindo a LISTA DE IDs:

---

CONTEXTO: Base de dados do addon WoW "ToyFinder" (repo https://github.com/barnir/Toys-Addon, ficheiro ToyFinder/ToyFinder_Database.lua, tabela "Entries"). O addon é 100% INGLÊS (regra permanente): todas as entradas em inglês, nada de português.

TAREFA: para CADA item ID da lista, pesquisa na web (wowhead `item=ID`, wowdb, wowpedia, warcraft.wiki.gg, wow-pro, icy-veins, method.gg, wowhead comments para coordenadas) e produz UMA entrada Lua neste formato EXATO, em inglês:

    [ID] = { name = "English name", sourceType = "VENDOR|LOOT|TREASURE|QUEST|ACHIEVEMENT|EVENT|PROFESSION|TRADING_POST|STORE|OTHER", zone = "Zone (English, /way-compatible)", coords = "x.x, y.y", target = "NPC/boss/chest name", cost = "cost or Free", difficulty = "Very Easy/Easy/Medium/Farm", guide = "1. ...\n2. ...\n3. ...", waypoint = "/way ZoneName x.x y.y Label" },

REGRAS:
- Mínimo 2 fontes verificadas por entrada; coordenadas cruzadas entre pelo menos 2 guias com coordenadas.
- Se não encontrares fonte/coordenadas verificadas, OMITE o item e lista os omitidos no fim.
- waypoint usa SEMPRE o nome da zona em inglês (/way Valdrakken, /way The Azure Span, /way Zaralek Cavern, /way Shadowmoon Valley DR, /way Icecrown, /way Shattrath City, /way Drustvar, /way Mechagon, /way Revendreth, /way Maldraxxus, /way Korthia, /way Emerald Dream, /way The Ringing Deeps ...).
- Guia em inglês, 2-5 passos, linguagem para iniciantes ("travel to X, find Y at coords, kill/loot, done").
- Itens de evento já terminados: mantém a entrada mas marca no guia "no longer obtainable".
- Itens que não são toys (junk, transmog templates): omite.
- Sem ponto-e-vírgula em lado nenhum.

ENTREGA: responde apenas com o bloco Lua completo dentro de um bloco de código ```lua, e a lista de IDs omitidos.

LISTA DE IDs:
<colocar aqui, separados por vírgula>
