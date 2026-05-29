#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    golem_add_external_resources(),
    bslib::page_navbar(
      title = tags$span(
        tags$img(
          src    = "www/favicon.ico",
          height = "26px",
          style  = "margin-right:8px; vertical-align:middle;"
        ),
        "Painel de Monitoramento | Gestão de Pessoas"
      ),
      theme = bslib::bs_theme(
        version    = 5,
        bg         = "#f8f9fa",
        fg         = "#212529",
        primary    = "#004587",
        secondary  = "#1351b4",
        base_font  = bslib::font_google("Open Sans"),
        "navbar-bg" = "#004587"
      ),
      bg      = "#004587",
      inverse = TRUE,
      fillable = TRUE,

      # ---- Módulo Indígenas ----
      bslib::nav_panel(
        title = tagList(shiny::icon("feather-alt"), " Indígenas na APF"),
        value = "indigenas",
        mod_indigenas_ui("indigenas")
      ),

      # ---- Módulo Raça e Liderança ----
      bslib::nav_panel(
        title = tagList(shiny::icon("users"), " Raça e Liderança"),
        value = "etnia",
        mod_etnia_lideranca_ui("etnia")
      ),

      # ---- Sobre ----
      bslib::nav_menu(
        title = "Sobre",
        icon  = shiny::icon("info-circle"),
        bslib::nav_panel(
          title = "Sobre o Painel",
          tags$div(
            class = "container py-4",
            tags$h4(class = "text-primary fw-bold",
                    "Plataforma de Monitoramento de Políticas Públicas"),
            tags$p(
              "Painel desenvolvido pela ", tags$strong("CGINF/DIGID/SGP/MGI"),
              " para monitorar indicadores de diversidade e representatividade",
              " na Administração Pública Federal."
            ),
            tags$hr(),
            tags$ul(
              tags$li(tags$strong("Fonte de dados:"), " MGI / SIAPE"),
              tags$li(tags$strong("Base legal:"),
                      " Decreto nº 11.443/2023 – Cotas em cargos de liderança"),
              tags$li(tags$strong("Metodologia:"),
                      " Indicadores alinhados ao PFGP e acórdãos TCU (IESGO)")
            )
          )
        )
      ),

      bslib::nav_spacer(),
      bslib::nav_item(
        tags$small(
          class = "text-white-50",
          style = "padding-right:12px;",
          paste0("Dados: SIAPE | v0.1 | ",
                 format(Sys.Date(), "%d/%m/%Y"))
        )
      )
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path      = app_sys("app/www"),
      app_title = "Painel de Monitoramento | Gestão de Pessoas"
    ),
    # CSS customizado: identidade Gov.br
    tags$style(HTML("
      .navbar-brand { font-weight: 700; font-size: 1rem; }
      .bslib-card { border-radius: 8px; box-shadow: 0 1px 4px rgba(0,0,0,.08); }
      .bslib-card .card-header { font-weight: 600; font-size: 0.9rem; }
      .value-box .value-box-title { font-size: 0.8rem; }
      .value-box .value-box-value { font-size: 1.5rem; font-weight: 700; }
      .reactable { font-size: 0.88rem; }
      body { background-color: #f0f2f5 !important; }
      .tab-content > .tab-pane { padding-top: 14px; }
    "))
  )
}
