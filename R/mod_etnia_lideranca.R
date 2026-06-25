#' etnia_lideranca UI Function
#'
#' @description Módulo de monitoramento da ocupação de Cargos Comissionados
#'   (CCE/FCE) por pessoas negras – Decreto nº 11.443/2023.
#'
#' @param id Internal parameter for {shiny}.
#' @noRd
#' @importFrom shiny NS tagList
mod_etnia_lideranca_ui <- function(id) {
  ns <- NS(id)
  tagList(
    bslib::navset_card_underline(
      id = ns("nav_etnia"),
      selected = "visao",

      # ------------------------------------------------------------------
      # Aba 1: Visão Geral
      # ------------------------------------------------------------------
      bslib::nav_panel(
        title = "Visão Geral",
        value = "visao",
        icon  = shiny::icon("users"),
        shiny::uiOutput(ns("kpi_boxes")),
        bslib::card(
          bslib::card_header(
            class = "bg-primary text-white",
            shiny::icon("chart-line"),
            "Evolução Mensal – % de Cargos CCE/FCE ocupados por pessoas negras"
          ),
          bslib::card_body(.spin(plotly::plotlyOutput(ns("serie_mensal"), height = "380px")))
        )
      ),

      # ------------------------------------------------------------------
      # Aba 2: Por Órgão
      # ------------------------------------------------------------------
      bslib::nav_panel(
        title = "Por Órgão",
        value = "orgao",
        icon  = shiny::icon("building"),
        bslib::layout_columns(
          col_widths = c(6, 6),
          bslib::card(
            bslib::card_header(
              class = "bg-primary text-white",
              shiny::icon("sitemap"), " Por Órgão Superior"
            ),
            bslib::card_body(fill = FALSE, .spin(DT::DTOutput(ns("tab_superior"))))
          ),
          bslib::card(
            bslib::card_header(
              class = "bg-primary text-white",
              shiny::icon("building"), " Por Órgão Vinculado"
            ),
            bslib::card_body(fill = FALSE, .spin(DT::DTOutput(ns("tab_vinculado"))))
          )
        )
      ),

      # ------------------------------------------------------------------
      # Aba 3: Suficiência de Vagas
      # ------------------------------------------------------------------
      bslib::nav_panel(
        title = "Suficiência de Vagas",
        value = "suficiencia",
        icon  = shiny::icon("balance-scale"),
        bslib::layout_columns(
          col_widths = c(3, 9),
          bslib::card(
            bslib::card_header(
              # "Texto Markdown",
              class = "bg-primary text-white",
              # Badge flutuante no canto superior esquerdo
              tags$div(
                # style = "position: absolute; top: -14px; left: 22px; display: flex; align-items: center; gap: 8px;",
                tags$span(
                  # style = paste0(
                  #   "background: #FF7800; color: white; border-radius: 50%;",
                  #   "width: 30px; height: 30px; display: inline-flex;",
                  #   "align-items: center; justify-content: center;",
                  #   "font-size: 13px; box-shadow: 0 2px 6px rgba(255,120,0,0.45);"
                  #   ),
                  shiny::icon("circle-info")
                ),
                tags$span(
                  # style = paste0(
                  #   "background: #FF7800; color: white; border-radius: 4px;",
                  #   "padding: 2px 10px; font-size: 0.68rem; font-weight: 700;",
                  #   "text-transform: uppercase; letter-spacing: 1px;",
                  #   "box-shadow: 0 2px 6px rgba(255,120,0,0.35);"
                  #   ),
                  "Índice de suficiência de vagas em  cargos FCE"
                )
              )
            ),
            bslib::card_body(
              # shiny::withMathJax(),
              tags$div(
                class = "p-3",
                style = "font-size: 1.1rem;",
                shiny::uiOutput(ns("texto_razao_suficiencia"))
              )
            )
          ),
          bslib::layout_columns(
            col_widths = c(12, 12),
            bslib::card(
              bslib::card_header(
                class = "bg-primary text-white",
                "Índice de Suficiência – Nível 1 a 12"
                ),
              bslib::card_body(fill = FALSE, .spin(DT::DTOutput(ns("suf_1a12"))))
              ),
            bslib::card(
              bslib::card_header(
                class = "bg-primary text-white",
                "Índice de Suficiência – Nível 13 a 17"
                ),
              bslib::card_body(fill = FALSE, .spin(DT::DTOutput(ns("suf_13a17"))))
              )
            )
        )
      ),

      # ------------------------------------------------------------------
      # Aba 4: Razão de Equidade
      # ------------------------------------------------------------------
      bslib::nav_panel(
        title = "Razão de Equidade",
        value = "equidade",
        icon  = shiny::icon("chart-bar"),
        bslib::layout_columns(
          col_widths = c(3,9),
          bslib::card(
            bslib::card_header(
              # "Texto Markdown",
              class = "bg-primary text-white",
              # Badge flutuante no canto superior esquerdo
              tags$div(
                # style = "position: absolute; top: -14px; left: 22px; display: flex; align-items: center; gap: 8px;",
                tags$span(
                  # style = paste0(
                  #   "background: #FF7800; color: white; border-radius: 50%;",
                  #   "width: 30px; height: 30px; display: inline-flex;",
                  #   "align-items: center; justify-content: center;",
                  #   "font-size: 13px; box-shadow: 0 2px 6px rgba(255,120,0,0.45);"
                  #   ),
                  shiny::icon("circle-info")
                ),
                tags$span(
                  # style = paste0(
                  #   "background: #FF7800; color: white; border-radius: 4px;",
                  #   "padding: 2px 10px; font-size: 0.68rem; font-weight: 700;",
                  #   "text-transform: uppercase; letter-spacing: 1px;",
                  #   "box-shadow: 0 2px 6px rgba(255,120,0,0.35);"
                  #   ),
                  "Índice de equidade de acesso a cargos FCE"
                )
              )
            ),
            bslib::card_body(
              # shiny::withMathJax(),
              tags$div(
                class = "p-3",
                style = "font-size: 1.1rem;",
                shiny::uiOutput(ns("texto_razao_equidade"))
              )
            )
          ),
          tags$div(
            class = "d-flex flex-column gap-3 h-100",
            bslib::card(
              style = "flex: 6;",
              bslib::card_header(
                class = "bg-primary text-white",
                shiny::icon("chart-bar"),
                " Razão de Equidade por Cor/Raça nos Cargos CCE/FCE"
                ),
              bslib::card_body(.spin(plotly::plotlyOutput(ns("razao_equidade"), height = "420px")))
              ),
            bslib::card(
              style = "flex: 4;",
              bslib::card_header(
                class = "bg-primary text-white",
                shiny::icon("chart-bar"),
                " Razão de Equidade por Cor/Raça nos Cargos CCE/FCE"
                ),
              bslib::card_body(fill = FALSE, .spin(DT::DTOutput(ns("tab_equidade_orgao"))))
              # bslib::layout_columns(
              # col_widths = c(6,6),
              # bslib::card_body(fill = FALSE, .spin(DT::DTOutput(ns("tab_equidade_13a17"))))
              # )
              )
            )
          )
        )
      )
    )
  }


