#' pfgp_dim2 UI Function — Carreiras, Cargos, Progressão e Promoção
#' @noRd
#' @importFrom shiny NS tagList

load(file = "data-raw/data_pfgp.rda")

mod_pfgp_dim2_ui <- function(id) {
  ns <- NS(id)
  bslib::layout_sidebar(
    sidebar = bslib::sidebar(
      shiny::selectInput(ns("orgao_ref"), "Órgão",
                         choices  = c("Total", lista_orgaos),
                         selected = "Total")
    ),
    bslib::layout_columns(
      col_widths = c(8, 4),
      bslib::layout_columns(
        col_widths = c(12, 12),
        bslib::card(
          bslib::card_header(
            class = "bg-primary text-white",
            shiny::icon("chart-bar"),
            "Percentual de cargos com exercício descentralizado"
          ),
          bslib::card_body(.spin(plotly::plotlyOutput(ns("p_cargos_descent"), height = "420px")))
        ),
        bslib::card(
          bslib::card_header(
            class = "bg-primary text-white",
            shiny::icon("chart-bar"),
            "Percentual de servidores ativos em exercício descentralizado"
          ),
          bslib::card_body(.spin(plotly::plotlyOutput(ns("p_serv_descent"), height = "420px")))
        )
      ),
      bslib::layout_columns(
        bslib::card(
          bslib::card_header(
            class = "bg-primary text-white",
            shiny::icon("chart-bar"),
            "Distribuição por raça e gênero, exercícios descentralizados X não descentralizados"
          ),
          bslib::card_body(.spin(plotly::plotlyOutput(ns("dist_racagen_descent"), height = "420px")))
        )
      )
    )
  )
}

mod_pfgp_dim2_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {

    tab_cargo_transversal       <- readRDS(here::here("data-raw/data_pfgp/tab_cargo_transversal.rds"))
    tab_ativo_transversal       <- readRDS(here::here("data-raw/data_pfgp/tab_ativo_transversal.rds"))
    tab_raca_genero_transversal <- readRDS(here::here("data-raw/data_pfgp/tab_raca_genero_transversal.rds"))

    tab_raca_genero_transversal <- dplyr::filter(tab_raca_genero_transversal,
                                                 !no_cor_origem_etnica %in% c(NA),
                                                 !grepl("N.O INFORMADO", no_cor_origem_etnica),
                                                 N > 5)

    tab_raca_genero_transversal |>
      dplyr::group_by(no_cor_origem_etnica) |>
      dplyr::summarise(N = sum(N)) |>
      dplyr::arrange(dplyr::desc(N)) |>
      dplyr::filter(N > 50) -> tot_raca

    tab_raca_genero_transversal <-
      tab_raca_genero_transversal |>
      dplyr::mutate(
        f_cor_origem_etnica = factor(no_cor_origem_etnica,
                                     levels = tot_raca$no_cor_origem_etnica,
                                     ordered = TRUE),
        nm_transv = ifelse(transversal,
                           "Exercício Descentralizado",
                           "Exercício Não Descentralizado"),
        periodo   = substr(compet, 1, 4) |> as.numeric(),
        sexo      = ifelse(co_sexo == "F", "Mulheres", "Homens")
      ) |>
      dplyr::mutate(nm_transv_sexo = paste0(nm_transv, ": ", sexo))

    output$p_cargos_descent <- plotly::renderPlotly({
      req(input$orgao_ref)
      ft_orgao <- as.character(input$orgao_ref)

      tab_filtro <- tab_cargo_transversal |>
        dplyr::filter(sg_orgao == ft_orgao) |>
        dplyr::mutate(p_cargo_transv = round(100 * n_transversais / N, 2),
                      periodo        = substr(compet, 1, 4) |> as.numeric())

      tab_filtro |>
        ggplot_cat(aes(x = periodo, y = p_cargo_transv)) +
        ylim(c(0, 1.2 * max(tab_filtro$p_cargo_transv))) +
        geom_line(linewidth = 0.8) +
        geom_point(size = 2) +
        labs(colour = NULL, y = NULL, x = NULL) -> gr_cargos_descent

      ggplotly_c(gr_cargos_descent)
    })

    output$p_serv_descent <- plotly::renderPlotly({
      req(input$orgao_ref)
      ft_orgao <- as.character(input$orgao_ref)

      tab_filtro <- dplyr::filter(tab_ativo_transversal, sg_orgao == ft_orgao, transversal) |>
        dplyr::mutate(periodo      = substr(compet, 1, 4) |> as.numeric(),
                      p_serv_transv = round(100 * N / N_total, 2))

      tab_filtro |>
        ggplot_cat(aes(x = periodo, y = p_serv_transv, col = no_sit_serv)) +
        ylim(c(0, 1.2 * max(tab_filtro$p_serv_transv))) +
        geom_line(linewidth = 0.8) +
        geom_point(size = 2) +
        labs(colour = NULL, y = NULL, x = NULL) -> gr_serv_descent

      ggplotly_c(gr_serv_descent)
    })

    output$dist_racagen_descent <- plotly::renderPlotly({
      req(input$orgao_ref)
      ft_orgao <- as.character(input$orgao_ref)

      if (ft_orgao != "Total") {
        tab_filtro <- dplyr::filter(tab_raca_genero_transversal, sg_orgao == ft_orgao)
      } else {
        tab_filtro <- tab_raca_genero_transversal |>
          dplyr::group_by(periodo, nm_transv, f_cor_origem_etnica, sexo, nm_transv_sexo) |>
          dplyr::summarise(N = sum(N))
      }

      tab_filtro <- dplyr::filter(tab_filtro, periodo > 2019)

      tab_filtro <-
        tab_filtro |>
        dplyr::group_by(periodo, nm_transv) |>
        dplyr::mutate(N_total = sum(N)) |>
        dplyr::ungroup() |>
        dplyr::mutate(p_raca_genero = round(100 * N / N_total, 2))

      tab_filtro |>
        ggplot_cat(aes(x = periodo, y = p_raca_genero, col = f_cor_origem_etnica)) +
        geom_line(linewidth = 0.8) +
        geom_point(size = 2) +
        labs(col = NULL, y = "Percentual de Raça e Gênero", x = NULL) +
        facet_wrap(nm_transv_sexo ~.) -> gr_racagenero_descent

      ggplotly_c(gr_racagenero_descent)
    })
  })
}
