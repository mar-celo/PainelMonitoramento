#' etnia_lideranca UI Function
#'
#' @description Módulo de monitoramento da ocupação de Cargos Comissionados
#'   (CCE/FCE) por pessoas negras – Decreto nº 11.443/2023.
#'
#' @param id Internal parameter for {shiny}.
#' @noRd
#' @importFrom shiny NS tagList
mod_etnia_lideranca_ui <- function(id) {
  ns <- NS(id)
  tagList(
    bslib::navset_card_underline(
      id = ns("nav_etnia"),
      selected = "visao",

      # ------------------------------------------------------------------
      # Aba 1: Visão Geral
      # ------------------------------------------------------------------
      bslib::nav_panel(
        title = "Visão Geral",
        value = "visao",
        icon  = shiny::icon("users"),
        shiny::uiOutput(ns("kpi_boxes")),
        bslib::card(
          bslib::card_header(
            class = "bg-primary text-white",
            shiny::icon("chart-line"),
            " Evolução Mensal – % de Pessoas Negras em Cargos CCE/FCE"
          ),
          bslib::card_body(plotly::plotlyOutput(ns("serie_mensal"), height = "380px"))
        )
      ),

      # ------------------------------------------------------------------
      # Aba 2: Por Órgão
      # ------------------------------------------------------------------
      bslib::nav_panel(
        title = "Por Órgão",
        value = "orgao",
        icon  = shiny::icon("building"),
        bslib::layout_columns(
          col_widths = c(6, 6),
          bslib::card(
            bslib::card_header(
              class = "bg-primary text-white",
              shiny::icon("sitemap"), " Por Órgão Superior"
            ),
            bslib::card_body(DT::DTOutput(ns("tab_superior")))
          ),
          bslib::card(
            bslib::card_header(
              class = "bg-primary text-white",
              shiny::icon("building"), " Por Órgão Vinculado"
            ),
            bslib::card_body(DT::DTOutput(ns("tab_vinculado")))
          )
        )
      ),

      # ------------------------------------------------------------------
      # Aba 3: Suficiência de Vagas
      # ------------------------------------------------------------------
      bslib::nav_panel(
        title = "Suficiência de Vagas",
        value = "suficiencia",
        icon  = shiny::icon("balance-scale"),
        bslib::layout_columns(
          col_widths = c(6, 6),
          bslib::card(
            bslib::card_header(
              class = "bg-primary text-white",
              "Índice de Suficiência – Nível 1 a 12"
            ),
            bslib::card_body(DT::DTOutput(ns("suf_1a12")))
          ),
          bslib::card(
            bslib::card_header(
              class = "bg-primary text-white",
              "Índice de Suficiência – Nível 13 a 17"
            ),
            bslib::card_body(DT::DTOutput(ns("suf_13a17")))
          )
        )
      ),

      # ------------------------------------------------------------------
      # Aba 4: Razão de Equidade
      # ------------------------------------------------------------------
      bslib::nav_panel(
        title = "Razão de Equidade",
        value = "equidade",
        icon  = shiny::icon("chart-bar"),
        bslib::card(
          bslib::card_header(
            class = "bg-primary text-white",
            shiny::icon("chart-bar"),
            " Razão de Equidade por Cor/Raça nos Cargos CCE/FCE"
          ),
          bslib::card_body(plotly::plotlyOutput(ns("razao_equidade"), height = "420px"))
        )
      )
    )
  )
}


