#' pfgp_dim4 UI Function — Desenvolvimento e Desempenho de Pessoas e Formação de Lideranças Públicas
#' @noRd
#' @importFrom shiny NS tagList

mod_pfgp_dim4_ui <- function(id) {
  ns <- NS(id)
  tagList(
    bslib::layout_columns(
      col_widths = c(6, 6),
      bslib::card(
        bslib::card_header(
          class = "bg-primary text-white",
          shiny::icon("chart-line"),
          "Evolução Mensal – % de Cargos CCE/FCE ocupados por pessoas negras"
        ),
        bslib::card_body(.spin(plotly::plotlyOutput(ns("serie_lidera_negros"), height = "380px")))
      ),
      bslib::card(
        bslib::card_header(
          class = "bg-primary text-white",
          shiny::icon("chart-line"),
          "Evolução Anual – % de Cargos CCE/FCE ocupados por mulheres"
        ),
        bslib::card_body(.spin(plotly::plotlyOutput(ns("serie_lidera_mulheres"), height = "380px")))
      ),
      bslib::card(
        bslib::card_header(
          class = "bg-primary text-white",
          shiny::icon("chart-line"),
          "Evolução Anual – % de Cargos CCE/FCE ocupados por servidores efetivos"
        ),
        bslib::card_body(.spin(plotly::plotlyOutput(ns("serie_lidera_efetivos"), height = "380px")))
      ),
      bslib::card(
        bslib::card_header(
          class = "bg-primary text-white",
          shiny::icon("chart-line"),
          "Evolução Anual – % de servidores em Cargos CCE/FCE por origem territorial"
        ),
        bslib::card_body(.spin(plotly::plotlyOutput(ns("serie_lidera_origem"), height = "380px")))
      )
    ),
    bslib::card(
      bslib::card_header(
        class = "bg-primary text-white",
        shiny::icon("chart-bar"),
        "Percepção Oportunidades de capacitação"
      ),
      bslib::card_body(.spin(plotly::plotlyOutput(ns("vozes_opor_capacita"), height = "420px")))
    ),
    bslib::card(
      bslib::card_header(
        class = "bg-primary text-white",
        shiny::icon("chart-bar"),
        "Percepção de desempenho de equipe"
      ),
      bslib::card_body(.spin(plotly::plotlyOutput(ns("vozes_desemp_equipe"), height = "420px")))
    ),
    bslib::card(
      bslib::card_header(
        class = "bg-primary text-white",
        shiny::icon("chart-bar"),
        "Percepção de desempenho de organizacional"
      ),
      bslib::card_body(.spin(plotly::plotlyOutput(ns("vozes_desemp_org"), height = "420px")))
    )
  )
}

mod_pfgp_dim4_server <- function(id,
                                 grafico_compartilhado,
                                 reac_capacitacao,
                                 reac_desemp_equipe,
                                 reac_desemp_org) {
  shiny::moduleServer(id, function(input, output, session) {

    df_liderancas <- readRDS(here::here("data-raw/data_pfgp/df_liderancas.rds"))

    output$serie_lidera_negros <- plotly::renderPlotly({
      grafico_compartilhado()
    })

    serie_lid_mulheres <-
      df_liderancas |>
      dplyr::filter((lideranca)) |>
      dplyr::mutate(ano   = substr(MES, 1, 4) |> as.numeric(),
                    n_fem = ifelse(NOME_SEXO %in% "Fem", n, 0)) |>
      dplyr::group_by(ano, nivel_fce_cce) |>
      dplyr::summarise(n     = sum(n),
                       n_fem = sum(n_fem)) |>
      dplyr::mutate(p_mulheres = round(100 * n_fem / n, 1)) |>
      dplyr::filter(ano >= 2022)

    max_p_mulheres <- max(serie_lid_mulheres$p_mulheres)

    output$serie_lidera_mulheres <- plotly::renderPlotly({
      serie_lid_mulheres |>
        ggplot_cat(aes(x = ano, y = p_mulheres, colour = nivel_fce_cce)) +
        ylim(c(0, 1.2 * max_p_mulheres)) +
        geom_line(linewidth = .8) +
        geom_point(size = 2) +
        labs(colour = NULL, y = "Percentual de mulheres", x = NULL) -> gr_lid_mulheres

      ggplotly_c(gr_lid_mulheres)
    })

    serie_lid_efetivos <-
      df_liderancas |>
      dplyr::filter((lideranca)) |>
      dplyr::mutate(ano    = substr(MES, 1, 4) |> as.numeric(),
                    n_efet = ifelse(efetivo, n, 0)) |>
      dplyr::group_by(ano, nivel_fce_cce) |>
      dplyr::summarise(n      = sum(n),
                       n_efet = sum(n_efet)) |>
      dplyr::mutate(p_efet = round(100 * n_efet / n, 1)) |>
      dplyr::filter(ano >= 2022)

    max_p_efet <- max(serie_lid_efetivos$p_efet)

    output$serie_lidera_efetivos <- plotly::renderPlotly({
      serie_lid_efetivos |>
        ggplot_cat(aes(x = ano, y = p_efet, colour = nivel_fce_cce)) +
        ylim(c(0, 1.2 * max_p_efet)) +
        geom_line(linewidth = .8) +
        geom_point(size = 2) +
        labs(colour = NULL, y = "Percentual de efetivos", x = NULL) -> gr_lid_efetivos

      ggplotly_c(gr_lid_efetivos)
    })

    serie_origem_lid <-
      df_liderancas |>
      dplyr::mutate(ano         = substr(MES, 1, 4) |> as.numeric(),
                    n_lid_1a12  = ifelse(nivel_fce_cce %in% c("Níveis 1 a 12"), n, 0),
                    n_lid_13a18 = ifelse(nivel_fce_cce %in% c("Níveis 13 a 18"), n, 0)) |>
      dplyr::group_by(ano, REGIAO_NATURALIDADE) |>
      dplyr::summarise(n           = sum(n),
                       n_lid_1a12  = sum(n_lid_1a12),
                       n_lid_13a18 = sum(n_lid_13a18)) |>
      dplyr::mutate(p_lid_1a12  = round(100 * n_lid_1a12  / n, 1),
                    p_lid_13a18 = round(100 * n_lid_13a18 / n, 1)) |>
      dplyr::filter(ano >= 2022, !is.na(REGIAO_NATURALIDADE))

    max_p_efet_origem <- max(serie_origem_lid$p_lid_13a18)

    output$serie_lidera_origem <- plotly::renderPlotly({
      serie_origem_lid |>
        ggplot_cat(aes(x = ano, y = p_lid_13a18, colour = REGIAO_NATURALIDADE)) +
        ylim(c(0, 1.2 * max_p_efet_origem)) +
        geom_line(linewidth = .8) +
        geom_point(size = 2) +
        labs(colour = NULL, y = "Percentual com FCE/CCE 13 ou maior", x = NULL) -> gr_lid_origem

      ggplotly_c(gr_lid_origem)
    })

    ### server: Percepção de critérios de promoção ----
    output$vozes_opor_capacita <- plotly::renderPlotly({reac_capacitacao()})

    ### server: Percepção de desempenho da equipe ----
    output$vozes_desemp_equipe <- plotly::renderPlotly({reac_desemp_equipe()})

    ### server: Percepção de desempenho organizacional ----
    output$vozes_desemp_org <- plotly::renderPlotly({reac_desemp_org()})


  })
}
