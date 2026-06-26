# ==============================================================================
# utils_pfgp.R
# Helpers de visualização para o módulo PFGP
# Extraído de data/setup_rmd.R para disponibilização no pacote
# ==============================================================================

### opções de tamanhos de texto dos itens (eixo, legendas, etc)
txt_size <- 9

# Paletas de cores
.pal_primaria <- c(
  azul = "#0000AA",
  ponto     = "#FF7800",
  principal = "#00A100"
)

.pal_complementar <- c(
  .pal_primaria,
  "#FFCE08", "#EE3A79", "#37C2D5", "#C13C01", "#9B83D9"
)


# Scales ggplot2
.plot_fill_cat   <- ggplot2::scale_fill_manual(values = unname(.pal_complementar))
.plot_color_cat  <- ggplot2::scale_color_manual(values = unname(.pal_complementar))
.plot_fill_cont  <- ggplot2::scale_fill_gradient(high = "#006401", low = "#CDFFCC")
.plot_color_cont <- ggplot2::scale_colour_gradient(high = "#006401", low = "#CDFFCC")
.plot_fill_cont2  <- ggplot2::scale_fill_gradient(high = "#0000AA", low = "#FFFFFF")
.plot_color_cont2 <- ggplot2::scale_colour_gradient(high = "#0000AA", low = "#FFFFFF")

# Tema base
.txt_size <- 9L

.plot_config <-
  ggplot2::theme_minimal(base_family = "") +
  ggplot2::theme(
    plot.title        = ggplot2::element_text(size = 15, face = "bold",
                                              color = .pal_primaria[1], hjust = 0),
    plot.subtitle     = ggplot2::element_text(size = .txt_size, color = "grey40",
                                              margin = ggplot2::margin(b = 25)),
    plot.caption      = ggplot2::element_text(size = .txt_size, color = "grey60",
                                              margin = ggplot2::margin(t = 20)),
    legend.position   = "bottom",
    legend.title      = ggplot2::element_text(size = .txt_size, face = "bold"),
    legend.text       = ggplot2::element_text(size = .txt_size),
    panel.grid.minor       = ggplot2::element_blank(),
    panel.grid.major.x     = ggplot2::element_blank(),
    axis.title        = ggplot2::element_text(size = .txt_size),
    axis.text         = ggplot2::element_text(size = .txt_size, color = "#555555"),
    strip.text.x.top  = ggplot2::element_text(color = "#0000aa", size = .txt_size)
  )

# ggplot com tema Gov.br — sem scales manuais para compatibilidade com ggplotly()
ggplot_cat <- function(...) {
  ggplot2::ggplot(...)+
    .plot_fill_cat +
    .plot_color_cat  +
    .plot_config
}

# Converte ggplot para plotly limpando nomes duplicados na legenda
ggplotly_c <- function(gg_obj){
  seen <- c()
  ptly_obj <- plotly::ggplotly(gg_obj)
  ptly_obj$x$data <- lapply(ptly_obj$x$data, function(tr) {
    if (is.null(tr$name)) return(tr)
    nm <- gsub("^\\(|\\)$","",tr$name)
    nm <- gsub(",([0-9]|NA)", "", nm)
    if (length(nm) == 0L) return(tr)

    if(nm %in% seen){
      tr$showlegend  <- FALSE
    }else{
      tr$name <- nm
      seen <<- c(seen,tr$name)
    }
    tr
  })
  ptly_obj
}



# 'NOVO' ggplot para escala de cores contínuoas
.likert_values <- c("Discordo totalmente" = "#CA0020",
                    "Discordo" = "#F4A582",
                    "Não concordo nem discordo" =  "#F7F7F7",
                    "Concordo" = "#92C5DE",
                    "Concordo totalmente" = "#0571B0")


ggplot_likert <- function(...){
  ggplot2::ggplot(...) +
    ggplot2::scale_fill_manual(values = .likert_values) +
    ggplot2::theme_minimal() +
    ggplot2::theme(text = ggplot2::element_text(size = txt_size),
                   legend.position = "bottom",
                   legend.direction = "horizontal") #+

    # ajustando a legenda
    # theme(
    #   legend.position = c(0.3, -0.07)  # ajusta aqui
    # )
}


# quebras na escala y (para escala de likert)
quebras_y <- seq(0,100,25)
labels_y  <- paste0(quebras_y,"%")




# função para criar gráfico de respostas ao item
likert_vozes <- function(etl_dt,q,concordancia = F,colsby = NULL){
  # parar se colsby tiver mais de uma variável
  if(length(colsby) > 1) stop("escolha apenas uma variável em colsby")


  # agrupando
  etl_dt |>
    dplyr::filter(cod_item %in% q) |>
    dplyr::group_by(
      across(
        all_of(
          c(colsby)
          )
        ),
      cod_item,item.q2,opcao,opcao.f) |>
    dplyr::summarise(N = sum(N)) |>
    dplyr::ungroup() |>
    dplyr::group_by(
      across(
        all_of(
          c(colsby)
          )
        ),
      cod_item) |>
    dplyr::mutate(p = 100*N/sum(N)) |>
    dplyr::ungroup() -> etl_filter

  # alterações para concordancia = T ou com algum colsby
  if(concordancia | !is.null(colsby)){
    # define a posição das colunas a depender e concordancia e colsby
    posicao_barras <- position_dodge()

    # define a posição das labels a depender da concordancia e colsby
    posicao_texto <- position_dodge(width = 0.9)


    # setando nomes das colunas em 'colsby'
    if(!is.null(colsby)){
      setnames(etl_filter,colsby,'colsby')
      etl_filter <- dplyr::filter(etl_filter,!colsby %in% c(NA,""))
      etl_filter <- dplyr::mutate(etl_filter,opcao.f = as.character(colsby))
    }else{
      etl_filter <- dplyr::mutate(etl_filter,opcao.f = 'Concordância')
    }

    #  novo agrupamento
    etl_filter <-
      etl_filter |>
      dplyr::filter(opcao %in% c(4,5)) |>
      dplyr::group_by(opcao.f,cod_item,item.q2) |>
      dplyr::summarise(N = sum(N),
                       p = sum(p)) |>
      dplyr::ungroup()


    # plot base
    p_base <-
      # iniciando ggplot
      etl_filter |>
      ggplot_cat(aes(x = item.q2,
                     fill = opcao.f,
                     y = p))



  }else{

    # define a posição das colunas a depender da concordancia e colsby
    posicao_barras <- position_stack(reverse = T)

    # define a posição das labels a depender da concordancia e colsby
    posicao_texto <- position_stack(reverse = T,vjust = 0.5)

    # plot base
    p_base <-
      # iniciando ggplot
      etl_filter |>
      ggplot_likert(aes(x = item.q2,
                        fill = opcao.f,
                        y = p))

  }

  p_base +

    # criando colunas empilhadas
    geom_col(position = posicao_barras) +

    # incluindo labels com os % (se maiores que 5%)
    geom_text(
      aes(
        label = ifelse(p < 5,
                       "",
                       paste0(round(p,0),"%")
        ),
        group = opcao.f
      ),
      position = posicao_texto,
      hjust = ifelse(concordancia | !is.null(colsby),-0.2,0.5)
    ) +

    # eixos sem títulos
    labs(x = "",y = "",fill = "") +

    # labels e quebras do eixo y
    scale_y_continuous(breaks = quebras_y,labels = labels_y) +

    # 'girando' gráfico
    coord_flip() -> p

  return(p)
}

