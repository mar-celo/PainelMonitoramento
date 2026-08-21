# ==============================================================================.
# A. CONFIGURAÇÕES INICIAIS E BIBLIOTECAS -------
# ==============================================================================.


rm(list = ls()); gc()

# abre pacotes-------------------------------------------------------------

library(dplyr)
library(data.table)
library(stringr)
library(janitor)
library(readxl)
library(fuzzyjoin)

# função para quebra de textos em gráficos (chatGPT)
quebra_texto2 <- function(texto, largura_max = 40, aplicar_se_maior = 40) {

  if (nchar(texto) <= aplicar_se_maior) {
    return(texto)
  }

  return(paste(strwrap(texto, width = largura_max), collapse = "\n"))
}

# diretório oneDrive -----------------------------------------------------------
dir_onedrive <- "C:/Users/wesley.jesus/OneDrive - Ministério da Gestão e da Inovação dos Serv. Pub/"

# diretórios Vozes -------------------------------------------------------------

## diretório Vozes 1: pegando versão usada no painel
dir_vozes1 <- file.path(dir_onedrive,"DIGID - Pesquisa Vozes SP/Painel de Dados")


## diretório Vozes 2: pegando versão pseudoanonimizada
dir_vozes2 <- file.path(dir_onedrive,"DIGID - Pesquisa Vozes SP/Vozes 2/Analise de dados/dados estruturados")


# ==============================================================================.
# B. Carregando dados  e dicionários -------
# ==============================================================================.

## Dados Vozes 1
data_vozes1 <- read_excel(
  file.path(
    dir_vozes1,
    "tb_dados_vozes1_multiplas.xlsx"
    )
  ) |>
  setDT()

## Dicionário Vozes 1
dicio_vozes1 <- read_excel(
  file.path(
    dir_vozes1,
    "tb_auxiliares.xlsx"
  ),
  sheet = "temas",
  skip = 1) |>
  setDT() |>
  janitor::clean_names()

# setando algumas infos na Vozes 1
dicio_vozes1[,item_review := gsub("^(Pensando.*\\?)","",item) %>% str_trim()]
dicio_vozes1[,item_review := gsub("APOIO.*AMIGOS.*","Redes de relacionamento",item_review)]

## Vozes 2
load(file = file.path(dir_vozes2,"vozes2_microdados_estruturados.rda"))
assign("data_vozes2",data_vozes2_unindent);rm(data_vozes2_unindent);gc()


## Indicadores PFGP
ind_pfgp <- read_excel(
  file.path(dir_onedrive,
  "Documentos/Monitoramento_politicas_SGP/plataforma_pfgp_indicadores.xlsx"
  ),
  sheet = "Indicadores PFGP"
  ) |>
  setDT() |>
  janitor::clean_names() |>
  setnames("esta_na_apresentacao_pfgp_2030_02_06_todos",
           "no_pfgp_2030")



# ==============================================================================.
# C. Relação entre indicadores e questões -------
# ==============================================================================.

### filtro PFGP
ind_pfgp <-
  ind_pfgp |>
  filter(grepl("sim",no_pfgp_2030,ignore.case = T),
         grepl("vozes",fonte,ignore.case = T),
         status != 'Mapear fonte')


### separando perguntas listadas
ind_pfgp[,.(pergunta = str_split(descricao,";") |>
              unlist() |>
              str_trim()),
         .(id_indicador,indicador_novo,no_pfgp_2030,fonte)] |>
  unique() -> pfgp_vozes_itens

### Fuzzy join 1: indicadores pfgp X indicadores Vozes 1
pfgp_vozes1_questoes <-
  stringdist_left_join(
    pfgp_vozes_itens,
    dicio_vozes1[,.(item_review, questao_base)],
    distance_col = 'dist',
    method = "cosine",
    q = 6,
    max_dist = 0.5,
    ignore_case = T,
    by = c("pergunta" = "item_review")
  ) |>
  setorder(pergunta,dist) |>
  group_by(pergunta) |>
  slice_head(n=1) |>
  ungroup() |>
  setDT() |>
  setnames(c('item_review','questao_base'),
           c('item_vozes1','cod_item_vozes1')
           )


