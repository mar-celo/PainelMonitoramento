#' etnia_lideranca UI Function
#'
#' @description Módulo de monitoramento do Plano Federal de Gestão de Pessoas (PFGP)
#'
#' @param id Internal parameter for {shiny}.
#' @noRd
#' @importFrom shiny NS tagList
mod_pfgp_ui <- function(id) {
  ns <- NS(id)
  tagList(
    bslib::navset_card_underline(
      id = ns("nav_pfgp"),
      selected = "pfgp_1",

      # ------------------------------------------------------------------
      # Aba 1: Dimensão 1
      # ------------------------------------------------------------------
      bslib::nav_panel(
        title = "Dimensão 1: Dimensionamento\nda Força de Trabalho",
        value = "pfgp_1",
        icon  = shiny::icon("users"),
        shiny::uiOutput(ns("kpi_boxes")),
        bslib::card(
          bslib::card_header(
            class = "bg-primary text-white",
            shiny::icon("chart-line"),
            " Evolução Mensal – % de Pessoas Negras em Cargos CCE/FCE"
          )#,
          # bslib::card_body(.spin(plotly::plotlyOutput(ns("serie_mensal"), height = "380px")))
        )
      ),

      # ------------------------------------------------------------------
      # Aba 2: Dimensão 2
      # ------------------------------------------------------------------
      bslib::nav_panel(
        title = "Dimensão 2: Alocação, Ambientação, Estágio Probatório e Bem-Estar",
        value = "pfgp_2",
        icon  = shiny::icon("building"),
        bslib::layout_columns(
          col_widths = c(6, 6),
          bslib::card(
            bslib::card_header(
              class = "bg-primary text-white",
              shiny::icon("sitemap"), " Por Órgão Superior"
            ),
            # bslib::card_body(fill = FALSE, .spin(DT::DTOutput(ns("tab_superior"))))
          ),
          bslib::card(
            bslib::card_header(
              class = "bg-primary text-white",
              shiny::icon("building"), " Por Órgão Vinculado"
            )#,
            # bslib::card_body(fill = FALSE, .spin(DT::DTOutput(ns("tab_vinculado"))))
          )
        )
      ),

      # ------------------------------------------------------------------
      # Aba 3: Dimensão 3:
      # ------------------------------------------------------------------
      bslib::nav_panel(
        title = "Dimensão 3: Desenvolvimento e Desempenho de Pessoas e Formação de Lideranças Públicas",
        value = "pfgp_3",
        icon  = shiny::icon("balance-scale"),
        bslib::layout_columns(
          col_widths = c(6, 6),
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
              "Evolução Mensal – % de servidores em Cargos CCE/FCE por origem territorial"
              ),
            bslib::card_body(.spin(plotly::plotlyOutput(ns("serie_lidera_origem"), height = "380px")))
            )
          )
        ),

      # ------------------------------------------------------------------
      # Aba 4: Dimensão 4
      # ------------------------------------------------------------------
      bslib::nav_panel(
        title = "Dimensão 4: Carreiras, Cargos, Progressão e Promoção",
        value = "pfgp_4",
        icon  = shiny::icon("chart-bar"),
        bslib::card(
          bslib::card_header(
            class = "bg-primary text-white",
            shiny::icon("chart-bar"),
            " Razão de Equidade por Cor/Raça nos Cargos CCE/FCE"
          )#,
          # bslib::card_body(.spin(plotly::plotlyOutput(ns("razao_equidade"), height = "420px")))
        )
      ),

      # ------------------------------------------------------------------
      # Aba 5: Dimensão 5
      # ------------------------------------------------------------------
      bslib::nav_panel(
        title = "Dimensão 5: Remuneração, Benefícios, Reconhecimento e Recompensas Não Pecuniárias",
        value = "pfgp_5",
        icon  = shiny::icon("chart-bar"),
        bslib::card(
          bslib::card_header(
            class = "bg-primary text-white",
            shiny::icon("chart-bar"),
            " Razão de Equidade por Cor/Raça nos Cargos CCE/FCE"
          )#,
          # bslib::card_body(.spin(plotly::plotlyOutput(ns("razao_equidade"), height = "420px")))
        )
      ),

      # ------------------------------------------------------------------
      # Aba 6: Dimensão 6
      # ------------------------------------------------------------------
      bslib::nav_panel(
        title = "Dimensão 6: Aposentação, Pensões e Desligamentos",
        value = "pfgp_",
        icon  = shiny::icon("chart-bar"),
        bslib::card(
          bslib::card_header(
            class = "bg-primary text-white",
            shiny::icon("chart-bar"),
            " Razão de Equidade por Cor/Raça nos Cargos CCE/FCE"
          ),
          bslib::card_body(.spin(plotly::plotlyOutput(ns("razao_equidade"), height = "420px")))
        )
      )
    )
  )
}


