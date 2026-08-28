#' pfgp_dim1 UI Function — Dimensionamento da Força de Trabalho
#' @noRd
#' @importFrom shiny NS tagList

load(file = "data-raw/data_pfgp.rda")

mod_pfgp_dim1_ui <- function(id) {
  ns <- NS(id)
  bslib::layout_sidebar(
    sidebar = bslib::sidebar(
      shiny::selectInput(ns("orgao_ref"), "Órgão",
                         choices  = c("Total", lista_orgaos),
                         selected = "Total"),
      shiny::selectInput(ns("ingr_categoria"),
                         "Categorias para análise de ingressos",
                         choices = c())
    ),
    bslib::card(
      bslib::card_header(
        class = "bg-primary text-white",
        tags$div(
          tags$span(shiny::icon("circle-info")),
          tags$span("Equidade de distribuição de servidores: estatutários ativos X distribuição demográfica na população")
        )
      ),
      bslib::card_body(
        tags$div(
          class = "p-3",
          style = "font-size: 1.1rem;",
          shiny::uiOutput(ns("texto_razao_equidade_atv"))
        )
      )
    ),
    bslib::layout_columns(
      col_widths = c(3, 9),
      bslib::card(
        bslib::card_header(
          class = "bg-primary text-white",
          tags$div(
            tags$span(shiny::icon("circle-info")),
            tags$span("Equidade de ingresso: novos ingressantes X distribuição demográfica na população")
          )
        ),
        bslib::card_body(
          tags$div(
            class = "p-3",
            style = "font-size: 1.1rem;",
            shiny::uiOutput(ns("texto_razao_equidade_ingr"))
          )
        )
      ),
      bslib::layout_columns(
        col_widths = c(12, 12),
        bslib::card(
          bslib::card_header(
            class = "bg-primary text-white",
            shiny::icon("chart-line"),
            "Análise de Equidade de Ingresso: Comparação População X APF"
          ),
          bslib::card_body(
            bslib::layout_columns(
              col_widths = c(6, 6),
              div(
                tags$h5("Linha de Base (2023)", class = "text-muted mb-3"),
                .spin(plotly::plotlyOutput(ns("eq_ingr_baseline"), height = "380px"))
              ),
              div(
                tags$h5("Situação Atual", class = "text-muted mb-3"),
                .spin(plotly::plotlyOutput(ns("eq_ingr_sit_atual"), height = "380px"))
              )
            )
          )
        ),
        bslib::card(
          bslib::card_header(
            class = "bg-primary text-white",
            shiny::icon("chart-line"),
            " Evolução Mensal – Equidade de acesso"
          ),
          bslib::card_body(.spin(plotly::plotlyOutput(ns("eq_ingr_serie"), height = "380px")))
        )
      )
    )
  )
}

