#' pfgp_dim5 UI Function — Remuneração, Benefícios, Reconhecimento e Recompensas Não Pecuniárias
#' @noRd
#' @importFrom shiny NS tagList

mod_pfgp_dim5_ui <- function(id) {
  ns <- NS(id)
  tagList(
    bslib::card(
      bslib::card_header(
        class = "bg-primary text-white d-flex align-items-center justify-content-between",
        tags$div(shiny::icon("coins"), " Índice de Desigualdade de Remuneração"),
        tags$span(class = "badge bg-success", "Dados disponíveis")
      ),
      bslib::card_body(
        bslib::layout_columns(
          col_widths = c(5, 7),
          tags$div(
            tags$h6("Metodologia de Cálculo", class = "fw-bold text-primary"),
            tags$p(
              "O indicador será construído com base no ",
              tags$strong("Coeficiente de Gini"),
              " e na ",
              tags$strong("Curva de Lorenz"),
              " aplicados à distribuição salarial dos servidores da APF."
            ),
            tags$ul(
              tags$li(tags$strong("Fonte:"), " SIAPE"),
              tags$li(tags$strong("Status:"), " Dados disponíveis/obtidos"),
              tags$li(
                tags$strong("Dificuldade de obtenção: "),
                tags$span("★★", style = "color: #FF7800; font-size: 1.1rem;"),
                tags$span("☆☆☆", style = "color: #dee2e6; font-size: 1.1rem;")
              )
            ),
            tags$hr(),
            tags$h6("Referências Metodológicas", class = "fw-bold text-primary"),
            tags$p(
              class = "text-muted",
              style = "font-size: 0.85rem;",
              "Os estudos abaixo fundamentam a abordagem de cálculo adotada para este indicador:"
            ),
            tags$div(
              class = "d-flex flex-column gap-2",
              tags$a(
                href   = "https://mar-celo.github.io/Coef_de_Gini_e_Curva_de_Lorenz/",
                target = "_blank",
                class  = "btn btn-outline-primary btn-sm",
                shiny::icon("arrow-up-right-from-square"), " Coeficiente de Gini e Curva de Lorenz"
              ),
              tags$a(
                href   = "https://mar-celo.github.io/Indice_de_Gini/",
                target = "_blank",
                class  = "btn btn-outline-primary btn-sm",
                shiny::icon("arrow-up-right-from-square"), " Índice de Gini — Distribuição Salarial"
              )
            ),
            tags$div(
              class = "alert alert-info mt-3 p-2",
              style = "font-size: 0.83rem;",
              shiny::icon("circle-info"), " ",
              "A implementação do cálculo de Gini e da Curva de Lorenz está prevista para a ",
              "próxima iteração de desenvolvimento deste módulo."
            )
          ),
          tags$div(
            style = paste0(
              "height: 380px; background: #f5f7fb; border-radius: 8px;",
              "display: flex; align-items: center; justify-content: center;",
              "border: 2px dashed #dee2e6;"
            ),
            tags$div(
              style = "text-align: center; color: #868e96;",
              shiny::icon("chart-area",
                           style = "font-size: 3rem; margin-bottom: 16px; display: block;"),
              tags$p(tags$strong("Curva de Lorenz"),
                     style = "margin: 0 0 4px; font-size: 0.95rem; color: #495057;"),
              tags$p("Coeficiente de Gini — distribuição salarial APF",
                     style = "margin: 0; font-size: 0.82rem;"),
              tags$p("Implementação em desenvolvimento",
                     style = "margin: 8px 0 0; font-size: 0.8rem; color: #adb5bd;")
            )
          )
        )
      )
    )
  )
}

mod_pfgp_dim5_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    # Cálculo do Índice de Gini e Curva de Lorenz a implementar
  })
}
