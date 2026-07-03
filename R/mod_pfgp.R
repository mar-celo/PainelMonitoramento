#' pfgp UI Function — Orquestrador das 6 Dimensões do PFGP
#'
#' @description Módulo de monitoramento do Plano Federal de Gestão de Pessoas (PFGP).
#'   Cada dimensão é implementada em seu próprio módulo (mod_pfgp_dim1.R … mod_pfgp_dim6.R).
#'
#' @param id Internal parameter for {shiny}.
#' @noRd
#' @importFrom shiny NS tagList

mod_pfgp_ui <- function(id) {
  ns <- NS(id)
  tagList(
    bslib::navset_card_underline(
      id       = ns("nav_pfgp"),
      selected = "pfgp_1",

      bslib::nav_panel(
        title = "Dimensão 1: Dimensionamento da Força de Trabalho",
        value = "pfgp_1",
        icon  = shiny::icon("users"),
        mod_pfgp_dim1_ui(ns("dim1"))
      ),

      bslib::nav_panel(
        title = "Dimensão 2: Carreiras, Cargos, Progressão e Promoção",
        value = "pfgp_2",
        icon  = shiny::icon("chart-bar"),
        mod_pfgp_dim2_ui(ns("dim2"))
      ),

      bslib::nav_panel(
        title = "Dimensão 3: Alocação, Ambientação, Estágio Probatório e Bem-Estar",
        value = "pfgp_3",
        icon  = shiny::icon("seedling"),
        mod_pfgp_dim3_ui(ns("dim3"))
      ),

      bslib::nav_panel(
        title = "Dimensão 4: Desenvolvimento e Desempenho de Pessoas e Formação de Lideranças",
        value = "pfgp_4",
        icon  = shiny::icon("balance-scale"),
        mod_pfgp_dim4_ui(ns("dim4"))
      ),

      bslib::nav_panel(
        title = "Dimensão 5: Remuneração, Benefícios e Reconhecimento",
        value = "pfgp_5",
        icon  = shiny::icon("coins"),
        mod_pfgp_dim5_ui(ns("dim5"))
      ),

      bslib::nav_panel(
        title = "Dimensão 6: Aposentação, Pensões e Desligamentos",
        value = "pfgp_6",
        icon  = shiny::icon("door-open"),
        mod_pfgp_dim6_ui(ns("dim6"))
      )
    )
  )
}

