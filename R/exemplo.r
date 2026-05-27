library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)
library(DT)

# ==========================================
# 1. BASE DE DADOS FICTÍCIOS E METADADOS
# ==========================================

# Histórico fictício de evolução (2023 a 2026)
dados_historicos <- data.frame(
  Ano = c(2023, 2024, 2025, 2026),
  Total_Vinculos_Pretos_Pardos = c(120000, 122000, 125000, 128000),
  Perc_Lideranca = c(18.5, 22.1, 26.8, 30.5), # Meta é 30% até 2026
  Orcamento_Capacitacao = c(120000, 280000, 410000, 500000),
  Cargos_Lideranca_Total = c(8500, 8600, 8550, 8620),
  Acoes_Capacitacao = c(12, 25, 40, 45),
  Qtd_Nomeados_CCE_FCE = c(1572, 1900, 2291, 2629),
  Desigualdade_Salarial = c(15.4, 14.2, 12.8, 11.1),
  Gini_Remuneracao = c(0.45, 0.43, 0.41, 0.39)
)

# Dicionário dos Indicadores baseado no Modelo Lógico fornecido
tabela_indicadores <- data.frame(
  Item = c("1.2", "1.2", "1.2", "1.2", "1.2", "1.2", "1.2", "1.2", "1.2"),
  Fase = c("Caracterização da População", "Dimensionamento do Problema", "Insumos", "Insumos", "Atividades", "Produtos", "Resultados", "Impactos", "Impactos"),
  Indicador = c(
    "Total de vínculos ativos de pardos e pretas na APF",
    "Percentual de pretos e pardos que ocupam cargos de liderança",
    "Orçamento executado para capacitação e sensibilização de gestores sobre o Decreto 11.443/23",
    "Número de cargos de liderança disponíveis (ocupados/vagos)",
    "Ações de capacitação e sensibilização de gestores sobre o Decreto 11.443/23",
    "Quantidade de pessoas pretas e pardas nomeadas em cargos CCE e FCE de níveis 13 a 17",
    "Percentual de cargos de liderança ocupados por pessoas pretas e pardas (Meta: 30% até 2026)",
    "Desigualdade salarial média entre raças na administração pública federal",
    "Índice de Gini da remuneração na administração pública federal"
  ),
  Frequencia = c("Mensal", "Mensal", "Semestral", "Mensal", "Trimestral", "Mensal", "Anual", "Quadrienal", "Quadrienal"),
  Fonte = c("MGI / Sistema SIAPE", "MGI / Sistema SIAPE", "Órgão Setorial / MIR / MGI", "MGI / Sistema SIAPE", "Unidades de Gestão de Pessoas", "MGI / Sistema SIAPE", "MGI / Sistema SIAPE", "MGI / Sistema SIAPE", "MGI / Sistema SIAPE"),
  Dificuldade = c("Baixa", "Baixa", "Alta", "Moderada", "Alta", "Baixa", "Baixa", "Baixa", "Baixa"),
  Status = c("Sugerido", "Sugerido", "Sugerido", "Calculado", "Sugerido", "Calculado", "Calculado", "Sugerido", "Sugerido")
)

