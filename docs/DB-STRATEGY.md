# Estratégia da Base de Dados — ToyFinder

Objetivo: **cobertura máxima de toys com a melhor informação possível de "como obter e onde ir"** (fonte, zona, NPC/alvo, custo, expansão, coordenadas GPS e guia passo a passo), 100% em inglês, verificada e maintenível.

Estado atual (v1.9.3): **306 guias completos** (`Entries`) + **927 entradas MassDB** = **1.181 IDs únicos** (v1.9.3: +32 verified guides TWW/Dragonflight vendors & treasures).

---

## 1. Arquitetura da base de dados (`ToyFinder/ToyFinder_Database.lua`)

Dois níveis, lidos por `ToyFinderDatabase:GetToyData(itemID)` (Entries primeiro, depois MassDB):

| Nível | Tabela | Quando usar | Campos |
|---|---|---|---|
| Guias completos | `Entries` | Toy tem guia passo a passo verificado com coordenadas GPS (mostra badge 📖 e botão /way ativo) | `name, sourceType, zone, coords, target, cost, difficulty, guide, waypoint, expansion?` |
| Entradas em massa | `MassDB` | Cobertura lata de todos os toys (~1.000) com fonte/zona/NPC/custo | compactos: `n, t, s, z, g, e, c, p` → expandidos por `GetToyData` |

Regras de qualidade dos dados:
- **100% inglês** (regra permanente do AGENTS.md) — nomes, zonas (em inglês, compatíveis com `/way`), guias, fontes.
- `waypoint` sempre no formato `/way <ZoneNameInEnglish> x.x y.y <Label>`.
- `sourceType` ∈ VENDOR, LOOT, TREASURE, QUEST, ACHIEVEMENT, EVENT, PROFESSION, TRADING_POST, STORE, OTHER.
- Sem ponto-e-vírgula; Lua 5.1; strings escapadas.

## 2. Fontes de dados e pipeline (scripts em [tools/db/](../tools/db/))

| Fonte | O que dá | Como obter |
|---|---|---|
| [ToyBoxEnhanced](https://github.com/exochron/ToyBoxEnhanced) `Database/toys.db.lua` | mapa itemID → nome EN (~1.161 toys) | `curl -o tools/db/sources/toys.db.lua https://raw.githubusercontent.com/exochron/ToyBoxEnhanced/master/Database/toys.db.lua` |
| [WoWDB](https://thewowdb.com/toys/) (⭐ fonte primária, datamined do build retail atual) | 1.147 toys com ID, nome, source type + por página "How to Obtain" (vendor/NPC/zona/custo) | list: `curl -o tools/db/sources/wowdb_toys.html https://thewowdb.com/toys/` → parsear `wowdb_cards.tsv`; páginas: `xargs` com `-P 2` + `sleep` (Cloudflare rate-limits a -P 8, error 1015) → parsear para `wowdb_obtain.tsv`; usar `tools/db/gen_massdb_wowdb.ps1` |
| [EliteGrindLab](https://elitegrindlab.com/wow/toys/) `/data/wow/toys.json` | 1.137 toys com source/group/detail/expansion/npc/zone/cost/slug (fallback + expansão) | `curl -o tools/db/sources/egl_toys.json https://elitegrindlab.com/data/wow/toys.json` |
| Páginas individuais EGL `/wow/toys/<slug>/` | texto "How to get it" estruturado (dt/dd) | `cat tools/db/sources/egl_slugs.txt \| xargs -P 8 -n1 sh -c 'curl -sL "https://elitegrindlab.com$0/" -o "tools/db/sources/pages/$(basename $0).html"'` |
| WoWHead/WowDB/Wowpedia | coordenadas exatas, NPCs, drop rates | **scraping bloqueado** — usar agentes de pesquisa (web_search), nunca curl direto |

Pipeline MassDB: `tools/db/gen_massdb.ps1` (join por nome normalizado toys.db.lua × egl_toys.json, classifica `t`, gera `s/z/g/e/c/p`, substitui o bloco MassDB no ficheiro). Repetir sempre que as fontes atualizarem.

## 3. Guias completos via agentes de pesquisa

Fluxo por lote (já usado com sucesso em 4 rondas: +36, +37, +35, +38 guias):

1. Escolher lote de IDs: MassDB entries sem guia, priorizando VENDOR/TREASURE/LOOT em zonas populares (ver `grep` de zonas no ficheiro).
2. Lançar 2-3 sub-agentes em paralelo (~15-20 IDs cada) com o [prompt template](../tools/db/agent_prompt_template.md).
3. Regras do agente: mínimo 2 fontes verificadas por entrada; coordenadas cruzadas; omitir o que não confirmar; saída em bloco Lua EN, sem `;`.
4. Juntar os blocos com `tools/db/merge_entries.ps1` (insere no fim da tabela `Entries`).
5. Portar um ID de MassDB para Entries remove-o da MassDB na regeneração seguinte (GetToyData dá prioridade a Entries de qualquer forma).

## 4. Portas de qualidade (antes de cada commit)

- `tools/db/check_lua_syntax.ts` (sandbox TS do agente): lexer + balanceamento de chavetas/blocos + deteção de `,,`, `;;`, `;` no fim de linha → corre sobre os 6 ficheiros `.lua`.
- Scan de PT nos campos da DB (name/guide/zone/target/cost/sourceText) — deve dar zero.
- Contagem de entradas (Entries vs MassDB) e IDs duplicados entre níveis.
- Atualizar README/COMO-INSTALAR com os números novos; reconstruir `ToyFinder.zip`.

## 5. Roadmap / prioridades seguintes

1. **Mais guias completos** nas zonas com mais MassDB e menos guides: Dragonflight treasures (The Waking Shores, Ohn'ahran, Thaldraszus, Zaralek, Emerald Dream), TWW (Isle of Dorn, The Ringing Deeps, Azj-Kahet), Shadowlands covenant zones, Legion rares, Classic dungeons/raids.
2. **Coordenadas para MassDB**: agentes podem enriquecer entradas MassDB existentes com `coords`/`waypoint` (mover para Entries ou adicionar campos à MassDB).
3. **Filtros por expansão**: o campo `e` já existe na MassDB — expor filtro "Expansão" no dropdown de continentes quando houver UI para isso.
4. **Atualização por patch**: o agente `wow-addon-news-desk` corre no início de cada patch; se o ToyBoxEnhanced/EGL atualizarem, regenerar MassDB.
5. **Qualidade sobre quantidade**: nunca sacrificar verificação — entradas não verificadas ficam como MassDB básica, nunca como guia completo.

## 6. Anti-padrões (já cometidos e corrigidos)

- Não meter guias completos dentro da tabela MassDB (campos errados) — usar sempre `merge_entries.ps1`.
- Não introduzir `},,` ao juntar blocos — o merge script e o syntax check apanham.
- Não traduzir os padrões de deteção (SOURCE_LABELS/SourcePatterns) — são input multilingue, não output.