mod_pfgp_dim1_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {

    base_censo     <- readRDS(here::here("data-raw/data_pfgp/base_censo.rds"))
    base_ingressos <- readRDS(here::here("data-raw/data_pfgp/base_ingressos.rds"))

    base_censo_melt <-
      base_censo |>
      dplyr::filter(!faixa_etaria %in% c("75 a 79 anos", "80 anos ou mais"),
                    nivel_instrucao %in% "Superior completo") |>
      data.table::melt(
        measure.vars    = c("sexo", "no_cor_origem_etnica", "no_regiao"),
        variable.name   = "fator",
        value.name      = c("categoria"),
        variable.factor = FALSE,
        value.factor    = FALSE
      ) |>
      dplyr::group_by(fator, categoria) |>
      dplyr::summarise(popcenso = sum(populacao_adj))

    base_siape_melt <-
      base_ingressos |>
      dplyr::rename("no_regiao" = "no_regiao_naturalidade") |>
      data.table::melt(
        measure.vars    = c("sexo", "no_cor_origem_etnica", "no_regiao"),
        variable.name   = "fator",
        value.name      = c("categoria"),
        variable.factor = FALSE,
        value.factor    = FALSE
      ) |>
      dplyr::group_by(co_orgao, sg_orgao, fator, categoria, ano_ingresso) |>
      dplyr::summarise(popsiape = sum(total))

    base_censo_melt <-
      base_censo_melt |>
      dplyr::group_by(fator) |>
      dplyr::mutate(total_fator_censo    = sum(popcenso),
                    p_categoria_censo    = round(100 * popcenso / total_fator_censo, 2)) |>
      dplyr::ungroup()

    base_siape_melt <-
      base_siape_melt |>
      dplyr::group_by(co_orgao, fator, ano_ingresso) |>
      dplyr::mutate(total_fator_siape    = sum(popsiape),
                    p_categoria_siape    = round(100 * popsiape / total_fator_siape, 2)) |>
      dplyr::ungroup()
    base_siape_melt <- dplyr::filter(base_siape_melt, !categoria %in% c("", "NAO_SE_APLICA"))

    base_ingressos_show <-
      dplyr::left_join(base_siape_melt, base_censo_melt, by = c("fator", "categoria")) |>
      dplyr::mutate(eq_ingresso = p_categoria_siape / p_categoria_censo)

    categorias_unicas <- unique(base_ingressos_show$fator)

    observe({
      shiny::updateSelectInput(
        session  = session,
        inputId  = "ingr_categoria",
        choices  = categorias_unicas,
        selected = categorias_unicas[1]
      )
    })

    output$texto_razao_equidade_atv <- shiny::renderUI({
      # arquivo_html <- readLines(here::here('docs/indicador_11_equidade_distribuicao.html'))
      # shiny::withMathJax(shiny::HTML(arquivo_html))

      tags$iframe(
        src = "relatorios/indicador_11_equidade_distribuicao.html",
        width = "100%",
        height = "1500px",
        style = "border:none;"
      )
      })

    output$texto_razao_equidade_ingr <- shiny::renderUI({
      texto_html <- "
      <ul>
      <li><strong>Hipótese analítica:</strong> na ausência de desigualdade no ingresso, a proporção de
      ingressantes de uma categoria deveria ser equivalente à sua proporção entre população.</li>
      <br>
      <li><strong>Definição:</strong> Razão entre o percentual de uma categoria dentre os ingressantes
      na APF e o percentual observado na população.</li>
      <br>
      <li><strong>Detalhe importante:</strong> O percentual da população é obtido com base nos dados do
      Censo de 2022, considerando a população com 18 anos ou mais e com pelo menos o ensino superior
      completo. Tal recorte justifica-se pelo fato de que este recorte ocorrem em 80% da APF.</li>
      <br>
      <li><strong>Fórmula conceitual:</strong>
        $$\\frac{\\text{% de ingressantes em uma categoria}}{\\text{% desta categoria na população}}$$
      </li>
      <br>
      <li><strong>Interpretação:</strong>
        <ul>
          <li>\\( = 1 \\) &rarr; Equidade no ingresso</li>
          <li>\\( < 1 \\) &rarr; Sub-representação da categoria na APF</li>
          <li>\\( > 1 \\) &rarr; Sobre-representação</li>
        </ul>
      </li>
    </ul>"
      shiny::withMathJax(shiny::HTML(texto_html))
    })

    output$eq_ingr_baseline <- plotly::renderPlotly({
      req(input$orgao_ref)
      req(input$ingr_categoria)
      ft_orgao <- as.character(input$orgao_ref)
      ft_categ <- as.character(input$ingr_categoria)

      base_ingressos_show |>
        dplyr::filter(sg_orgao == ft_orgao, ano_ingresso == 2023, fator == ft_categ) |>
        tidyr::pivot_longer(
          cols      = c("p_categoria_siape", "p_categoria_censo"),
          names_to  = "universo",
          values_to = "p_categ"
        ) |>
        dplyr::mutate(
          p_categ  = ifelse(universo == "p_categoria_censo", -p_categ, p_categ) |> round(1),
          universo = gsub("p_categoria_", "", universo)
        ) -> tab_filtro

      tab_filtro |>
        ggplot_cat(ggplot2::aes(x = categoria, y = p_categ, fill = universo)) +
        ggplot2::geom_col(position = "stack") +
        ggplot2::geom_text(ggplot2::aes(label = paste0(abs(p_categ), "%")),
                  size = 5, col = "white", fontface = "bold",
                  position = ggplot2::position_stack(vjust = 0.5)) +
        ggplot2::coord_flip() +
        ggplot2::labs(x = NULL, y = NULL, fill = NULL) -> gr_ingr

      ggplotly_c(gr_ingr)
    })

    output$eq_ingr_sit_atual <- plotly::renderPlotly({
      req(input$orgao_ref)
      req(input$ingr_categoria)
      ft_orgao <- as.character(input$orgao_ref)
      ft_categ <- as.character(input$ingr_categoria)
      max_ano  <- max(base_ingressos_show$ano_ingresso)

      base_ingressos_show |>
        dplyr::filter(sg_orgao == ft_orgao, ano_ingresso == max_ano, fator == ft_categ) |>
        tidyr::pivot_longer(
          cols      = c("p_categoria_siape", "p_categoria_censo"),
          names_to  = "universo",
          values_to = "p_categ"
        ) |>
        dplyr::mutate(
          p_categ  = ifelse(universo == "p_categoria_censo", -p_categ, p_categ) |> round(1),
          universo = gsub("p_categoria_", "", universo)
        ) -> tab_filtro

      tab_filtro |>
        ggplot_cat(ggplot2::aes(x = categoria, y = p_categ, fill = universo)) +
        ggplot2::geom_col(position = "stack") +
        ggplot2::geom_text(ggplot2::aes(label = paste0(abs(p_categ), "%")),
                  size = 5, col = "white", fontface = "bold",
                  position = ggplot2::position_stack(vjust = 0.5)) +
        ggplot2::coord_flip() +
        ggplot2::labs(x = NULL, y = NULL, fill = NULL) -> gr_ingr

      ggplotly_c(gr_ingr)
    })

    output$eq_ingr_serie <- plotly::renderPlotly({
      req(input$orgao_ref)
      req(input$ingr_categoria)
      ft_orgao <- as.character(input$orgao_ref)
      ft_categ <- as.character(input$ingr_categoria)

      base_ingressos_show |>
        dplyr::filter(sg_orgao == ft_orgao, fator == ft_categ) |>
        ggplot_cat(ggplot2::aes(x = ano_ingresso, y = eq_ingresso, col = categoria)) +
        ggplot2::geom_line(linewidth = 0.8) +
        ggplot2::geom_hline(yintercept = 1, linewidth = 1) +
        ggplot2::geom_point(size = 2) +
        ggplot2::labs(x = NULL, y = NULL, col = NULL) -> gr_ingr

      ggplotly_c(gr_ingr)
    })
  })
}