#' etnia_lideranca Server Functions
#'
#' @param id Internal parameter for {shiny}.
#' @noRd
mod_etnia_lideranca_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {

    # ------------------------------------------------------------------
    # Carregamento de dados
    # ------------------------------------------------------------------
    Tab_serie    <- readRDS(here::here("data-raw/data_etnia/Tab_inds_1_e_2.rds"))
    Tab_vinc     <- readRDS(here::here("data-raw/data_etnia/Tab.rds"))
    Tab_sup      <- readRDS(here::here("data-raw/data_etnia/Tab_sup.rds"))
    Tab_ind3     <- readRDS(here::here("data-raw/data_etnia/Tab_ind3.rds"))
    Tab_eq_mes   <- readRDS(here::here("data-raw/data_etnia/Tab_inds_4_mes.rds"))
    Tab_ind4_orgaos   <- readRDS(here::here("data-raw/data_etnia/Tab_inds_4_orgaos.rds"))

    # Normalizar nomes de colunas (remove acentuação para evitar problemas de encoding)
    names(Tab_vinc) <- iconv(names(Tab_vinc), "UTF-8", "ASCII//TRANSLIT")
    names(Tab_sup)  <- iconv(names(Tab_sup),  "UTF-8", "ASCII//TRANSLIT")

    # ------------------------------------------------------------------
    # Valores do mês mais recente
    # ------------------------------------------------------------------
    mes_max <- max(Tab_serie$anomes)

    atual <- Tab_serie |>
      dplyr::filter(anomes == mes_max)

    pct_1a12  <- atual$p_negras[atual$decreto_nivel == "Nível 1 a 12"]
    pct_13a17 <- atual$p_negras[atual$decreto_nivel == "Nível 13 a 17"]

    mes_ant <- max(Tab_serie$anomes[Tab_serie$anomes < mes_max])

    anterior <- Tab_serie |>
      dplyr::filter(anomes == mes_ant)

    ant_1a12  <- anterior$p_negras[anterior$decreto_nivel == "Nível 1 a 12"]
    ant_13a17 <- anterior$p_negras[anterior$decreto_nivel == "Nível 13 a 17"]

    delta_1a12  <- if (length(ant_1a12)  > 0) round(pct_1a12  - ant_1a12,  2) else NA_real_
    delta_13a17 <- if (length(ant_13a17) > 0) round(pct_13a17 - ant_13a17, 2) else NA_real_

    fmt_delta <- function(d) {
      if (is.na(d)) return("–")
      paste0(ifelse(d >= 0, "+", ""), d, " pp")
    }

    # ------------------------------------------------------------------
    # KPI boxes
    # ------------------------------------------------------------------
    output$kpi_boxes <- shiny::renderUI({
      bslib::layout_columns(
        col_widths = c(3, 3, 3, 3),
        bslib::value_box(
          title    = "Negros – Nível 1 a 12",
          value    = paste0(round(pct_1a12, 1), "%"),
          showcase = shiny::icon("users"),
          theme    = if (pct_1a12 >= 30) "success" else "warning",
          shiny::p(
            paste0("Meta: 30% | ", ifelse(pct_1a12 >= 30, "Meta atingida", "Abaixo da meta")),
            style = "font-size:0.85rem;"
          )
        ),
        bslib::value_box(
          title    = "Negros – Nível 13 a 17",
          value    = paste0(round(pct_13a17, 1), "%"),
          showcase = shiny::icon("crown"),
          theme    = if (pct_13a17 >= 30) "success" else "danger",
          shiny::p(
            paste0("Meta: 30% | ", ifelse(pct_13a17 >= 30, "Meta atingida", "Abaixo da meta")),
            style = "font-size:0.85rem;"
          )
        ),
        bslib::value_box(
          title    = "Var. Mensal – Nível 1-12",
          value    = fmt_delta(delta_1a12),
          showcase = shiny::icon(if (!is.na(delta_1a12) && delta_1a12 >= 0) "arrow-up" else "arrow-down"),
          theme    = "primary",
          shiny::p("pontos percentuais vs. mês anterior", style = "font-size:0.85rem;")
        ),
        bslib::value_box(
          title    = "Meta – Decreto 11.443/2023",
          value    = "30%",
          showcase = shiny::icon("gavel"),
          theme    = bslib::value_box_theme(bg = "#0c326f", fg = "#ffffff"),
          shiny::p("cargos CCE/FCE ocupados por pessoas negras", style = "font-size:0.85rem;")
        )
      )
    })

    # ------------------------------------------------------------------
    # Série mensal % negros em CCE/FCE
    # ------------------------------------------------------------------
    serie_negros_fce_cce <- reactive({


      dt_decreto <- zoo::as.yearmon("Mar 2023","%b %Y")
      Tab_serie |>
        ggplot_cat(aes(x = anomes,
                       y = p_negras,
                       col = decreto_nivel)) +
        geom_line() +
        geom_point(size = 2.2,show.legend = F) +
        # guides(color = guide_legend(override.aes = list(linetype = 0))) +
        geom_vline(aes(xintercept = dt_decreto,
                       linetype = "Decreto 11.443/2023")
        )+
        geom_hline(aes(yintercept = 30,
                       linetype = "Meta: 30%"),
                   col = .pal_primaria["principal"]
        ) +
        scale_linetype_manual(
          values = c( "Decreto 11.443/2023" = "dashed",
                      "Meta: 30%" = 'solid')
        ) +
        # ylim(0,1.1*max(comissionados_negros_mes$p_negra)) +
        labs(x = "",col = "",y = "",linetype = "") -> p_neg_mes

      ggplotly_c(p_neg_mes)

    })
    output$serie_mensal <- plotly::renderPlotly({serie_negros_fce_cce()})

    # ------------------------------------------------------------------
    # Tabela por órgão superior
    # ------------------------------------------------------------------
    output$tab_superior <- DT::renderDT({
      .dt_orgao(Tab_sup, "Orgao Superior")
    })

    # ------------------------------------------------------------------
    # Tabela por órgão vinculado
    # ------------------------------------------------------------------
    output$tab_vinculado <- DT::renderDT({
      df <- Tab_vinc |>
        dplyr::select(-dplyr::starts_with("Orgao Superior"))
      .dt_orgao(df, "Orgao")
    })

    # ------------------------------------------------------------------
    # Índice de suficiência de vagas
    # ------------------------------------------------------------------

    ### texto
    output$texto_razao_suficiencia <- shiny::renderUI({
      texto_html <- "

<ul>
  <li><strong>Definição:</strong> Relação entre o total de cargos CCE/FCE disponíveis no órgão e o número de vagas que deveriam ser ocupadas por pessoas negras para cumprimento da meta.</li>
</ul>

<p>
  O indicador 2 é calculado apenas para os órgãos que não atingiram a meta estabelecida no Decreto.
  O indicador é baseado no número de nomeações adicionais que seriam necessárias para cumprir a meta do decreto, sem alterar a distribuição atual de cargos.
  Em outras palavras, considerando \\( T \\) a quantidade de vínculos em cargos comissionados e \\( N \\) o total destes que se autodeclaram negros, o total de cargos adicionais, \\( A \\), necessários para cumprir a meta é definido de tal forma que:
</p>

$$100\\times \\frac{N + A}{T + A} \\geq 30$$

<p>Assim, temos:</p>

$$A \\geq \\frac{0.3T - N}{1-0.3}$$

<p>
  Além das vagas necessárias, o indicador 2 leva em conta o total de cargos disponíveis \\( D \\), definido como a diferença entre o total de cargos distribuídos para o órgão e o total de ocupados.
</p>

<ul>
  <li><strong>Fórmula conceitual:</strong>
    $$Indicador 2 = \\frac{D}{A}$$
  </li>
  <br>
  <li><strong>Interpretação:</strong>
    <ul>
      <li>\\( = 1 \\) -> As vagas disponíveis são exatamente suficientes para atingir a meta</li>
      <li>\\( < 1 \\) -> As vagas disponíveis são insuficientes para atingir a meta</li>
      <li>\\( > 1 \\) -> As vagas disponíveis são mais do que suficientes para atingir a meta</li>
    </ul>
  </li>
</ul>

      "

      shiny::withMathJax(
        # shiny::markdown(texto_md)
        shiny::HTML(texto_html)
      )

      })


    output$suf_1a12  <- DT::renderDT({ .dt_suficiencia(Tab_ind3, "Nível 1 a 12")  })
    output$suf_13a17 <- DT::renderDT({ .dt_suficiencia(Tab_ind3, "Nível 13 a 17") })

    # ------------------------------------------------------------------
    # Razão de equidade por cor/raça
    # ------------------------------------------------------------------

    ### texto
    output$texto_razao_equidade <- shiny::renderUI({
      texto_md <-"

* **Hipótese analítica:** na ausência de desigualdade racial no acesso a cargos de liderança, a proporção de negros em cargos FCE deveria ser equivalente à sua proporção entre os servidores efetivos ativos.

* **Definição:** Razão entre o percentual de pessoas negras em cargos de liderança (FCE) e o percentual de pessoas negras no conjunto de servidores efetivos ativos.

* **Fórmula conceitual:** RE = $$\\frac{\\text{% negros em cargos FCE}}{\\text{% negros no quadro efetivo ativo}}$$

* **Interpretação:**
    * $= 1$ → Equidade na ocupação dos cargos
    * $< 1$ → Sub-representação de pessoas negras na liderança
    * $> 1$ → Sobre-representação
"

      texto_html <- "

      <ul>
      <li><strong>Hipótese analítica:</strong> na ausência de desigualdade racial no acesso a cargos de liderança, a proporção de negros em cargos FCE deveria ser equivalente à sua proporção entre os servidores efetivos ativos.</li>
      <br>
      <li><strong>Definição:</strong> Razão entre o percentual de pessoas negras em cargos de liderança (FCE) e o percentual de pessoas negras no conjunto de servidores efetivos ativos.</li>
      <br>
      <li><strong>Fórmula conceitual:</strong>
        $$\\frac{\\text{% negros em cargos FCE}}{\\text{% negros no quadro efetivo ativo}}$$
      </li>
      <br>
      <li><strong>Interpretação:</strong>
        <ul>
          <li>\\( = 1 \\) &rarr; Equidade na ocupação dos cargos</li>
          <li>\\( < 1 \\) &rarr; Sub-representação de pessoas negras na liderança</li>
          <li>\\( > 1 \\) &rarr; Sobre-representação</li>
        </ul>
      </li>
    </ul>

      "
      shiny::withMathJax(
        # shiny::markdown(texto_md)
        shiny::HTML(texto_html)
      )

    })

    ### Gráfico
    output$razao_equidade <- plotly::renderPlotly({

      ## melt na base
      df_long <- Tab_eq_mes |>
        tidyr::pivot_longer(
          cols      = c(ind4_1_a_12, ind4_13_a_17),
          names_to  = "nivel_cod",
          values_to = "razao"
        ) |>
        dplyr::mutate(
          nivel_label = dplyr::case_when(
            nivel_cod == "ind4_1_a_12"   ~ "Níveis 1 a 12",
            nivel_cod == "ind4_13_a_17"  ~ "Níveis 13 a 17"
          )
        ) |>
        dplyr::filter(nome_cor_origem_etnica %in%
                 c("BRANCA","PRETA","PARDA","Negras"))

      # facet_wrap + col + geom_hline quebra gg2list no plotly;
      # solução: subplot manual com um painel por nivel_label
      make_panel <- function(nivel, show_legend) {
        df_nivel <- dplyr::filter(df_long, nivel_label == nivel)
        gf <- ggplot_cat(df_nivel,
                         aes(x = anomes, y = razao,
                             col = nome_cor_origem_etnica)) +
          geom_line() +
          geom_point(size = 2.2) +
          geom_hline(yintercept = 1, linetype = 2) +
          labs(x = "", col = "", y = "", title = nivel)
        p <- plotly::ggplotly(gf)
        if (!show_legend) p <- plotly::layout(p, showlegend = FALSE)
        p
      }

      plotly::subplot(
        make_panel("Níveis 1 a 12",  show_legend = FALSE),
        make_panel("Níveis 13 a 17", show_legend = TRUE),
        nrows    = 1,
        shareY   = TRUE,
        titleX   = TRUE
      )

    })

    # ------------------------------------------------------------------
    # Razão de equidade por cor/raça: TABELAS
    # ------------------------------------------------------------------
    output$tab_equidade_orgao <- DT::renderDT({
      # Criar a tabela usando datatable com as configurações personalizadas
      configuracao <- list(
        language = list(
          infoFiltered = "(filtrado num total de _MAX_ registros)",
          info = "Exibindo _START_ até _END_ de _TOTAL_ registros",
          lengthMenu = "Mostrar _MENU_ registros por página",
          search = "Pesquisar:",
          paginate = list(
            first = "Primeiro",
            last = "Último",
            `next` = "Próximo",
            previous = "Anterior"),
          aria = list(
            sortAscending = ": ativar para classificar coluna em ordem crescente",
            sortDescending = ": ativar para classificar coluna em ordem decrescente"
          )
        ),
        dom = 'Bfrtip',
        buttons = c('csv', 'excel', 'pdf', 'print')

      )


      # tbela necessidade de vagas
      lim1 <- Tab_ind4_orgaos |>
        dplyr::filter(is.finite(ind4_1_a_12),
               nome_cor_origem_etnica == "Negras") |>
        dplyr::summarise(li = max(abs(ind4_1_a_12 - 1),na.rm = T)) |>
        dplyr::select(li)

      lim2 <- Tab_ind4_orgaos |>
        dplyr::filter(is.finite(ind4_13_a_17),
               nome_cor_origem_etnica == "Negras") |>
        dplyr::summarise(ls = max(abs(ind4_13_a_17 - 1),na.rm = T)) |>
        dplyr::select(ls)

      lim <- max(lim1,lim2)

      pal <- scales::col_numeric(
        palette = c(.pal_primaria['ponto'],"white",.pal_primaria["principal"]),
        domain = c(1 - lim, 1 + lim)
      )

      dom_ind4_12 <- Tab_ind4_orgaos$ind4_1_a_12
      dom_ind4_17 <- Tab_ind4_orgaos$ind4_13_a_17

      dt4 <-
        Tab_ind4_orgaos |>
        dplyr::arrange(desc(ind4_13_a_17)) |>
        dplyr::filter(nome_cor_origem_etnica == "Negras")|>
        dplyr::select(orgao_vinculado_cargos_e_funcoes,
                      qtde,
                      `Nivel 1 a 12`,
                      `Nivel 13 a 17`,
                      ind4_1_a_12,
                      ind4_13_a_17) |>
        DT::datatable(#filter = "top",
          #style = "bootstrap",
          class = "compact",
          width = "100%",
          extensions = 'Buttons',
          options = configuracao,
          colnames =
            c("Órgão",
              "Percentual de Efetivos Negros",
              "% de negros, nível 1 a 12",
              "% de negros, nível 13 a 17",
              "Razão equidade, nível 1 a 12",
              "Razão equidade, nível 13 a 17")
        ) |>
        DT::formatStyle(
          "ind4_1_a_12",
          background = styleEqual(dom_ind4_12,pal(dom_ind4_12)),
          backgroundSize = '98% 88%',
          backgroundRepeat = 'no-repeat',
          backgroundPosition = 'center'
        ) |>
        DT::formatStyle(
          "ind4_13_a_17",
          background = styleEqual(dom_ind4_17,pal(dom_ind4_17)),
          backgroundSize = '98% 88%',
          backgroundRepeat = 'no-repeat',
          backgroundPosition = 'center'
        )

      # Sys.setlocale("LC_TIME", "pt_BR.ISO8859-1")
      dt4
      }
    )

    return(serie_negros_fce_cce)
    }
  )
}


