#' pfgp_dim6 UI Function — Aposentação, Pensões e Desligamentos
#' @noRd
#' @importFrom shiny NS tagList

.card_futuro_dim6 <- function(titulo, icone, status, dificuldade, descricao) {
  status_cfg <- list(
    "A avaliar"                            = list(badge_class = "bg-warning text-dark",  border = "#ffc107"),
    "A agendar com unidade responsável"    = list(badge_class = "bg-info text-dark",     border = "#0dcaf0"),
    "Mapear fonte"                         = list(badge_class = "bg-secondary",          border = "#6c757d")
  )

  cfg <- if (!is.null(status_cfg[[status]])) status_cfg[[status]] else
    list(badge_class = "bg-secondary", border = "#6c757d")

  estrelas_on  <- paste(rep("★", dificuldade), collapse = "")
  estrelas_off <- paste(rep("☆", 5 - dificuldade), collapse = "")

  bslib::card(
    style = paste0("border-left: 5px solid ", cfg$border, ";"),
    bslib::card_header(
      class = "d-flex align-items-center justify-content-between",
      tags$span(shiny::icon(icone), " ", titulo),
      tags$span(class = paste("badge", cfg$badge_class), status)
    ),
    bslib::card_body(
      tags$p(class = "text-muted", style = "font-size: 0.9rem;", descricao),
      tags$div(
        tags$small("Dificuldade de obtenção: ", class = "text-muted"),
        tags$span(estrelas_on,  style = "color: #FF7800; font-size: 1rem;"),
        tags$span(estrelas_off, style = "color: #dee2e6; font-size: 1rem;")
      )
    )
  )
}

mod_pfgp_dim6_ui <- function(id) {
  ns <- NS(id)
  tagList(
    # --- Indicador com dados disponíveis: Abono de Permanência ---
    tags$h6(
      shiny::icon("check-circle", style = "color: #198754;"),
      " Indicador disponível: Abono de Permanência",
      class = "fw-bold mb-3"
    ),
    bslib::layout_columns(
      col_widths = c(4, 4, 4),
      bslib::value_box(
        title    = "Servidores em Abono de Permanência",
        value    = "69.518",
        showcase = shiny::icon("user-check"),
        theme    = "primary"
      ),
      bslib::value_box(
        title    = "% do quadro ativo em Abono de Permanência",
        value    = "12,31%",
        showcase = shiny::icon("percent"),
        theme    = bslib::value_box_theme(bg = "#004587", fg = "#ffffff")
      ),
      bslib::value_box(
        title    = "Fonte dos dados",
        value    = "PEP / SIAPE",
        showcase = shiny::icon("database"),
        theme    = bslib::value_box_theme(bg = "#1351b4", fg = "#ffffff")
      )
    ),
    tags$div(
      class = "alert alert-info d-flex align-items-start gap-2 mt-2 mb-4",
      style = "font-size: 0.84rem;",
      shiny::icon("circle-info", style = "flex-shrink: 0; margin-top: 2px;"),
      tags$div(
        tags$strong("Fonte de automação prevista: "),
        "Webscraping ou integração de dados referenciando ",
        tags$a("PEP — Painéis de Gestão de Pessoas",
               href   = "https://pep.paineis.gov.br/extensions/pep/index.html#servidores-abono",
               target = "_blank"),
        ". Os valores acima são referência de validação para conferência após a integração."
      )
    ),
    tags$hr(),

    # --- Indicadores futuros / em construção ---
    tags$h6(
      shiny::icon("clock", style = "color: #6c757d;"),
      " Indicadores em desenvolvimento",
      class = "fw-bold mb-3"
    ),
    bslib::layout_columns(
      col_widths = c(6, 6),
      .card_futuro_dim6(
        titulo      = "Ações estruturadas de preparação para a inatividade",
        icone       = "graduation-cap",
        status      = "A avaliar",
        dificuldade = 5,
        descricao   = paste0(
          "Percentual de órgãos que possuem programas ou ações formalizadas de preparação ",
          "de servidores para a aposentadoria (PREPAV e similares)."
        )
      ),
      .card_futuro_dim6(
        titulo      = "Assentamentos digitalizados (RPPS)",
        icone       = "file-alt",
        status      = "A agendar com unidade responsável",
        dificuldade = 5,
        descricao   = paste0(
          "Percentual de assentamentos funcionais digitalizados em relação ao total de ",
          "registros do Regime Próprio de Previdência Social."
        )
      ),
      .card_futuro_dim6(
        titulo      = "Tempo médio de tramitação em processos de aposentadoria e pensão",
        icone       = "hourglass-half",
        status      = "A agendar com unidade responsável",
        dificuldade = 4,
        descricao   = paste0(
          "Tempo médio de tramitação e atendimento de processos de concessão de aposentadoria ",
          "e pensão por morte, medido em dias úteis."
        )
      ),
      .card_futuro_dim6(
        titulo      = "Processos apoiados por fluxos digitais e automação",
        icone       = "robot",
        status      = "Mapear fonte",
        dificuldade = 3,
        descricao   = paste0(
          "Percentual de processos de aposentação e pensão que tramitam integralmente em ",
          "sistemas digitais com suporte de automação ou fluxos estruturados."
        )
      )
    )
  )
}

mod_pfgp_dim6_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    # Integração com PEP via webscraping a implementar
  })
}
