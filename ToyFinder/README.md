# ToyFinder (Midnight & Retail) - Addon para World of Warcraft

O **ToyFinder** é um addon completo e moderno para World of Warcraft (preparado para **Midnight 12.0** e versões atuais de **The War Within / Retail 11.x**). Ele permite explorar todos os brinquedos (toys) existentes no jogo, verificar instantaneamente quais já tens na tua conta ou quais estão em falta, descobrir onde são obtidos (**Vendedores**, **Loot / Drops**, **Tesouros**, **Missões**, etc.) e obter **links diretos do WoWhead** para abrir no teu navegador com mapas, coordenadas e comentários.

---

## ✨ Funcionalidades Principais

1. **Catálogo Completo de Brinquedos (Toys)**:
   - Indexa automaticamente todos os brinquedos do World of Warcraft.
   - Suporte para as mais recentes expansões (*Midnight* e *The War Within*).
   - Mostra ícone com moldura colorida por raridade (Comum, Incomum, Raro, Épico).

2. **Filtro Rápido de Obtenção**:
   - **Todas as Toys**: Vê o catálogo completo.
   - **✕ Em Falta (Não Obtidas)**: Foca-te apenas nos brinquedos que ainda não tens para colecionar.
   - **✓ Já Obtidas**: Visualiza tudo o que a tua conta já desbloqueou.
   - **★ Favoritas**: Lista de desejos pessoal para itens que estás a farmar ativamente.

3. **Sistema Completo de Filtros Avançados**:
   - 📦 **Forma de Obtenção / Tipo de Loot**:
     - 💰 **Vendedores**: Compra direta com ouro ou moedas.
     - 📦 **Tesouros**: Baús escondidos, puzzles e contentores.
     - ⚔️ **Saques / Loot**: Drops de chefes de raide, masmorras e monstros raros.
     - 📜 **Missões**: Recompensas de campanhas e missões secundárias.
     - 🏆 **Conquistas**: Feitos de força e metas de coleção.
     - 🎪 **Eventos Mundiais**: Noturnália, Véu de Inverno, Feira de Negraluna, etc.
     - ⚙️ **Profissões**: Engenharia, Alfaiataria, Couraria, etc.
     - 🏛️ **Posto de Trocas & Promoções**.
   - 🌍 **Filtro por Continente / Expansão**:
     - Khaz Algar (*Midnight* e *The War Within*)
     - Ilhas do Dragão (*Dragonflight*)
     - Terras Sombrias (*Shadowlands*)
     - Zandalar e Kul Tiras (*Battle for Azeroth*)
     - Ilhas Partidas (*Legion*)
     - Draenor (*Warlords of Draenor*)
     - Pandária (*Mists of Pandaria*)
     - Nortúndria (*Wrath of the Lich King*)
     - Terralém (*The Burning Crusade*)
     - Reinos do Leste & Kalimdor (*Classic / Cataclysm*)
   - 📍 **Filtro por Zona Específica**:
     - Filtra diretamente por cidades e zonas (ex: *Dornogal*, *Ilha de Dorn*, *Hallowfall*, *Azj-Kahet*, *Valdrakken*, *Dalaran*, *Oribos*, etc.).
   - ⚡ **Filtro por Dificuldade**:
     - *Fácil (Compra Direta)*, *Garantido (Missão)*, *Exploração (Tesouro)*, *Sorte / Farm (Drop de Chefe)*.
   - ✕ **Botão Limpar Filtros**:
     - Repõe todas as seleções no estado inicial com 1 clique!

4. **Base de Dados Offline Integrada & TomTom (/way)**:
   - **Mais de 1.150 IDs únicos cobertos (144 guias completos + 1.043 entradas MassDB);
   - As entradas da base de dados em massa são geradas a partir de dados da comunidade (ToyBoxEnhanced + EliteGrindLab) e as guias completos são curadas manualmente e com agentes de pesquisa que verificam fontes no WoWhead/WowDB/Wowpedia.
   - Inclui coordenadas GPS precisas e botão `[ 📍 Ponto no Mapa /way (TomTom) ]` que cria uma seta no ecrã automaticamente!
   - O painel do guia tem **barra de rolagem**: guias longos nunca ficam cortados.
   - Badge **📖** na lista marca os brinquedos que têm guia completo com GPS integrado.
   - Se uma combinação de filtros não tiver resultados, aparece um **ecrã de estado vazio** com botão para limpar os filtros com 1 clique.
   - Mantém o botão opcional para o WoWhead caso queiras ver vídeos ou comentários da comunidade.

5. **Interface Moderna Midnight**:
   - Estética inspirada no Vazio e Arcano com tema Midnight.
   - Barra de progresso da coleção em tempo real com percentagem e contagem.
   - Pesquisa instantânea por nome, zona, vendedor ou ID do item.
   - Painel lateral de inspeção com descrição completa do brinquedo e efeito de uso.
   - Dropdowns de filtros muestran **contagem de brinquedos por categoria** (ex: `💰 Vendedores (38)`).
   - A posição da janela é **memorizada** entre sessões.
   - Botão no Minimapa arrastável com resumo rápido e atalhos de clique.