#' etnia_lideranca Server Functions
#'
#' @param id Internal parameter for {shiny}.
#' @noRd
mod_pfgp_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {

    # ------------------------------------------------------------------
    # Carregamento de dados
    # ------------------------------------------------------------------
    df_liderancas  <- readRDS(here::here("data-raw/data_pfgp/df_liderancas.rds"))



    # ------------------------------------------------------------------
    # Série anual % mulheres em CCE/FCE
    # ------------------------------------------------------------------



    # agregando
    serie_lid_mulheres <-
      df_liderancas |>
      dplyr::filter((lideranca)) |>
      dplyr::mutate(ano = substr(MES,1,4) |> as.numeric(),
             n_fem = ifelse(NOME_SEXO %in% "Fem",n,0)) |>
      dplyr::group_by(ano,nivel_fce_cce) |>
      dplyr::summarise(n = sum(n),
                n_fem = sum(n_fem)
      ) |>
      dplyr::mutate(p_mulheres = round(100*n_fem/n,1)) |>
      dplyr::filter(ano >= 2022)

    # cat("\n\ndeu certo aqui!\n\n")

    max_p_mulheres <- max(serie_lid_mulheres$p_mulheres)


    ## output
    output$serie_lidera_mulheres <- plotly::renderPlotly({


      # objeto ggplot
      serie_lid_mulheres |>
        ggplot_cat(
          aes(x = ano,
              y = p_mulheres,
              colour = nivel_fce_cce)
          ) +
        ylim(c(0,1.2*max_p_mulheres)) +
        geom_line(linewidth = .8) +
        geom_point(size = 2) +
        labs(colour = NULL,y = "Percentual de mulheres",x = NULL) -> gr_lid_mulheres

      ggplotly_c(gr_lid_mulheres)

    })



    # ------------------------------------------------------------------
    # Série anual: % de cargos CCE/FCE ocupados por efetivos
    # ------------------------------------------------------------------



    # agregando
    serie_lid_efetivos <-
      df_liderancas |>
      dplyr::filter((lideranca)) |>
      dplyr::mutate(ano = substr(MES,1,4) |> as.numeric(),
             n_efet = ifelse(efetivo,n,0)) |>
      dplyr::group_by(ano,nivel_fce_cce) |>
      dplyr::summarise(n = sum(n),
                n_efet = sum(n_efet)
      ) |>
      dplyr::mutate(p_efet = round(100*n_efet/n,1)) |>
      dplyr::filter(ano >= 2022)

    # cat("\n\ndeu certo aqui!\n\n")

    max_p_efet <- max(serie_lid_efetivos$p_efet)


    ## output
    output$serie_lidera_efetivos <- plotly::renderPlotly({


      # objeto ggplot
      serie_lid_efetivos |>
        ggplot_cat(
          aes(x = ano,
              y = p_efet,
              colour = nivel_fce_cce)
        ) +
        ylim(c(0,1.2*max_p_efet)) +
        geom_line(linewidth = .8) +
        geom_point(size = 2) +
        labs(colour = NULL,y = "Percentual de efetivos",x = NULL) -> gr_lid_efetivos

      ggplotly_c(gr_lid_efetivos)

    })





    # ------------------------------------------------------------------
    # Série anual: % de servidores efetivos em cargos FCE
    # ------------------------------------------------------------------



    # agregando
    serie_origem_lid <-
      df_liderancas |>
      # dplyr::filter(efetivo) |>
      dplyr::mutate(ano = substr(MES,1,4) |> as.numeric(),
             n_lid_1a12 = ifelse(nivel_fce_cce %in% c("Níveis 1 a 12"),n,0),
             n_lid_13a18 = ifelse(nivel_fce_cce %in% c("Níveis 13 a 18"),n,0)
             ) |>
      dplyr::group_by(ano,REGIAO_NATURALIDADE) |>
      dplyr::summarise(n = sum(n),
                n_lid_1a12 = sum(n_lid_1a12),
                n_lid_13a18 = sum(n_lid_13a18)
      ) |>
      dplyr::mutate(p_lid_1a12 = round(100*n_lid_1a12/n,1),
             p_lid_13a18 = round(100*n_lid_13a18/n,1)) |>
      dplyr::filter(ano >= 2022,
             !is.na(REGIAO_NATURALIDADE))

    # cat("\n\ndeu certo aqui!\n\n")

    max_p_efet_origem <- max(serie_origem_lid$p_lid_13a18)


    ## output
    output$serie_lidera_origem <- plotly::renderPlotly({


      # objeto ggplot
      serie_origem_lid |>
        ggplot_cat(
          aes(x = ano,
              y = p_lid_13a18,
              colour = REGIAO_NATURALIDADE)
        ) +
        ylim(c(0,1.2*max_p_efet_origem)) +
        geom_line(linewidth = .8) +
        geom_point(size = 2) +
        labs(colour = NULL,y = "Percentual com FCE/CCE 13 ou maior",x = NULL) -> gr_lid_origem

      ggplotly_c(gr_lid_origem)

    })
  })
  }

