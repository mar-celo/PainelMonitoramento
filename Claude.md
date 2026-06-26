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

## Deploy (shinyapps.io)

```r
rsconnect::deployApp(
  appDir    = '.',
  appFiles  = c(
    'app.R', 'data-raw', 'DESCRIPTION', 'NAMESPACE',
    'R/app_config.R', 'R/app_server.R', 'R/app_ui.R',
    'R/mod_capa.R', 'R/mod_etnia_lideranca.R',
    'R/mod_indigenas.R',
    'R/mod_pfgp.R',
    'R/mod_pfgp_dim1.R', 'R/mod_pfgp_dim2.R', 'R/mod_pfgp_dim3.R',
    'R/mod_pfgp_dim4.R', 'R/mod_pfgp_dim5.R', 'R/mod_pfgp_dim6.R',
    'R/run_app.R', 'R/utils_ui.R', 'R/utils_pfgp.R', 'inst'
  ),
  forceUpdate = TRUE
)
```

Ao adicionar novo módulo ou arquivo utilitário em `R/`, acrescentá-lo à lista `appFiles` acima.

---

## Estado Atual dos Módulos

| Arquivo | Abas | Dados |
|---|---|---|
| `R/mod_capa.R` | — (página inicial) | nenhum |
| `R/mod_indigenas.R` | 6 (Panorama, Série Histórica, Efetividade/Função, Cargos CCE/FCE, Geografia/Órgãos, Perfil Demográfico) | `data-raw/data_indigenas/` |
| `R/mod_etnia_lideranca.R` | 4 (Visão Geral, Por Órgão, Suficiência de Vagas, Razão de Equidade) | `data-raw/data_etnia/` |
| `R/mod_pfgp.R` | Dimensões do PFGP (Dimensão 3 inclui lideranças) | `data-raw/data_pfgp/` |

Todos registrados em `R/app_server.R` e `R/app_ui.R`.

### Navegação (app_ui.R)
```
Início          ← mod_capa_ui("capa")        value="capa"
Monitoramento   ← nav_menu()
  Indígenas na APF  ← mod_indigenas_ui("indigenas")   value="indigenas"
  Raça e Liderança  ← mod_etnia_lideranca_ui("etnia") value="etnia"
  PFGP              ← mod_pfgp_ui("pfgp")             value="pfgp"
Sobre           ← nav_menu() com texto estático
```

`page_navbar` tem `id = "main_nav"` — necessário para `updateNavbarPage()`.

### Dados disponíveis — `data-raw/data_indigenas/`
`df_efetivos.rds`, `df_etnia.rds`, `df_funcao.rds`, `df_funcao_efetivos.rds`, `df_funcao_total.rds`, `df_indigenas_sit.rds`, `df_indigenas_uf.rds`, `df_mapa_final.rds`, `df_natjur.rds`, `df_orgao.rds`, `df_piramide.rds`, `df_piramide_indigena.rds`, `df_saidas.rds`, `df_treemap_ind.rds`, `serie_cotas.rds`, `serie_ingressos.rds`

### Dados disponíveis — `data-raw/data_etnia/`
`Tab_inds_1_e_2.rds`, `Tab.rds`, `Tab_sup.rds`, `Tab_ind3.rds`, `Tab_inds_4_mes.rds`, `Tab_inds_4_orgaos.rds`, `Tab_inds_5_mes.rds`, `Tab_inds_5_niveis.rds`, `Tab_inds_5_orgaos.rds`, `data_1a12.rds`, `data_13a17.rds`, `subdata1a12.rds`, `subdata_13a17.rds`

### Dados disponíveis — `data-raw/data_pfgp/`
`base_censo.rds`, `base_ingressos.rds`, `df_liderancas.rds`, `tab_ativo_transversal.rds`, `tab_cargo_transversal.rds`, `tab_raca_genero_transversal.rds`

---

## Arquitetura do Pacote (Golem)

O app é um **pacote R de produção** via `{golem}`. Estrutura relevante:

```
R/
  app_ui.R               ← page_navbar() + registra todos os nav_panel()
  app_server.R           ← chama mod_*_server() de cada módulo
  app_config.R           ← app_sys() e get_golem_config() — não modificar
  mod_capa.R             ← página inicial com links de navegação
  mod_indigenas.R        ← módulo indígenas (UI + Server)
  mod_etnia_lideranca.R  ← módulo raça/liderança (UI + Server)
  mod_pfgp.R             ← módulo PFGP (UI + Server)
  utils_ui.R             ← helper .spin() — spinner Gov.br para todos os outputs
  utils_pfgp.R           ← ggplot_cat(), ggplotly_c(), paletas e tema base
  docs_etnia/            ← análises de referência (index.Rmd) — não são módulos
  docs_indigenas/        ← análises de referência (index.qmd, index.rmd)
data-raw/
  data_indigenas/        ← dados do módulo indígenas (.rds)
  data_etnia/            ← dados do módulo raça/liderança (.rds)
  data_pfgp/             ← dados do módulo PFGP (.rds)
dev/
  run_dev.R              ← script principal de desenvolvimento
  02_dev.R               ← scaffolding (golem::add_module, etc.)
  03_deploy.R            ← deploy (rsconnect, Docker, etc.)
inst/golem-config.yml    ← configuração de ambiente
```

Cada novo módulo: par `mod_<nome>_ui(id)` + `mod_<nome>_server(id)` em `R/mod_<nome>.R`, registrado em `app_ui.R` e `app_server.R`. Dependências novas: adicionar ao `DESCRIPTION` (manualmente ou via `attachment::att_amend_desc()`).