---

## 🗄️ Estrutura da Base de Dados

O ficheiro `ToyFinder_Database.lua` tem dois níveis:

1. **`Entries`** — guias completos (com `guide`, `coords`, `waypoint`, `cost`, `target`), escritos à mão ou por agentes de pesquisa com verificação de fontes. Estas toys mostram o badge **📖** na lista e o botão verde de GPS ativo.
2. **`MassDB`** — entradas compactas geradas automaticamente (`n` = nome, `t` = tipo de fonte, `s` = texto da fonte, `z` = zona, `g` = NPC) cobrindo ~1.080 toys. Servem para filtros, pesquisa e painel de detalhes; o guia completo pode ser adicionado a qualquer uma movendo-a para `Entries`.

Para expandir: adiciona entradas a `Entries` (guias completos) ou regenera a `MassDB` a partir dos dados da comunidade (pipeline: `toys.db.lua` do ToyBoxEnhanced + `/data/wow/toys.json` da EliteGrindLab, com join por nome). A documentação (este README e `COMO-INSTALAR.txt`) deve ser atualizada em conjunto com qualquer alteração.

## 🛠️ Convenções de desenvolvimento (Midnight 12.0 / Interface 120001)

- Cada ficheiro `.lua` começa com `local addonName, ns = ...`; toda a API do addon vive em `ns` (`ns.L`, `ns.Data`, `ns.Database`, `ns.ToyFinder`, `ns.UI`, `ns.Minimap`). O único global permitido é a SavedVariable declarada no `.toc` (`ToyFinderDB`) — mais as excepções obrigatórias do engine: `SLASH_*`/`SlashCmdList` (slash commands) e as funções `AddonCompartmentFunc*` do `.toc`.
- Eventos usam **despacho por tabela** (`local handlers = { EVENT = function(...) end }` + `RegisterEvent` em loop), nunca cadeias `if/elseif` no `OnEvent`.
- SavedVariables só são tocadas depois de `ADDON_LOADED` do próprio addon.
- Lua 5.1 do WoW: sem `goto`, `//`, `_ENV`, `load()` com env; bitwise via `bit.band/bor/lshift`.
- APIs depreciadas não são usadas (`C_Spell.*`, `C_Item.*`, `C_Container.*`, `C_UnitAuras.*`, etc. — ver convenções do projeto); quando uma `C_*` devolve tabela, acede-se aos campos (`info.name`), nunca a múltiplos retornos.
- `.toc` com `## Interface: 120001`.

---

## 🚀 Como Instalar

### Método 1: Cópia Manual (Padrão)
1. Certifica-te de que o World of Warcraft está fechado.
2. Copia a pasta **`ToyFinder`** para o diretório de addons do teu WoW:
   ```
   C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\
   ```
3. O caminho final dos ficheiros deve ficar assim:
   ```
   World of Warcraft\_retail_\Interface\AddOns\ToyFinder\ToyFinder.toc
   World of Warcraft\_retail_\Interface\AddOns\ToyFinder\ToyFinder_Core.lua
   ...
   ```
4. Abre o World of Warcraft. No ecrã de seleção de personagens, clica em **Addons** no canto inferior esquerdo e confirma que o **ToyFinder** está ativo.

### Método 2: Instalador Automático (Windows)
- Dá duplo clique no ficheiro `Install-Addon.bat` que se encontra nesta pasta para detetar e instalar o addon automaticamente na tua pasta do WoW.

---

## 🎮 Comandos no Jogo (Slash Commands)

Podes abrir a janela a qualquer momento através do botão no **Minimapa** ou escrevendo qualquer um destes comandos no chat:

- `/tf` ou `/toyfinder` ou `/toys` - Abre ou fecha o ToyFinder.
- `/tf scan` - Força uma atualização e re-varredura da tua coleção.
- `/tf missing` - Abre a janela diretamente no filtro de brinquedos em falta.
- `/tf help` - Mostra a lista de comandos no chat.

---

## ⌨️ Atalhos Rápidos na Interface

- **Clique numa Linha**: Seleciona o brinquedo e abre os detalhes completos no painel direito.
- **Botão WoWhead**: Abre a janela pop-up com o link URL já selecionado (basta pressionar `Ctrl + C`).
- **Botão ★**: Adiciona ou remove o brinquedo da tua lista de favoritas / farm.
- **Botão Partilhar**: Insere o link colorido do brinquedo no teu chat para partilhar com amigos ou guilda.
- **Botão do Minimapa**:
  - *Botão Esquerdo*: Abre / Fecha a janela.
  - *Botão Direito*: Alterna rapidamente entre "Em Falta" e "Todas".
  - *Arrastar*: Move o botão para a tua posição favorita à volta do minimapa.
- **Tecla ESC**: Fecha a janela principal ou o pop-up do WoWhead.
