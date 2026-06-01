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

  # Container principal: flex-column que preenche o viewport sem scroll
  shiny::tags$div(
    style = paste0(
      "display: flex; flex-direction: column; gap: 14px;",
      "height: 100%; box-sizing: border-box; padding: 0 2px 8px 2px;"
    ),

    # ── Hero ──────────────────────────────────────────────────────────────────
    shiny::tags$div(
      style = paste0(
        "background: linear-gradient(135deg, #004587 0%, #1351b4 65%, #0d3d7a 100%);",
        "padding: 18px 28px 16px 28px; border-radius: 10px;",
        "display: flex; align-items: center; gap: 20px; flex-shrink: 0;"
      ),
      # Ícone
      shiny::tags$div(
        style = paste0(
          "background: rgba(255,255,255,0.13); border-radius: 10px;",
          "padding: 10px 13px; display: flex; align-items: center; flex-shrink: 0;"
        ),
        shiny::icon("chart-line", style = "font-size: 1.6rem; color: #FF7800;")
      ),
      # Título + subtítulo
      shiny::tags$div(
        style = "flex: 1; min-width: 0;",
        shiny::tags$p(
          style = paste0(
            "color: rgba(255,255,255,0.6); font-size: 0.72rem; font-weight: 600;",
            "letter-spacing: 1.8px; text-transform: uppercase; margin: 0 0 3px 0;"
          ),
          "Ministério da Gestão e da Inovação — SGP / DIGID / CGINF"
        ),
        shiny::tags$div(
          style = "display: flex; align-items: baseline; gap: 10px; flex-wrap: wrap;",
          shiny::tags$h1(
            style = paste0(
              "color: #fff; font-size: 1.45rem; font-weight: 700;",
              "margin: 0; line-height: 1.2;"
            ),
            "Painel de Monitoramento —",
            shiny::tags$span(style = "color: #FF7800;", " Gestão de Pessoas")
          )
        ),
        shiny::tags$p(
          style = paste0(
            "color: rgba(255,255,255,0.78); font-size: 0.84rem;",
            "line-height: 1.5; margin: 5px 0 0 0;"
          ),
          "Indicadores de ",
          shiny::tags$strong(style = "color:#fff;", "diversidade e representatividade"),
          " na APF — dados SIAPE atualizados mensalmente."
        )
      )
    ),

    # ── Sobre o painel ─────────────────────────────────────────────────────────
    shiny::tags$div(
      style = paste0(
        "background: #fff; border-radius: 10px; border-left: 4px solid #004587;",
        "padding: 14px 20px; box-shadow: 0 1px 6px rgba(0,0,0,0.07);",
        "flex-shrink: 0;"
      ),
      shiny::tags$div(
        style = "display: flex; align-items: baseline; gap: 8px; margin-bottom: 7px;",
        shiny::icon("circle-info", style = "color:#004587; font-size:0.9rem;"),
        shiny::tags$strong(
          style = "color:#004587; font-size: 0.9rem;", "Sobre o Painel"
        )
      ),
      shiny::tags$p(
        style = "color:#343a40; font-size:0.83rem; line-height:1.65; margin:0;",
        "Desenvolvido pela ",
        shiny::tags$strong("CGINF/DIGID/SGP/MGI"),
        " para monitorar indicadores de diversidade e inclusão no serviço público federal.",
        " Fonte: ", shiny::tags$strong("SIAPE"),
        ". Metodologia alinhada ao PFGP e às recomendações do TCU/IESGO.",
        " Recortes: raça/cor, gênero, etnia indígena e cargos CCE/FCE",
        " (", shiny::tags$strong("Decreto nº 11.443/2023"), " — cotas de 30% para pessoas negras)."
      )
    ),

    # ── Módulos disponíveis ────────────────────────────────────────────────────
    shiny::tags$div(
      style = "flex: 1; display: flex; flex-direction: column; min-height: 0;",

      shiny::tags$div(
        style = paste0(
          "display: flex; align-items: center; gap: 8px;",
          "margin-bottom: 10px; flex-shrink: 0;"
        ),
        shiny::icon("table-columns", style = "color:#004587; font-size:0.9rem;"),
        shiny::tags$strong(
          style = "color:#004587; font-size:0.9rem;", "Módulos Disponíveis"
        )
      ),

      # Dois cards lado a lado
      shiny::tags$div(
        style = "display: flex; gap: 14px; flex: 1; min-height: 0;",

        # Card — Indígenas
        shiny::tags$div(
          style = paste0(
            "flex: 1; background: linear-gradient(135deg, #fff7f0, #fff);",
            "border: 1.5px solid #FF7800; border-radius: 10px;",
            "padding: 16px 20px; box-shadow: 0 2px 8px rgba(255,120,0,0.09);",
            "display: flex; flex-direction: column; gap: 8px;"
          ),
          # Ícone + título clicável
          shiny::tags$div(
            style = "display: flex; align-items: center; gap: 10px;",
            shiny::tags$div(
              style = paste0(
                "background:#FF7800; color:#fff; border-radius:8px;",
                "width:34px; height:34px; display:flex; align-items:center;",
                "justify-content:center; font-size:1rem; flex-shrink:0;"
              ),
              shiny::icon("feather-alt")
            ),
            shiny::actionLink(
              ns("go_ind"), "Indígenas na APF",
              style = paste0(
                "color:#004587; font-size:0.95rem; font-weight:700;",
                "text-decoration:none; line-height:1.2;"
              )
            )
          ),
          # Descrição
          shiny::tags$p(
            style = "color:#495057; font-size:0.81rem; line-height:1.6; margin:0; flex:1;",
            "Série histórica de vínculos, representatividade por órgão e UF,",
            " efetividade funcional, cargos CCE/FCE e perfil demográfico",
            " dos servidores autodeclarados indígenas na APF."
          ),
          # Badges
          shiny::tags$div(
            style = "display:flex; flex-wrap:wrap; gap:5px;",
            .badge_tag("Série Histórica",   "#004587"),
            .badge_tag("Cargos CCE/FCE",    "#FF7800"),
            .badge_tag("Geografia",          "#1351b4"),
            .badge_tag("Perfil Demográfico", "#6c757d")
          )
        ),

        # Card — Raça e Liderança
        shiny::tags$div(
          style = paste0(
            "flex: 1; background: linear-gradient(135deg, #f0f4fa, #fff);",
            "border: 1.5px solid #1351b4; border-radius: 10px;",
            "padding: 16px 20px; box-shadow: 0 2px 8px rgba(19,81,180,0.09);",
            "display: flex; flex-direction: column; gap: 8px;"
          ),
          # Ícone + título clicável
          shiny::tags$div(
            style = "display: flex; align-items: center; gap: 10px;",
            shiny::tags$div(
              style = paste0(
                "background:#1351b4; color:#fff; border-radius:8px;",
                "width:34px; height:34px; display:flex; align-items:center;",
                "justify-content:center; font-size:1rem; flex-shrink:0;"
              ),
              shiny::icon("users")
            ),
            shiny::actionLink(
              ns("go_etnia"), "Raça e Liderança",
              style = paste0(
                "color:#004587; font-size:0.95rem; font-weight:700;",
                "text-decoration:none; line-height:1.2;"
              )
            )
          ),
          # Descrição
          shiny::tags$p(
            style = "color:#495057; font-size:0.81rem; line-height:1.6; margin:0; flex:1;",
            "Representatividade étnico-racial nos cargos de direção e assessoramento",
            " (CCE/FCE). Monitoramento do Decreto nº 11.443/2023, suficiência de vagas",
            " e razão de equidade por raça/cor nos órgãos federais."
          ),
          # Badges
          shiny::tags$div(
            style = "display:flex; flex-wrap:wrap; gap:5px;",
            .badge_tag("Decreto 11.443/2023", "#004587"),
            .badge_tag("Cotas 30%",            "#1351b4"),
            .badge_tag("Por Órgão",            "#FF7800"),
            .badge_tag("Razão de Equidade",    "#6c757d")
          )
        )
      )
    ),

    # ── Rodapé ────────────────────────────────────────────────────────────────
    shiny::tags$div(
      style = paste0(
        "display:flex; align-items:center; gap:20px; flex-wrap:wrap;",
        "padding: 10px 16px; background:#f8f9fa; border-radius:8px;",
        "flex-shrink:0;"
      ),
      shiny::tags$div(
        style = "display:flex; align-items:center; gap:8px;",
        shiny::tags$span(
          style = paste0(
            "background:#004587; color:#fff; border-radius:4px;",
            "padding:3px 8px; font-size:0.68rem; font-weight:700;"
          ),
          shiny::icon("database"), " SIAPE"
        ),
        shiny::tags$span(
          style = "color:#6c757d; font-size:0.75rem;",
          "Sistema Integrado de Administração de Pessoal"
        )
      ),
      shiny::tags$div(
        style = "display:flex; align-items:center; gap:8px;",
        shiny::tags$span(
          style = paste0(
            "background:#155724; color:#fff; border-radius:4px;",
            "padding:3px 8px; font-size:0.68rem; font-weight:700;"
          ),
          shiny::icon("scale-balanced"), " PFGP / TCU"
        ),
        shiny::tags$span(
          style = "color:#6c757d; font-size:0.75rem;",
          "Metodologia: IESGO/TCU e Plano Federal de Gestão de Pessoas"
        )
      ),
      shiny::tags$span(
        style = "margin-left:auto; color:#adb5bd; font-size:0.7rem;",
        paste0("Atualização: ", format(Sys.Date(), "%d/%m/%Y"))
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
      "background:", cor, "18; color:", cor, ";",
      "border:1px solid ", cor, "44;",
      "border-radius:20px; padding:2px 8px;",
      "font-size:0.68rem; font-weight:600;"
    ),
    label
  )
}
