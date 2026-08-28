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
      fillable = FALSE,

      # ---- Capa ----
      bslib::nav_panel(
        title = shiny::tagList(shiny::icon("house"), " Início"),
        value = "capa",
        mod_capa_ui("capa")
      ),

      # ---- Menu Monitoramento ----
      bslib::nav_menu(
        title = shiny::tagList(shiny::icon("chart-bar"), " Monitoramento"),
        bslib::nav_panel(
          title = shiny::tagList(shiny::icon("feather-alt"), " Indígenas na APF"),
          value = "indigenas",
          mod_indigenas_ui("indigenas")
        ),
        bslib::nav_panel(
          title = shiny::tagList(shiny::icon("users"), "Raça e Liderança"),
          value = "etnia",
          mod_etnia_lideranca_ui("etnia")
        ),
        bslib::nav_panel(
          title = shiny::tagList(shiny::icon("users"), "PFGP"),
          value = "pfgp",
          mod_pfgp_ui("pfgp")
        )
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

  relatorios_path <- system.file("relatorios", package = "PainelMonitoramento")
  if (nzchar(relatorios_path) && dir.exists(relatorios_path)) {
    shiny::addResourcePath("relatorios", relatorios_path)
  }

  shiny::tags$head(
    shiny::tags$link(
      rel = "shortcut icon",
      href = "www/favicon.ico"
    ),
    shiny::tags$style(shiny::HTML("

      /* ── Design tokens ──────────────────────────────────────── */
      :root {
        --c-brand:        #004587;
        --c-brand-mid:    #1351b4;
        --c-accent:       #FF7800;
        --c-surface-0:    #eef1f6;
        --c-surface-1:    #ffffff;
        --c-surface-2:    #f5f7fb;
        --c-border:       rgba(0,69,135,.14);
        --c-border-sub:   rgba(0,0,0,.13);
        --c-ink-1:        #18202e;
        --c-ink-2:        #495057;
        --c-ink-3:        #868e96;
        --shadow-sm:      0 2px 6px rgba(0,0,0,.09), 0 1px 2px rgba(0,0,0,.06);
        --shadow-md:      0 4px 16px rgba(0,0,0,.13), 0 2px 4px rgba(0,0,0,.07);
        --shadow-lg:      0 10px 32px rgba(0,0,0,.16), 0 3px 8px rgba(0,0,0,.08);
        --shadow-focus:   0 0 0 3px rgba(19,81,180,.22);
        --radius-sm:      6px;
        --radius-md:      10px;
        --radius-lg:      14px;
        --ease-out:       cubic-bezier(0.16, 1, 0.3, 1);
        --ease-in-out:    cubic-bezier(0.45, 0, 0.55, 1);
        --dur-fast:       110ms;
        --dur-base:       190ms;
      }

      /* ── Base ───────────────────────────────────────────────── */
      body {
        background: var(--c-surface-0) !important;
        color: var(--c-ink-1) !important;
        -webkit-font-smoothing: antialiased;
        text-rendering: optimizeLegibility;
      }

      /* ── Navbar ─────────────────────────────────────────────── */
      .navbar {
        border-bottom: 1px solid rgba(255,255,255,.08) !important;
      }
      .navbar-brand {
        font-weight: 700;
        font-size: 0.92rem;
        letter-spacing: -.01em;
      }
      /* Força cor branca em todos os contextos de especificidade Bootstrap */
      nav .navbar-nav .nav-link,
      .navbar .navbar-nav .nav-link,
      .navbar-dark .navbar-nav .nav-link,
      .bg-primary .navbar-nav .nav-link {
        font-size: 0.83rem !important;
        font-weight: 500 !important;
        color: rgba(255,255,255,.90) !important;
        position: relative;
        transition: color var(--dur-fast) ease;
      }
      nav .navbar-nav .nav-link:hover,
      .navbar .navbar-nav .nav-link:hover,
      .navbar-dark .navbar-nav .nav-link:hover {
        color: #fff !important;
        opacity: 1 !important;
      }
      nav .navbar-nav .nav-link.active,
      nav .navbar-nav .nav-link.show,
      .navbar .navbar-nav .nav-link.active,
      .navbar .navbar-nav .nav-link.show {
        color: #fff !important;
        font-weight: 700 !important;
        opacity: 1 !important;
      }
      /* Dropdown de navegação — azul Gov.br, texto branco */
      .navbar-nav .dropdown-menu,
      .navbar .dropdown-menu {
        background: #003d7a !important;
        border: 1px solid rgba(255,255,255,.12) !important;
        border-radius: var(--radius-md) !important;
        box-shadow: 0 8px 24px rgba(0,0,0,.30) !important;
        padding: 6px !important;
        min-width: 200px;
      }
      .navbar-nav .dropdown-menu .dropdown-item,
      .navbar .dropdown-menu .dropdown-item {
        font-size: 0.83rem !important;
        font-weight: 500 !important;
        color: rgba(255,255,255,.90) !important;
        border-radius: var(--radius-sm) !important;
        padding: 8px 14px !important;
        display: flex !important;
        align-items: center !important;
        gap: 8px !important;
      }
      .navbar-nav .dropdown-menu .dropdown-item:hover,
      .navbar-nav .dropdown-menu .dropdown-item:focus,
      .navbar .dropdown-menu .dropdown-item:hover,
      .navbar .dropdown-menu .dropdown-item:focus {
        background: rgba(255,255,255,.12) !important;
        color: #fff !important;
      }
      .navbar-nav .nav-link::after {
        content: '';
        position: absolute;
        bottom: 2px; left: 50%; right: 50%;
        height: 2px;
        background: rgba(255,255,255,.9);
        border-radius: 2px;
        transition: left var(--dur-base) var(--ease-out),
                    right var(--dur-base) var(--ease-out);
      }
      .navbar-nav .nav-link.active::after { left: 12px; right: 12px; }
      @media (hover: hover) {
        .navbar-nav .nav-link:not(.active):hover::after {
          left: 12px; right: 12px; opacity: .40;
        }
      }

      /* ── Cards (exclui value boxes que têm temas próprios) ──── */
      .bslib-card:not(.bslib-value-box) {
        background: var(--c-surface-1) !important;
        border: 1px solid var(--c-border-sub) !important;
        border-radius: var(--radius-md) !important;
        box-shadow: var(--shadow-sm) !important;
        transition: box-shadow var(--dur-base) var(--ease-out),
                    transform var(--dur-base) var(--ease-out);
      }
      @media (hover: hover) {
        .bslib-card:not(.bslib-value-box):hover {
          box-shadow: var(--shadow-md) !important;
          transform: translateY(-2px);
        }
      }
      .bslib-card:not(.bslib-value-box) .card-header {
        font-size: 0.78rem !important;
        font-weight: 700 !important;
        letter-spacing: .025em !important;
        text-transform: uppercase !important;
        padding: 10px 16px !important;
        border-bottom: 1px solid rgba(255,255,255,.15) !important;
      }
      /* Card headers coloridos com gradiente */
      .bslib-card .card-header.bg-primary {
        background: linear-gradient(135deg, #004587 0%, #1351b4 100%) !important;
      }
      /* Value boxes: deixa o tema do bslib agir, só ajusta sombra/raio */
      .bslib-value-box {
        border-radius: var(--radius-md) !important;
        box-shadow: var(--shadow-md) !important;
        border: none !important;
      }


      /* ── Tabs internos (navset_card_underline) ─────────────── */
      .card > .card-header > .nav-underline,
      .bslib-card > .card-header > .nav-underline {
        border-bottom: none !important;
        gap: 2px;
      }
      .nav-underline .nav-link {
        font-size: 0.8rem !important;
        font-weight: 500 !important;
        color: var(--c-ink-2) !important;
        padding: 7px 14px !important;
        border-radius: var(--radius-sm) var(--radius-sm) 0 0 !important;
        border-bottom: 2px solid transparent !important;
        transition: color var(--dur-fast) ease,
                    background var(--dur-fast) ease,
                    border-color var(--dur-fast) ease !important;
      }
      .nav-underline .nav-link:hover {
        color: var(--c-brand) !important;
        background: rgba(0,69,135,.05) !important;
      }
      .nav-underline .nav-link.active {
        color: var(--c-brand) !important;
        font-weight: 700 !important;
        background: rgba(0,69,135,.06) !important;
        border-bottom-color: var(--c-brand) !important;
      }

      /* ── Value boxes ────────────────────────────────────────── */
      .value-box .value-box-title {
        font-size: 0.68rem !important;
        font-weight: 700 !important;
        text-transform: uppercase !important;
        letter-spacing: .07em !important;
      }
      .value-box .value-box-value {
        font-size: 1.8rem !important;
        font-weight: 800 !important;
        letter-spacing: -.025em !important;
        line-height: 1.05 !important;
      }

      /* ── Botões ─────────────────────────────────────────────── */
      .btn {
        font-size: 0.8rem !important;
        font-weight: 600 !important;
        border-radius: var(--radius-sm) !important;
        transition: transform var(--dur-fast) ease,
                    box-shadow var(--dur-fast) ease !important;
      }
      .btn:active { transform: scale(0.97); }
      @media (hover: hover) {
        .btn-primary:hover {
          box-shadow: 0 4px 16px rgba(0,69,135,.32) !important;
        }
      }

      /* ── Inputs / selects ───────────────────────────────────── */
      .form-select, .form-control {
        font-size: 0.82rem !important;
        border-color: var(--c-border) !important;
        border-radius: var(--radius-sm) !important;
        background-color: var(--c-surface-1) !important;
        transition: border-color var(--dur-fast) ease,
                    box-shadow var(--dur-fast) ease;
      }
      .form-select:focus, .form-control:focus {
        border-color: var(--c-brand-mid) !important;
        box-shadow: var(--shadow-focus) !important;
        outline: none !important;
      }
      label, .control-label {
        font-size: 0.78rem !important;
        font-weight: 600 !important;
        color: var(--c-ink-2) !important;
        margin-bottom: 4px !important;
      }

      /* ── Sidebar ────────────────────────────────────────────── */
      .bslib-sidebar-layout > .sidebar {
        background: var(--c-surface-2) !important;
        border-right: 1px solid var(--c-border-sub) !important;
      }

      /* ── DT tables ──────────────────────────────────────────── */
      .dataTables_wrapper { font-size: 0.8rem; color: var(--c-ink-1); }
      .dataTables_wrapper .dataTables_filter input {
        border-radius: var(--radius-sm) !important;
        font-size: 0.78rem !important;
      }

      /* ── Tab panels — fade ao entrar ────────────────────────── */
      .tab-content > .tab-pane {
        padding-top: 12px;
        animation: pmFadeIn 160ms var(--ease-out) both;
      }
      @keyframes pmFadeIn {
        from { opacity: 0; transform: translateY(3px); }
        to   { opacity: 1; transform: none; }
      }

      /* ── Capa: decorações do hero ───────────────────────────── */
      .pm-hero {
        position: relative;
        overflow: hidden;
      }
      .pm-hero::before {
        content: '';
        position: absolute; inset: 0;
        background: repeating-linear-gradient(
          -55deg,
          transparent, transparent 28px,
          rgba(255,255,255,.025) 28px, rgba(255,255,255,.025) 29px
        );
        pointer-events: none;
      }
      .pm-hero::after {
        content: '';
        position: absolute;
        right: -80px; bottom: -80px;
        width: 320px; height: 320px;
        border-radius: 50%;
        background: radial-gradient(circle,
          rgba(255,120,0,.18) 0%,
          transparent 65%);
        pointer-events: none;
      }

      /* ── Acessibilidade ─────────────────────────────────────── */
      @media (prefers-reduced-motion: reduce) {
        *, *::before, *::after {
          animation-duration: 0.01ms !important;
          transition-duration: 0.01ms !important;
        }
      }

    "))
  )
}
