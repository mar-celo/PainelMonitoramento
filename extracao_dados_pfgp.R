# ==============================================================================.
# A. CONFIGURAÇÕES INICIAIS E BIBLIOTECAS -------
# ==============================================================================.

rm(list = ls()); gc()
# abre pacotes-------------------------------------------------------------

library(dplyr)
library(data.table)
library(reticulate)
library(sparklyr)
library(stringr)
library(lubridate)
library(DBI)
library(sparklyr)
library(stringr)
library(reticulate)
library(janitor)
library(readxl)
library(geobr)
library(basedosdados)

# objetos e diretório  --------------------------------------------------------
output_pfgp <- file.path('data-raw','data_pfgp')
dir.create(output_pfgp,showWarnings = F)


# ==============================================================================.
# B. CONEXÃO as fontes de dados -------
# ==============================================================================.


### 2.1 - conexão com DataBricks ----
use_virtualenv(Sys.getenv("venv_path"), required = TRUE)
sc <- spark_connect(
  master     = Sys.getenv("master"),
  method     = Sys.getenv("method"),
  cluster_id = Sys.getenv("cluster_id"),
  token      = Sys.getenv("token_databricks3"),
  envname    = Sys.getenv("venv_path")
)

### 2.2 - conexão com Extração DW-SIAPE ----

# # Leitura dos dados apontando para o bd_coest/df_pfgp_all na camada Ouro
# df_dwsiape_pfgp <- sdf_sql(sc,"SELECT * FROM `mgi-ouro`.`bd_coest`.`df_pfgp_all`")
#
# ### 2.3 - vetor com agregadores mínimos e outros agregadores
# agreg_min <- c("MES",
#                "ORGAO_VINC",
#                "NOME_ORGAO_VINC",
#                "NOME_ORGAO_VINC_COMPLETO",
#                #"NOME_NATUREZA_JURIDICA_CNNJ",
#                "NOME_SEXO",
#                "UF_NATURALIDADE")
#
# ## 2.4 - vetor com demais agregadores para outros indicadores
# agreg_ind <- c("NOME_FUNCAO",
#                "NOME_NIVEL_FUNCAO",
#                "IDADE",
#                "GRUPO_CARGO",
#                "NOME_GRUPO_CARGO",
#                "CARGO",
#                "NOME_CARGO",
#                "GRUPO_CARGO_ORIGEM",
#                "NOME_GRUPO_CARGO_ORIGEM",
#                "CARGO_ORIGEM",
#                "NOME_CARGO_ORIGEM")
#
#
# ## 2.5 - lista de regiões de naturalidade
# regioes_list <-
#   list(
#     Norte = data.table(UF_NATURALIDADE = c("AM","AC","AP","PA","RO","RR","TO")),
#     Nordeste = data.table(UF_NATURALIDADE = c("PB","RN","BA","CE","PE","MA","PI","SE","AL")),
#     Sul = data.table(UF_NATURALIDADE = c("PR","SC","RS")),
#     Sudeste = data.table(UF_NATURALIDADE = c("ES","MG","RJ","SP")),
#     "Centro-Oeste" = data.table(UF_NATURALIDADE = c("DF","GO","MS","MT"))
#   ) %>%
#   rbindlist(idcol = "REGIAO_NATURALIDADE")
#
#
# # salvando lista de siglas de órgãos
# lista_orgaos <- transverais_ag_tab[,unique(sg_orgao)]
# save(lista_orgaos,file = "data-raw/data_pfgp.rda")

# ==============================================================================.
# Dimensão 1 -------
# ==============================================================================.

###
# 0 - Base do Censo (para indicadores 11 e 17) ----
###


## registrando labels
labels <-
  list(
    regiao = c('1' = "NORTE",
               '2' = "NORDESTE",
               '3' = "SUDESTE",
               '4' = "SUL",
               '5' = "CENTRO_OESTE"),
    sexo = c('1' = "Homens", '2' = "Mulheres"),
    cor_raca = c('1' = "BRANCA",
                 '2' = "PRETA",
                 '3' = "AMARELA",
                 '4' = "PARDA",
                 '5' = "INDIGENA"),
    deficiencia = c("1" = "Pessoa COM deficiência","2" = "Pessoa SEM deficiência"),
    nivel_instrucao =
      c('1' = 'Sem instrução e menos de 1 ano',
        '2' = 'Ensino fundamental incompleto ou equivalente',
        '3' = 'Ensino fundamental completo ou equivalente',
        '4' = 'Ensino médio incompleto ou equivalente',
        '5' = 'Ensino médio completo ou equivalente',
        '6' = 'Superior incompleto ou equivalente',
        '7' = 'Superior completo',
        '8' = 'Não determinado',
        '9' = 'Ignorado',
        '901' = 'Ignorado',
        '902' = 'Ignorado',
        '903' = 'Ignorado',
        '911' = 'Ignorado',
        '912' = 'Ignorado',
        '913' = 'Ignorado',
        '914' = 'Ignorado')
  )

## carregando agregadão do Censo
pessoas_censo <- readRDS("data-raw/data_pfgp/agregado_microdado_censo.rds" ) %>% setDT()


## cortes de faixa etária
breaks_faixa_etaria <- c(0,15,20,25,30,45,60,75,120)

## cortes de geração
breaks_geracao <- c(1946,1964,1980,1996,2012)

