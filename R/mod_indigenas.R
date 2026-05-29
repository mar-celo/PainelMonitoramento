# ==============================================================================
# mod_indigenas.R
# Módulo completo: Representatividade Indígena na Administração Pública Federal
# Fontes: docs_indigenas/index.qmd + docs_indigenas/index.rmd
# ==============================================================================

# Paleta Gov.br para uso interno
.PAL_IND <- c(
  principal = "#004587",
  destaque  = "#FF7800",
  apoio     = "#1351b4",
  fem       = "#FF7800",
  mas       = "#0000aa",
  cinza     = "#6c757d",
  verde     = "#28a745"
)

# ==============================================================================
# UI
# ==============================================================================
#' indigenas UI Function
#'
#' @param id Internal parameter for {shiny}.
#' @noRd
#' @importFrom shiny NS tagList
mod_indigenas_ui <- function(id) {
  ns <- NS(id)
  tagList(
    bslib::navset_card_underline(
      id       = ns("nav_ind"),
      selected = "panorama",

      # ---- 1. Panorama Atual ----
      bslib::nav_panel(
        title = tagList(shiny::icon("chart-pie"), " Panorama Atual"),
        value = "panorama",
        shiny::uiOutput(ns("kpi_boxes")),
        bslib::card(
          bslib::card_header(
            class = "bg-primary text-white",
            shiny::icon("table"),
            " Distribuição Étnica no Serviço Público Federal"
          ),
          bslib::card_body(reactable::reactableOutput(ns("tabela_etnia")))
        ),
        shiny::uiOutput(ns("analise_representatividade"))
      ),

      # ---- 2. Série Histórica ----
      bslib::nav_panel(
        title = tagList(shiny::icon("chart-line"), " Série Histórica"),
        value = "serie",
        bslib::layout_sidebar(
          sidebar = bslib::sidebar(
            title = shiny::strong("Filtros"),
            bg    = "#f0f4fa",
            width = 220,
            shiny::radioButtons(
              ns("tipo_serie"), "Exibir:",
              choices  = c("Total absoluto" = "total",
                           "Percentual (%)" = "pct",
                           "Ambos (eixo duplo)" = "ambos"),
              selected = "ambos"
            )
          ),
          bslib::card(
            bslib::card_header(
              class = "bg-primary text-white",
              "Evolução de Servidores Indígenas na APF (2016 – 2026)"
            ),
            bslib::card_body(plotly::plotlyOutput(ns("serie_historica"), height = "420px"))
          )
        )
      ),

      # ---- 3. Efetividade e Função ----
      bslib::nav_panel(
        title = tagList(shiny::icon("briefcase"), " Efetividade e Função"),
        value = "efetivos",
        bslib::layout_sidebar(
          sidebar = bslib::sidebar(
            title = shiny::strong("Filtros"),
            bg    = "#f0f4fa",
            width = 220,
            shiny::selectInput(
              ns("mes_ref_efet"), "Mês de referência:",
              choices  = NULL,
              selected = NULL
            ),
            shiny::hr(),
            shiny::p(class = "text-muted small",
                     "Gráficos de barras mostram o mês selecionado.",
                     "Séries temporais mostram toda a série histórica.")
          ),
          bslib::layout_columns(
            col_widths = c(6, 6),
            bslib::card(
              bslib::card_header(
                class = "bg-primary text-white",
                "Incidência de Vínculos Efetivos por Sexo e Raça/Cor"
              ),
              bslib::card_body(plotly::plotlyOutput(ns("efetivos_sexo"), height = "340px"))
            ),
            bslib::card(
              bslib::card_header(
                class = "bg-primary text-white",
                "Vínculos com Função de Liderança por Sexo e Raça/Cor"
              ),
              bslib::card_body(plotly::plotlyOutput(ns("funcao_sexo"), height = "340px"))
            )
          ),
          bslib::layout_columns(
            col_widths = c(6, 6),
            bslib::card(
              bslib::card_header(
                class = "bg-primary text-white",
                "Série: % de Vínculos Efetivos – Indígenas vs Demais"
              ),
              bslib::card_body(plotly::plotlyOutput(ns("serie_efetivos"), height = "300px"))
            ),
            bslib::card(
              bslib::card_header(
                class = "bg-primary text-white",
                "Série: % de Vínculos com Função – Indígenas vs Demais"
              ),
              bslib::card_body(plotly::plotlyOutput(ns("serie_funcao"), height = "300px"))
            )
          )
        )
      ),

      # ---- 4. Cargos CCE/FCE ----
      bslib::nav_panel(
        title = tagList(shiny::icon("crown"), " Cargos CCE/FCE"),
        value = "cce",
        bslib::layout_sidebar(
          sidebar = bslib::sidebar(
            title = shiny::strong("Filtros"),
            bg    = "#f0f4fa",
            width = 220,
            shiny::selectInput(
              ns("mes_ref_func"), "Mês de referência:",
              choices  = NULL,
              selected = NULL
            ),
            shiny::radioButtons(
              ns("tipo_viz_func"), "Pirâmide – Visualizar:",
              choices  = c("Quantitativo absoluto" = "abs",
                           "Percentual (%)"         = "pct"),
              selected = "abs"
            ),
            shiny::hr(),
            shiny::selectInput(
              ns("etnia_cce"), "Etnia (pirâmide):",
              choices  = c("Indígenas", "Demais Raça/cor"),
              selected = "Indígenas"
            )
          ),
          bslib::layout_columns(
            col_widths = c(6, 6),
            bslib::card(
              bslib::card_header(
                class = "bg-primary text-white",
                "Ocupação de Cargos CCE/FCE por Nível e Gênero"
              ),
              bslib::card_body(plotly::plotlyOutput(ns("piramide_cce"), height = "360px"))
            ),
            bslib::card(
              bslib::card_header(
                class = "bg-primary text-white",
                "Evolução de Cargos CCE/FCE por Nível (a partir de 2022)"
              ),
              bslib::card_body(plotly::plotlyOutput(ns("serie_niveis"), height = "360px"))
            )
          ),
          bslib::card(
            bslib::card_header(
              class = "bg-primary text-white",
              "Razão de Equidade nos Cargos CCE/FCE – Indígenas vs Total (por Sexo)"
            ),
            bslib::card_body(plotly::plotlyOutput(ns("razao_equiv"), height = "340px"))
          )
        )
      ),

      # ---- 5. Distribuição Geográfica e Órgãos ----
      bslib::nav_panel(
        title = tagList(shiny::icon("map-marker-alt"), " Geografia e Órgãos"),
        value = "geo",
        bslib::layout_sidebar(
          sidebar = bslib::sidebar(
            title = shiny::strong("Filtros"),
            bg    = "#f0f4fa",
            width = 220,
            shiny::sliderInput(
              ns("top_n_orgao"), "Top N órgãos:",
              min = 5, max = 50, value = 20, step = 5
            ),
            shiny::hr(),
            shiny::selectInput(
              ns("ano_orgao"), "Ano de referência (órgãos):",
              choices  = NULL,
              selected = NULL
            )
          ),

          # Linha 1: Mapa + Tabela de órgãos
          bslib::layout_columns(
            col_widths = c(6, 6),
            bslib::card(
              bslib::card_header(
                class = "bg-primary text-white",
                shiny::icon("map"), " Vínculos Indígenas por UF"
              ),
              bslib::card_body(
                bslib::navset_pill(
                  bslib::nav_panel(
                    "Mapa",
                    shiny::plotOutput(ns("mapa_uf"), height = "420px")
                  ),
                  bslib::nav_panel(
                    "Barras por UF",
                    plotly::plotlyOutput(ns("plot_uf"), height = "420px")
                  )
                )
              )
            ),
            bslib::card(
              bslib::card_header(
                class = "bg-primary text-white",
                shiny::icon("building"), " Representatividade por Órgão"
              ),
              bslib::card_body(DT::DTOutput(ns("tab_orgaos")))
            )
          ),

          # Linha 2: Natureza Jurídica (série histórica anual)
          bslib::card(
            bslib::card_header(
              class = "bg-primary text-white",
              shiny::icon("chart-bar"),
              " Natureza Jurídica dos Órgãos de Indígenas ao Longo do Tempo (%)"
            ),
            bslib::card_body(echarts4r::echarts4rOutput(ns("natjur_echart"), height = "340px"))
          )
        )
      ),

      # ---- 6. Perfil Demográfico ----
      bslib::nav_panel(
        title = tagList(shiny::icon("users"), " Perfil Demográfico"),
        value = "perfil",
        bslib::layout_columns(
          col_widths = c(6, 6),
          bslib::card(
            bslib::card_header(
              class = "bg-primary text-white",
              "Pirâmide Etária – Servidores Indígenas"
            ),
            bslib::card_body(plotly::plotlyOutput(ns("piramide_ind"), height = "400px"))
          ),
          bslib::card(
            bslib::card_header(
              class = "bg-primary text-white",
              "Pirâmide Etária – APF (Todos os Servidores)"
            ),
            bslib::card_body(plotly::plotlyOutput(ns("piramide_apf"), height = "400px"))
          )
        ),
        bslib::layout_columns(
          col_widths = c(6, 6),
          bslib::card(
            bslib::card_header(
              class = "bg-primary text-white",
              "Escolaridade dos Servidores Indígenas (Treemap)"
            ),
            bslib::card_body(plotly::plotlyOutput(ns("treemap_escol"), height = "400px"))
          ),
          bslib::card(
            bslib::card_header(
              class = "bg-primary text-white",
              "Ingressos Históricos e Vínculos por Tipo de Cota"
            ),
            bslib::card_body(
              bslib::navset_pill(
                bslib::nav_panel(
                  "Ingressos por Ano",
                  plotly::plotlyOutput(ns("serie_ingressos"), height = "340px")
                ),
                bslib::nav_panel(
                  "Por Tipo de Cota",
                  plotly::plotlyOutput(ns("serie_cotas"), height = "340px")
                )
              )
            )
          )
        )
      )
    )
  )
}