#' etnia_lideranca Server Functions
#'
#' @param id Internal parameter for {shiny}.
#' @noRd
mod_etnia_lideranca_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {

    # ------------------------------------------------------------------
    # Carregamento de dados
    # ------------------------------------------------------------------
    Tab_serie    <- readRDS(here::here("data-raw/data_etnia/Tab_inds_1_e_2.rds"))
    Tab_vinc     <- readRDS(here::here("data-raw/data_etnia/Tab.rds"))
    Tab_sup      <- readRDS(here::here("data-raw/data_etnia/Tab_sup.rds"))
    Tab_ind3     <- readRDS(here::here("data-raw/data_etnia/Tab_ind3.rds"))
    Tab_eq_mes   <- readRDS(here::here("data-raw/data_etnia/Tab_inds_4_mes.rds"))

    # Normalizar nomes de colunas (remove acentuação para evitar problemas de encoding)
    names(Tab_vinc) <- iconv(names(Tab_vinc), "UTF-8", "ASCII//TRANSLIT")
    names(Tab_sup)  <- iconv(names(Tab_sup),  "UTF-8", "ASCII//TRANSLIT")

    # ------------------------------------------------------------------
    # Valores do mês mais recente
    # ------------------------------------------------------------------
    mes_max <- max(Tab_serie$anomes)

    atual <- Tab_serie |>
      dplyr::filter(anomes == mes_max)

    pct_1a12  <- atual$p_negras[atual$decreto_nivel == "Nível 1 a 12"]
    pct_13a17 <- atual$p_negras[atual$decreto_nivel == "Nível 13 a 17"]

    mes_ant <- max(Tab_serie$anomes[Tab_serie$anomes < mes_max])

    anterior <- Tab_serie |>
      dplyr::filter(anomes == mes_ant)

    ant_1a12  <- anterior$p_negras[anterior$decreto_nivel == "Nível 1 a 12"]
    ant_13a17 <- anterior$p_negras[anterior$decreto_nivel == "Nível 13 a 17"]

    delta_1a12  <- if (length(ant_1a12)  > 0) round(pct_1a12  - ant_1a12,  2) else NA_real_
    delta_13a17 <- if (length(ant_13a17) > 0) round(pct_13a17 - ant_13a17, 2) else NA_real_

    fmt_delta <- function(d) {
      if (is.na(d)) return("–")
      paste0(ifelse(d >= 0, "+", ""), d, " pp")
    }

    # ------------------------------------------------------------------
    # KPI boxes
    # ------------------------------------------------------------------
    output$kpi_boxes <- shiny::renderUI({
      bslib::layout_columns(
        col_widths = c(3, 3, 3, 3),
        bslib::value_box(
          title    = "Negros – Nível 1 a 12",
          value    = paste0(round(pct_1a12, 1), "%"),
          showcase = shiny::icon("users"),
          theme    = if (pct_1a12 >= 30) "success" else "warning",
          shiny::p(
            paste0("Meta: 30% | ", ifelse(pct_1a12 >= 30, "Meta atingida", "Abaixo da meta")),
            style = "font-size:0.85rem;"
          )
        ),
        bslib::value_box(
          title    = "Negros – Nível 13 a 17",
          value    = paste0(round(pct_13a17, 1), "%"),
          showcase = shiny::icon("crown"),
          theme    = if (pct_13a17 >= 30) "success" else "danger",
          shiny::p(
            paste0("Meta: 30% | ", ifelse(pct_13a17 >= 30, "Meta atingida", "Abaixo da meta")),
            style = "font-size:0.85rem;"
          )
        ),
        bslib::value_box(
          title    = "Var. Mensal – Nível 1-12",
          value    = fmt_delta(delta_1a12),
          showcase = shiny::icon(if (!is.na(delta_1a12) && delta_1a12 >= 0) "arrow-up" else "arrow-down"),
          theme    = "primary",
          shiny::p("pontos percentuais vs. mês anterior", style = "font-size:0.85rem;")
        ),
        bslib::value_box(
          title    = "Meta – Decreto 11.443/2023",
          value    = "30%",
          showcase = shiny::icon("gavel"),
          theme    = bslib::value_box_theme(bg = "#0c326f", fg = "#ffffff"),
          shiny::p("cargos CCE/FCE ocupados por pessoas negras", style = "font-size:0.85rem;")
        )
      )
    })

    # ------------------------------------------------------------------
    # Série mensal % negros em CCE/FCE
    # ------------------------------------------------------------------
    output$serie_mensal <- plotly::renderPlotly({
      dt_decreto <- 2023 + (3L - 1L) / 12   # marco/2023

      cores <- c("Nível 1 a 12" = "#004587", "Nível 13 a 17" = "#1351b4")

      plotly::plot_ly(
        Tab_serie,
        x     = ~anomes,
        y     = ~p_negras,
        color = ~decreto_nivel,
        colors = cores,
        type  = "scatter",
        mode  = "lines+markers",
        text  = ~mes_ano_cargos,
        hovertemplate = "<b>%{text}</b><br>%{y:.1f}%<extra></extra>",
        marker = list(size = 5)
      ) |>
        plotly::add_segments(
          inherit   = FALSE,
          x         = dt_decreto, xend = dt_decreto,
          y         = 0, yend = max(Tab_serie$p_negras, na.rm = TRUE) * 1.12,
          line      = list(color = "#6c757d", dash = "dash", width = 1),
          name      = "Decreto 11.443/2023",
          showlegend = TRUE,
          hoverinfo  = "none"
        ) |>
        plotly::add_segments(
          inherit   = FALSE,
          x         = min(Tab_serie$anomes),
          xend      = max(Tab_serie$anomes),
          y         = 30, yend = 30,
          line      = list(color = "#dc3545", dash = "dot", width = 1.5),
          name      = "Meta: 30%",
          showlegend = TRUE,
          hoverinfo  = "none"
        ) |>
        plotly::layout(
          xaxis  = list(title = ""),
          yaxis  = list(title = "% de Pessoas Negras", ticksuffix = "%"),
          legend = list(orientation = "h", x = 0, y = -0.18),
          hovermode     = "x unified",
          paper_bgcolor = "#ffffff",
          plot_bgcolor  = "#f8f9fa"
        )
    })

    # ------------------------------------------------------------------
    # Tabela por órgão superior
    # ------------------------------------------------------------------
    output$tab_superior <- DT::renderDT({
      .dt_orgao(Tab_sup, "Orgao Superior")
    })

    # ------------------------------------------------------------------
    # Tabela por órgão vinculado
    # ------------------------------------------------------------------
    output$tab_vinculado <- DT::renderDT({
      df <- Tab_vinc |>
        dplyr::select(-dplyr::starts_with("Orgao Superior"))
      .dt_orgao(df, "Orgao")
    })

    # ------------------------------------------------------------------
    # Índice de suficiência de vagas
    # ------------------------------------------------------------------
    output$suf_1a12  <- DT::renderDT({ .dt_suficiencia(Tab_ind3, "Nível 1 a 12")  })
    output$suf_13a17 <- DT::renderDT({ .dt_suficiencia(Tab_ind3, "Nível 13 a 17") })

    # ------------------------------------------------------------------
    # Razão de equidade por cor/raça
    # ------------------------------------------------------------------
    output$razao_equidade <- plotly::renderPlotly({
      df_long <- Tab_eq_mes |>
        tidyr::pivot_longer(
          cols      = c(ind4_1_a_12, ind4_13_a_17),
          names_to  = "nivel_cod",
          values_to = "razao"
        ) |>
        dplyr::mutate(
          nivel_label = dplyr::case_when(
            nivel_cod == "ind4_1_a_12"   ~ "Nível 1 a 12",
            nivel_cod == "ind4_13_a_17"  ~ "Nível 13 a 17"
          ),
          serie = paste(nome_cor_origem_etnica, nivel_label)
        )

      cores_etnia <- c(
        "NEGRAS" = "#004587",  "BRANCA"   = "#6c757d",
        "AMARELA" = "#d4a017", "INDIGENA" = "#FF7800",
        "PARDA"   = "#8b4513", "PRETA"    = "#343a40"
      )

      plotly::plot_ly(
        df_long,
        x         = ~anomes,
        y         = ~razao,
        color     = ~nome_cor_origem_etnica,
        colors    = cores_etnia,
        linetype  = ~nivel_label,
        type      = "scatter",
        mode      = "lines",
        hovertemplate = "<b>%{text}</b><br>Razão: %{y:.2f}<extra></extra>",
        text      = ~serie
      ) |>
        plotly::add_segments(
          inherit    = FALSE,
          x          = min(Tab_eq_mes$anomes),
          xend       = max(Tab_eq_mes$anomes),
          y          = 1, yend = 1,
          line       = list(color = "#dc3545", dash = "dot", width = 1.5),
          name       = "Paridade (= 1)",
          showlegend = TRUE,
          hoverinfo  = "none"
        ) |>
        plotly::layout(
          xaxis  = list(title = ""),
          yaxis  = list(
            title    = "Razão de Equidade",
            zeroline = FALSE
          ),
          legend = list(orientation = "h", x = 0, y = -0.25),
          hovermode     = "x unified",
          paper_bgcolor = "#ffffff",
          plot_bgcolor  = "#f8f9fa",
          annotations   = list(list(
            x         = max(Tab_eq_mes$anomes),
            y         = 1.02,
            text      = "Paridade",
            showarrow = FALSE,
            xanchor   = "right",
            font      = list(color = "#dc3545", size = 10)
          ))
        )
    })
  })
}