## recriando variáveis nos moldes do SIAPE
pessoas_censo[,`:=`(
  # região de naturalidade
  no_regiao_naturalidade = ifelse(local_nascimento == 3,
                                  "Outro país",
                                  ifelse(local_nascimento == 2,
                                         substr(UF_nascimento,1,1) %>% labels$regiao[.],
                                         labels$regiao[grande_regiao]
                                         )
                                  ),

  # sexo
  sexo = labels$sexo[sexo],

  # cor/origem étnica
  no_cor_origem_etnica = labels$cor_raca[cor_raca],

  # limites faixa etária
  fx_li = ifelse(faixa_etaria %in% c(NA,"",99),
                 NA,
                 (faixa_etaria - 1)*5),


  fx_ls = ifelse(faixa_etaria %in% c(NA,"",99),
                 NA,
                 (faixa_etaria)*5 - 1),

  # deficiênciia
  pcd = labels$deficiencia[deficiencia]
  )]

## criando anos de nascimento com base nas faixas etárias (referência, jul-agos/2022)
pessoas_censo[,`:=`(
  anonasc_li = 2022 - fx_ls,
  anonasc_ls = 2022 - fx_li
)]


## > recriando algumas variáveis de interesse (fazer o mesmo no SIAPE) ----
pessoas_censo[,`:=`(
  ## faixa etária
  idade_servidor = cut(fx_ls,
                       breaks = breaks_faixa_etaria,
                       include.lowest = T,
                       right = F
                       ),

  ## cor/origem étnica agregando pretos e pardos em negros
  no_cor_origem_etnica_ag = ifelse(no_cor_origem_etnica %in% c("PRETA","PARDA"),
                                    "NEGRA",
                                    no_cor_origem_etnica)

  )]

## novas variáveis de interesse
pessoas_censo[,`:=`(
  cor_sexo    =    paste0("Cor/origem\nétnica ",str_to_title(no_cor_origem_etnica),", ",sexo),
  cor_sexo_ag =    paste0("Cor/origem\nétnica ",str_to_title(no_cor_origem_etnica_ag),", ",sexo)
)]



###
# 11 - Equidade de distribuição ----
##


#### > extração dos tabelões no SIAPE -----

## agregados mínimos para os indicadores
agreg_min <- c(# "CO_ORGAO",
               # "SG_ORGAO",
               # "NO_ORGAO",
               # "NO_NATUREZA_JURIDICA",
               'geracao',
               'pcd',
               'NO_COR_ORIGEM_ETNICA',
               'CO_SEXO',
               'NO_REGIAO_NATURALIDADE',
               'IDADE_SERVIDOR') %>%
  tolower()




## caminho para os tabelões no databricks
path_tabeloes <- "/Volumes/mgi-bronze/raw_data_volumes/mgi/DIGID/CGINF/01.Bases_SAS/COEST/tabelao_csv/"

## listando tabelões disponíveis no datalake
DBI::dbGetQuery(
  sc,
  paste0("LIST '",path_tabeloes,"'")
) -> lista_de_tabeloes

meses_tabeloes <- str_extract_all(lista_de_tabeloes$name,"20[0-9]{0,4}") %>% unlist %>% unique

## captando meses correspondentes ao último mês de cada ano e último do ano corrente
ano_cor <- year(Sys.Date())
ultimo_mes <- grep(paste0("^",ano_cor),meses_tabeloes,value = T) %>% max()
meses_analise <- grep("(12$)",meses_tabeloes,value = T) %>% c(.,ultimo_mes)
# meses_analise <- c('201912',grep("202",meses_tabeloes,value = T))


## Rodando consulta para cada mês
ti <- Sys.time()
ativos_equidade_list <-
  sapply(meses_analise,
         function(m){
           cat("Conectando tabelão de ",m,"\n")
           df_tabelao <- spark_read_csv(
             sc,
             name = "tabelao2",
             path = paste0(path_tabeloes,"VW001_TABELAO_SERV_",m,".csv")) %>%
             janitor::clean_names()

           colunas_dispoiniveis <- colnames(df_tabelao)

           # se lista é uma string só, separador tá errado, tentando outro
           if(length(colunas_dispoiniveis) == 1){
             cat("Conectando tabelão de ",m,"\n")
             df_tabelao <- spark_read_csv(
               sc,
               name = "tabelao2",
               delimiter = ";", # mudando separador aqui
               path = paste0(path_tabeloes,"VW001_TABELAO_SERV_",m,".csv")) %>%
               janitor::clean_names()

             colunas_dispoiniveis <- colnames(df_tabelao)

           }

           # return(colunas_dispoiniveis)})

           cat("Filtro PEP e agregando\n\n")
           ativos_equidade <-
             df_tabelao  %>%
             filter(var_0001_situacao %in% 'ATIVO',
                    sg_regime_juridico %in% 'EST',
                    var_0048_qtd_serv_p %in% 1
                    ) %>%
             # filter(!co_natureza_juridica %in% c(10,5,6),
             #        #!no_natureza_juridica %in% c("SERVICO PUBLICO ESTADUAL","EMPRESA PUBLICA","SOCIEDADE ECONOMIA  MISTA"),
             #        co_orgao != 99072,
             #        !sg_regime_juridico %in% c("RMI","ETE","ETG"),
             #        !regime_jur_e_sit %in%
             #          c(#"EST-18","EST-19",
             #            "EST-41","EST-42","ANS-36","ANS-37"
             #          ),
             #        var_0001_situacao %in% 'ATIVO'#,
             #        # var_0182_forca_trab %in% 1
             # ) %>%
             mutate(ano_nasc = as.numeric(year(dt_nasc_serv))) %>%
             mutate(idade_servidor = cut(idade_servidor,
                                         breaks = breaks_faixa_etaria,
                                         include.lowest = T,
                                         right = F
                                         ),

                    geracao = cut(ano_nasc,
                                  breaks = breaks_geracao,
                                  right = FALSE,
                                  include.lowest = T,
                                  labels = c("Boomers",
                                             "X",
                                             "Millenials",
                                             "Z")),

                    pcd = ifelse(co_grupo_deficiencia_fisica %in% 0,
                                 "Pessoa SEM deficiência",
                                 "Pessoa COM deficiência")

                    ) %>%
             group_by(
               across(
                 all_of(
                   c('compet',
                     agreg_min ,
                     "var_0001_situacao",
                     "var_0048_qtd_serv_p") #%>%
                     # das colunas listadas, pegando apenas as colunas disponíveis
                     # intersect(colunas_dispoiniveis)
                 )
               )) %>%
             # group_by(var_0001_situacao,var_0048_qtd_serv_p) %>%
             summarise(n = n()) %>%
             collect() %>%
             setDT() #%>% View
             # setnames('idade_servidor',"faixa_etaria")
           Sys.sleep(30)
           return(ativos_equidade)
         },
         simplify = F)