# ==============================================================================
# SERVER
# ==============================================================================
#' indigenas Server Functions
#'
#' @param id Internal parameter for {shiny}.
#' @noRd
mod_indigenas_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # --------------------------------------------------------------------------
    # Carregamento de dados (uma vez ao iniciar o módulo)
    # --------------------------------------------------------------------------
    df_etnia        <- readRDS(here::here("data-raw/data_indigenas/df_etnia.rds"))
    df_efetivos     <- readRDS(here::here("data-raw/data_indigenas/df_efetivos.rds"))
    df_funcao       <- readRDS(here::here("data-raw/data_indigenas/df_funcao.rds"))
    df_funcao_tot   <- readRDS(here::here("data-raw/data_indigenas/df_funcao_total.rds"))
    df_funcao_eqv   <- readRDS(here::here("data-raw/data_indigenas/df_funcao_efetivos.rds"))
    df_natjur       <- readRDS(here::here("data-raw/data_indigenas/df_natjur.rds"))
    df_orgao_raw    <- readRDS(here::here("data-raw/data_indigenas/df_orgao.rds"))
    df_uf           <- readRDS(here::here("data-raw/data_indigenas/df_indigenas_uf.rds"))
    df_pir_ind      <- readRDS(here::here("data-raw/data_indigenas/df_piramide_indigena.rds"))
    df_pir_apf      <- readRDS(here::here("data-raw/data_indigenas/df_piramide.rds"))
    df_tree         <- readRDS(here::here("data-raw/data_indigenas/df_treemap_ind.rds"))
    df_ingressos    <- readRDS(here::here("data-raw/data_indigenas/serie_ingressos.rds"))
    df_cotas        <- readRDS(here::here("data-raw/data_indigenas/serie_cotas.rds"))
    df_mapa         <- readRDS(here::here("data-raw/data_indigenas/df_mapa_final.rds"))

    # --------------------------------------------------------------------------
    # Valores derivados globais (mês e ano de referência)
    # --------------------------------------------------------------------------
    mes_max   <- max(df_etnia$mes)
    label_mes <- format(as.Date(paste0(mes_max, "01"), "%Y%m%d"), "%b/%Y")

    meses_disp <- sort(unique(df_efetivos$mes), decreasing = TRUE)
    meses_label <- setNames(
      meses_disp,
      format(as.Date(paste0(meses_disp, "01"), "%Y%m%d"), "%b/%Y")
    )
    anos_orgao <- sort(unique(df_orgao_raw$ano), decreasing = TRUE)

    # Popular selectInputs dinâmicos
    shiny::updateSelectInput(session, "mes_ref_efet",
                             choices = meses_label, selected = meses_label[1])
    shiny::updateSelectInput(session, "mes_ref_func",
                             choices = meses_label, selected = meses_label[1])
    shiny::updateSelectInput(session, "ano_orgao",
                             choices = anos_orgao, selected = anos_orgao[1])

    # ---- Dados do panorama atual ----
    etnia_atual <- df_etnia |>
      dplyr::filter(mes == mes_max) |>
      dplyr::arrange(dplyr::desc(pct))

    n_ind   <- sum(etnia_atual$n[etnia_atual$is_indigena == "Sim"])
    pct_ind <- sum(etnia_atual$pct[etnia_atual$is_indigena == "Sim"]) * 100

    mes_ant <- mes_max - 100L
    n_ant   <- sum(df_etnia$n[df_etnia$mes == mes_ant & df_etnia$is_indigena == "Sim"])
    delta_n <- if (n_ant > 0) n_ind - n_ant else NA_integer_

    df_ind_serie <- df_etnia |>
      dplyr::filter(is_indigena == "Sim") |>
      dplyr::mutate(ano = as.integer(substr(as.character(mes), 1, 4)),
                    pct_show = round(pct * 100, 3))
    pico_n  <- max(df_ind_serie$n)
    pico_ano <- df_ind_serie$ano[which.max(df_ind_serie$n)]

    # ==========================================================================
    # 1. PANORAMA ATUAL
    # ==========================================================================
    output$kpi_boxes <- shiny::renderUI({
      bslib::layout_columns(
        col_widths = c(3, 3, 3, 3),
        bslib::value_box(
          title    = "Servidores Indígenas (APF)",
          value    = format(n_ind, big.mark = ".", scientific = FALSE),
          showcase = shiny::icon("user"),
          theme    = "primary",
          shiny::p(label_mes, style = "font-size:.83rem;")
        ),
        bslib::value_box(
          title    = "Participação na APF",
          value    = paste0(round(pct_ind, 3), "%"),
          showcase = shiny::icon("chart-pie"),
          theme    = bslib::value_box_theme(bg = "#1351b4", fg = "#fff"),
          shiny::p("do total de vínculos ativos", style = "font-size:.83rem;")
        ),
        bslib::value_box(
          title    = "Var. Anual (vínculos)",
          value    = if (!is.na(delta_n))
            paste0(ifelse(delta_n >= 0, "+", ""),
                   format(delta_n, big.mark = ".", scientific = FALSE))
          else "–",
          showcase = shiny::icon(if (!is.na(delta_n) && delta_n >= 0) "arrow-up" else "arrow-down"),
          theme    = if (!is.na(delta_n) && delta_n >= 0) "success" else "danger",
          shiny::p("vs. mesmo mês do ano anterior", style = "font-size:.83rem;")
        ),
        bslib::value_box(
          title    = "Pico Histórico",
          value    = paste0(format(pico_n, big.mark = "."), " (", pico_ano, ")"),
          showcase = shiny::icon("trophy"),
          theme    = bslib::value_box_theme(bg = "#6c757d", fg = "#fff"),
          shiny::p("maior total já registrado na série", style = "font-size:.83rem;")
        )
      )
    })

    output$tabela_etnia <- reactable::renderReactable({
      df <- etnia_atual |>
        dplyr::mutate(pct_show = round(pct * 100, 2))

      reactable::reactable(
        df |> dplyr::select(nome_cor_origem_etnica, n, pct_show),
        sortable     = TRUE,
        highlight    = TRUE,
        striped      = TRUE,
        compact      = TRUE,
        defaultSorted    = "pct_show",
        defaultSortOrder = "desc",
        theme = reactable::reactableTheme(
          borderColor    = "#dfe2e5",
          stripedColor   = "#f0f4fa",
          highlightColor = "#e8f0fb",
          cellPadding    = "10px 14px"
        ),
        columns = list(
          nome_cor_origem_etnica = reactable::colDef(
            name    = "Cor/Origem Étnica",
            minWidth = 150,
            style   = function(value) {
              if (grepl("IND[ÍI]GENA|INDIGENA", value, ignore.case = TRUE))
                list(fontWeight = "bold", color = "#fff",
                     backgroundColor = "#FF7800", borderRadius = "4px")
              else list(color = "#212529")
            }
          ),
          n = reactable::colDef(
            name   = "Total de Vínculos",
            align  = "right",
            format = reactable::colFormat(separators = TRUE, locales = "pt-BR")
          ),
          pct_show = reactable::colDef(
            name = "Participação (%)",
            defaultSortOrder = "desc",
            cell = function(value, index) {
              is_ind <- grepl("IND[ÍI]GENA|INDIGENA",
                              df$nome_cor_origem_etnica[index],
                              ignore.case = TRUE)
              cor <- if (is_ind) "#FF7800" else "#004587"
              w   <- paste0(min(value, 100), "%")
              htmltools::div(
                style = "display:flex; align-items:center; gap:8px;",
                htmltools::span(style = "min-width:48px; text-align:right;",
                                paste0(value, "%")),
                htmltools::div(style = paste0(
                  "background:", cor, "; width:", w,
                  "; height:10px; border-radius:3px; flex:1;"
                ))
              )
            }
          )
        )
      )
    })

    output$analise_representatividade <- shiny::renderUI({
      n_fmt   <- format(n_ind, big.mark = ".", scientific = FALSE)
      pct_fmt <- gsub("\\.", ",", format(round(pct_ind, 3), nsmall = 3))

      tags$div(
        style = "margin-top: 12px;",
        tags$div(
          style = paste0(
            "position: relative; padding: 28px 28px 20px 28px;",
            "background: linear-gradient(120deg, #fff7f0 0%, #ffffff 60%, #f0f4fa 100%);",
            "border-left: 5px solid #FF7800; border-radius: 10px;",
            "box-shadow: 0 3px 12px rgba(255,120,0,0.12);"
          ),

          # Badge flutuante no canto superior esquerdo
          tags$div(
            style = "position: absolute; top: -14px; left: 22px; display: flex; align-items: center; gap: 8px;",
            tags$span(
              style = paste0(
                "background: #FF7800; color: white; border-radius: 50%;",
                "width: 30px; height: 30px; display: inline-flex;",
                "align-items: center; justify-content: center;",
                "font-size: 13px; box-shadow: 0 2px 6px rgba(255,120,0,0.45);"
              ),
              shiny::icon("feather-alt")
            ),
            tags$span(
              style = paste0(
                "background: #FF7800; color: white; border-radius: 4px;",
                "padding: 2px 10px; font-size: 0.68rem; font-weight: 700;",
                "text-transform: uppercase; letter-spacing: 1px;",
                "box-shadow: 0 2px 6px rgba(255,120,0,0.35);"
              ),
              "Análise de Representatividade"
            )
          ),

          # Texto principal
          tags$p(
            style = "font-size: 0.96rem; color: #212529; line-height: 1.85; margin: 10px 0 16px 0;",
            "Em ", tags$strong(style = "color: #004587;", label_mes),
            ", a Administração Pública Federal (APF) contava com um total de ",
            tags$span(
              style = paste0(
                "display: inline-block; background: #FF7800; color: white;",
                "font-weight: 700; font-size: 1.05rem; padding: 1px 8px;",
                "border-radius: 4px; margin: 0 2px;"
              ),
              n_fmt
            ),
            " vínculos ativos de pessoas que se autodeclaram como indígenas,",
            " o que representa ",
            tags$span(
              style = paste0(
                "display: inline-block; background: #004587; color: white;",
                "font-weight: 700; font-size: 1.05rem; padding: 1px 8px;",
                "border-radius: 4px; margin: 0 2px;"
              ),
              paste0(pct_fmt, "%")
            ),
            " do total de vínculos ativos na APF,",
            " conforme detalhado na tabela acima."
          ),

          # Rodapé com fonte e referência
          tags$div(
            style = "display: flex; align-items: center; gap: 10px; flex-wrap: wrap;",
            tags$span(
              style = paste0(
                "background: #004587; color: white; border-radius: 4px;",
                "padding: 3px 9px; font-size: 0.7rem; font-weight: 700;",
                "letter-spacing: 0.5px;"
              ),
              shiny::icon("database"), " SIAPE"
            ),
            tags$span(
              style = "color: #6c757d; font-size: 0.78rem;",
              paste0("Referência: ", label_mes, " • Administração Pública Federal")
            )
          )
        )
      )
    })

    # ==========================================================================
    # 2. SÉRIE HISTÓRICA
    # ==========================================================================
    output$serie_historica <- plotly::renderPlotly({
      tipo <- input$tipo_serie

      p <- plotly::plot_ly()

      if (tipo %in% c("total", "ambos")) {
        p <- p |>
          plotly::add_trace(
            data = df_ind_serie, x = ~data, y = ~n,
            name = "Total Absoluto", type = "scatter", mode = "lines+markers",
            line   = list(color = .PAL_IND["principal"], width = 2.5),
            marker = list(color = .PAL_IND["principal"], size  = 5),
            yaxis  = "y",
            hovertemplate = "<b>%{x|%b/%Y}</b><br>Total: %{y:,.0f}<extra></extra>"
          )
      }

      if (tipo %in% c("pct", "ambos")) {
        p <- p |>
          plotly::add_trace(
            data = df_ind_serie, x = ~data, y = ~pct_show,
            name = "Participação (%)", type = "scatter", mode = "lines+markers",
            line   = list(color = .PAL_IND["destaque"], width = 2, dash = "dot"),
            marker = list(color = .PAL_IND["destaque"], size  = 5),
            yaxis  = if (tipo == "ambos") "y2" else "y",
            hovertemplate = "<b>%{x|%b/%Y}</b><br>%: %{y:.3f}%<extra></extra>"
          )
      }

      layout_args <- list(
        xaxis  = list(title = ""),
        legend = list(orientation = "h", x = 0, y = -0.15),
        hovermode     = "x unified",
        paper_bgcolor = "#ffffff",
        plot_bgcolor  = "#f8f9fa"
      )

      if (tipo == "ambos") {
        layout_args$yaxis  <- list(title = "Total de Vínculos",
                                   titlefont = list(color = .PAL_IND["principal"]),
                                   tickfont  = list(color = .PAL_IND["principal"]))
        layout_args$yaxis2 <- list(title = "Participação (%)", overlaying = "y",
                                   side = "right", showgrid = FALSE,
                                   titlefont = list(color = .PAL_IND["destaque"]),
                                   tickfont  = list(color = .PAL_IND["destaque"]))
        layout_args$margin <- list(r = 65)
      } else if (tipo == "total") {
        layout_args$yaxis <- list(title = "Total de Vínculos")
      } else {
        layout_args$yaxis <- list(title = "Participação (%)", ticksuffix = "%")
      }

      do.call(plotly::layout, c(list(p), layout_args))
    })

    # ==========================================================================
    # 3. EFETIVIDADE E FUNÇÃO
    # ==========================================================================

    # ---- 3a. Efetivos por sexo e raça (mês selecionado) ----
    output$efetivos_sexo <- plotly::renderPlotly({
      req(input$mes_ref_efet)
      mes_sel <- as.integer(input$mes_ref_efet)

      df_plot <- df_efetivos |>
        dplyr::filter(mes == mes_sel, efetivo,
                      nome_cor_origem_etnica != "NAO INFORMADO") |>
        dplyr::mutate(
          nome_sexo2 = factor(nome_sexo, levels = c("Mas", "Fem")),
          destaque   = grepl("IND[ÍI]GENA|INDIGENA", nome_cor_origem_etnica, ignore.case = TRUE)
        )

      cores <- c("Mas" = "#0000aa", "Fem" = "#FF7800")

      plotly::plot_ly(
        df_plot,
        x     = ~p, y = ~nome_cor_origem_etnica,
        color = ~nome_sexo2, colors = cores,
        type  = "bar", orientation = "h",
        hovertemplate = "<b>%{y}</b><br>%{data.name}: %{x}%<extra></extra>"
      ) |>
        plotly::layout(
          barmode = "group",
          xaxis   = list(title = "% com vínculo efetivo", ticksuffix = "%"),
          yaxis   = list(title = "", categoryorder = "total ascending"),
          legend  = list(
            orientation = "v",
            x = 1.02, xanchor = "left",
            y = 0.5,  yanchor = "middle",
            bgcolor     = "rgba(255,255,255,0.85)",
            bordercolor = "#dee2e6", borderwidth = 1,
            font        = list(size = 12),
            traceorder  = "normal"
          ),
          margin        = list(r = 110),
          paper_bgcolor = "#ffffff", plot_bgcolor = "#f8f9fa"
        )
    })

    # ---- 3b. Função por sexo e raça (butterfly, mês selecionado) ----
    output$funcao_sexo <- plotly::renderPlotly({
      req(input$mes_ref_efet)
      mes_sel <- as.integer(input$mes_ref_efet)

      df_plot <- df_funcao |>
        dplyr::filter(
          mes == mes_sel,
          !grepl("^[sS]/", nome_funcao),
          nome_cor_origem_etnica != "NAO INFORMADO"
        ) |>
        dplyr::group_by(nome_cor_origem_etnica, nome_sexo) |>
        dplyr::summarise(total = sum(total), .groups = "drop") |>
        dplyr::group_by(nome_cor_origem_etnica) |>
        dplyr::mutate(p = round(100 * total / sum(total)),
                      p_adj = ifelse(nome_sexo == "Fem", -p, p)) |>
        dplyr::ungroup()

      mas <- df_plot |> dplyr::filter(nome_sexo == "Mas")
      fem <- df_plot |> dplyr::filter(nome_sexo == "Fem")

      plotly::plot_ly() |>
        plotly::add_bars(
          data = mas, x = ~p_adj, y = ~nome_cor_origem_etnica,
          name = "Masculino", orientation = "h",
          marker = list(color = .PAL_IND["mas"]),
          hovertemplate = "<b>%{y}</b><br>Masculino: %{x}%<extra></extra>"
        ) |>
        plotly::add_bars(
          data = fem, x = ~p_adj, y = ~nome_cor_origem_etnica,
          name = "Feminino", orientation = "h",
          marker = list(color = .PAL_IND["fem"]),
          customdata = ~p,
          hovertemplate = "<b>%{y}</b><br>Feminino: %{customdata}%<extra></extra>"
        ) |>
        plotly::layout(
          barmode = "overlay",
          xaxis   = list(title = "% dentre servidores com função",
                         tickvals = c(-50, -25, 0, 25, 50),
                         ticktext = c("50%", "25%", "0%", "25%", "50%")),
          yaxis   = list(title = "", categoryorder = "total ascending"),
          legend  = list(
            orientation = "v",
            x = 1.02, xanchor = "left",
            y = 0.5,  yanchor = "middle",
            bgcolor     = "rgba(255,255,255,0.85)",
            bordercolor = "#dee2e6", borderwidth = 1,
            font        = list(size = 12),
            traceorder  = "normal"
          ),
          margin        = list(r = 110),
          paper_bgcolor = "#ffffff", plot_bgcolor = "#f8f9fa"
        )
    })

    # ---- 3c. Série de efetivos (Indígenas vs Demais) ----
    output$serie_efetivos <- plotly::renderPlotly({
      # p no dado = % com vínculo efetivo dentro do grupo raça/sexo
      # Agregamos por etnia usando média ponderada de p pelo total
      df_plot <- df_efetivos |>
        dplyr::filter(
          efetivo == TRUE,
          !grepl("NAO INFORMADO", nome_cor_origem_etnica, ignore.case = TRUE)
        ) |>
        dplyr::mutate(
          etnia = ifelse(
            grepl("IND[ÍI]GENA|INDIGENA", nome_cor_origem_etnica, ignore.case = TRUE),
            "Indígenas", "Demais raça/cor"
          )
        ) |>
        dplyr::group_by(mes, etnia) |>
        dplyr::summarise(p = round(stats::weighted.mean(p, total), 2), .groups = "drop") |>
        dplyr::mutate(data = as.Date(paste0(mes, "01"), "%Y%m%d"))

      cores <- c("Indígenas" = "#FF7800", "Demais raça/cor" = "#6c757d")

      plotly::plot_ly(
        df_plot, x = ~data, y = ~p, color = ~etnia, colors = cores,
        type = "scatter", mode = "lines+markers",
        marker = list(size = 4),
        hovertemplate = "<b>%{x|%b/%Y}</b><br>%{data.name}: %{y:.2f}%<extra></extra>"
      ) |>
        plotly::layout(
          xaxis  = list(title = ""),
          yaxis  = list(title = "% de vínculos efetivos", ticksuffix = "%"),
          legend = list(orientation = "h", x = 0.5, xanchor = "center", y = -0.2),
          hovermode = "x unified",
          paper_bgcolor = "#ffffff", plot_bgcolor = "#f8f9fa"
        )
    })

    # ---- 3d. Série de função (Indígenas vs Demais) ----
    output$serie_funcao <- plotly::renderPlotly({
      # p = % com função dentro de cada grupo étnico (com / com+sem)
      df_plot <- df_funcao |>
        dplyr::filter(
          !grepl("NAO INFORMADO", nome_cor_origem_etnica, ignore.case = TRUE)
        ) |>
        dplyr::mutate(
          etnia      = ifelse(
            grepl("IND[ÍI]GENA|INDIGENA", nome_cor_origem_etnica, ignore.case = TRUE),
            "Indígenas", "Demais raça/cor"
          ),
          com_funcao = !grepl("^[sS]/", nome_funcao)
        ) |>
        dplyr::group_by(mes, etnia) |>
        dplyr::summarise(
          com = sum(total[com_funcao]),
          tot = sum(total),
          .groups = "drop"
        ) |>
        dplyr::mutate(
          p    = round(100 * com / tot, 2),
          data = as.Date(paste0(mes, "01"), "%Y%m%d")
        )

      cores <- c("Indígenas" = "#FF7800", "Demais raça/cor" = "#6c757d")

      plotly::plot_ly(
        df_plot, x = ~data, y = ~p, color = ~etnia, colors = cores,
        type = "scatter", mode = "lines+markers",
        marker = list(size = 4),
        hovertemplate = "<b>%{x|%b/%Y}</b><br>%{data.name}: %{y:.2f}%<extra></extra>"
      ) |>
        plotly::layout(
          xaxis  = list(title = ""),
          yaxis  = list(title = "% de vínculos com função", ticksuffix = "%"),
          legend = list(orientation = "h", x = 0.5, xanchor = "center", y = -0.2),
          hovermode = "x unified",
          paper_bgcolor = "#ffffff", plot_bgcolor = "#f8f9fa"
        )
    })

    # ==========================================================================
    # 4. CARGOS CCE/FCE
    # ==========================================================================

    # ---- 4a. Pirâmide CCE/FCE (butterfly) ----
    output$piramide_cce <- plotly::renderPlotly({
      req(input$mes_ref_func, input$etnia_cce, input$tipo_viz_func)
      mes_sel   <- as.integer(input$mes_ref_func)
      etnia_sel <- input$etnia_cce
      tipo_viz  <- input$tipo_viz_func

      df_plot <- df_funcao_tot |>
        dplyr::filter(mes == mes_sel, etnia == etnia_sel)

      y_var  <- if (tipo_viz == "abs") "total_funcao_adj" else "p_sexo"
      y_fmt  <- if (tipo_viz == "abs") ":,d" else ".1f%"
      y_lab  <- if (tipo_viz == "abs") "Ocupantes dos cargos" else "% por gênero"

      mas <- df_plot |> dplyr::filter(nivel_sexo == "Mas")
      fem <- df_plot |> dplyr::filter(nivel_sexo == "Fem")

      plotly::plot_ly() |>
        plotly::add_bars(
          data = mas, y = ~nivel_ord,
          x    = if (tipo_viz == "abs") ~total_funcao_adj else ~p_sexo,
          name = "Masculino", orientation = "h",
          marker = list(color = .PAL_IND["mas"]),
          hovertemplate = paste0("<b>%{y}</b><br>Masculino: %{x", y_fmt, "}<extra></extra>")
        ) |>
        plotly::add_bars(
          data = fem, y = ~nivel_ord,
          x    = if (tipo_viz == "abs") ~total_funcao_adj else ~p_sexo,
          name = "Feminino", orientation = "h",
          marker = list(color = .PAL_IND["fem"]),
          customdata = if (tipo_viz == "abs") ~total_funcao else ~abs(p_sexo),
          hovertemplate = paste0("<b>%{y}</b><br>Feminino: %{customdata", y_fmt, "}<extra></extra>")
        ) |>
        plotly::layout(
          barmode  = "overlay",
          title    = list(text = etnia_sel, font = list(size = 13)),
          xaxis    = list(title = y_lab),
          yaxis    = list(title = "Nível CCE/FCE",
                          categoryorder = "category ascending"),
          legend   = list(orientation = "h", x = 0.3, y = -0.15),
          shapes   = list(list(type = "line", x0 = 0, x1 = 0,
                               y0 = 0, y1 = 1, yref = "paper",
                               line = list(color = "#343a40", width = 1))),
          paper_bgcolor = "#ffffff", plot_bgcolor = "#f8f9fa"
        )
    })

    # ---- 4b. Série temporal de cargos CCE/FCE por nível (a partir de 2022) ----
    output$serie_niveis <- plotly::renderPlotly({
      df_plot <- df_funcao_tot |>
        dplyr::mutate(ano = as.integer(substr(as.character(mes), 1, 4))) |>
        dplyr::filter(ano >= 2022) |>
        dplyr::group_by(ano, etnia, nivel_ord) |>
        dplyr::summarise(total = sum(total), total_fc = sum(total_funcao),
                         .groups = "drop")

      cores_nivel <- c(
        "Nível 1 a 4"   = "#004587", "Nível 5 e 6"    = "#1351b4",
        "Nível 7 a 9"   = "#4a7fc1", "Nível 10 a 12"  = "#FF7800",
        "Nível 13 e 14" = "#e65a00", "Nível 15 a 18"  = "#b34000"
      )

      plotly::plot_ly(
        df_plot |> dplyr::filter(etnia == "Indígenas"),
        x     = ~ano, y = ~total_fc, color = ~nivel_ord, colors = cores_nivel,
        type  = "scatter", mode = "lines+markers",
        marker = list(size = 6),
        hovertemplate = "<b>%{x}</b><br>%{data.name}: %{y}<extra></extra>"
      ) |>
        plotly::layout(
          xaxis  = list(title = "Ano", dtick = 1),
          yaxis  = list(title = "Total de Vínculos com CCE/FCE"),
          legend = list(title = list(text = "Nível CCE/FCE"),
                        orientation = "v"),
          paper_bgcolor = "#ffffff", plot_bgcolor = "#f8f9fa"
        )
    })

    # ---- 4c. Razão de equidade por sexo ----
    output$razao_equiv <- plotly::renderPlotly({
      df_plot <- df_funcao_eqv |>
        dplyr::filter(mes > 202112, !is.nan(p_etnia), !is.nan(p_total), p_total > 0) |>
        dplyr::mutate(
          razao = round(p_etnia / p_total, 2),
          data  = as.Date(paste0(mes, "01"), "%Y%m%d"),
          serie = paste0(nivel_ord, " – ", nome_sexo)
        )

      cores_nivel <- c(
        "Nível 1 a 4"   = "#004587", "Nível 5 e 6"    = "#1351b4",
        "Nível 7 a 9"   = "#4a7fc1", "Nível 10 a 12"  = "#FF7800",
        "Nível 13 e 14" = "#e65a00", "Nível 15 a 18"  = "#b34000"
      )

      # subplot por sexo
      make_razao <- function(sexo_sel, show_legend) {
        plotly::plot_ly(
          df_plot |> dplyr::filter(nome_sexo == sexo_sel),
          x     = ~data, y = ~razao, color = ~nivel_ord, colors = cores_nivel,
          type  = "scatter", mode = "lines+markers",
          marker = list(size = 4),
          showlegend = show_legend,
          hovertemplate = "<b>%{x|%b/%Y}</b><br>%{data.name}: %{y:.2f}<extra></extra>"
        ) |>
          plotly::add_segments(
            inherit = FALSE,
            x = min(df_plot$data), xend = max(df_plot$data),
            y = 1, yend = 1,
            line = list(color = "#dc3545", dash = "dot", width = 1.5),
            name = "Paridade", showlegend = show_legend,
            hoverinfo = "none"
          ) |>
          plotly::layout(
            annotations = list(list(
              text = paste0("<b>", sexo_sel, "</b>"),
              x = 0.5, y = 1.02, xref = "paper", yref = "paper",
              showarrow = FALSE, font = list(size = 13)
            )),
            xaxis = list(title = ""),
            yaxis = list(title = if (sexo_sel == "Fem") "Razão de equidade" else "")
          )
      }

      plotly::subplot(
        make_razao("Fem", TRUE),
        make_razao("Mas", FALSE),
        shareY     = TRUE,
        titleX     = TRUE,
        margin     = 0.05
      ) |>
        plotly::layout(
          legend = list(orientation = "h", x = 0, y = -0.15,
                        title = list(text = "Nível CCE/FCE")),
          paper_bgcolor = "#ffffff", plot_bgcolor = "#f8f9fa"
        )
    })

    # ==========================================================================
    # 5. DISTRIBUIÇÃO GEOGRÁFICA E ÓRGÃOS
    # ==========================================================================

    # ---- 5a. Gráfico UF ----
    output$plot_uf <- plotly::renderPlotly({
      df_plot <- df_uf |>
        dplyr::filter(grepl("IND[ÍI]GENA|INDIGENA", nome_cor_origem_etnica,
                            ignore.case = TRUE)) |>
        dplyr::mutate(pct = round(100 * total_indigenas / sum(total_indigenas), 2)) |>
        dplyr::arrange(pct)

      plotly::plot_ly(
        df_plot,
        x    = ~pct, y = ~forcats::fct_reorder(uf, pct),
        type = "bar", orientation = "h",
        marker = list(
          color = ~pct,
          colorscale = list(c(0, "#d0dff0"), c(1, .PAL_IND["principal"])),
          showscale  = FALSE
        ),
        text          = ~paste0(pct, "%"),
        textposition  = "outside",
        hovertemplate = "<b>%{y}</b><br>%{x:.2f}% dos indígenas<br>Total: %{customdata:,}<extra></extra>",
        customdata    = ~total_indigenas
      ) |>
        plotly::layout(
          xaxis  = list(title = "% dentre servidores indígenas", ticksuffix = "%",
                        range = c(0, max(df_plot$pct) * 1.15)),
          yaxis  = list(title = ""),
          paper_bgcolor = "#ffffff", plot_bgcolor = "#f8f9fa",
          margin = list(l = 50, r = 40)
        )
    })

    # ---- 5b. Tabela de órgãos ----
    output$tab_orgaos <- DT::renderDT({
      req(input$ano_orgao, input$top_n_orgao)
      ano_sel <- as.integer(input$ano_orgao)
      n_top   <- input$top_n_orgao

      df_plot <- df_orgao_raw |>
        dplyr::filter(ano == ano_sel) |>
        dplyr::group_by(orgao_vinc, nome_orgao_vinc, no_orgao) |>
        dplyr::summarise(
          total_orgao    = sum(total),
          total_indigena = sum(total[grepl("IND[ÍI]GENA|INDIGENA",
                                          nome_cor_origem_etnica,
                                          ignore.case = TRUE)]),
          .groups = "drop"
        ) |>
        dplyr::mutate(pct_ind = round(100 * total_indigena / total_orgao, 2)) |>
        dplyr::filter(total_indigena > 0) |>
        dplyr::arrange(dplyr::desc(pct_ind)) |>
        dplyr::slice_head(n = n_top) |>
        dplyr::select(
          `Sigla`  = no_orgao,
          `Órgão`  = nome_orgao_vinc,
          `Total`  = total_orgao,
          `Indígenas` = total_indigena,
          `% Indígenas` = pct_ind
        )

      DT::datatable(
        df_plot,
        rownames = FALSE,
        class    = "compact stripe hover",
        options  = list(
          pageLength = 15,
          scrollX    = TRUE,
          language   = list(
            search   = "Pesquisar:",
            info     = "Exibindo _START_–_END_ de _TOTAL_ órgãos",
            paginate = list(`next` = "Próximo", previous = "Anterior")
          )
        )
      ) |>
        DT::formatStyle(
          "% Indígenas",
          background         = DT::styleColorBar(c(0, max(df_plot$`% Indígenas`)), .PAL_IND["destaque"]),
          backgroundSize     = "98% 50%",
          backgroundRepeat   = "no-repeat",
          backgroundPosition = "center"
        ) |>
        DT::formatRound("% Indígenas", digits = 2) |>
        DT::formatCurrency(c("Total", "Indígenas"), currency = "", mark = ".", digits = 0)
    })

    # ---- 5c. Natureza Jurídica (echarts4r) ----
    output$natjur_echart <- echarts4r::renderEcharts4r({
      # pct em escala 0-1 para usar os formatters nativos de percent do echarts4r
      df_plot <- df_natjur |>
        dplyr::filter(grepl("IND[ÍI]GENA|INDIGENA", nome_cor_origem_etnica,
                            ignore.case = TRUE)) |>
        dplyr::group_by(ano, nome_natureza_juridica_cnnj) |>
        dplyr::summarise(total = sum(total), .groups = "drop") |>
        dplyr::group_by(ano) |>
        dplyr::mutate(pct = round(total / sum(total), 4)) |>
        dplyr::ungroup() |>
        # ano como character garante eixo X categórico (ano a ano, sem interpolação)
        dplyr::mutate(ano_chr = as.character(ano)) |>
        tidyr::pivot_wider(
          id_cols     = ano_chr,
          names_from  = nome_natureza_juridica_cnnj,
          values_from = pct,
          values_fill = 0
        ) |>
        dplyr::arrange(ano_chr)

      nat_cols <- setdiff(names(df_plot), "ano_chr")

      p <- df_plot |> echarts4r::e_charts(ano_chr)

      for (col in nat_cols) {
        p <- p |> echarts4r::e_bar_(col, stack = "grp")
      }

      p |>
        echarts4r::e_tooltip(
          trigger   = "axis",
          formatter = echarts4r::e_tooltip_item_formatter("percent", digits = 1)
        ) |>
        echarts4r::e_y_axis(
          name      = "Participação (%)",
          formatter = echarts4r::e_axis_formatter("percent", digits = 0),
          max       = 1,
          nameTextStyle = list(color = "#555", fontWeight = "bold", fontSize = 11)
        ) |>
        echarts4r::e_x_axis(
          name          = "Ano",
          nameLocation  = "center",
          nameGap       = 28,
          axisLabel     = list(fontSize = 12)
        ) |>
        echarts4r::e_legend(right = 10, top = "middle", orient = "vertical") |>
        echarts4r::e_color(c(.PAL_IND["principal"], .PAL_IND["destaque"], .PAL_IND["verde"])) |>
        echarts4r::e_datazoom(show = FALSE)
    })

    # ---- 5d. Mapa coroplético de UF ----
    output$mapa_uf <- shiny::renderPlot({
      df_plot <- df_mapa |>
        dplyr::mutate(
          label = ifelse(total_indigenas > 0,
                         format(total_indigenas, big.mark = ".", scientific = FALSE),
                         "")
        )

      ggplot2::ggplot(df_plot) +
        ggplot2::geom_sf(
          ggplot2::aes(fill = total_indigenas),
          color = "white", linewidth = 0.5
        ) +
        ggplot2::scale_fill_gradient(
          low    = "#d0e4f7",
          high   = "#004587",
          name   = "Vínculos\nIndígenas",
          labels = function(x) format(x, big.mark = ".", scientific = FALSE)
        ) +
        ggplot2::geom_sf_text(
          ggplot2::aes(label = label),
          color    = "#FF7800",
          size     = 3,
          fontface = "bold",
          check_overlap = TRUE
        ) +
        ggplot2::labs(
          title   = paste0("Vínculos Indígenas Ativos por UF — ", label_mes),
          x = NULL, y = NULL
        ) +
        ggplot2::theme_void(base_size = 11) +
        ggplot2::theme(
          plot.title      = ggplot2::element_text(
            size = 12, face = "bold", color = "#004587", margin = ggplot2::margin(b = 8)
          ),
          legend.position = "right",
          legend.title    = ggplot2::element_text(size = 9, face = "bold"),
          legend.text     = ggplot2::element_text(size = 9),
          plot.background = ggplot2::element_rect(fill = "#ffffff", color = NA)
        )
    }, res = 110)

    # ==========================================================================
    # 6. PERFIL DEMOGRÁFICO
    # ==========================================================================

    # ---- 6a. Pirâmide etária – indígenas ----
    output$piramide_ind <- plotly::renderPlotly({
      .piramide_etaria(
        df_pir_ind |> dplyr::filter(nome_faixa_etaria != "15 a 18 anos"),
        titulo = "Vínculos Indígenas"
      )
    })

    # ---- 6b. Pirâmide etária – APF ----
    output$piramide_apf <- plotly::renderPlotly({
      .piramide_etaria(
        df_pir_apf |> dplyr::filter(nome_faixa_etaria != "15 a 18 anos"),
        titulo = "APF – Total de Vínculos"
      )
    })

    # ---- 6c. Treemap de escolaridade ----
    output$treemap_escol <- plotly::renderPlotly({
      df_plot <- df_tree |>
        dplyr::filter(grepl("IND[ÍI]GENA|INDIGENA", nome_cor_origem_etnica,
                            ignore.case = TRUE)) |>
        dplyr::group_by(escol = as.character(nome_escolaridade.f)) |>
        dplyr::summarise(total = sum(total), .groups = "drop") |>
        dplyr::arrange(dplyr::desc(total))

      labels  <- c("Indígenas", df_plot$escol)
      parents <- c("", rep("Indígenas", nrow(df_plot)))
      values  <- c(sum(df_plot$total), df_plot$total)

      plotly::plot_ly(
        labels        = labels,
        parents       = parents,
        values        = values,
        type          = "treemap",
        branchvalues  = "total",
        textinfo      = "label+value+percent parent",
        hovertemplate = "<b>%{label}</b><br>Total: %{value:,.0f}<br>%{percentParent:.1%} dos indígenas<extra></extra>",
        marker        = list(
          colors = c(
            "#004587", "#FF7800", "#1351b4", "#6c757d",
            "#28a745", "#ffc107", "#dc3545", "#17a2b8",
            "#343a40", "#e83e8c", "#20c997", "#fd7e14"
          )
        )
      ) |>
        plotly::layout(
          paper_bgcolor = "#ffffff",
          margin        = list(t = 10, b = 10)
        )
    })

    # ---- 6d. Ingressos históricos ----
    output$serie_ingressos <- plotly::renderPlotly({
      df_plot <- df_ingressos |>
        dplyr::filter(efetivo) |>
        dplyr::mutate(ano = as.integer(substr(as.character(mes), 1, 4))) |>
        dplyr::group_by(ano) |>
        dplyr::summarise(total = sum(total), .groups = "drop") |>
        dplyr::filter(ano >= 1985)

      plotly::plot_ly(
        df_plot, x = ~ano, y = ~total,
        type   = "bar",
        marker = list(
          color      = ~total,
          colorscale = list(c(0, "#d0dff0"), c(1, .PAL_IND["principal"])),
          showscale  = FALSE
        ),
        hovertemplate = "<b>%{x}</b><br>Ingressos: %{y:,}<extra></extra>"
      ) |>
        plotly::layout(
          xaxis = list(title = "Ano"),
          yaxis = list(title = "Ingressos de Indígenas"),
          paper_bgcolor = "#ffffff", plot_bgcolor = "#f8f9fa"
        )
    })

    # ---- 6e. Cotas ----
    output$serie_cotas <- plotly::renderPlotly({
      df_plot <- df_cotas |>
        dplyr::filter(efetivo) |>
        dplyr::mutate(ano = as.integer(substr(as.character(mes), 1, 4))) |>
        dplyr::group_by(ano, no_tipo_cota) |>
        dplyr::summarise(total = sum(total), .groups = "drop")

      cores_cota <- c(
        "Cota Indígena" = .PAL_IND["destaque"],
        "Cota Racial"   = .PAL_IND["principal"],
        "Cota PcD"      = .PAL_IND["apoio"]
      )

      plotly::plot_ly(
        df_plot, x = ~ano, y = ~total, color = ~no_tipo_cota, colors = cores_cota,
        type = "bar",
        hovertemplate = "<b>%{x}</b><br>%{data.name}: %{y:,}<extra></extra>"
      ) |>
        plotly::layout(
          barmode = "group",
          xaxis   = list(title = "Ano"),
          yaxis   = list(title = "Vínculos Ativos por Tipo de Cota"),
          legend  = list(orientation = "h", x = 0.5, xanchor = "center", y = -0.2),
          paper_bgcolor = "#ffffff", plot_bgcolor = "#f8f9fa"
        )
    })
  })
}