# ------------------------------------------------------------------
# Helpers internos
# ------------------------------------------------------------------

# Monta DT para tabelas de órgão com color bar de percentuais
.dt_orgao <- function(df, col_orgao) {
  col_n1 <- grep("^N.vel.1|^Nivel.1", names(df), value = TRUE)[1]
  col_n2 <- grep("^N.vel.13|^Nivel.13", names(df), value = TRUE)[1]

  dt_opts <- list(
    pageLength  = 15,
    scrollX     = TRUE,
    order       = list(list(which(names(df) == col_n1) - 1L, "asc")),
    language    = list(
      search    = "Pesquisar:",
      info      = "Exibindo _START_ até _END_ de _TOTAL_ órgãos",
      paginate  = list(`next` = "Próximo", previous = "Anterior")
    )
  )

  DT::datatable(df, rownames = FALSE, class = "compact stripe hover",
                options = dt_opts) |>
    DT::formatStyle(
      col_n1,
      background           = DT::styleColorBar(c(0, 100), "#004587"),
      backgroundSize       = "98% 50%",
      backgroundRepeat     = "no-repeat",
      backgroundPosition   = "center"
    ) |>
    DT::formatStyle(
      col_n2,
      background           = DT::styleColorBar(c(0, 100), "#1351b4"),
      backgroundSize       = "98% 50%",
      backgroundRepeat     = "no-repeat",
      backgroundPosition   = "center"
    ) |>
    DT::formatStyle(
      col_n1,
      color = DT::styleInterval(30, c("#dc3545", "#155724"))
    ) |>
    DT::formatStyle(
      col_n2,
      color = DT::styleInterval(30, c("#dc3545", "#155724"))
    )
}

