#' pfgp UI Function — Orquestrador das 6 Dimensões do PFGP
#'
#' @description Módulo de monitoramento do Plano Federal de Gestão de Pessoas (PFGP).
#'   Cada dimensão é implementada em seu próprio módulo (mod_pfgp_dim1.R … mod_pfgp_dim6.R).
#'
#' @param id Internal parameter for {shiny}.
#' @noRd
#' @importFrom shiny NS tagList

mod_pfgp_ui <- function(id) {
  ns <- NS(id)
  tagList(
    bslib::navset_card_underline(
      id       = ns("nav_pfgp"),
      selected = "pfgp_1",

      bslib::nav_panel(
        title = "Dimensão 1: Dimensionamento da Força de Trabalho",
        value = "pfgp_1",
        icon  = shiny::icon("users"),
        mod_pfgp_dim1_ui(ns("dim1"))
      ),

      bslib::nav_panel(
        title = "Dimensão 2: Carreiras, Cargos, Progressão e Promoção",
        value = "pfgp_2",
        icon  = shiny::icon("chart-bar"),
        mod_pfgp_dim2_ui(ns("dim2"))
      ),

      bslib::nav_panel(
        title = "Dimensão 3: Alocação, Ambientação, Estágio Probatório e Bem-Estar",
        value = "pfgp_3",
        icon  = shiny::icon("seedling"),
        mod_pfgp_dim3_ui(ns("dim3"))
      ),

      bslib::nav_panel(
        title = "Dimensão 4: Desenvolvimento e Desempenho de Pessoas e Formação de Lideranças",
        value = "pfgp_4",
        icon  = shiny::icon("balance-scale"),
        mod_pfgp_dim4_ui(ns("dim4"))
      ),

      bslib::nav_panel(
        title = "Dimensão 5: Remuneração, Benefícios e Reconhecimento",
        value = "pfgp_5",
        icon  = shiny::icon("coins"),
        mod_pfgp_dim5_ui(ns("dim5"))
      ),

      bslib::nav_panel(
        title = "Dimensão 6: Aposentação, Pensões e Desligamentos",
        value = "pfgp_6",
        icon  = shiny::icon("door-open"),
        mod_pfgp_dim6_ui(ns("dim6"))
      )
    )
  )
}

#' pfgp Server Function
#' @param id Internal parameter for {shiny}.
#' @param grafico_compartilhado Reactive que retorna o gráfico de % negros em CCE/FCE
#'   gerado em mod_etnia_lideranca_server (reutilizado na Dimensão 4).
#' @noRd
mod_pfgp_server <- function(id, grafico_compartilhado) {
  shiny::moduleServer(id, function(input, output, session) {
    mod_pfgp_dim1_server("dim1")
    mod_pfgp_dim2_server("dim2")
    mod_pfgp_dim3_server("dim3")
    mod_pfgp_dim4_server("dim4", grafico_compartilhado = grafico_compartilhado)
    mod_pfgp_dim5_server("dim5")
    mod_pfgp_dim6_server("dim6")
  })
}