(tf <- difftime(Sys.time(),ti,units = "secs"))

# juntando todas as competências
ativos_equidade_tab <- rbindlist(ativos_equidade_list,fill = T)

#### > ajustes nas variáveis ----

# compatibilizações com Censo
ativos_equidade_tab[,`:=`(

  # # faixa etária como fator
  # faixa_etaria.f =
  #   ifelse(grepl("18\\]$",idade_servidor),
  #          "Até 18 anos",
  #          ifelse(grepl("^\\[60",idade_servidor),
  #                 "60 anos ou mais",
  #                 idade_servidor)
  #          ) %>%
  #   gsub("\\[|\\)","",.) %>%
  #   gsub(","," a ",.) %>%
  #   factor(ordered = T),


  # sexo como 'Homens' ou 'Mulheres
  sexo = ifelse(co_sexo == "F","Mulheres","Homens"),


  ## cor/origem étnica agregando pretos e pardos em negros
  no_cor_origem_etnica_ag = ifelse(no_cor_origem_etnica %in% c("PRETA","PARDA"),
                                   "NEGRA",
                                   no_cor_origem_etnica)
  )]

## novas variáveis de interesse
ativos_equidade_tab[,`:=`(
  cor_sexo    =    paste0("Cor/origem\nétnica ",str_to_title(no_cor_origem_etnica),", ",sexo),
  cor_sexo_ag =    paste0("Cor/origem\nétnica ",str_to_title(no_cor_origem_etnica_ag),", ",sexo)
)]



# termos que significam NA como NA
categorias_interesse <- setdiff(names(ativos_equidade_tab),
                                c('compet','var_0001_situacao',"var_0048_qtd_serv_p","n"))

ativos_equidade_tab[,c(categorias_interesse) :=
                      lapply(.SD,function(x){
                        ifelse(x %in% c(NA,'NAO_SE_APLICA','N�O INFORMADO'),
                               NA,
                               x)
                      }),
                    .SDcols = categorias_interesse
]


# faixa de 25 a 75 anos no SIAPE
ativos_equidade_tab[,is_25_75 := idade_servidor >= "[25,30)" & idade_servidor < "[75,120)"]


#### >  equidades, proporções e chi-quadrados cruzados -----

## função para agregar nas variáveis de interesse e juntar com censo
agrega_junta_censo <- function(dt_siape,dt_censo,vars.v,cruzados = T){
  if(cruzados){
    # agregando siape
    dt_siape_ag <- dt_siape[,.(n_siape = sum(n,na.rm = T),
                               n_siape_25_75 = sum(n*is_25_75,na.rm = T)),
                            by = c('compet',vars.v)] %>%
      # percentuais no SIAPE
      .[,`:=`(p_siape = n_siape/sum(n_siape),
              p_siape_25_75 = n_siape_25_75/sum(n_siape_25_75)),.(compet)]

    # agregando censo
    dt_censo_ag <- dt_censo[,.(n_censo = sum(populacao_estimada,na.rm = T),
                               n_censo_sup = sum(populacao_estimada*(nivel_instrucao %in% 7),
                                                 na.rm = T),
                               n_censo_25_75 = sum(populacao_estimada*(fx_li >= 25 & fx_ls < 75),
                                                   na.rm = T)
                               ),
                            by = c(vars.v)] %>%
      # percentuais no Censo
      .[,`:=`(p_censo = n_censo/sum(n_censo,na.rm = T),
              p_censo_sup = n_censo_sup/sum(n_censo_sup,na.rm = T),
              p_censo_25_75 = n_censo_25_75/sum(n_censo_25_75,na.rm = T))]

    # juntando
    dt_ag <- left_join(dt_siape_ag,dt_censo_ag,by = vars.v)


    # identificando onde tem vazios
    dt_ag[,any_vazio :=
            eval(
              parse(
                text =
                  paste0(
                    # "grepl(",
                    "(",
                    vars.v,
                    " %in% c(NA,'NAO_SE_APLICA','N�O INFORMADO'))",
                    collapse = "|"
                    )
                )
              )
          ]

  }else{

    # agregando siape
    dt_siape_ag <-
      melt(dt_siape,
           id.vars = c('compet','is_25_75','n'),
           measure.vars = vars.v,
           variable.name = 'variavel',
           value.name = 'categoria') %>%
      .[,.(n_siape = sum(n,na.rm = T),
           n_siape_25_75 = sum(n*is_25_75,na.rm = T)),
        by = c('compet','variavel','categoria')] %>%
      # percentuais no SIAPE
      .[,`:=`(p_siape = n_siape/sum(n_siape),
              p_siape_25_75 = n_siape_25_75/sum(n_siape_25_75)),
        .(compet,variavel)]

    # agregando censo
    dt_censo_ag <-
      dt_censo %>%
      copy %>%
      .[,`:=`(compet = 2022,
              populacao_sup = populacao_estimada*(nivel_instrucao %in% 7),
              populacao_25_75 = populacao_estimada*(fx_li >= 25 & fx_ls < 75))] %>%
      melt(id.vars = c('compet','populacao_estimada','populacao_sup','populacao_25_75'),
           measure.vars = vars.v,
           variable.name = 'variavel',
           value.name = 'categoria') %>%
      .[,.(n_censo = sum(populacao_estimada,na.rm = T),
           n_censo_sup = sum(populacao_sup,na.rm = T),
           n_censo_25_75 = sum(populacao_25_75,na.rm = T)
           ),
        by = c('variavel','categoria')] %>%
      # percentuais no Censo
      .[,`:=`(p_censo = n_censo/sum(n_censo,na.rm = T),
              p_censo_sup = n_censo_sup/sum(n_censo_sup,na.rm = T),
              p_censo_25_75 = n_censo_25_75/sum(n_censo_25_75,na.rm = T)),
        .(variavel)]


    # juntando
    dt_ag <- left_join(dt_siape_ag,dt_censo_ag,by = c("variavel","categoria"))


    # identificando onde tem vazios
    dt_ag[,any_vazio := is.na(categoria) | grepl("(^| )((NA)|(NAO_SE_APLICA)|(N.*O INFORMADO))($|\\,| )",
                                                 categoria,
                                                 ignore.case = T)]

  }
  return(dt_ag)
}