# Monta DT para tabela de suficiência de vagas filtrada por nível
.dt_suficiencia <- function(df, nivel) {
  df_filt <- df |>
    dplyr::filter(decreto_nivel == nivel) |>
    dplyr::select(
      orgao_vinculado_cargos_e_funcoes,
      Total_ocupados,
      total_negras,
      total_dist,
      necessidade_vagas,
      cargos_disponiveis,
      indice_suficiencia
    ) |>
    dplyr::rename(
      Orgao                       = orgao_vinculado_cargos_e_funcoes,
      `Cargos Ocupados`           = Total_ocupados,
      `Negros Ocupando`           = total_negras,
      `Cargos Distribuidos`       = total_dist,
      `Vagas Necessarias`         = necessidade_vagas,
      `Vagas Disponiveis`         = cargos_disponiveis,
      `Indice Suficiencia`        = indice_suficiencia
    ) |>
    dplyr::arrange(`Indice Suficiencia`)

  rng <- range(df$indice_suficiencia, na.rm = TRUE)

  DT::datatable(
    df_filt,
    rownames = FALSE,
    class    = "compact stripe hover",
    options  = list(
      pageLength = 15,
      scrollX    = TRUE,
      language   = list(
        search   = "Pesquisar:",
        paginate = list(`next` = "Próximo", previous = "Anterior")
      )
    )
  ) |>
    DT::formatStyle(
      "Indice Suficiencia",
      background         = DT::styleColorBar(rng, "#004587"),
      backgroundSize     = "98% 50%",
      backgroundRepeat   = "no-repeat",
      backgroundPosition = "center"
    ) |>
    DT::formatStyle(
      "Indice Suficiencia",
      color = DT::styleInterval(1, c("#dc3545", "#155724"))
    ) |>
    DT::formatRound("Indice Suficiencia", digits = 2)
}
