#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  observe({
    # Lê os parâmetros vindos na URL (ex: ?pagina=graficos_detalhados)
    query <- parseQueryString(session$clientData$url_search)

    if (!is.null(query[['pagina']])) {

      # 1º: Muda para o Módulo B no tabset principal do app
      updateTabsetPanel(
        session = session,
        inputId = "main_nav", # ID do tabset/navbar da UI principal
        selected = "pfgp"                  # Value do tabPanel do Módulo B
      )

      # 2º: Muda para a sub-aba interna dentro do Módulo B
      updateTabsetPanel(
        session = session,
        inputId = "pfgp_dim1",  # ID do tabset com o namespace do Módulo B
        selected = query[['pagina']]            # Valor recebido da URL
      )
    }
  })


  mod_capa_server("capa", root_session = session)
  mod_indigenas_server("indigenas")
  grafico_etnia <- mod_etnia_lideranca_server("etnia")
  mod_pfgp_server('pfgp',grafico_compartilhado = grafico_etnia)
}
