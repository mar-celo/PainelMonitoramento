# ==============================================================================
# mod_capa.R
# Capa / página de entrada do Painel de Monitoramento de Gestão de Pessoas
# ==============================================================================

#' capa UI Function
#'
#' @param id Internal parameter for {shiny}.
#' @noRd
#' @importFrom shiny NS tagList
mod_capa_ui <- function(id) {
  ns <- NS(id)

  shiny::tagList(

    # ── Hero ────────────────────────────────────────────────────────────────────
    shiny::tags$div(
      class = "pm-hero",
      style = paste0(
        "background: linear-gradient(135deg, #004587 0%, #1351b4 60%, #0d3d7a 100%);",
        "padding: 56px 48px 48px 48px;",
        "border-radius: 0 0 16px 16px;",
        "margin: -14px -14px 0 -14px;"
      ),

      # Logotipo + Título
      shiny::tags$div(
        style = "display: flex; align-items: center; gap: 18px; margin-bottom: 18px;",
        shiny::tags$div(
          style = paste0(
            "background: rgba(255,255,255,0.12); border-radius: 12px;",
            "padding: 10px 14px; display: flex; align-items: center;"
          ),
          shiny::icon("chart-line",
                      style = "font-size: 2rem; color: #FF7800;")
        ),
        shiny::tags$div(
          shiny::tags$p(
            style = "color: rgba(255,255,255,0.65); font-size: 0.78rem; font-weight: 600;
                     letter-spacing: 2px; text-transform: uppercase; margin: 0;",
            "Ministério da Gestão e da Inovação — SGP / DIGID / CGINF"
          ),
          shiny::tags$h1(
            style = "color: #ffffff; font-size: 1.75rem; font-weight: 700;
                     margin: 4px 0 0 0; line-height: 1.25;",
            "Painel de Monitoramento",
            shiny::tags$br(),
            shiny::tags$span(
              style = "color: #FF7800;",
              "Gestão de Pessoas"
            )
          )
        )
      ),

      # Subtítulo / descrição curta
      shiny::tags$p(
        style = "color: rgba(255,255,255,0.82); font-size: 1rem;
                 max-width: 680px; line-height: 1.7; margin: 0;",
        "Acompanhe indicadores de ",
        shiny::tags$strong(style = "color: #fff;", "diversidade, representatividade e efetividade"),
        " das políticas de gestão de pessoas na Administração Pública Federal,",
        " com dados do SIAPE atualizados mensalmente."
      )
    ),

    # ── Corpo principal ──────────────────────────────────────────────────────────
    shiny::tags$div(
      style = "padding: 36px 4px 24px 4px;",

      # --- Sobre o painel -------------------------------------------------------
      shiny::tags$div(
        style = paste0(
          "background: #ffffff; border-radius: 12px;",
          "border-left: 5px solid #004587;",
          "padding: 28px 32px; margin-bottom: 32px;",
          "box-shadow: 0 2px 10px rgba(0,0,0,0.07);"
        ),
        shiny::tags$h3(
          style = "color: #004587; font-size: 1.05rem; font-weight: 700;
                   margin: 0 0 14px 0; display: flex; align-items: center; gap: 10px;",
          shiny::icon("circle-info"), " Sobre o Painel"
        ),
        shiny::tags$p(
          style = "color: #343a40; font-size: 0.95rem; line-height: 1.8; margin: 0;",
          "Este painel foi desenvolvido pela ",
          shiny::tags$strong("Coordenação-Geral de Informações de Pessoal (CGINF)"),
          " da Diretoria de Diversidade e Inclusão (DIGID/SGP/MGI) para subsidiar",
          " o monitoramento de políticas públicas de diversidade e inclusão no",
          " serviço público federal.",
          shiny::tags$br(), shiny::tags$br(),
          "Os indicadores são construídos a partir da base do ",
          shiny::tags$strong("SIAPE"),
          " e seguem a metodologia do Plano Federal de Gestão de Pessoas (PFGP)",
          " e as recomendações do TCU/IESGO. Os recortes contemplam raça/cor, gênero,",
          " etnia indígena e ocupação de cargos de liderança (CCE/FCE),",
          " com base no ",
          shiny::tags$strong("Decreto nº 11.443/2023"),
          ", que instituiu cotas de 30% para pessoas negras nesses cargos."
        )
      ),

      # --- Cards de navegação ---------------------------------------------------
      shiny::tags$h3(
        style = "color: #004587; font-size: 1rem; font-weight: 700;
                 margin: 0 0 18px 0; display: flex; align-items: center; gap: 10px;",
        shiny::icon("table-columns"), " Módulos Disponíveis"
      ),

      bslib::layout_columns(
        col_widths = c(6, 6),

        # Card — Indígenas
        shiny::tags$div(
          class = "pm-nav-card",
          style = paste0(
            "background: linear-gradient(135deg, #fff7f0 0%, #ffffff 100%);",
            "border: 1.5px solid #FF7800; border-radius: 12px;",
            "padding: 28px 28px 24px 28px;",
            "box-shadow: 0 3px 12px rgba(255,120,0,0.10);",
            "height: 100%;"
          ),
          shiny::tags$div(
            style = "display: flex; align-items: center; gap: 12px; margin-bottom: 14px;",
            shiny::tags$div(
              style = paste0(
                "background: #FF7800; color: #fff; border-radius: 10px;",
                "width: 44px; height: 44px; display: flex;",
                "align-items: center; justify-content: center; font-size: 1.25rem;",
                "flex-shrink: 0;"
              ),
              shiny::icon("feather-alt")
            ),
            shiny::actionLink(
              ns("go_ind"),
              "Indígenas na APF",
              style = paste0(
                "color: #004587; font-size: 1rem; font-weight: 700;",
                "text-decoration: none; display: block; line-height: 1.2;",
                "transition: color 150ms ease;"
              )
            )
          ),
          shiny::tags$p(
            style = "color: #495057; font-size: 0.88rem; line-height: 1.7; margin: 0 0 16px 0;",
            "Série histórica de vínculos, representatividade por órgão e UF,",
            " efetividade funcional, cargos CCE/FCE, razão de equidade por gênero",
            " e pirâmide etária dos servidores autodeclarados indígenas na APF."
          ),
          shiny::tags$div(
            style = "display: flex; flex-wrap: wrap; gap: 8px;",
            .badge_tag("Série Histórica",    "#004587"),
            .badge_tag("Cargos CCE/FCE",     "#FF7800"),
            .badge_tag("Geografia",           "#1351b4"),
            .badge_tag("Perfil Demográfico",  "#6c757d")
          )
        ),

        # Card — Raça e Liderança
        shiny::tags$div(
          class = "pm-nav-card",
          style = paste0(
            "background: linear-gradient(135deg, #f0f4fa 0%, #ffffff 100%);",
            "border: 1.5px solid #1351b4; border-radius: 12px;",
            "padding: 28px 28px 24px 28px;",
            "box-shadow: 0 3px 12px rgba(19,81,180,0.10);",
            "height: 100%;"
          ),
          shiny::tags$div(
            style = "display: flex; align-items: center; gap: 12px; margin-bottom: 14px;",
            shiny::tags$div(
              style = paste0(
                "background: #1351b4; color: #fff; border-radius: 10px;",
                "width: 44px; height: 44px; display: flex;",
                "align-items: center; justify-content: center; font-size: 1.25rem;",
                "flex-shrink: 0;"
              ),
              shiny::icon("users")
            ),
            shiny::actionLink(
              ns("go_etnia"),
              "Raça e Liderança",
              style = paste0(
                "color: #004587; font-size: 1rem; font-weight: 700;",
                "text-decoration: none; display: block; line-height: 1.2;",
                "transition: color 150ms ease;"
              )
            )
          ),
          shiny::tags$p(
            style = "color: #495057; font-size: 0.88rem; line-height: 1.7; margin: 0 0 16px 0;",
            "Representatividade étnico-racial nos cargos de direção e assessoramento",
            " (CCE/FCE). Monitoramento do Decreto nº 11.443/2023, suficiência de vagas,",
            " razão de equidade e composição por raça/cor nos órgãos federais."
          ),
          shiny::tags$div(
            style = "display: flex; flex-wrap: wrap; gap: 8px;",
            .badge_tag("Decreto 11.443/2023", "#004587"),
            .badge_tag("Cotas 30%",            "#1351b4"),
            .badge_tag("Por Órgão",            "#FF7800"),
            .badge_tag("Razão de Equidade",    "#6c757d")
          )
        )
      ),

      # --- Rodapé de fonte -------------------------------------------------------
      shiny::tags$div(
        style = paste0(
          "margin-top: 36px; padding: 20px 24px;",
          "background: #f8f9fa; border-radius: 10px;",
          "display: flex; align-items: center; gap: 24px; flex-wrap: wrap;"
        ),
        shiny::tags$div(
          style = "display: flex; align-items: center; gap: 10px;",
          shiny::tags$span(
            style = paste0(
              "background: #004587; color: white; border-radius: 4px;",
              "padding: 4px 10px; font-size: 0.72rem; font-weight: 700;",
              "letter-spacing: 0.5px;"
            ),
            shiny::icon("database"), " SIAPE"
          ),
          shiny::tags$span(
            style = "color: #6c757d; font-size: 0.8rem;",
            "Sistema Integrado de Administração de Pessoal — fonte primária dos dados"
          )
        ),
        shiny::tags$div(
          style = "display: flex; align-items: center; gap: 10px;",
          shiny::tags$span(
            style = paste0(
              "background: #155724; color: white; border-radius: 4px;",
              "padding: 4px 10px; font-size: 0.72rem; font-weight: 700;"
            ),
            shiny::icon("scale-balanced"), " PFGP / TCU"
          ),
          shiny::tags$span(
            style = "color: #6c757d; font-size: 0.8rem;",
            "Metodologia alinhada ao IESGO/TCU e ao Plano Federal de Gestão de Pessoas"
          )
        ),
        shiny::tags$div(
          style = "margin-left: auto;",
          shiny::tags$span(
            style = "color: #adb5bd; font-size: 0.75rem;",
            paste0("Atualização: ", format(Sys.Date(), "%d/%m/%Y"))
          )
        )
      )
    )
  )
}


#' capa Server Functions
#'
#' @param id Internal parameter for {shiny}.
#' @param root_session Sessão raiz do app (para navegar entre abas da navbar).
#' @noRd
mod_capa_server <- function(id, root_session = NULL) {
  shiny::moduleServer(id, function(input, output, session) {

    shiny::observeEvent(input$go_ind, {
      shiny::updateNavbarPage(root_session, "main_nav", selected = "indigenas")
    }, ignoreInit = TRUE)

    shiny::observeEvent(input$go_etnia, {
      shiny::updateNavbarPage(root_session, "main_nav", selected = "etnia")
    }, ignoreInit = TRUE)

  })
}


# Helper interno: badge tag colorida
.badge_tag <- function(label, cor) {
  shiny::tags$span(
    style = paste0(
      "background: ", cor, "18; color: ", cor, ";",
      "border: 1px solid ", cor, "44;",
      "border-radius: 20px; padding: 3px 10px;",
      "font-size: 0.72rem; font-weight: 600;"
    ),
    label
  )
}
