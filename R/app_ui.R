#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @noRd
app_ui <- function(request) {
  shiny::tagList(
    golem_add_external_resources(),
    bslib::page_navbar(
      id    = "main_nav",
      title = shiny::tags$span(
        shiny::tags$img(
          src    = "www/favicon.ico",
          height = "26px",
          style  = "margin-right:8px; vertical-align:middle;"
        ),
        "Painel de Monitoramento | Gestão de Pessoas"
      ),
      theme = bslib::bs_theme(
        version     = 5,
        bg          = "#f8f9fa",
        fg          = "#212529",
        primary     = "#004587",
        secondary   = "#1351b4",
        base_font   = bslib::font_google("Open Sans"),
        "navbar-bg" = "#004587"
      ),
      bg = "#004587",
      inverse = TRUE,
      fillable = TRUE,

      # ---- Capa ----
      bslib::nav_panel(
        title = shiny::tagList(shiny::icon("house"), " Início"),
        value = "capa",
        mod_capa_ui("capa")
      ),

      # ---- Módulo Indígenas ----
      bslib::nav_panel(
        title = shiny::tagList(shiny::icon("feather-alt"), " Indígenas na APF"),
        value = "indigenas",
        mod_indigenas_ui("indigenas")
      ),

      # ---- Módulo Raça e Liderança ----
      bslib::nav_panel(
        title = shiny::tagList(shiny::icon("users"), " Raça e Liderança"),
        value = "etnia",
        mod_etnia_lideranca_ui("etnia")
      ),

      # ---- Sobre ----
      bslib::nav_menu(
        title = "Sobre",
        icon  = shiny::icon("info-circle"),
        bslib::nav_panel(
          title = "Sobre o Painel",
          shiny::tags$div(
            class = "container py-4",
            shiny::tags$h4(
              class = "text-primary fw-bold",
              "Plataforma de Monitoramento de Políticas Públicas"
            ),
            shiny::tags$p(
              "Painel desenvolvido pela ", shiny::tags$strong("CGINF/DIGID/SGP/MGI"),
              " para monitorar indicadores de diversidade e representatividade",
              " na Administração Pública Federal."
            ),
            shiny::tags$hr(),
            shiny::tags$ul(
              shiny::tags$li(shiny::tags$strong("Fonte de dados:"), " MGI / SIAPE"),
              shiny::tags$li(
                shiny::tags$strong("Base legal:"),
                " Decreto nº 11.443/2023 – Cotas em cargos de liderança"
              ),
              shiny::tags$li(
                shiny::tags$strong("Metodologia:"),
                " Indicadores alinhados ao PFGP e acórdãos TCU (IESGO)"
              )
            )
          )
        )
      ),

      bslib::nav_spacer(),
      bslib::nav_item(
        shiny::tags$small(
          class = "text-white-50",
          style = "padding-right:12px;",
          paste0("Dados: SIAPE | v0.1 | ", format(Sys.Date(), "%d/%m/%Y"))
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
#' @noRd
golem_add_external_resources <- function() {

  shiny::addResourcePath(
    "www",
    "inst/app/www"
  )

  shiny::tags$head(
    shiny::tags$link(
      rel = "shortcut icon",
      href = "www/favicon.ico"
    ),
    shiny::tags$style(shiny::HTML("

      /* ── Easing curves ──────────────────────────────────────── */
      :root {
        --ease-out:    cubic-bezier(0.23, 1, 0.32, 1);
        --ease-in-out: cubic-bezier(0.77, 0, 0.175, 1);
      }

      /* ── Base ───────────────────────────────────────────────── */
      body { background-color: #f0f2f5 !important; }

      /* ── Navbar brand ───────────────────────────────────────── */
      .navbar-brand { font-weight: 700; font-size: 1rem; }

      /* Nav links — indicador deslizante */
      .navbar-nav .nav-link {
        position: relative;
        transition: color 150ms ease;
      }
      .navbar-nav .nav-link::after {
        content: '';
        position: absolute;
        bottom: 2px;
        left: 50%;
        right: 50%;
        height: 2px;
        background: rgba(255,255,255,0.85);
        border-radius: 1px;
        transition: left 200ms var(--ease-out), right 200ms var(--ease-out);
      }
      .navbar-nav .nav-link.active::after {
        left: 10px;
        right: 10px;
      }
      @media (hover: hover) and (pointer: fine) {
        .navbar-nav .nav-link:not(.active):hover::after {
          left: 10px;
          right: 10px;
          opacity: 0.45;
        }
      }

      /* ── Cards ──────────────────────────────────────────────── */
      .bslib-card {
        border-radius: 8px;
        box-shadow: 0 1px 4px rgba(0,0,0,.08);
        transition: transform 200ms var(--ease-out),
                    box-shadow 200ms var(--ease-out);
      }
      .bslib-card .card-header { font-weight: 600; font-size: 0.9rem; }

      @media (hover: hover) and (pointer: fine) {
        .bslib-card:hover {
          transform: translateY(-2px);
          box-shadow: 0 6px 20px rgba(0,0,0,.12);
        }
      }

      /* ── Value boxes ────────────────────────────────────────── */
      .value-box .value-box-title { font-size: 0.8rem; }
      .value-box .value-box-value { font-size: 1.5rem; font-weight: 700; }

      /* ── Botões — feedback de pressão ───────────────────────── */
      .btn {
        transition: transform 160ms var(--ease-out),
                    box-shadow 160ms var(--ease-out);
      }
      .btn:active {
        transform: scale(0.97);
      }
      @media (hover: hover) and (pointer: fine) {
        .btn-primary:hover {
          box-shadow: 0 4px 14px rgba(0, 69, 135, 0.30);
        }
      }

      /* ── Tabelas ────────────────────────────────────────────── */
      .reactable { font-size: 0.88rem; }

      /* ── Painéis de aba — fade ao entrar ────────────────────── */
      .tab-content > .tab-pane {
        padding-top: 14px;
        animation: pmFadeIn 150ms var(--ease-out) both;
      }
      @keyframes pmFadeIn {
        from { opacity: 0; transform: translateY(4px); }
        to   { opacity: 1; transform: translateY(0);   }
      }

      /* ── Sidebar / Filtros ──────────────────────────────────── */
      .form-select,
      .form-control {
        transition: border-color 150ms ease, box-shadow 150ms ease;
      }
      .form-select:focus,
      .form-control:focus {
        box-shadow: 0 0 0 3px rgba(0, 69, 135, 0.18);
      }

      /* ── Acessibilidade — prefers-reduced-motion ────────────── */
      @media (prefers-reduced-motion: reduce) {
        *, *::before, *::after {
          animation-duration:   0.01ms !important;
          transition-duration:  0.01ms !important;
        }
      }

    "))
  )
}
