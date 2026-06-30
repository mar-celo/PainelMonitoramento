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

    ## indicador 'compartilhado' 1: justiça remuneratória
    render_vozes <- function(nm_indicador){
      reactive({


        # 1. filtrando itens correspondentes a 'justiça remuneratória'
        pfgp_filter <- pfgp_vozes_itens |> dplyr::filter(indicador == nm_indicador)

        # 2. criando objetos ggplot
        p_v1 <- likert_vozes(etl_dt = etl_vozes1,q = pfgp_filter$cod_item_vozes1,concordancia = F,colsby = NULL)
        p_v2 <- likert_vozes(etl_dt = etl_vozes2,q = pfgp_filter$cod_item_vozes2,concordancia = F,colsby = NULL)

        # 3. criando objetos ggplotly
        fig1 <- ggplotly_c(p_v1)
        fig2 <- ggplotly_c(p_v2)


        # 4. Juntar lado a lado de forma nativa e segura para o Deploy
        plotly::subplot(
          fig1, fig2,
          nrows = 1,          # Uma linha (lado a lado)
          margin = 0.05,       # Espaço entre os dois gráficos
          titleX = TRUE,      # Mantém os títulos dos eixos X
          titleY = TRUE       # Mantém os títulos dos eixos Y
        )  |>
          plotly::layout(
            showlegend = FALSE, # Remove legendas duplicadas se houver
            autosize = TRUE,
            # O PULO DO GATO: Criamos dois títulos falsos usando coordenadas da tela
            annotations = list(
              list(
                x = 0.22, # Centralizado no primeiro gráfico (22% da largura)
                y = 1.05, # Levemente acima do topo do gráfico
                text = "<b>Vozes 1</b>", # Tag HTML para negrito
                showarrow = FALSE,
                xref = "paper", yref = "paper",
                font = list(size = 14)
              ),
              list(
                x = 0.78, # Centralizado no segundo gráfico (78% da largura)
                y = 1.05,
                text = "<b>Vozes 2</b>",
                showarrow = FALSE,
                xref = "paper", yref = "paper",
                font = list(size = 14)
              )
            )
          ) -> fig_final

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
