# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

# Plataforma de Monitoramento de Gestão de Pessoas — Guia Operacional (Shiny + Golem)

---

## Comandos de Desenvolvimento

```r
# Carregar o pacote e rodar a app (fluxo principal de desenvolvimento)
source("dev/run_dev.R")          # detecta pacote + run_app() numa porta aleatória

# Alternativa manual no console R
devtools::load_all()             # recarrega todos os arquivos R/
run_app()                        # inicia a app

# Atualizar DESCRIPTION com novas dependências detectadas no código
attachment::att_amend_desc()

# Verificar o pacote antes de deploy
devtools::check()

# Adicionar novo módulo (cria R/mod_<nome>.R com esqueleto UI + Server)
golem::add_module(name = "nome_do_modulo")
```

**Nota crítica de paths:** `app_sys()` usa `system.file()` e só funciona com o pacote instalado. Durante desenvolvimento com `devtools::load_all()`, todos os dados em `data-raw/` devem ser carregados via `here::here("data-raw/<pasta>/<arquivo>.rds")`. Nunca use `app_sys()` para apontar para `data-raw/`.

---

## Estado Atual dos Módulos

| Arquivo | Abas | Dados |
|---|---|---|
| `R/mod_indigenas.R` | 6 (Panorama, Série Histórica, Efetividade/Função, Cargos CCE/FCE, Geografia/Órgãos, Perfil Demográfico) | `data-raw/data_indigenas/` |
| `R/mod_etnia_lideranca.R` | 4 (Visão Geral, Por Órgão, Suficiência de Vagas, Razão de Equidade) | `data-raw/data_etnia/` |

Ambos os módulos estão registrados em `R/app_server.R` e `R/app_ui.R`.

### Dados disponíveis — `data-raw/data_indigenas/`
`df_efetivos.rds`, `df_etnia.rds`, `df_funcao.rds`, `df_funcao_efetivos.rds`, `df_funcao_total.rds`, `df_indigenas_sit.rds`, `df_indigenas_uf.rds`, `df_mapa_final.rds`, `df_natjur.rds`, `df_orgao.rds`, `df_piramide.rds`, `df_piramide_indigena.rds`, `df_saidas.rds`, `df_treemap_ind.rds`, `serie_cotas.rds`, `serie_ingressos.rds`

### Dados disponíveis — `data-raw/data_etnia/`
`Tab_inds_1_e_2.rds`, `Tab.rds`, `Tab_sup.rds`, `Tab_ind3.rds`, `Tab_inds_4_mes.rds`, `Tab_inds_4_orgaos.rds`, `Tab_inds_5_mes.rds`, `Tab_inds_5_niveis.rds`, `Tab_inds_5_orgaos.rds`, `data_1a12.rds`, `data_13a17.rds`, `subdata1a12.rds`, `subdata_13a17.rds`

---

## Decisões Técnicas Estabelecidas

- **Gráficos interativos:** `plotly` para todos os charts (barras, linhas, pirâmides, treemap, subplots). Usar `echarts4r` apenas para gráficos empilhados 100% com muitas categorias dinâmicas.
- **Tabelas:** `reactable` para tabelas com barras visuais inline; `DT` para tabelas com download/busca.
- **Layout de filtros:** `bslib::layout_sidebar()` dentro de cada `bslib::nav_panel()` — sidebar à esquerda com os filtros, conteúdo à direita.
- **Pirâmides etárias:** `plotly::plot_ly(type = "bar", orientation = "h")` com `barmode = "overlay"` e valores negativos para um dos sexos.
- **Encoding de nomes de colunas:** Aplicar `iconv(names(df), "UTF-8", "ASCII//TRANSLIT")` ao carregar `.rds` com nomes acentuados para evitar erros de correspondência.
- **Formatação de números inteiros BR:** `format(n, big.mark = ".", scientific = FALSE)` — nunca usar `big.mark = "."` junto com `decimal.mark = ","` no mesmo `format()` (conflito).

---

## Identidade Visual Gov.br

| Token | Valor |
|---|---|
| Azul principal | `#004587` |
| Azul secundário | `#1351b4` |
| Destaque indígena | `#FF7800` |
| Fundo cards | `#f8f9fa` / `#f0f2f5` |
| Texto | `#212529` |
| Verde desaturado | `#155724` |
| Vermelho/terracota | `#721c24` |

A navbar usa `bg = "#004587"` + `inverse = TRUE`. Fonte: `bslib::font_google("Open Sans")`.

---

## Arquitetura do Pacote (Golem)

O app é um **pacote R de produção** via `{golem}`. Estrutura relevante:

```
R/
  app_ui.R          ← page_navbar() + registra todos os nav_panel()
  app_server.R      ← chama mod_*_server() de cada módulo
  app_config.R      ← app_sys() e get_golem_config() — não modificar
  mod_indigenas.R   ← módulo indígenas (UI + Server)
  mod_etnia_lideranca.R  ← módulo raça/liderança (UI + Server)
  docs_etnia/       ← análises de referência (index.Rmd) — não são módulos
  docs_indigenas/   ← análises de referência (index.qmd, index.rmd)
data-raw/
  data_indigenas/   ← dados do módulo indígenas (.rds, .xlsx)
  data_etnia/       ← dados do módulo raça/liderança (.rds, .xlsx)
dev/
  run_dev.R         ← script principal de desenvolvimento
  02_dev.R          ← scaffolding (golem::add_module, etc.)
  03_deploy.R       ← deploy (rsconnect, Docker, etc.)
inst/golem-config.yml  ← configuração de ambiente
```

Cada novo módulo: par `mod_<nome>_ui(id)` + `mod_<nome>_server(id)` em `R/mod_<nome>.R`, registrado em `app_ui.R` e `app_server.R`. Dependências novas: adicionar ao `DESCRIPTION` (manualmente ou via `attachment::att_amend_desc()`).

---

## Contexto de Domínio

### Escopo Temático
- **Diversidade e Inclusão:** Recortes étnico-raciais, gênero, PcD e representatividade em cargos de liderança
- **Liderança:** Perfil dos ocupantes de CCE/FCE (antigos DAS/FC), monitoramento do Decreto nº 11.443/2023 (cotas de 30% para pessoas negras)
- **Força de Trabalho:** Dimensionamento, ingressos, vacâncias, progressão funcional
- **Fonte primária:** SIAPE; referência metodológica: PFGP, TCU/IESGO

### Regra Crítica — Coluna "Status" nos dados de Marco Lógico
Indicadores com status **`A avaliar`** implicam: viabilidade não pacificada, dependência de regras de negócio não documentadas, possíveis restrições de confidencialidade. Sempre alertar o usuário antes de implementar.

### Documentação Analítica de Referência
- `R/docs_indigenas/index.qmd` e `index.rmd` — análises-fonte para `mod_indigenas.R`
- `R/docs_etnia/index.Rmd` — análises-fonte para `mod_etnia_lideranca.R`
- Usar esses documentos como referência de métricas e visualizações ao expandir os módulos

### Referências Externas
- **DFT:** psee.io/dft-dados — granularidades e regras de cálculo já operacionalizadas
- **IESGO/TCU:** iesgo.tcu.gov.br — harmonização conceitual dos indicadores de governança