#' pfgp Server Function
#' @param id Internal parameter for {shiny}.
#' @param grafico_compartilhado Reactive que retorna o gráfico de % negros em CCE/FCE
#'   gerado em mod_etnia_lideranca_server (reutilizado na Dimensão 4).
#' @noRd
mod_pfgp_server <- function(id, grafico_compartilhado) {
  shiny::moduleServer(id, function(input, output, session) {

    pfgp_vozes_itens <- readRDS(here::here("data-raw/data_pfgp/pfgp_vozes_itens.rds"))
    etl_vozes1       <- readRDS(here::here("data-raw/data_pfgp/etl_vozes1.rds"))
    etl_vozes2       <- readRDS(here::here("data-raw/data_pfgp/etl_vozes2.rds"))

    ## indicador 'compartilhado' 1: justiça remuneratória
    render_vozes <- function(nm_indicador){
      reactive({


        # 1. filtrando itens correspondentes a 'justiça remuneratória'
        pfgp_filter <- pfgp_vozes_itens |> dplyr::filter(indicador == nm_indicador)

        # 2. criando objetos ggplot
        p_v1 <- likert_vozes(etl_dt = etl_vozes1,q = pfgp_filter$cod_item_vozes1,concordancia = F,colsby = NULL)
        p_v2 <- likert_vozes(etl_dt = etl_vozes2,q = pfgp_filter$cod_item_vozes2,concordancia = F,colsby = NULL)

        # 3. Juntar lado a lado de forma nativa e segura para o Deploy
        tem_fig1 <- !all(is.na(pfgp_filter$cod_item_vozes1)) # Ou sua lógica de validação de dados
        tem_fig2 <- !all(is.na(pfgp_filter$cod_item_vozes2))

        # ---- CASO 1: Ambos os gráficos possuem dados ----
        if (tem_fig1 && tem_fig2) {

          # 4.1 criando objetos ggplotly com subplot
          fig1 <- ggplotly_c(p_v1)
          fig2 <- ggplotly_c(p_v2)

          fig_final <- plotly::subplot(
            fig1, fig2,
            nrows = 1,
            margin = 0.05,
            titleX = TRUE,
            titleY = TRUE
          ) |>
            plotly::layout(
              showlegend = FALSE,
              autosize = TRUE,
              margin = list(t = 40),
              annotations = list(
                list(
                  x = 0.22, # Alinhado na esquerda (22%)
                  y = 1.05,
                  text = "<b>Vozes 1</b>",
                  showarrow = FALSE,
                  xref = "paper", yref = "paper",
                  font = list(size = 14)
                ),
                list(
                  x = 0.78, # Alinhado na direita (78%)
                  y = 1.05,
                  text = "<b>Vozes 2</b>",
                  showarrow = FALSE,
                  xref = "paper", yref = "paper",
                  font = list(size = 14)
                )
              )
            )

          # ---- CASO 2: Apenas o Gráfico 1 possui dados ----
        } else if (tem_fig1) {

          # 4.2 criando objetos ggplotly SEM subplot
          fig_final <- ggplotly_c(p_v1) |>
            plotly::layout(
              showlegend = FALSE,
              autosize = TRUE,
              margin = list(t = 40),
              annotations = list(
                list(
                  x = 0.50, # O PULO DO GATO: Centralizado perfeitamente no meio (50%)
                  y = 1.05,
                  text = "<b>Vozes 1</b>",
                  showarrow = FALSE,
                  xref = "paper", yref = "paper",
                  font = list(size = 14)
                )
              )
            )

          # ---- CASO 3: Apenas o Gráfico 2 possui dados ----
        } else if (tem_fig2) {

          # 4.3 criando objetos ggplotly SEM subplot
          fig_final <- ggplotly_c(p_v2) |>
            plotly::layout(
              showlegend = FALSE,
              autosize = TRUE,
              margin = list(t = 40),
              annotations = list(
                list(
                  x = 0.50, # Centralizado perfeitamente no meio (50%)
                  y = 1.05,
                  text = "<b>Vozes 2</b>",
                  showarrow = FALSE,
                  xref = "paper", yref = "paper",
                  font = list(size = 14)
                )
              )
            )

          # ---- CASO 4: Nenhum gráfico possui dados ----
        } else {
          # Retorna um painel vazio amigável para não estourar erro na tela do usuário
          fig_final <- plotly::plotly_empty() |>
            plotly::layout(
              title = list(text = "Sem dados disponíveis para este indicador", font = list(size = 14))
            )
        }

        fig_final

      })
    }


    mod_pfgp_dim1_server("dim1")

    mod_pfgp_dim2_server("dim2",
                         reac_justica_remun = render_vozes("Percepção de justiça remuneratória"),
                         reac_criterios_promo = render_vozes("Percepções sobre critérios de promoção"))

    mod_pfgp_dim3_server("dim3",
                         reac_seguranca_psico = render_vozes("Percepção de segurança psicológica"))

    mod_pfgp_dim4_server("dim4",
                         grafico_compartilhado = grafico_compartilhado,
                         reac_capacitacao = render_vozes("Oportunidade de capacitação"),
                         reac_desemp_equipe = render_vozes("Percepção de desempenho de equipe"),
                         reac_desemp_org = render_vozes("Percepção de desempenho organizacional"))

    mod_pfgp_dim5_server("dim5",
                         reac_justica_remun = render_vozes("Percepção de justiça remuneratória"),
                         reac_engaja_trab = render_vozes("Percepção de engajamento no trabalho"),
                         reac_satisf_trab = render_vozes("Satisfação no trabalho"),
                         reac_inten_saida = render_vozes("Intenção de saída / permanência")
                         )

    mod_pfgp_dim6_server("dim6")


    })
}