## função chi-quadrado para aderencia
calcula_chisq_aderencia <- function(p.v,pi.v){
  # stopifnot(sum(p.v) %in% c(1,100) & sum(pi.v)  %in% c(1,100))

  #retirando vazios e zeros
  p_vazios_n0  <- is.finite(p.v)
  pi_vazios_n0 <- is.finite(pi.v) & pi.v > 0

  p.v_n <- p.v[p_vazios_n0 & pi_vazios_n0]
  pi.v_n <- pi.v[p_vazios_n0 & pi_vazios_n0]

  if(length(p.v_n) >= 2 & length(pi.v_n) >= 2){
    if(sum(p.v_n) > 1) p.v_n <- p.v_n/100
    if(sum(pi.v_n) > 1) pi.v_n <- pi.v_n/100
    chisq.n <- sum(((p.v_n - pi.v_n)^2)/pi.v_n)
  }else{
    return(NA)
  }
}

## percentuais nos cruzamentos de interesse
ativos_equidade_cruzados <- agrega_junta_censo(ativos_equidade_tab,
                                               pessoas_censo,
                                               vars.v = c("no_cor_origem_etnica_ag",
                                                          "sexo",
                                                          "idade_servidor",
                                                          "no_regiao_naturalidade"))
## razões de equidade nos grupos cruzados, mês a mes
ativos_equidade_cruzados[,`:=`(equidade_cruzados = p_siape/p_censo,
                               equidade_cruzados_sup = p_siape/p_censo_sup,
                               equidade_cruzados_25_75 = p_siape_25_75/p_censo_25_75)]


## total observado no SIAPE no mês
ativos_equidade_cruzados[,`:=`(geral_siape = sum(n_siape),
                               geal_siape_25_75 = sum(n_siape_25_75)),.(compet)]

## maior razão de probabilidade possível
ativos_equidade_cruzados[,`:=`(razao_prop     = ifelse(n_censo > geral_siape,(1-p_censo)/p_censo,NA),
                               razao_prop_sup = ifelse(n_censo_sup > geral_siape,(1 - p_censo_sup)/p_censo_sup,NA),
                               razao_prop_25_75 = ifelse(n_censo_25_75 > geal_siape_25_75,
                                                         (1-p_censo_25_75)/p_censo_25_75,
                                                         NA))]



## medidas qui-quadrado cruzadas, mês a mês
ativos_equidade_cruzados[!(any_vazio),# & compet > 201912,
                         .(n_categ = .N,
                           qui_quadrado = calcula_chisq_aderencia(p_siape,p_censo),
                           qui_quadrado_sup = calcula_chisq_aderencia(p_siape,p_censo_sup),
                           qui_quadrado_25_75 = calcula_chisq_aderencia(p_siape_25_75,p_censo_25_75),
                           max_qui = max(razao_prop,na.rm = T),
                           max_qui_sup = max(razao_prop_sup,na.rm = T),
                           max_qui_25_75 = max(razao_prop_25_75,na.rm = T)),
                         .(compet)] -> equidade_chisq_cruzados


## contingência
equidade_chisq_cruzados[,`:=`(coef_contin = 100*sqrt(qui_quadrado/max_qui),
                              coef_contin_sup = 100*sqrt(qui_quadrado_sup/max_qui_sup),
                              coef_contin_25_75 = 100*sqrt(qui_quadrado_25_75/max_qui_25_75))]




#### >  equidades, proporções e chi-quadrados marginais -----

## percentuais marginais nas variáveis de interesse e outras
ativos_equidade_marginais <- agrega_junta_censo(ativos_equidade_tab,
                                                pessoas_censo,
                                                vars.v = c("no_cor_origem_etnica",
                                                           "no_cor_origem_etnica_ag",
                                                           "sexo",
                                                           "cor_sexo",
                                                           "cor_sexo_ag",
                                                           "idade_servidor",
                                                           "pcd",
                                                           "no_regiao_naturalidade"),
                                                cruzados = F)

## razões de equidade cruzadas
ativos_equidade_marginais[,`:=`(equidade_marginais = p_siape/p_censo,
                                equidade_marginais_sup = p_siape/p_censo_sup,
                                equidade_marginais_25_75 = p_siape_25_75/p_censo_25_75)]

## total observado no SIAPE no mês
ativos_equidade_marginais[,`:=`(geral_siape = sum(n_siape),
                                geal_siape_25_75 = sum(n_siape_25_75)),
                          .(compet,variavel)]

