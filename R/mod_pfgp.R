#' etnia_lideranca UI Function
#'
#' @description Módulo de monitoramento do Plano Federal de Gestão de Pessoas (PFGP)
#'
#' @param id Internal parameter for {shiny}.
#' @noRd
#' @importFrom shiny NS tagList


##
# > sidebar Input ----
##
load(file = "data-raw/data_pfgp.rda")

##
# > Organiza UI input
##
mod_pfgp_ui <- function(id) {
  ns <- NS(id)
  tagList(



    # title = div(
    #   style = "width:250px;",
    #   selectInput(
    #     "ano",
    #     choices = 2018:2024
    #     )
    #   ),


    bslib::navset_card_underline(
      id = ns("nav_pfgp"),
      selected = "pfgp_1",
      sidebar = bslib::sidebar(
        shiny::selectInput(ns("orgao_ref"),
                           "Órgão",
                           choices  = c("Total",lista_orgaos),
                           selected = "Total"
                           ),

        # ==================================================================
        # INSERÇÃO DO CONDITIONAL PANEL AQUI (Dentro da Sidebar)
        # ==================================================================
        shiny::conditionalPanel(
          # Condição em JavaScript adaptada para o ecossistema de módulos
          condition = sprintf("input['%s'] == 'pfgp_1'", ns("nav_pfgp")),

          # Insira aqui o input que só deve aparecer na aba 'pfgp_1'
          shiny::selectInput(ns("ingr_categoria"),
                             "Categorias para análise de ingressos",
                             choices  = c()
                             )
          )
        ),

      # ------------------------------------------------------------------.
      # Aba 1: UI, Dimensão 1 ------
      # ------------------------------------------------------------------.
      bslib::nav_panel(
        title = "Dimensão 1: Dimensionamento\nda Força de Trabalho",
        value = "pfgp_1",
        icon  = shiny::icon("users"),
        # shiny::uiOutput(ns("kpi_boxes")),
        bslib::layout_columns(
          col_widths = c(3,9),
          bslib::card(
            bslib::card_header(
              # "Texto Markdown",
              class = "bg-primary text-white",
              # Badge no canto superior esquerdo
              tags$div(
                tags$span(
                  shiny::icon("circle-info")
                ),
                tags$span(
                  "Equidade de distribuição: servidores X distribuição demográfica na população"
                  )
                )
              ),
            bslib::card_body(
              # shiny::withMathJax(),
              tags$div(
                class = "p-3",
                style = "font-size: 1.1rem;",
                shiny::uiOutput(ns("texto_razao_equidade_ingr"))
                )
              )
            ),
          bslib::layout_columns(
            col_widths = c(12,12),
            bslib::card(
              # TÍTULO MACRO COMUM
              bslib::card_header(
                class = "bg-primary text-white",
                shiny::icon("chart-line"),
                "Análise de Equidade de Ingresso: Comparação População X APF"
              ),
              bslib::card_body(
                bslib::layout_columns(
                  col_widths = c(6, 6), # Divide o espaço ao meio

                  # Lado Esquerdo: Baseline
                  div(
                    tags$h5("Linha de Base (2023)", class = "text-muted mb-3"),
                    .spin(plotly::plotlyOutput(ns("eq_ingr_baseline"), height = "380px"))
                  ),

                  # Lado Direito: Situação Atual
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
        ),



      # ------------------------------------------------------------------.
      # Aba 2: UI, Dimensão 2 -----
      # ------------------------------------------------------------------.
      bslib::nav_panel(
        title = "Dimensão 2: Carreiras, Cargos, Progressão e Promoção",
        value = "pfgp_2",
        icon  = shiny::icon("chart-bar"),
        bslib::layout_columns(
          col_widths = c(8,4),
          bslib::layout_columns(
            col_widths = c(12,12),
            bslib::card(
              bslib::card_header(
                class = "bg-primary text-white",
                shiny::icon("chart-bar"),
                "Percentual de cargos com exercício descentralizado"
              ),
              bslib::card_body(.spin(plotly::plotlyOutput(ns("p_cargos_descent"), height = "420px")))
            ),
            bslib::card(
              bslib::card_header(
                class = "bg-primary text-white",
                shiny::icon("chart-bar"),
                "Percentual de servidores ativos em exercício descentralizado"
              ),
              bslib::card_body(.spin(plotly::plotlyOutput(ns("p_serv_descent"), height = "420px")))
            )
          ),
          bslib::layout_columns(
            bslib::card(
              bslib::card_header(
                class = "bg-primary text-white",
                shiny::icon("chart-bar"),
                "Distribuição por raça e gênero, exercícios descentralizados X não descentralizados"
              ),
              bslib::card_body(.spin(plotly::plotlyOutput(ns("dist_racagen_descent"), height = "420px")))
            )
          )
        )
      ),

      # ------------------------------------------------------------------.
      # Aba 2: UI, Dimensão 2 -----
      # ------------------------------------------------------------------.

      # bslib::nav_panel(
      #   title = "Dimensão 2: Carreiras, Cargos, Progressão e Promoção",
      #   value = "pfgp_2",
      #   icon  = shiny::icon("building"),
      #   bslib::layout_columns(
      #     col_widths = c(6, 6),
      #     bslib::card(
      #       bslib::card_header(
      #         class = "bg-primary text-white",
      #         shiny::icon("sitemap"), " Por Órgão Superior"
      #       ),
      #       # bslib::card_body(fill = FALSE, .spin(DT::DTOutput(ns("tab_superior"))))
      #     ),
      #     bslib::card(
      #       bslib::card_header(
      #         class = "bg-primary text-white",
      #         shiny::icon("building"), " Por Órgão Vinculado"
      #       )#,
      #       # bslib::card_body(fill = FALSE, .spin(DT::DTOutput(ns("tab_vinculado"))))
      #     )
      #   )
      # ),

      # ------------------------------------------------------------------.
      # Aba 4: UI, Dimensão 4 ------
      # ------------------------------------------------------------------.
      bslib::nav_panel(
        title = "Dimensão 4: Desenvolvimento e Desempenho de Pessoas e Formação de Lideranças Públicas",
        value = "pfgp_4",
        icon  = shiny::icon("balance-scale"),
        bslib::layout_columns(
          col_widths = c(6, 6),
          bslib::card(
            bslib::card_header(
              class = "bg-primary text-white",
              shiny::icon("chart-line"),
              "Evolução Mensal – % de Cargos CCE/FCE ocupados por pessoas negras"
            ),
            bslib::card_body(.spin(plotly::plotlyOutput(ns("serie_lidera_negros"), height = "380px")))
          ),
          bslib::card(
            bslib::card_header(
              class = "bg-primary text-white",
              shiny::icon("chart-line"),
              "Evolução Anual – % de Cargos CCE/FCE ocupados por mulheres"
            ),
            bslib::card_body(.spin(plotly::plotlyOutput(ns("serie_lidera_mulheres"), height = "380px")))
          ),
          bslib::card(
            bslib::card_header(
              class = "bg-primary text-white",
              shiny::icon("chart-line"),
              "Evolução Anual – % de Cargos CCE/FCE ocupados por servidores efetivos"
            ),
            bslib::card_body(.spin(plotly::plotlyOutput(ns("serie_lidera_efetivos"), height = "380px")))
          ),
          bslib::card(
            bslib::card_header(
              class = "bg-primary text-white",
              shiny::icon("chart-line"),
              "Evolução Anual – % de servidores em Cargos CCE/FCE por origem territorial"
              ),
            bslib::card_body(.spin(plotly::plotlyOutput(ns("serie_lidera_origem"), height = "380px")))
            )
          )
        )#,

      # ------------------------------------------------------------------.
      # Aba 5: ui, Dimensão 5 ------
      # ------------------------------------------------------------------.

      # bslib::nav_panel(
      #   title = "Dimensão 5: Remuneração, Benefícios, Reconhecimento e Recompensas Não Pecuniárias",
      #   value = "pfgp_5",
      #   icon  = shiny::icon("chart-bar"),
      #   bslib::card(
      #     bslib::card_header(
      #       class = "bg-primary text-white",
      #       shiny::icon("chart-bar"),
      #       " Razão de Equidade por Cor/Raça nos Cargos CCE/FCE"
      #     )#,
      #     # bslib::card_body(.spin(plotly::plotlyOutput(ns("razao_equidade"), height = "420px")))
      #   )
      # ),

      # ------------------------------------------------------------------.
      # Aba 6: ui, Dimensão 6 ------
      # ------------------------------------------------------------------.

      # bslib::nav_panel(
      #   title = "Dimensão 6: Aposentação, Pensões e Desligamentos",
      #   value = "pfgp_",
      #   icon  = shiny::icon("chart-bar"),
      #   bslib::card(
      #     bslib::card_header(
      #       class = "bg-primary text-white",
      #       shiny::icon("chart-bar"),
      #       " Razão de Equidade por Cor/Raça nos Cargos CCE/FCE"
      #     ),
      #     bslib::card_body(.spin(plotly::plotlyOutput(ns("razao_equidade"), height = "420px")))
      #   )
      # )
    )
  )
}


#' pfgp Server Functions
#'
#' @param id Internal parameter for {shiny}.
#' @noRd


##
# > Organiza SERVER output
##
mod_pfgp_server <- function(id,grafico_compartilhado) {
  shiny::moduleServer(id, function(input, output, session) {

    # -----------------------------------------------------------------.
    # Dimensão 1, server  ------
    # -----------------------------------------------------------------.


    ##
    # > Carregamento de dados ----
    ##
    base_censo  <- readRDS(here::here("data-raw/data_pfgp/base_censo.rds"))

    base_ingressos  <- readRDS(here::here("data-raw/data_pfgp/base_ingressos.rds"))


    ##
    # > Melt e totais ----
    ##

    base_censo_melt <-
      base_censo  |>
      dplyr::filter(!faixa_etaria %in% c("75 a 79 anos",
                                         "80 anos ou mais"),
                    nivel_instrucao %in% "Superior completo") |>
      data.table::melt(
        measure.vars = c("sexo","no_cor_origem_etnica","no_regiao"),
        variable.name = "fator",
        value.name = c("categoria"),
        variable.factor = F,
        value.factor = F
        ) |>
      dplyr::group_by(fator,categoria)  |>
      dplyr::summarise(popcenso = sum(populacao_adj))


    base_siape_melt <-
      base_ingressos |>
      dplyr::rename('no_regiao' = 'no_regiao_naturalidade') |>
      data.table::melt(
        measure.vars = c("sexo","no_cor_origem_etnica","no_regiao"),
        variable.name = "fator",
        value.name = c("categoria"),
        variable.factor = F,
        value.factor = F
        )  |>
      dplyr::group_by(co_orgao,sg_orgao,fator,categoria,ano_ingresso) |>
      dplyr::summarise(popsiape = sum(total))

    ##
    # > Percentuais ----
    ##

    base_censo_melt <-
      base_censo_melt |>
      dplyr::group_by(fator) |>
      dplyr::mutate(total_fator_censo = sum(popcenso)) |>
      dplyr::mutate(p_categoria_censo = round(100*popcenso/total_fator_censo,2)) |>
      dplyr::ungroup()



    base_siape_melt <-
      base_siape_melt |>
      dplyr::group_by(co_orgao,fator,ano_ingresso) |>
      dplyr::mutate(total_fator_siape = sum(popsiape)) |>
      dplyr::mutate(p_categoria_siape = round(100*popsiape/total_fator_siape,2)) |>
      dplyr::ungroup()
    base_siape_melt <- dplyr::filter(base_siape_melt,!categoria %in% c( "","NAO_SE_APLICA"))



    ##
    # > juntando ----
    ##
    base_ingressos_show <-
      dplyr::left_join(
        base_siape_melt,
        base_censo_melt,
        by = c("fator","categoria")
      ) |>
      dplyr::mutate(eq_ingresso = p_categoria_siape/p_categoria_censo)

    # 2. Extrai as categorias únicas que vão alimentar o Select
    categorias_unicas <- unique(base_ingressos_show$fator)

    # 3. Alimenta o selectInput assim que o módulo inicializa
    # Usamos o 'observe' solto no server para rodar uma vez no início
    observe({
      shiny::updateSelectInput(
        session = session,         # Obrigatório para o Shiny saber qual módulo atualizar
        inputId = "ingr_categoria",     # ATENÇÃO: Use o ID PURO da UI (sem ns("..."))
        choices = categorias_unicas,
        selected = categorias_unicas[1] # Opcional: seleciona a primeira por padrão
      )
    })


    ### > output 0: texto ----
    output$texto_razao_equidade_ingr <- shiny::renderUI({
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
      <li><strong>Hipótese analítica:</strong> na ausência de desigualdade no ingresso, a proporção de ingressantes de uma categoria deveria ser equivalente à sua proporção entre população.</li>
      <br>
      <li><strong>Definição:</strong> Razão entre o percentual de uma categoria dentre os ingressantes na APF e o percentual observado na população.</li>
      <br>
       <br>
      <li><strong>Detalhe importante:</strong> O percentual da população é obtido com base nos dados do Censo de 2022, considerando a população com 18 anos ou mais e com pelo menos o ensino superior completo. Tal recorte justifica-se pelo fato de que este recorte ocorrem em 80% da APF.</li>
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
    </ul>

      "
      shiny::withMathJax(
        # shiny::markdown(texto_md)
        shiny::HTML(texto_html)
      )

    })

    ### > output 1: baseline ----
    output$eq_ingr_baseline <- plotly::renderPlotly({
      ## filtrando no órgão de interesse
      req(input$orgao_ref)
      req(input$ingr_categoria)
      ft_orgao <- as.character(input$orgao_ref)
      ft_categ <- as.character(input$ingr_categoria)


      ## rearranjando base
      base_ingressos_show |>
        dplyr::filter(
          sg_orgao == ft_orgao,
          ano_ingresso == 2023,
          fator == ft_categ
        ) |>
        tidyr::pivot_longer(
          cols = c("p_categoria_siape", "p_categoria_censo"), # Colunas que vão derreter (measure.vars)
          names_to = "universo",                             # Nome da nova coluna de texto (variable.name)
          values_to = "p_categ"                              # Nome da nova coluna de valores (value.name)
        ) |>
        dplyr::mutate(
          p_categ = ifelse(universo == "p_categoria_censo",-p_categ,p_categ) |> round(1),
          universo = gsub("p_categoria_","",universo)
        ) -> tab_filtro

      ## gráfico
      tab_filtro |>
        ggplot_cat(aes(x = categoria,
                       y = p_categ,
                       fill = universo)) +
        geom_col(position = 'stack') +
        # ylim(c(-110,110)) +
        geom_text(aes(label = paste0(abs(p_categ),"%")),
                  size = 5,
                  # col = pal_primaria["principal"],
                  col = "white",
                  face = 'bold',
                  position = position_stack(vjust =  0.5)#,
                  # hjust = -2
        ) +
        coord_flip() +
        labs(x = NULL,
             y = NULL,
             fill = NULL)-> gr_ingr

      ggplotly_c(gr_ingr)


    })


    ### > output 2: situação atual ----
    output$eq_ingr_sit_atual <- plotly::renderPlotly({

      ## filtrando no órgão de interesse
      req(input$orgao_ref)
      req(input$ingr_categoria)
      ft_orgao <- as.character(input$orgao_ref)
      ft_categ <- as.character(input$ingr_categoria)
      max_ano <- max(base_ingressos_show$ano_ingresso)


      ## rearranjando base
      base_ingressos_show |>
        dplyr::filter(
          sg_orgao == ft_orgao,
          ano_ingresso == max_ano,
          fator == ft_categ
        ) |>
        tidyr::pivot_longer(
          cols = c("p_categoria_siape", "p_categoria_censo"), # Colunas que vão derreter (measure.vars)
          names_to = "universo",                             # Nome da nova coluna de texto (variable.name)
          values_to = "p_categ"                              # Nome da nova coluna de valores (value.name)
        ) |>
        dplyr::mutate(
          p_categ = ifelse(universo == "p_categoria_censo",-p_categ,p_categ) |> round(1),
          universo = gsub("p_categoria_","",universo)
        ) -> tab_filtro

      ## gráfico
      tab_filtro |>
        ggplot_cat(aes(x = categoria,
                       y = p_categ,
                       fill = universo)) +
        geom_col(position = 'stack') +
        # ylim(c(-110,110)) +
        geom_text(aes(label = paste0(abs(p_categ),"%")),
                  size = 5,
                  # col = pal_primaria["principal"],
                  col = "white",
                  face = 'bold',
                  position = position_stack(vjust =  0.5)#,
                  # hjust = -2
        ) +
        coord_flip() +
        labs(x = NULL,
             y = NULL,
             fill = NULL)-> gr_ingr

      ggplotly_c(gr_ingr)


    })

    ### > output 3: série ----
    output$eq_ingr_serie <- plotly::renderPlotly({

      ## filtrando no órgão de interesse
      req(input$orgao_ref)
      req(input$ingr_categoria)
      ft_orgao <- as.character(input$orgao_ref)
      ft_categ <- as.character(input$ingr_categoria)


      ## rearranjando base
      base_ingressos_show |>
        dplyr::filter(
          sg_orgao == ft_orgao,
          fator == ft_categ
        ) |>
        ggplot_cat(
          aes(
            x = ano_ingresso,
            y = eq_ingresso,
            col = categoria
          )
        ) +
        geom_line(linewidth = 0.8) +
        geom_hline(yintercept = 1,size = 1) +
        geom_point(size = 2)+
        labs(x = NULL,
             y = NULL,
             col = NULL) -> gr_ingr

      ggplotly_c(gr_ingr)

    })

    # -----------------------------------------------------------------.
    # Dimensão 4, server  ------
    # -----------------------------------------------------------------.


    ##
    # > Carregamento de dados ----
    ##
    df_liderancas  <- readRDS(here::here("data-raw/data_pfgp/df_liderancas.rds"))



    ##
    # > Série mensal % negros em CCE/FCE -----
    ##

    # Reaproveita o mesmo gráfico para mostrar na UI do Módulo B
    output$serie_lidera_negros <-  plotly::renderPlotly({
      grafico_compartilhado() # <--- Usa como se fosse um reativo local
    })

    ##
    # > Série anual % mulheres em CCE/FCE -----
    ##



    # agregando
    serie_lid_mulheres <-
      df_liderancas |>
      dplyr::filter((lideranca)) |>
      dplyr::mutate(ano = substr(MES,1,4) |> as.numeric(),
             n_fem = ifelse(NOME_SEXO %in% "Fem",n,0)) |>
      dplyr::group_by(ano,nivel_fce_cce) |>
      dplyr::summarise(n = sum(n),
                n_fem = sum(n_fem)
      ) |>
      dplyr::mutate(p_mulheres = round(100*n_fem/n,1)) |>
      dplyr::filter(ano >= 2022)

    # cat("\n\ndeu certo aqui!\n\n")

    max_p_mulheres <- max(serie_lid_mulheres$p_mulheres)


    ## output
    output$serie_lidera_mulheres <- plotly::renderPlotly({


      # objeto ggplot
      serie_lid_mulheres |>
        ggplot_cat(
          aes(x = ano,
              y = p_mulheres,
              colour = nivel_fce_cce)
          ) +
        ylim(c(0,1.2*max_p_mulheres)) +
        geom_line(linewidth = .8) +
        geom_point(size = 2) +
        labs(colour = NULL,y = "Percentual de mulheres",x = NULL) -> gr_lid_mulheres

      ggplotly_c(gr_lid_mulheres)

    })



    ##
    # > Série anual: % de cargos CCE/FCE ocupados por efetivos ----
    ##



    # agregando
    serie_lid_efetivos <-
      df_liderancas |>
      dplyr::filter((lideranca)) |>
      dplyr::mutate(ano = substr(MES,1,4) |> as.numeric(),
             n_efet = ifelse(efetivo,n,0)) |>
      dplyr::group_by(ano,nivel_fce_cce) |>
      dplyr::summarise(n = sum(n),
                n_efet = sum(n_efet)
      ) |>
      dplyr::mutate(p_efet = round(100*n_efet/n,1)) |>
      dplyr::filter(ano >= 2022)

    # cat("\n\ndeu certo aqui!\n\n")

    max_p_efet <- max(serie_lid_efetivos$p_efet)


    ## output
    output$serie_lidera_efetivos <- plotly::renderPlotly({


      # objeto ggplot
      serie_lid_efetivos |>
        ggplot_cat(
          aes(x = ano,
              y = p_efet,
              colour = nivel_fce_cce)
        ) +
        ylim(c(0,1.2*max_p_efet)) +
        geom_line(linewidth = .8) +
        geom_point(size = 2) +
        labs(colour = NULL,y = "Percentual de efetivos",x = NULL) -> gr_lid_efetivos

      ggplotly_c(gr_lid_efetivos)

    })





    ##
    # > Série anual: % de servidores efetivos em cargos FCE ----
    ##



    # agregando
    serie_origem_lid <-
      df_liderancas |>
      # dplyr::filter(efetivo) |>
      dplyr::mutate(ano = substr(MES,1,4) |> as.numeric(),
             n_lid_1a12 = ifelse(nivel_fce_cce %in% c("Níveis 1 a 12"),n,0),
             n_lid_13a18 = ifelse(nivel_fce_cce %in% c("Níveis 13 a 18"),n,0)
             ) |>
      dplyr::group_by(ano,REGIAO_NATURALIDADE) |>
      dplyr::summarise(n = sum(n),
                n_lid_1a12 = sum(n_lid_1a12),
                n_lid_13a18 = sum(n_lid_13a18)
      ) |>
      dplyr::mutate(p_lid_1a12 = round(100*n_lid_1a12/n,1),
             p_lid_13a18 = round(100*n_lid_13a18/n,1)) |>
      dplyr::filter(ano >= 2022,
             !is.na(REGIAO_NATURALIDADE))

    # cat("\n\ndeu certo aqui!\n\n")

    max_p_efet_origem <- max(serie_origem_lid$p_lid_13a18)


    ## output
    output$serie_lidera_origem <- plotly::renderPlotly({


      # objeto ggplot
      serie_origem_lid |>
        ggplot_cat(
          aes(x = ano,
              y = p_lid_13a18,
              colour = REGIAO_NATURALIDADE)
        ) +
        ylim(c(0,1.2*max_p_efet_origem)) +
        geom_line(linewidth = .8) +
        geom_point(size = 2) +
        labs(colour = NULL,y = "Percentual com FCE/CCE 13 ou maior",x = NULL) -> gr_lid_origem

      ggplotly_c(gr_lid_origem)

    })

    # -----------------------------------------------------------------.
    # Dimensão 2, server  ------
    # -----------------------------------------------------------------.


    ##
    # > Carregamento de dados ----
    ##
    tab_cargo_transversal       <- readRDS(here::here('data-raw/data_pfgp/tab_cargo_transversal.rds'))
    tab_ativo_transversal       <- readRDS(here::here('data-raw/data_pfgp/tab_ativo_transversal.rds'))
    tab_raca_genero_transversal <- readRDS(here::here('data-raw/data_pfgp/tab_raca_genero_transversal.rds'))

    ## limpeza inicial
    tab_raca_genero_transversal <- dplyr::filter(tab_raca_genero_transversal,
                                                 !no_cor_origem_etnica %in% c(NA),
                                                 !grepl("N.O INFORMADO",no_cor_origem_etnica),
                                                 N > 5)

    ## definindo ordem de raça-cor
    tab_raca_genero_transversal |>
      dplyr::group_by(no_cor_origem_etnica) |>
      dplyr::summarise(N = sum(N)) |>
      dplyr::arrange(desc(N)) |>
      dplyr::filter(N > 50) -> tot_raca


    ## outras limpezas
    tab_raca_genero_transversal <-
      tab_raca_genero_transversal|>
      dplyr::mutate(f_cor_origem_etnica = factor(no_cor_origem_etnica,
                                                 levels = tot_raca$no_cor_origem_etnica,
                                                 ordered = T),
                    nm_transv = ifelse(transversal,
                                       "Exercício Descentralizado",
                                       "Exercício Não Descentralizado"),
                    periodo = substr(compet,1,4) |> as.numeric(),
                    sexo = ifelse(co_sexo == "F","Mulheres","Homens"))

    tab_raca_genero_transversal <- tab_raca_genero_transversal |>
      dplyr::mutate(nm_transv_sexo = paste0(nm_transv,": ",sexo))



    ##
    # > Série anual: % cargos e servidores ativos com exercício descentralizado ----
    ##
    output$p_cargos_descent <- plotly::renderPlotly({

      ## filtrando no órgão de interesse
      req(input$orgao_ref)
      ft_orgao <- as.character(input$orgao_ref)

      tab_filtro <- tab_cargo_transversal |>
        dplyr::filter(sg_orgao == ft_orgao) |>
        dplyr::mutate(p_cargo_transv = round(100*n_transversais/N,2),
                      periodo = substr(compet,1,4) |> as.numeric())

      # plotando
      tab_filtro |>
        ggplot_cat(aes(x = periodo,
                       y = p_cargo_transv)) +
        ylim(c(0,1.2*max(tab_filtro$p_cargo_transv))) +
        geom_line(linewidth = 0.8) +
        geom_point(size = 2) +
        labs(colour = NULL,y = NULL,x = NULL) -> gr_cargos_descent

      ggplotly_c(gr_cargos_descent)
    })



    ##
    # > Série anual: % servidores em exercício descentralizado ----
    ##
    output$p_serv_descent <- plotly::renderPlotly({


      # servidores ativos: filtrando no órgão de interesse
      req(input$orgao_ref)
      ft_orgao <- as.character(input$orgao_ref)

      tab_filtro <- dplyr::filter(tab_ativo_transversal,
                                  sg_orgao == ft_orgao,
                                  transversal) |>
        dplyr::mutate(periodo = substr(compet,1,4) |> as.numeric(),
                      p_serv_transv = round(100*N/N_total,2))

      # plotando
      tab_filtro |>
        ggplot_cat(aes(x = periodo,
                       y = p_serv_transv,
                       col = no_sit_serv)) +
        ylim(c(0,1.2*max(tab_filtro$p_serv_transv))) +
        geom_line(linewidth = 0.8) +
        geom_point(size = 2) +
        labs(colour = NULL,y = NULL,x = NULL) -> gr_serv_descent

      ggplotly_c(gr_serv_descent)
    })



    ##
    # > Série anual: Distribuição por raça e gênero, transversal X não transversal ----
    ##
    output$dist_racagen_descent <- plotly::renderPlotly({


      ## filtrando no órgão de interesse
      req(input$orgao_ref)
      ft_orgao <- as.character(input$orgao_ref)

      if(ft_orgao != "Total"){
        tab_filtro <- dplyr::filter(tab_raca_genero_transversal,sg_orgao == ft_orgao)
      }else{
        tab_filtro <- tab_raca_genero_transversal |>
          dplyr::group_by(periodo,nm_transv,f_cor_origem_etnica,sexo,nm_transv_sexo) |>
          dplyr::summarise(N = sum(N))
      }

      # filtrando e rearranjando variáveis
      tab_filtro <- tab_filtro  |>
        dplyr::filter(periodo > 2019)

      # totais por mês e por transversal X não transversal
      tab_filtro <-
        tab_filtro |>
        dplyr::group_by(periodo,nm_transv)  |>
        dplyr::mutate(N_total = sum(N))|>
        dplyr::ungroup() |>
        dplyr::mutate(p_raca_genero = round(100*N/N_total,2))




      # gráfico
      tab_filtro |>
        ggplot_cat(
          aes(x = periodo,
              y = p_raca_genero,
              col = f_cor_origem_etnica
              )
          ) +
        geom_line(linewidth = 0.8) +
        geom_point(size = 2) +
        labs(col = NULL,
             y = "Percentual de Raça e Gênero",
             x = NULL) +
        facet_wrap(nm_transv_sexo ~.) -> gr_racagenero_descent

      ggplotly_c(gr_racagenero_descent)

    })
  })

  }

