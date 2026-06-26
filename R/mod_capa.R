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

  shiny::tags$div(
    style = paste0(
      "display:flex; flex-direction:column; gap:14px;",
      "height:100%; box-sizing:border-box; padding:0 2px 8px 2px;"
    ),

    # ── Hero ──────────────────────────────────────────────────────────────────
    shiny::tags$div(
      class = "pm-hero",
      style = paste0(
        "background: linear-gradient(140deg, #003470 0%, #004587 40%, #1351b4 100%);",
        "padding: 20px 28px 18px; border-radius: 12px;",
        "display:flex; align-items:center; gap:20px; flex-shrink:0;"
      ),

      # Ícone
      shiny::tags$div(
        style = paste0(
          "background:rgba(255,255,255,.12); border-radius:10px;",
          "padding:11px 13px; display:flex; align-items:center;",
          "flex-shrink:0; position:relative; z-index:1;"
        ),
        shiny::icon("chart-line", style = "font-size:1.55rem; color:#FF7800;")
      ),

      # Texto
      shiny::tags$div(
        style = "flex:1; min-width:0; position:relative; z-index:1;",
        shiny::tags$p(
          style = paste0(
            "color:rgba(255,255,255,.55); font-size:0.68rem; font-weight:700;",
            "letter-spacing:.12em; text-transform:uppercase; margin:0 0 4px 0;"
          ),
          "MGI — SGP / DIGID / CGINF"
        ),
        shiny::tags$h1(
          style = paste0(
            "color:#fff; font-size:1.4rem; font-weight:800;",
            "margin:0 0 6px 0; line-height:1.15; letter-spacing:-.02em;"
          ),
          "Painel de Monitoramento",
          shiny::tags$span(style = "color:#FF7800;", " · Gestão de Pessoas")
        ),
        shiny::tags$p(
          style = paste0(
            "color:rgba(255,255,255,.72); font-size:0.83rem;",
            "line-height:1.55; margin:0;"
          ),
          "Indicadores de ",
          shiny::tags$strong(style = "color:#fff; font-weight:600;",
                             "diversidade e representatividade"),
          " na Administração Pública Federal — dados SIAPE atualizados mensalmente."
        )
      )
    ),

    # ── Sobre o painel ─────────────────────────────────────────────────────────
    shiny::tags$div(
      style = paste0(
        "background:var(--c-surface-1,#fff);",
        "border:1px solid rgba(0,69,135,.12);",
        "border-top:2px solid var(--c-brand,#004587);",
        "border-radius:10px; padding:14px 20px;",
        "box-shadow:var(--shadow-sm,0 1px 4px rgba(0,0,0,.06));",
        "flex-shrink:0;"
      ),
      shiny::tags$div(
        style = "display:flex; align-items:center; gap:8px; margin-bottom:6px;",
        shiny::icon("circle-info", style = "color:var(--c-brand,#004587); font-size:0.9rem;"),
        shiny::tags$strong(
          style = "color:var(--c-brand,#004587); font-size:0.88rem;",
          "Sobre o Painel"
        )
      ),
      shiny::tags$p(
        style = paste0(
          "color:var(--c-ink-2,#495057); font-size:0.82rem;",
          "line-height:1.65; margin:0;"
        ),
        "Desenvolvido pela ",
        shiny::tags$strong("CGINF/DIGID/SGP/MGI"),
        " para monitorar indicadores de diversidade no serviço público federal.",
        " Fonte: ", shiny::tags$strong("SIAPE"),
        ". Metodologia: PFGP e recomendações TCU/IESGO.",
        " Inclui raça/cor, gênero, etnia indígena e cargos CCE/FCE",
        " (", shiny::tags$strong("Decreto nº 11.443/2023"),
        " — cotas de 30% para pessoas negras)."
      )
    ),

    # ── Módulos disponíveis ────────────────────────────────────────────────────
    shiny::tags$div(
      style = "flex:1; display:flex; flex-direction:column; min-height:0;",

      shiny::tags$div(
        style = "display:flex; align-items:center; gap:8px; margin-bottom:10px; flex-shrink:0;",
        shiny::icon("table-columns",
                    style = "color:var(--c-brand,#004587); font-size:0.85rem;"),
        shiny::tags$strong(
          style = "color:var(--c-ink-1,#18202e); font-size:0.85rem;",
          "Módulos Disponíveis"
        )
      ),

      shiny::tags$div(
        style = "display:flex; gap:14px; flex-wrap:wrap; flex:1; min-height:0;",

        # Card — Indígenas
        shiny::tags$div(
          style = paste0(
            "flex:1; min-width:220px; display:flex; flex-direction:column; gap:10px;",
            "background:var(--c-surface-1,#fff);",
            "border:1px solid rgba(255,120,0,.25);",
            "border-top:3px solid #FF7800;",
            "border-radius:10px; padding:16px 20px;",
            "box-shadow:var(--shadow-sm); cursor:default;"
          ),
          shiny::tags$div(
            style = "display:flex; align-items:center; gap:10px;",
            shiny::tags$div(
              style = paste0(
                "background:#FF7800; color:#fff; border-radius:8px;",
                "width:34px; height:34px; display:flex; align-items:center;",
                "justify-content:center; font-size:0.95rem; flex-shrink:0;"
              ),
              shiny::icon("feather-alt")
            ),
            shiny::actionLink(
              ns("go_ind"), "Indígenas na APF",
              style = paste0(
                "color:var(--c-brand,#004587); font-size:0.93rem; font-weight:700;",
                "text-decoration:none; line-height:1.2;"
              )
            )
          ),
          shiny::tags$p(
            style = paste0(
              "color:var(--c-ink-2,#495057); font-size:0.8rem;",
              "line-height:1.6; margin:0; flex:1;"
            ),
            "Série histórica de vínculos, representatividade por órgão e UF,",
            " efetividade funcional, cargos CCE/FCE e perfil demográfico dos",
            " servidores autodeclarados indígenas na APF."
          ),
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
            "flex:1; min-width:220px; display:flex; flex-direction:column; gap:10px;",
            "background:var(--c-surface-1,#fff);",
            "border:1px solid rgba(19,81,180,.20);",
            "border-top:3px solid #1351b4;",
            "border-radius:10px; padding:16px 20px;",
            "box-shadow:var(--shadow-sm); cursor:default;"
          ),
          shiny::tags$div(
            style = "display:flex; align-items:center; gap:10px;",
            shiny::tags$div(
              style = paste0(
                "background:#1351b4; color:#fff; border-radius:8px;",
                "width:34px; height:34px; display:flex; align-items:center;",
                "justify-content:center; font-size:0.95rem; flex-shrink:0;"
              ),
              shiny::icon("users")
            ),
            shiny::actionLink(
              ns("go_etnia"), "Raça e Liderança",
              style = paste0(
                "color:var(--c-brand,#004587); font-size:0.93rem; font-weight:700;",
                "text-decoration:none; line-height:1.2;"
              )
            )
          ),
          shiny::tags$p(
            style = paste0(
              "color:var(--c-ink-2,#495057); font-size:0.8rem;",
              "line-height:1.6; margin:0; flex:1;"
            ),
            "Representatividade étnico-racial nos cargos CCE/FCE.",
            " Monitoramento do Decreto nº 11.443/2023, suficiência de vagas",
            " e razão de equidade por raça/cor nos órgãos federais."
          ),
          shiny::tags$div(
            style = "display:flex; flex-wrap:wrap; gap:5px;",
            .badge_tag("Decreto 11.443/2023", "#004587"),
            .badge_tag("Cotas 30%",            "#1351b4"),
            .badge_tag("Por Órgão",            "#FF7800"),
            .badge_tag("Razão de Equidade",    "#6c757d")
          )
        ),

        # Card — PFGP
        shiny::tags$div(
          style = paste0(
            "flex:2; min-width:300px; display:flex; flex-direction:column; gap:10px;",
            "background:var(--c-surface-1,#fff);",
            "border:1px solid rgba(0,69,135,.20);",
            "border-top:3px solid #004587;",
            "border-radius:10px; padding:16px 20px;",
            "box-shadow:var(--shadow-sm); cursor:default;"
          ),
          shiny::tags$div(
            style = "display:flex; align-items:center; gap:10px;",
            shiny::tags$div(
              style = paste0(
                "background:#004587; color:#fff; border-radius:8px;",
                "width:34px; height:34px; display:flex; align-items:center;",
                "justify-content:center; font-size:0.95rem; flex-shrink:0;"
              ),
              shiny::icon("clipboard-list")
            ),
            shiny::actionLink(
              ns("go_pfgp"), "PFGP — Gestão de Pessoas",
              style = paste0(
                "color:var(--c-brand,#004587); font-size:0.93rem; font-weight:700;",
                "text-decoration:none; line-height:1.2;"
              )
            )
          ),
          shiny::tags$p(
            style = paste0(
              "color:var(--c-ink-2,#495057); font-size:0.8rem;",
              "line-height:1.6; margin:0; flex:1;"
            ),
            "Monitoramento das 6 dimensões estratégicas do Plano Federal de Gestão de Pessoas.",
            " Indicadores de dimensionamento, carreiras, lideranças, remuneração e desligamentos."
          ),
          shiny::tags$div(
            style = "display:flex; flex-wrap:wrap; gap:5px;",
            .badge_tag("Dim 1 — Dimensionamento",  "#004587"),
            .badge_tag("Dim 2 — Carreiras",         "#004587"),
            .badge_tag("Dim 3 — Bem-Estar",         "#FF7800"),
            .badge_tag("Dim 4 — Lideranças",        "#1351b4"),
            .badge_tag("Dim 5 — Remuneração",       "#1351b4"),
            .badge_tag("Dim 6 — Aposentação",       "#6c757d")
          )
        )
      )
    ),

    # ── Rodapé ────────────────────────────────────────────────────────────────
    shiny::tags$div(
      style = paste0(
        "display:flex; align-items:center; gap:20px; flex-wrap:wrap;",
        "padding:9px 16px;",
        "background:var(--c-surface-2,#f5f7fb);",
        "border:1px solid var(--c-border-sub,rgba(0,0,0,.06));",
        "border-radius:8px; flex-shrink:0;"
      ),
      shiny::tags$div(
        style = "display:flex; align-items:center; gap:8px;",
        shiny::tags$span(
          style = paste0(
            "background:var(--c-brand,#004587); color:#fff;",
            "border-radius:4px; padding:2px 8px;",
            "font-size:0.66rem; font-weight:700; letter-spacing:.04em;"
          ),
          shiny::icon("database"), " SIAPE"
        ),
        shiny::tags$span(
          style = "color:var(--c-ink-3,#868e96); font-size:0.73rem;",
          "Sistema Integrado de Administração de Pessoal"
        )
      ),
      shiny::tags$div(
        style = "display:flex; align-items:center; gap:8px;",
        shiny::tags$span(
          style = paste0(
            "background:#155724; color:#fff;",
            "border-radius:4px; padding:2px 8px;",
            "font-size:0.66rem; font-weight:700;"
          ),
          shiny::icon("scale-balanced"), " PFGP / TCU"
        ),
        shiny::tags$span(
          style = "color:var(--c-ink-3,#868e96); font-size:0.73rem;",
          "Metodologia: IESGO/TCU e Plano Federal de Gestão de Pessoas"
        )
      ),
      shiny::tags$span(
        style = "margin-left:auto; color:var(--c-ink-3,#868e96); font-size:0.68rem;",
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

    shiny::observeEvent(input$go_pfgp, {
      shiny::updateNavbarPage(root_session, "main_nav", selected = "pfgp")
    }, ignoreInit = TRUE)

  })
}


# Helper interno: badge tag
.badge_tag <- function(label, cor) {
  shiny::tags$span(
    style = paste0(
      "background:", cor, "15; color:", cor, ";",
      "border:1px solid ", cor, "35;",
      "border-radius:20px; padding:2px 8px;",
      "font-size:0.66rem; font-weight:600; letter-spacing:.01em;"
    ),
    label
  )
}
