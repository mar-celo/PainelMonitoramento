#' pfgp_dim3 UI Function — Alocação, Ambientação, Estágio Probatório e Bem-Estar
#' @noRd
#' @importFrom shiny NS tagList

.card_em_construcao_dim3 <- function(ns_id, titulo, icone, dificuldade, descricao) {
  estrelas_on  <- paste(rep("★", dificuldade), collapse = "")
  estrelas_off <- paste(rep("☆", 5 - dificuldade), collapse = "")

  bslib::card(
    style = "border-left: 5px solid #FF7800;",
    bslib::card_header(
      class = "bg-primary text-white d-flex align-items-center justify-content-between",
      tags$div(shiny::icon(icone), " ", titulo),
      tags$span(class = "badge bg-warning text-dark", "Em alinhamento")
    ),
    bslib::card_body(
      tags$p(class = "text-muted", descricao),
      tags$ul(
        tags$li(tags$strong("Fonte:"), " SIAPE"),
        tags$li(tags$strong("Status:"), " Dados disponíveis/obtidos"),
        tags$li(
          tags$strong("Dificuldade de obtenção: "),
          tags$span(estrelas_on,  style = "color: #FF7800; font-size: 1.1rem;"),
          tags$span(estrelas_off, style = "color: #dee2e6; font-size: 1.1rem;")
        )
      ),
      tags$div(
        class = "alert alert-warning p-2 mb-3",
        style = "font-size: 0.85rem;",
        shiny::icon("triangle-exclamation"), " ",
        tags$strong("Regras de conceitos em fase de alinhamento"),
        " entre a equipe técnica e áreas de negócio."
      ),
      tags$div(
        style = paste0(
          "height: 200px; background: #f5f7fb; border-radius: 8px;",
          "display: flex; align-items: center; justify-content: center;",
          "border: 2px dashed #dee2e6;"
        ),
        tags$div(
          style = "text-align: center; color: #868e96;",
          shiny::icon("chart-line", style = "font-size: 2rem; margin-bottom: 8px; display: block;"),
          tags$p("Visualização em desenvolvimento", style = "margin: 0; font-size: 0.85rem;")
        )
      )
    )
  )
}

mod_pfgp_dim3_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$div(
      class = "alert d-flex align-items-start gap-3 mb-4",
      style = paste0(
        "background: #fff8f0; border: 1px solid #FF7800;",
        "border-left: 5px solid #FF7800; border-radius: 8px;"
      ),
      shiny::icon("triangle-exclamation",
                  style = "color: #FF7800; font-size: 1.3rem; margin-top: 2px; flex-shrink: 0;"),
      tags$div(
        tags$strong("Indicadores em fase de alinhamento conceitual"),
        tags$br(),
        tags$small(
          paste0(
            "As fórmulas e definições estão sendo validadas com as áreas técnicas responsáveis. ",
            "Os campos estão estruturados para atualização assim que os conceitos forem homologados."
          ),
          class = "text-muted"
        )
      )
    ),
    bslib::layout_columns(
      col_widths = c(6, 6),
      .card_em_construcao_dim3(
        ns_id       = ns("turnover"),
        titulo      = "Indicadores de Turnover",
        icone       = "rotate",
        dificuldade = 3,
        descricao   = paste0(
          "Mede a rotatividade de servidores na APF, relacionando entradas e saídas de ",
          "pessoal em determinado período de referência."
        )
      ),
      .card_em_construcao_dim3(
        ns_id       = ns("absenteismo"),
        titulo      = "Taxa de Absenteísmo",
        icone       = "user-clock",
        dificuldade = 2,
        descricao   = paste0(
          "Percentual de ausências dos servidores em relação ao total de dias esperados ",
          "de trabalho em um período de referência."
        )
      )
    )
  )
}

mod_pfgp_dim3_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    # Indicadores em fase de alinhamento — sem lógica de server ativa
  })
}