# ------------------------------------------------------------------
# Helpers internos
# ------------------------------------------------------------------

# Monta DT para tabelas de órgão com color bar de percentuais
.dt_orgao <- function(df, col_orgao) {# No seu server.R (ou no bloco correspondente do Shiny)

  # 1. Busca das colunas (certifique-se de usar df() se for reativo!)
  # Se 'df' for reativo, troque as duas linhas abaixo por df()
  col_n1 <- grep("^N.vel.1|^Nivel.1", names(df), value = TRUE)[1]
  col_n2 <- grep("^N.vel.13|^Nivel.13", names(df), value = TRUE)[1]

  dt_opts <- list(
    pageLength  = 15,
    scrollX     = TRUE,
    order       = list(list(which(names(df) == col_n1) - 1L, "asc")),
    language    = list(
      search    = "Pesquisar:",
      info      = "Exibindo _START_ até _END_ de _TOTAL_ órgãos",
      paginate  = list(`next` = "Próximo", previous = "Anterior")
    )
  )

  # 2. Renderização da Tabela
  DT::datatable(df, rownames = FALSE, class = "row-border compact hover", options = dt_opts) |>
    DT::formatStyle(
      col_n1,
      # JavaScript puro cuidando da cor e proporção da barra
      background = DT::JS(
        "isNaN(parseFloat(value)) ? '' : ",
        "(parseFloat(value) < 30 ? ",
        "'linear-gradient(90deg, #FF7800 ' + parseFloat(value) + '%, transparent ' + parseFloat(value) + '%)' : ",
        "'linear-gradient(90deg, #00A100 ' + parseFloat(value) + '%, transparent ' + parseFloat(value) + '%)')"
      ),
      backgroundSize     = "98% 70%",
      backgroundRepeat   = "no-repeat",
      backgroundPosition = "center",
      color              = "black",
      fontWeight         = "bold",
      textShadow         = "1px 1px 2px #fff, -1px -1px 2px #fff, 1px -1px 2px #fff, -1px 1px 2px #fff"
    ) |>
    DT::formatStyle(
      col_n2,
      background = DT::JS(
        "isNaN(parseFloat(value)) ? '' : ",
        "(parseFloat(value) < 30 ? ",
        "'linear-gradient(90deg, #FF7800 ' + parseFloat(value) + '%, transparent ' + parseFloat(value) + '%)' : ",
        "'linear-gradient(90deg, #00A100 ' + parseFloat(value) + '%, transparent ' + parseFloat(value) + '%)')"
      ),
      backgroundSize     = "98% 70%",
      backgroundRepeat   = "no-repeat",
      backgroundPosition = "center",
      color              = "black",
      fontWeight         = "bold",
      textShadow         = "1px 1px 2px #fff, -1px -1px 2px #fff, 1px -1px 2px #fff, -1px 1px 2px #fff"
    )}