# ==============================================================================
# Auxiliares internos
# ==============================================================================

# Pirâmide etária genérica (plotly)
.piramide_etaria <- function(df, titulo = "") {
  df <- df |>
    dplyr::filter(!is.na(nome_faixa_etaria)) |>
    dplyr::mutate(
      nivel_num = as.numeric(
        stringr::str_extract(as.character(faixa_etaria), "[0-9]+")
      )
    )

  mas <- df |> dplyr::filter(nome_sexo == "Mas")
  fem <- df |> dplyr::filter(nome_sexo == "Fem")

  plotly::plot_ly() |>
    plotly::add_bars(
      data = mas,
      x    = ~total_ajustado,
      y    = ~stats::reorder(nome_faixa_etaria, nivel_num),
      name = "Masculino", orientation = "h",
      marker = list(color = .PAL_IND["mas"]),
      hovertemplate = "<b>%{y}</b><br>Masculino: %{x:,}<extra></extra>"
    ) |>
    plotly::add_bars(
      data       = fem,
      x          = ~total_ajustado,
      y          = ~stats::reorder(nome_faixa_etaria, nivel_num),
      name       = "Feminino", orientation = "h",
      marker     = list(color = .PAL_IND["fem"]),
      customdata = ~total,
      hovertemplate = "<b>%{y}</b><br>Feminino: %{customdata:,}<extra></extra>"
    ) |>
    plotly::layout(
      title   = list(text = titulo, font = list(size = 13, color = "#004587")),
      barmode = "overlay",
      xaxis   = list(title = "Total de Vínculos"),
      yaxis   = list(title = ""),
      shapes  = list(list(
        type = "line", x0 = 0, x1 = 0, y0 = 0, y1 = 1,
        yref = "paper", line = list(color = "#343a40", width = 1)
      )),
      legend  = list(orientation = "h", x = 0.3, y = -0.15),
      paper_bgcolor = "#ffffff", plot_bgcolor = "#f8f9fa"
    )
}
