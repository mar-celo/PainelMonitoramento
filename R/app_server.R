#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  mod_capa_server("capa", root_session = session)
  mod_indigenas_server("indigenas")
  grafico_etnia <- mod_etnia_lideranca_server("etnia")
  mod_pfgp_server('pfgp',grafico_compartilhado = grafico_etnia)
}