### Fuzzy join 2: indicadores pfgp X indicadores Vozes 2
pfgp_vozes2_questoes <-
  stringdist_left_join(
    pfgp_vozes_itens,
    dicio_vozes2[,.(item,cod_item,questao)],
    distance_col = 'dist',
    method = "cosine",
    q = 6,
    max_dist = 0.5,
    ignore_case = T,
    by = c("pergunta" = "item")
  ) |>
  setorder(pergunta,dist) |>
  group_by(pergunta) |>
  slice_head(n=1) |>
  ungroup() |>
  setDT() |>
  setnames(c('item','cod_item'),
           c('item_vozes2','cod_item_vozes2')
  )

pfgp_vozes_itens <- left_join(pfgp_vozes_itens,
                              pfgp_vozes1_questoes,
                              by = names(pfgp_vozes_itens)) |>
  left_join(pfgp_vozes2_questoes,
            by = names(pfgp_vozes_itens))




# ==============================================================================.
# D. ETL com base na VOZES -------
# ==============================================================================.



### Vozes 1

## colunas para agregar
colsby <- c("co_sexo",
            "co_pgd",
            "co_cor_origem_etnica",
            "co_geracao...11")

## agregando
etl_vozes1 <-
  data_vozes1 %>%
  melt(id.vars = c(colsby),
       measure.vars = pfgp_vozes_itens$cod_item_vozes1 %>% na.omit(),
       variable.name = "cod_item",
       value.name = "opcao",
       na.rm = T) %>%
  .[,.(.N),
    by = c(colsby,"cod_item","opcao")] %>%
  .[,cod_questao := str_extract_all(cod_item,"^q[0-9]{1,2}") %>% unlist] %>%

  # inserindo enunciado do item
  left_join(dicio_vozes1[,.(questao_base,item_review)],
            by = c("cod_item" = "questao_base")) %>%
  setnames("item_review","item")


## Padronizando categorias

cor_origem_etnica <-
  c("Branca",
    "Amarela",
    "Indigena",
    "Parda",
    "Preta")

geracao.v <-
  c("Z",
    "Milenium",
    "X",
    "Boomers")

etl_vozes1[,`:=`(
  CO_SEXO = ifelse(co_sexo == 1,"Fem","Masc"),
  NO_COR_ORIGEM_ETNICA = cor_origem_etnica[co_cor_origem_etnica],
  in_pgd = ifelse(co_pgd == 1,"Sim","Não"),
  geracao = geracao.v[co_geracao...11])
  ]

etl_vozes1 <- select(etl_vozes1,-one_of(colsby))

## 'quebrando' enunciados
etl_vozes1[,`:=`(
  item.q2 = sapply(item,quebra_texto2,largura_max = 20,aplicar_se_maior = 20) %>%
    str_to_title()
  )]

### Vozes 2
colsby <- c("CO_SEXO",
            "in_pgd",
            "NO_COR_ORIGEM_ETNICA",
            "geracao")


etl_vozes2 <-
  data_vozes2 %>%
  melt(id.vars = c(colsby),
       measure.vars = pfgp_vozes_itens$cod_item_vozes2 %>% na.omit(),
       variable.name = "cod_item",
       value.name = "opcao",
       na.rm = T) %>%
  .[,.(.N),
    by = c(colsby,"cod_item","opcao")] %>%
  .[,cod_questao := str_extract_all(cod_item,"^q[0-9]{1,2}") %>% unlist]%>%

  # inserindo enunciado do item
  left_join(dicio_vozes2[,.(cod_item,item)],
            by = c("cod_item"))


## 'quebrando' enunciados
etl_vozes2[,`:=`(
  item.q2 = sapply(item,quebra_texto2,largura_max = 20,aplicar_se_maior = 20) %>%
    str_to_title()
  )]



## Padronizando categorias

etl_vozes2[,`:=`(
  CO_SEXO = ifelse(CO_SEXO == "F","Fem","Masc"),
  NO_COR_ORIGEM_ETNICA = str_to_title(NO_COR_ORIGEM_ETNICA),
  in_pgd = ifelse(in_pgd,"Sim","Não"))
]





# ==============================================================================.
# E. SALVANDO ETL E DICIONÁRIOS -------
# ==============================================================================.

saveRDS(etl_vozes1,
        "data-raw/data_pfgp/etl_vozes1.rds")

saveRDS(etl_vozes2,
        "data-raw/data_pfgp/etl_vozes2.rds")

saveRDS(pfgp_vozes_itens,
        "data-raw/data_pfgp/pfgp_vozes_itens.rds")
