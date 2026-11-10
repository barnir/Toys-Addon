# tools/db — pipeline da base de dados do ToyFinder

Scripts para manter [ToyFinder_Database.lua](../../ToyFinder/ToyFinder_Database.lua) (estratégia em [docs/DB-STRATEGY.md](../../docs/DB-STRATEGY.md)).

## Ficheiros

- `gen_massdb.ps1` — regenera a tabela `MassDB` (EN) a partir das fontes em `sources/`.
- `merge_entries.ps1 -Files "a.lua,b.lua"` — junta blocos de guias completos (de agentes) à tabela `Entries`.
- `check_lua_syntax.ts` — verificador de sintaxe Lua (corre na sandbox TS do agente; ver cabeçalho do ficheiro).
- `agent_prompt_template.md` — prompt standard para agentes de pesquisa de guias.

## Fontes ( descarregar para cá se faltarem )

```
mkdir -p tools/db/sources
curl -L -o tools/db/sources/toys.db.lua    https://raw.githubusercontent.com/exochron/ToyBoxEnhanced/master/Database/toys.db.lua
curl -L -o tools/db/sources/egl_toys.json  https://elitegrindlab.com/data/wow/toys.json
# slugs para páginas individuais (opcional, para texto "how to get" mais rico):
pwsh -c '(Get-Content -Raw tools/db/sources/egl_toys.json | ConvertFrom-Json).rows | % { $_[10] }' > tools/db/sources/egl_slugs.txt
cat tools/db/sources/egl_slugs.txt | xargs -P 8 -n1 sh -c 'curl -sL "https://elitegrindlab.com$0/" -o "tools/db/sources/pages/$(basename $0).html"'
```

WoWHead/WowDB estão bloqueados a scraping direto — para coordenadas/NPCs usar agentes de pesquisa (web_search), nunca curl.

## Fluxo típico

1. `pwsh -File tools/db/gen_massdb.ps1` (regenerar MassDB após atualizar fontes)
2. escolher lote de IDs da MassDB sem guia → agentes com `agent_prompt_template.md`
3. `pwsh -File tools/db/merge_entries.ps1 -Files "agent1.lua,agent2.lua"`
4. correr `check_lua_syntax.ts` nos 6 ficheiros + scan de PT nos campos da DB
5. atualizar README/COMO-INSTALAR, reconstruir `ToyFinder.zip`, commit + push