## maior razão de probabilidade possível
ativos_equidade_marginais[,`:=`(razao_prop     = ifelse(n_censo > geral_siape,(1-p_censo)/p_censo,NA),
                                razao_prop_sup = ifelse(n_censo_sup > geral_siape,(1 - p_censo_sup)/p_censo_sup,NA),
                                razao_prop_25_75 = ifelse(n_censo_25_75 > geal_siape_25_75,
                                                          (1-p_censo_25_75)/p_censo_25_75,
                                                         NA))]



## medidas qui-quadrado cruzadas, mês a mês
ativos_equidade_marginais[!(any_vazio),# & compet > 201912,
                          .(n_categ = .N,
                            qui_quadrado = calcula_chisq_aderencia(p_siape,p_censo),
                            qui_quadrado_sup = calcula_chisq_aderencia(p_siape,p_censo_sup),
                            qui_quadrado_25_75 = calcula_chisq_aderencia(p_siape_25_75,p_censo_25_75),
                            max_qui = max(razao_prop,na.rm = T),
                            max_qui_sup = max(razao_prop_sup,na.rm = T),
                            max_qui_25_75 = max(razao_prop_25_75,na.rm = T)),
                          .(variavel,compet)] -> equidade_chisq_marginais


## contingência
equidade_chisq_marginais[,`:=`(coef_contin = 100*sqrt(qui_quadrado/max_qui),
                               coef_contin_sup = 100*sqrt(qui_quadrado_sup/max_qui_sup),
                               coef_contin_25_75 = 100*sqrt(qui_quadrado_25_75/max_qui_25_75))]




### > salvando bases -------
saveRDS(ativos_equidade_tab,'data-raw/data_pfgp/ativos_equidade_tab.rds')

# salvando coeficientes
save(ativos_equidade_cruzados,
     ativos_equidade_marginais,
     equidade_chisq_cruzados,
     equidade_chisq_marginais,
     file = 'data-raw/data_pfgp/ativos_equidade_marginais.rda')


###
# 17 - Equidade de ingressos ----
##


library(data.table)
library(dplyr)
library(janitor)



src_tabelao <- paste0(path_tabeloes,"VW001_TABELAO_SERV_",ultimo_mes,".csv")


df_tabelao <- spark_read_csv(
  sc,
  name = "tabelao2",
  path = src_tabelao) %>%
  janitor::clean_names()

colunas_dispoiniveis <- colnames(df_tabelao)

# se lista é uma string só, separador tá errado, tentando outro
if(length(colunas_dispoiniveis) == 1){
  df_tabelao <- spark_read_csv(
    sc,
    name = "tabelao2",
    delimiter = ";", # mudando separador aqui
    path = src_tabelao) %>%
    janitor::clean_names()

  colunas_dispoiniveis <- colnames(df_tabelao)

}

colunas_filtro_pep <- c("CO_NATUREZA_JURIDICA",
                        "CO_ORGAO",
                        "SG_REGIME_JURIDICO",
                        "REGIME_JUR_E_SIT",
                        "VAR_0001_SITUACAO")

agreg_min_ingr <- c("CO_ORGAO",
                    "SG_ORGAO",
                    "NO_ORGAO",
                    "NO_NATUREZA_JURIDICA",
                    'NO_COR_ORIGEM_ETNICA',
                    'CO_SEXO',
                    'NO_REGIAO_NATURALIDADE')


ingressos_equidade <-
  df_tabelao  %>%
  filter(#var_0001_situacao %in% 'ATIVO',
         sg_regime_juridico %in% 'EST',
         var_0048_qtd_serv_p %in% 1
  ) %>%
  mutate(
    # Diferença da competência para a ocorrência (resultado positivo)
    idade_ingresso = datediff(dt_nasc_serv, dt_ocor_ingr_spub_serv)/365.25,

    # ano de ingresso
    ano_ingresso = year(dt_ocor_ingr_spub_serv),

    # ano de nascimento do servidor
    ano_nasc = as.numeric(year(dt_nasc_serv)),

    # faixa etária do servidor na data de ingresso
    idade_servidor = cut(idade_ingresso,
                         breaks = breaks_faixa_etaria,
                         include.lowest = T,
                         right = F),

    # geração (ano de nascimento)
    geracao = cut(ano_nasc,
                  breaks = breaks_geracao,
                  right = FALSE,
                  include.lowest = T,
                  labels = c("Boomers",
                             "X",
                             "Millenials",
                             "Z")),

    # pcd
    pcd = ifelse(co_grupo_deficiencia_fisica %in% 0,
                 "Pessoa SEM deficiência",
                 "Pessoa COM deficiência")
  ) %>%
  # filtrando 2010 em diante
  filter(ano_ingresso >= 2010)  %>%
  group_by(
    across(
      all_of(
        c('compet',
          'ano_ingresso',
          agreg_min ,
          "var_0001_situacao",
          "var_0048_qtd_serv_p") #%>%
        # das colunas listadas, pegando apenas as colunas disponíveis
        # intersect(colunas_dispoiniveis)
      )
      )
    ) %>%
  # group_by(var_0001_situacao,var_0048_qtd_serv_p) %>%
  summarise(n = n()) %>%
  collect() %>%
  setDT()


# transformando faixas etárias
ingressos_equidade[,`:=`(

  # faixa etária como fator
  faixa_etaria.f =
    ifelse(grepl("18\\]$",idade_servidor),
           "Até 18 anos",
           ifelse(grepl("^\\[60",idade_servidor),
                  "60 anos ou mais",
                  idade_servidor)
    ) %>%
    gsub("\\[|\\)","",.) %>%
    gsub(","," a ",.) %>%
    factor(ordered = T),

  # sexo como 'Homens' ou 'Mulheres
  sexo = ifelse(co_sexo == "F","Mulheres","Homens")
)]