### Utilitários compartilhados

**`R/utils_ui.R`** — exporta `.spin(x)`: envolve qualquer output com `shinycssloaders::withSpinner(type=6, color="#1351b4")`. Usar em todos os `plotlyOutput`, `DTOutput`, `echarts4rOutput` dos módulos.

**`R/utils_pfgp.R`** — funções de visualização para `mod_pfgp.R`:
- `ggplot_cat(...)`: `ggplot2::ggplot(...)` + tema `.plot_config`. **Não inclui `scale_fill_manual`/`scale_color_manual`** — escalas manuais quebram `ggplotly()`.
- `ggplotly_c(gg_obj)`: converte ggplot → plotly limpando nomes duplicados na legenda.
- `.pal_primaria`, `.pal_complementar`: paletas de cores Gov.br.

**Regra importante:** Nunca colocar funções auxiliares em `data/` — esses scripts não vão no bundle do shinyapps.io. Todo helper deve estar em `R/`.

---

## Compatibilidade com o Servidor (shinyapps.io)

O servidor usa **bslib 0.9.0** (local usa 0.10.0) e locale **C.UTF-8**. Diferenças que causam erros silenciosos:

| Problema | Causa | Solução |
|---|---|---|
| Selects travados após deploy | `updateSelectInput(choices=NULL)` + bslib 0.9.0 | Substituir por `renderUI` + `selectInput` dentro |
| Card com output colapsado (0px) | `card_body()` sem `fill=FALSE` em contexto fillable | Sempre usar `card_body(fill=FALSE, ...)` para DT e reactable |
| Erro em `format(big.mark=".")` | Locale C.UTF-8 não permite big.mark="." sem decimal.mark | **Sempre** especificar `format(n, big.mark=".", decimal.mark=",", scientific=FALSE)` |
| `could not find function "%>%"` | magrittr não no DESCRIPTION | Usar pipe nativo `\|>` (disponível R ≥ 4.1) |
| `\|> as.numeric` inválido | Pipe nativo exige `()` | `\|> as.numeric()` |
| `could not find function "filter"` | dplyr não resolvido sem `load_all()` | Prefixar com `dplyr::` em todo código de módulo |
| `subscript out of bounds` no ggplotly | `scale_fill_manual`/`scale_color_manual` em `ggplotly()` | Usar `ggplot_cat()` de `utils_pfgp.R` (sem escalas manuais) |
| `size=` em `geom_line` | Depreciado no ggplot2 3.4+ | Usar `linewidth=` |

**Navegação entre módulos (mod_capa):** `updateNavbarPage` requer a sessão raiz. Assinatura: `mod_capa_server(id, root_session = NULL)`. Em `app_server.R`: `mod_capa_server("capa", root_session = session)`.

---

## Decisões Técnicas Estabelecidas

- **Gráficos interativos:** `plotly` para todos os charts (barras, linhas, pirâmides, treemap, subplots). Usar `echarts4r` apenas para gráficos empilhados 100% com muitas categorias dinâmicas.
- **Tabelas:** `reactable` para tabelas com barras visuais inline; `DT` para tabelas com download/busca.
- **Layout de filtros:** `bslib::layout_sidebar()` dentro de cada `bslib::nav_panel()` — sidebar à esquerda com os filtros, conteúdo à direita.
- **Pirâmides etárias:** `plotly::plot_ly(type = "bar", orientation = "h")` com `barmode = "overlay"` e valores negativos para um dos sexos.
- **Encoding de nomes de colunas:** Aplicar `iconv(names(df), "UTF-8", "ASCII//TRANSLIT")` ao carregar `.rds` com nomes acentuados para evitar erros de correspondência.
- **Formatação numérica BR:** Sempre `format(n, big.mark=".", decimal.mark=",", scientific=FALSE)` — especificar ambos explicitamente para evitar conflito no locale C.UTF-8 do servidor.
- **Spinners:** Todo output usa `.spin()` de `utils_ui.R`.

---

## Identidade Visual Gov.br

| Token | Valor |
|---|---|
| Azul principal | `#004587` |
| Azul secundário | `#1351b4` |
| Destaque indígena/acento | `#FF7800` |
| Fundo surface-0 | `#eef1f6` |
| Fundo cards | `#ffffff` |
| Texto principal | `#18202e` |
| Texto secundário | `#495057` |

A navbar usa `bg = "#004587"` + `inverse = TRUE`. Dropdowns da navbar: `background: #003d7a`. Fonte: `bslib::font_google("Open Sans")`.

CSS usa custom properties (`--c-brand`, `--shadow-sm`, `--radius-md`, etc.) definidas em `:root` no `golem_add_external_resources()` em `app_ui.R`. O seletor `.bslib-card:not(.bslib-value-box)` é obrigatório para não sobrescrever temas dos value boxes.

---

## Contexto de Domínio

### Escopo Temático
- **Diversidade e Inclusão:** Recortes étnico-raciais, gênero, PcD e representatividade em cargos de liderança
- **Liderança:** Perfil dos ocupantes de CCE/FCE (antigos DAS/FC), monitoramento do Decreto nº 11.443/2023 (cotas de 30% para pessoas negras)
- **Força de Trabalho:** Dimensionamento, ingressos, vacâncias, progressão funcional
- **PFGP:** Programa de Fortalecimento da Gestão de Pessoas — dimensões de desenvolvimento, desempenho e formação de lideranças
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