# Monta DT para tabela de suficiência de vagas filtrada por nível
.dt_suficiencia <- function(df, nivel) {
  df_filt <- df |>
    dplyr::filter(decreto_nivel == nivel) |>
    dplyr::select(
      orgao_vinculado_cargos_e_funcoes,
      Total_ocupados,
      total_negras,
      total_dist,
      necessidade_vagas,
      cargos_disponiveis,
      indice_suficiencia
    ) |>
    dplyr::rename(
      Orgao                       = orgao_vinculado_cargos_e_funcoes,
      `Cargos Ocupados`           = Total_ocupados,
      `Negros Ocupando`           = total_negras,
      `Cargos Distribuidos`       = total_dist,
      `Vagas Necessarias`         = necessidade_vagas,
      `Vagas Disponiveis`         = cargos_disponiveis,
      `Indice Suficiencia`        = indice_suficiencia
    ) |>
    dplyr::arrange(`Indice Suficiencia`)

  rng <- range(df$indice_suficiencia, na.rm = TRUE)

  dt_opts <-  list(
    pageLength = 15,
    scrollX    = TRUE,
    order       = list(list(which(names(df_filt) == "Indice Suficiencia") - 1L, "desc")),
    language   = list(
      search   = "Pesquisar:",
      paginate = list(`next` = "Próximo", previous = "Anterior")
    )
  )

  # 1. Descobre o índice da coluna (0-indexed para o JavaScript do DataTables)
  col_idx <- which(names(df_filt) == "Indice Suficiencia") - 1

  # 2. Adiciona a regra da caixinha de texto (badge) nas opções da sua lista 'dt_opts'
  dt_opts$columnDefs <- list(
    list(
      targets = col_idx,
      render = DT::JS("
      function(data, type, row) {
        if (type === 'display') {
          if (isNaN(data) || data === null || data === '') return '';

          // Mesma regra de corte (valor 1) e cores da sua barra
          var color = parseFloat(data) < 1 ? '#FF7800' : '#00A100';

          // Arredonda para 2 casas decimais (substituindo o formatRound)
          var formatted = parseFloat(data).toFixed(2);

          // Retorna a caixinha de texto com fundo sólido e letra branca
          return '<span style=\"background-color: ' + color + '; color: white; padding: 4px 8px; border-radius: 4px; display: inline-block; font-weight: bold; min-width: 50px; text-align: center;\">' + formatted + '</span>';
        }
        return data;
      }
    ")
    )
  )

  DT::datatable(
    df_filt,
    rownames = FALSE,
    class    = "row-border compact hover",
    options  = dt_opts
    ) |>
    DT::formatStyle(
      "Indice Suficiencia",
      background = DT::JS(sprintf(
      "(function(val) {
      if (isNaN(val)) return '';
      var min = %f;
      var max = %f;
      var pct = Math.min(100, Math.max(0, ((val - min) / (max - min)) * 100));
      var color = val < 1 ? '#FF7800' : '#00A100';
      return 'linear-gradient(90deg, ' + color + ' ' + pct + '%%, transparent ' + pct + '%%)';
      })(parseFloat(value))",
      rng[1], rng[2]
      )),
      backgroundSize     = "98% 70%",
      backgroundRepeat   = "no-repeat",
      backgroundPosition = "center",)
  }