#### > ajustes nas variáveis ----

# compatibilizações com Censo
ativos_equidade_tab[,`:=`(

  # # faixa etária como fator
  # faixa_etaria.f =
  #   ifelse(grepl("18\\]$",idade_servidor),
  #          "Até 18 anos",
  #          ifelse(grepl("^\\[60",idade_servidor),
  #                 "60 anos ou mais",
  #                 idade_servidor)
  #          ) %>%
  #   gsub("\\[|\\)","",.) %>%
  #   gsub(","," a ",.) %>%
  #   factor(ordered = T),


  # sexo como 'Homens' ou 'Mulheres
  sexo = ifelse(co_sexo == "F","Mulheres","Homens"),


  ## cor/origem étnica agregando pretos e pardos em negros
  no_cor_origem_etnica_ag = ifelse(no_cor_origem_etnica %in% c("PRETA","PARDA"),
                                   "NEGRA",
                                   no_cor_origem_etnica)
)]

## novas variáveis de interesse
ativos_equidade_tab[,`:=`(
  cor_sexo    =    paste0("Cor/origem\nétnica ",str_to_title(no_cor_origem_etnica),", ",sexo),
  cor_sexo_ag =    paste0("Cor/origem\nétnica ",str_to_title(no_cor_origem_etnica_ag),", ",sexo)
)]



# termos que significam NA como NA
categorias_interesse <- setdiff(names(ativos_equidade_tab),
                                c('compet','var_0001_situacao',"var_0048_qtd_serv_p","n"))

ativos_equidade_tab[,c(categorias_interesse) :=
                      lapply(.SD,function(x){
                        ifelse(x %in% c(NA,'NAO_SE_APLICA','N�O INFORMADO'),
                               NA,
                               x)
                      }),
                    .SDcols = categorias_interesse
]


# faixa de 25 a 75 anos no SIAPE
ativos_equidade_tab[,is_25_75 := idade_servidor >= "[25,30)" & idade_servidor < "[75,120)"]



## > versão anterior que alimenta o shiny ----


df_tabelao_202604 <- df_tabelao %>%
  filter(!co_natureza_juridica %in% c(10,5,6),
         #!no_natureza_juridica %in% c("SERVICO PUBLICO ESTADUAL","EMPRESA PUBLICA","SOCIEDADE ECONOMIA  MISTA"),
         co_orgao != 99072,
         !sg_regime_juridico %in% c("RMI","ETE","ETG"),
         !regime_jur_e_sit %in%
           c(#"EST-18","EST-19",
             "EST-41","EST-42","ANS-36","ANS-37"
           ),
         var_0001_situacao %in% 'ATIVO'#,
         # var_0182_forca_trab %in% 1
  )





base_ingressos <- df_tabelao_202604 %>%
  filter(!is.na(dt_ocor_ingr_spub_serv)) %>%
  mutate(
    dt_ingresso = date_format(dt_ocor_ingr_spub_serv, "yyyyMM"),
    # Depois, cria o contador
    contador = 1
  )


base_ingressos <- base_ingressos %>%
  select(co_orgao,
         sg_orgao,no_natureza_juridica, no_cor_origem_etnica, co_sexo,
         no_regiao_naturalidade, dt_ingresso, contador) %>%
  group_by(co_orgao,
           sg_orgao,no_natureza_juridica, no_cor_origem_etnica, co_sexo,
           no_regiao_naturalidade, dt_ingresso) %>%
  summarise(total = sum(contador, na.rm = TRUE), .groups = 'drop') %>%
  filter(dt_ingresso >= 201600) %>%
  collect()

base_ingressos <-
  base_ingressos %>%
  mutate(sexo = ifelse(co_sexo %in% "F",
                       "Mulheres",
                       "Homens"),
         ano_ingresso = substr(dt_ingresso,1,4) %>% as.numeric
  )


# agregações mínimas para salvar
base_ingressos <-
  list(

    base_ingressos %>%
      setDT() %>%
      .[,.(co_orgao = 0,
           sg_orgao = "Total",
           total = sum(total)),
        .(ano_ingresso,no_cor_origem_etnica,sexo,no_regiao_naturalidade)
      ],

    base_ingressos %>%
      setDT() %>%
      .[,.(total = sum(total)),
        .(co_orgao,sg_orgao,ano_ingresso,no_cor_origem_etnica,sexo,no_regiao_naturalidade)
        ]
  ) %>%
  rbindlist(fill = T)

saveRDS(base_ingressos,"data-raw/data_pfgp/base_ingressos.rds")


# ==============================================================================.
# Dimensão 3 -------
# ==============================================================================.



###
# 3.1 - Lideranças ----
##



## agregação inicial
dt_liderancas <-
  df_dwsiape_pfgp %>%
  filter(NOME_GRUPO_SIT_VINC_SERV %in% "Ativo") %>%
  mutate(efetivo = !(CARGO %in% 0 & CARGO_ORIGEM %in% 0)) %>%
  group_by(
    across(
      all_of(
        c(agreg_min,
          "NOME_FUNCAO",
          "NOME_NIVEL_FUNCAO",
          "efetivo")
        )
      )
    ) %>%
  summarise(n = sum(qtd_vinculo)) %>%
  collect() %>%
  setDT


## trabalhando região de naturalidade e nível de função FCE/CCE

# regiões
dt_liderancas <- left_join(dt_liderancas,regioes_list,by = 'UF_NATURALIDADE')