# ==========================================
# 2. INTERFACE DO USUÁRIO (UI)
# ==========================================
ui <- dashboardPage(
  skin = "black",
  dashboardHeader(title = "Monitoramento de Cotas"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Visão Geral", tabName = "visao_geral", icon = icon("dashboard")),
      menuItem("Evolução Temporal", tabName = "graficos", icon = icon("chart-line")),
      menuItem("Estrutura do Modelo Lógico", tabName = "modelo_logico", icon = icon("sitemap")),
      menuItem("Base de Dados", tabName = "dados", icon = icon("table"))
    ),
    hr(),
    div(style = "padding: 20px; color: #b8c7ce;",
        p(strong("Referência:")),
        p("Decreto nº 11.433/2023"),
        p("Cotas para cargos de liderança na APF.")
    )
  ),
  
  dashboardBody(
    tabItems(
      # Aba 1: Visão Geral (Cards e Resumos)
      tabItem(tabName = "visao_geral",
        h2("Painel de Monitoramento - Cotas para Cargos de Liderança"),
        p("Acompanhamento das diretrizes de diversidade e inclusão baseadas no Decreto nº 11.433/2023."),
        br(),
        
        fluidRow(
          valueBox(paste0(dados_historicos$Perc_Lideranca[4], "%"), "Ocupação Atual (2026)", icon = icon("users"), color = "purple"),
          valueBox("30.0%", "Meta do Decreto (Até 2026)", icon = icon("target", lib = "glyphicon"), color = "green"),
          valueBox(paste0("R$ ", format(dados_historicos$Orcamento_Capacitacao[4], big.mark=".")), "Orçamento Executado (2026)", icon = icon("dollar-sign"), color = "blue")
        ),
        
        fluidRow(
          box(
            title = "Status da Meta Alcançada", width = 12, status = "success", solidHeader = TRUE,
            p(strong("Parabéns!"), " De acordo com os dados simulados para 2026, a meta de 30% de pretos e pardos em cargos de liderança (CCE e FCE 13 a 17) foi atingida, registrando um valor de ", span(strong(paste0(dados_historicos$Perc_Lideranca[4], "%")), style="color:green"), ".")
          )
        )
      ),
      
      # Aba 2: Gráficos de Evolução Temporal
      tabItem(tabName = "graficos",
        h2("Análise Temporal dos Indicadores (2023 - 2026)"),
        fluidRow(
          box(
            title = "Evolução da Representatividade na Liderança (%)", width = 6, status = "primary",
            plotOutput("plot_percentual")
          ),
          box(
            title = "Orçamento de Capacitação vs. Ações Realizadas", width = 6, status = "primary",
            plotOutput("plot_insumos")
          )
        ),
        fluidRow(
          box(
            title = "Redução do Índice de Gini de Remuneração (Impacto de Longo Prazo)", width = 6, status = "info",
            plotOutput("plot_gini")
          ),
          box(
            title = "Evolução Nominal de Nomeações (CCE e FCE 13 a 17)", width = 6, status = "info",
            plotOutput("plot_nomeacoes")
          )
        )
      ),
      
      # Aba 3: Estrutura do Modelo Lógico
      tabItem(tabName = "modelo_logico",
        h2("Indicadores por Fase do Modelo Lógico"),
        fluidRow(
          box(
            title = "Filtro por Fase", width = 4, status = "warning",
            selectInput("filtro_fase", "Escolha a Fase do Modelo Lógico:", 
                        choices = c("Todos", unique(tabela_indicadores$Fase)), selected = "Todos")
          )
        ),
        fluidRow(
          box(title = "Metadados dos Indicadores Propostos", width = 12, status = "primary", solidHeader = TRUE,
              DTOutput("tabela_modelo_logico")
          )
        )
      ),
      
      # Aba 4: Base de Dados Completa (Fictícia)
      tabItem(tabName = "dados",
        h2("Dados Históricos Consolidados (Fictícios)"),
        p("Tabela contendo os valores simulados ano a ano para cada indicador para fins de teste de interface:"),
        fluidRow(
          box(width = 12, status = "primary",
              DTOutput("tabela_dados_brutos")
          )
        )
      )
    )
  )
)

# ==========================================
# 3. LÓGICA DO SERVIDOR (SERVER)
# ==========================================
server <- function(input, output, session) {
  
  # Gráfico 1: Percentual de Liderança
  output$plot_percentual <- renderPlot({
    ggplot(dados_historicos, aes(x = Ano, y = Perc_Lideranca)) +
      geom_line(color = "#605ca8", size = 1.2) +
      geom_point(color = "#605ca8", size = 3) +
      geom_hline(yintercept = 30, linetype = "dashed", color = "red", size = 1) +
      annotate("text", x = 2024, y = 31, label = "Linha de Meta (30%)", color = "red") +
      labs(x = "Ano", y = "Percentual (%)", title = "% de Pretos e Pardos em Cargos de Liderança") +
      theme_minimal()
  })
  
  # Gráfico 2: Orçamento vs Capacitação
  output$plot_insumos <- renderPlot({
    ggplot(dados_historicos, aes(x = Ano, y = Orcamento_Capacitacao)) +
      geom_bar(stat = "identity", fill = "#3c8dbc", alpha = 0.8) +
      geom_text(aes(label = paste0("Ações: ", Acoes_Capacitacao)), vjust = -0.5, color = "black") +
      labs(x = "Ano", y = "Orçamento Executado (R$)", title = "Orçamento e Número de Ações de Capacitação") +
      theme_minimal()
  })
  
  # Gráfico 3: Índice de Gini
  output$plot_gini <- renderPlot({
    ggplot(dados_historicos, aes(x = Ano, y = Gini_Remuneracao)) +
      geom_line(color = "#dd4b39", size = 1.2) +
      geom_point(color = "#dd4b39", size = 3) +
      labs(x = "Ano", y = "Índice de Gini", title = "Tendência do Índice de Gini na Remuneração da APF") +
      theme_minimal()
  })
  
  # Gráfico 4: Evolução Absoluta de Nomeações
  output$plot_nomeacoes <- renderPlot({
    ggplot(dados_historicos, aes(x = Ano, y = Qtd_Nomeados_CCE_FCE)) +
      geom_line(color = "#00a65a", size = 1.2) +
      geom_point(color = "#00a65a", size = 3) +
      labs(x = "Ano", y = "Quantidade de Pessoas", title = "Total Absoluto de Pretos/Pardos em CCE/FCE (13 a 17)") +
      theme_minimal()
  })
  
  # Tabela Filtrável do Modelo Lógico
  output$tabela_modelo_logico <- renderDT({
    dados_filtrados <- tabela_indicadores
    if (input$filtro_fase != "Todos") {
      dados_filtrados <- dados_filtrados %>% filter(Fase == input$filtro_fase)
    }
    datatable(dados_filtrados, options = list(pageLength = 5, scrollX = TRUE), rownames = FALSE)
  })
  
  # Tabela com Dados Brutos Fictícios
  output$tabela_dados_brutos <- renderDT({
    datatable(dados_historicos, options = list(pageLength = 5, scrollX = TRUE), rownames = FALSE)
  })
}

# Executar o Aplicativo Shiny
shinyApp(ui = ui, server = server)