# nível de função
dt_liderancas[NOME_FUNCAO %in% c("CCX","FEX"),
              `:=`(tipo_funcao = NOME_FUNCAO,
                   nivel_fce_cce = gsub("(CCX|FEX)-[0-9]{2}","",NOME_NIVEL_FUNCAO) %>%
                     as.numeric() %>%
                     cut(breaks = c(0,12,18),
                         right = T,
                         include.lowest = T,
                         labels = c("Níveis 1 a 12",
                                    "Níveis 13 a 18")
                         )
                   )]
dt_liderancas[,lideranca := !is.na(nivel_fce_cce)]

# reagregando
dt_liderancas[,.(n = sum(n)),
              by = c("MES",
                     "ORGAO_VINC",
                     "NOME_ORGAO_VINC",
                     "NOME_ORGAO_VINC_COMPLETO",
                     "NOME_SEXO",
                     "REGIAO_NATURALIDADE",
                     "efetivo",
                     "lideranca",
                     "tipo_funcao",
                     "nivel_fce_cce")] -> dt_liderancas

# salvando
saveRDS(dt_liderancas,
        file = 'data-raw/data_pfgp/df_liderancas.rds')



# ==============================================================================.
# Dimensão 4 - Carreiras, Cargos, Progressão e Promoção  -------
# ==============================================================================.


###
# 4.0 deliberações e checagens sobre como definir cargos transversais -----
###


# sobre ocorrências de exercício descentralizado X órgão/cargo de origem, quase todos têm:
# * vazio no cargo/grupo cargo, porém alguma descrição no cargo/grupo_cargo de origem (90%)
# * 99% dos PGFN estão lotados na AGU. 97% dos CDT estão lotados no MGI

# Sobre os apontamentos acima, incluindo EST-18 e EST-19, dentre os exercícios descentralizados:
# * Todos estão vazios em cargo/grupo cargo. 98,8% têm cargo/grupo cargo de origem preenchidos
# * 99% dos PGFN estão lotados na AGU. 97% dos CDT estão lotados no MGI, 77% dos 'EXERC. DESCENT CARREI' estão no MGI, 19,65% estão na AGU
# * Com exceção dos CDT e dos PGFN, 100% das ocorrências com padrão 'EXERC. DESCENT. CARREI' estavam com regime_jur_e_sit em EST-18


# código de embasamento (com base no tabelão de 202604)

# df_tabelao  %>%
#   filter(var_0001_situacao %in% 'ATIVO') %>%
#   mutate(est_18 = ifelse(regime_jur_e_sit %in% "EST-18",1,0),
#          est_19 = ifelse(regime_jur_e_sit %in% "EST-19",1,0)
#   ) %>%
#   group_by(co_sit_serv,no_sit_serv,
#            co_orgao,co_orgao_origem,
#            no_grupo_cargo,no_grupo_cargo_origem,
#            sg_grupo_cargo,sg_grupo_cargo_origem) %>%
#   summarise(total = n(),
#             est_18 = sum(est_18),
#             est_19 = sum(est_19))  %>%
#   collect() %>%
#   setDT() -> sit_serv_origens
#
#
#
# sit_serv_origens[grepl("desc",no_sit_serv,ignore.case = T),
#                  .(vazios_cargo = mean(no_grupo_cargo %in% c(NA,"")),
#                    completos_cargo_origem = mean(!no_grupo_cargo_origem %in% c(NA,""))
#                  )]
#
#
# (sit_serv_origens[grepl("desc",no_sit_serv,ignore.case = T),
#                   .(total = sum(total),
#                     est_18 = sum(est_18),
#                     est_19 = sum(est_19)
#                   ),
#                   .(no_sit_serv,co_orgao_origem)]
# ) %>% .[,p := 100*total/sum(total),
#         .(co_orgao_origem)]  %>%
#   setorder(co_orgao_origem,-p) %>% View("% orgao_origem")
#
#
# (sit_serv_origens[grepl("desc",no_sit_serv,ignore.case = T),
#                   .(total = sum(total),
#                     est_18 = sum(est_18),
#                     est_19 = sum(est_19)
#                   ),
#                   .(no_sit_serv,co_orgao_origem)]
# ) %>% .[,p := 100*total/sum(total),
#         .(no_sit_serv)]  %>%
#   setorder(no_sit_serv,-p) %>% View("% no_sit_serv")
#
#
# df_orgao_vinc    <- sdf_sql(sc,'SELECT * FROM `mgi-ouro`.`bd_dwsiape`.`ORGAO_VINC`') %>% collect %>% setDT()



###
# 4.1 Cargos transversais -----
###

## agregados mínimos para os indicadores
agreg_min <- c("compet",
               "CO_ORGAO",
               "SG_ORGAO",
               "NO_ORGAO",
               "NO_NATUREZA_JURIDICA",
               'NO_COR_ORIGEM_ETNICA',
               'CO_SEXO',
               'NO_REGIAO_NATURALIDADE') %>%
  tolower()


## caminho para os tabelões no databricks
path_tabeloes <- "/Volumes/mgi-bronze/raw_data_volumes/mgi/DIGID/CGINF/01.Bases_SAS/COEST/tabelao_csv/"

## listando tabelões disponíveis no datalake
DBI::dbGetQuery(
  sc,
  paste0("LIST '",path_tabeloes,"'")
) -> lista_de_tabeloes

meses_tabeloes <- str_extract_all(lista_de_tabeloes$name,"20[0-9]{0,4}") %>% unlist %>% unique

## captando meses correspondentes ao último mês de cada ano e último do ano corrente
ano_cor <- year(Sys.Date())
ultimo_mes <- grep(paste0("^",ano_cor),meses_tabeloes,value = T) %>% max()
meses_analise <- grep("(12$)",meses_tabeloes,value = T) %>% c(.,ultimo_mes)
# meses_analise <- c('201912',grep("202",meses_tabeloes,value = T))


## Rodando consulta para cada mês
ti <- Sys.time()
transverais_ag_list <-
  sapply(meses_analise,
         function(m){
           cat("Conectando tabelão de ",m,"\n")
           df_tabelao <- spark_read_csv(
             sc,
             name = "tabelao2",
             path = paste0(path_tabeloes,"VW001_TABELAO_SERV_",m,".csv")) %>%
             janitor::clean_names()

           colunas_dispoiniveis <- colnames(df_tabelao)

           # return(colunas_dispoiniveis)})

           cat("Filtro PEP e agregando\n\n")
           df_agreg_transv <-
             df_tabelao  %>%
             filter(!co_natureza_juridica %in% c(10,5,6),
                    #!no_natureza_juridica %in% c("SERVICO PUBLICO ESTADUAL","EMPRESA PUBLICA","SOCIEDADE ECONOMIA  MISTA"),
                    co_orgao != 99072,
                    !sg_regime_juridico %in% c("RMI","ETE","ETG"),
                    !regime_jur_e_sit %in%
                      c(#"EST-18","EST-19",
                        "EST-41","EST-42","ANS-36","ANS-37"
                        ),
                    var_0001_situacao %in% 'ATIVO'#,
                    # var_0182_forca_trab %in% 1
                    ) %>%
             group_by(
               across(
                 all_of(
                   c('compet',
                     agreg_min,
                     "co_sit_serv",
                     "no_sit_serv",
                     "co_cargo",
                     "no_cargo",
                     "co_cargo_origem",
                     "no_cargo_origem",
                     "var_0182_forca_trab") %>%
                     # das colunas listadas, pegando apenas as colunas disponíveis
                     intersect(colunas_dispoiniveis)
                   )
                 )
               ) %>%
             summarise(n = n()) %>%
             collect() %>%
             setDT()
           return(df_agreg_transv,fill = T)
           },
         simplify = F)
(tf <- difftime(Sys.time(),ti,units = "secs"))

transverais_ag_tab <- rbindlist(transverais_ag_list,fill = T)

## Redefinindo cargo
transverais_ag_tab[,no_cargo_completo := ifelse(co_cargo %in% c(0,NA),
                                                ifelse(co_cargo_origem %in% c(0,NA),
                                                       "Não Efetivo",
                                                       no_cargo_origem
                                                       # paste0(no_grupo_cargo_origem," - ",no_cargo_origem)
                                                       ),
                                                no_cargo
                                                # paste0(no_grupo_cargo," - ",no_cargo)
                                                )
                   ]

## Definindo força de trabalho e exercício descentralizado
transverais_ag_tab[,`:=`(forca_trab = (!co_sit_serv %in% c("44","49","59","27","96","69","CLT","RJ","45","8"))|(var_0182_forca_trab %in% 1),
                         transversal = co_sit_serv %in% c(18,77,78))]

## tabela com as situações excluídas das força de trabalho
sit_serv_out_forca <- transverais_ag_tab[!(forca_trab),.(n = sum(n)),
                                         .(co_sit_serv,no_sit_serv)]

## filtrando na força de trabalho
transverais_ag_tab <- filter(transverais_ag_tab,forca_trab)

### Indicador 58: % de cargos transversais
tab_cargo_transversal <-
  list(transverais_ag_tab[,.(sg_orgao = "Total",
                             transversal = any(transversal)),
                          .(compet,
                            no_cargo_completo)],

       transverais_ag_tab[,.(transversal = any(transversal)),
                          .(sg_orgao,
                            compet,
                            no_cargo_completo)]
       ) %>%
  rbindlist(fill = T) %>%
  .[,.(.N,
       n_transversais = sum(transversal)),
    .(sg_orgao,compet)]


### Indicador 59: % de servidores ativos em cargos transversais
tab_ativo_transversal <-
  list(

    transverais_ag_tab[,.(ag_orgao = "total",
                          ag_sit = "total",
                          sg_orgao = "Total",
                          no_sit_serv = "Total",
                          N = sum(n)),
                       .(transversal,
                         compet)],

    transverais_ag_tab[,.(ag_orgao = "total",
                          ag_sit = "por sit",
                          sg_orgao = "Total",
                          N = sum(n)),
                       .(compet,
                         transversal,
                         no_sit_serv)],

    transverais_ag_tab[,.(ag_orgao = "por_orgao",
                          ag_sit = "total",
                          no_sit_serv = "Total",
                          N = sum(n)),
                       .(sg_orgao,
                         transversal,
                         compet)],

    transverais_ag_tab[,.(ag_orgao = "por_orgao",
                          ag_sit = "por_sit",
                          N = sum(n)),
                       .(sg_orgao,
                         compet,
                         transversal,
                         no_sit_serv)]
  ) %>%
  rbindlist(fill = T) %>%
  .[,N_total := sum(N),.(ag_orgao,ag_sit,sg_orgao,compet)] %>%
  select(-ag_sit,-ag_orgao)


### Indicador 60: distribuição por raça/gênero, transversais x não transversais
tab_raca_genero_transversal <-
  transverais_ag_tab[,.(N = sum(n)),
                     .(compet,
                       transversal,
                       sg_orgao,
                       no_cor_origem_etnica,
                       co_sexo)
  ]


# salvando
saveRDS(tab_cargo_transversal,
        file = 'data-raw/data_pfgp/tab_cargo_transversal.rds')


saveRDS(tab_ativo_transversal,
        file = 'data-raw/data_pfgp/tab_ativo_transversal.rds')


saveRDS(tab_raca_genero_transversal,
        file = 'data-raw/data_pfgp/tab_raca_genero_transversal.rds')

