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
  token      = Sys.getenv("token_databricks"),
  envname    = Sys.getenv("venv_path")
)

### 2.2 - conexão com Extração DW-SIAPE ----

# Leitura dos dados apontando para o bd_coest/df_pfgp_all na camada Ouro
df_dwsiape_pfgp <- sdf_sql(sc,"SELECT * FROM `mgi-ouro`.`bd_coest`.`df_pfgp_all`")

### 2.3 - vetor com agregadores mínimos e outros agregadores
agreg_min <- c("MES",
               "ORGAO_VINC",
               "NOME_ORGAO_VINC",
               "NOME_ORGAO_VINC_COMPLETO",
               #"NOME_NATUREZA_JURIDICA_CNNJ",
               "NOME_SEXO",
               "UF_NATURALIDADE")

## 2.4 - vetor com demais agregadores para outros indicadores
agreg_ind <- c("NOME_FUNCAO",
               "NOME_NIVEL_FUNCAO",
               "IDADE",
               "GRUPO_CARGO",
               "NOME_GRUPO_CARGO",
               "CARGO",
               "NOME_CARGO",
               "GRUPO_CARGO_ORIGEM",
               "NOME_GRUPO_CARGO_ORIGEM",
               "CARGO_ORIGEM",
               "NOME_CARGO_ORIGEM")


## 2.5 - lista de regiões de naturalidade
regioes_list <-
  list(
    Norte = data.table(UF_NATURALIDADE = c("AM","AC","AP","PA","RO","RR","TO")),
    Nordeste = data.table(UF_NATURALIDADE = c("PB","RN","BA","CE","PE","MA","PI","SE","AL")),
    Sul = data.table(UF_NATURALIDADE = c("PR","SC","RS")),
    Sudeste = data.table(UF_NATURALIDADE = c("ES","MG","RJ","SP")),
    "Centro-Oeste" = data.table(UF_NATURALIDADE = c("DF","GO","MS","MT"))
  ) %>%
  rbindlist(idcol = "REGIAO_NATURALIDADE")


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


## Rodando consulta para cada mês
ti <- Sys.time()
transverais_ag_list <-
  sapply(meses_analise,
         function(m){
           cat("Conectando tabelão de ",m,"\n")
           df_tabelao <- spark_read_csv(
             sc,
             name = "tabelao",
             path = paste0(path_tabeloes,"VW001_TABELAO_SERV_",m,".csv")) %>%
             janitor::clean_names()

           cat("Filtro PEP e agregando\n\n")
           df_agreg_transv <-
             df_tabelao  %>%
             filter(!no_natureza_juridica %in% c("SERVICO PUBLICO ESTADUAL","EMPRESA PUBLICA","SOCIEDADE ECONOMIA  MISTA"),
                    co_orgao != 99072,
                    !sg_regime_juridico %in% c("RMI","ETE","ETG"),
                    !regime_jur_e_sit %in%
                      c(#"EST-18","EST-19",
                        "EST-41","EST-42","ANS-36","ANS-37"
                        ),
                    var_0001_situacao %in% 'ATIVO'
                    ) %>%
             group_by(
               across(
                 all_of(
                   c('compet',
                     agreg_min,
                     "co_sit_serv",
                     "no_sit_serv")
                   )
                 )
               ) %>%
             summarise(n = n()) %>%
             collect() %>%
             setDT()
           return(df_agreg_transv)
           },
         simplify = F)
(tf <- difftime(Sys.time(),ti,units = "secs"))

transverais_ag_tab <- rbindlist(transverais_ag_list,fill = T)

df_tabelao  %>%
  group_by(var_0001_situacao) %>%
  summarise(total = n())


df_orgao_vinc[orgao_vinc %in% sit_serv_origens[grepl("desc",no_sit_serv,ignore.case = T),co_orgao_origem],] %>% View("orgao_origem")


df_uorg_vinc     <- sdf_sql(sc,'SELECT * FROM `mgi-ouro`.`bd_dwsiape`.`UORG_VINC`')
df_grupo_natjur  <- sdf_sql(sc,'SELECT * FROM `mgi-ouro`.`bd_dwsiape`.`GRUPO_NAT_JURIDICA_CNNJ`') %>% collect %>% setDT()
df_natjur        <- sdf_sql(sc,'SELECT * FROM `mgi-ouro`.`bd_dwsiape`.`NATUREZA_JURIDICA_CNNJ`') %>% collect %>% setDT()
df_sitserv       <- sdf_sql(sc,'SELECT * FROM `mgi-ouro`.`bd_dwsiape`.`SITUACAO_FUNC_VINC_SERV`') %>% collect %>% setDT()
df_grupo_sitserv <- sdf_sql(sc,'SELECT * FROM `mgi-ouro`.`bd_dwsiape`.`GRUPO_SIT_VINC_SERV`') %>% collect %>% setDT()
a17              <- sdf_sql(sc,'SELECT * FROM `mgi-ouro`.`bd_dwsiape`.`ESTADO_VINC_SERV`') %>% collect %>% setDT()

df_tabelao %>%
  group_by(co_orgao,
           no_orgao,
           co_natureza_juridica,
           no_natureza_juridica) %>%
  summarise(total = n()) %>%
  collect() %>%
  setDT -> tabelao_org_vinc

tabelao_org_vinc <-
  left_join(tabelao_org_vinc,df_orgao_vinc,
            by = c("co_orgao" = "orgao_vinc")
            ) %>%
  left_join(df_natjur %>% select(natureza_juridica_cnnj,nome_natureza_juridica_cnnj),
            by = "natureza_juridica_cnnj")%>%
  left_join(df_grupo_natjur %>% select(grupo_nat_juridica_cnnj,nome_grupo_nat_juridica_cnnj),
            by = "grupo_nat_juridica_cnnj")



df_dwsiape_mensal_situacao <- spark_read_parquet(
    sc,
    name = "pep_historico",
    # delimiter = "\t",
    # path = "/Volumes/mgi-bronze/raw_data_volumes/DIGID/CGINF/01.Bases_SAS/COEST/tabelao_csv/VW001_TABELAO_SERV_202602.csv",
    path = "/Volumes/mgi-bronze/raw_data_volumes/mgi/cginf/servidores_dwsiape_mensal_situacao") %>%
    janitor::clean_names()

###
# 4.1 - Carreiras Transversais ----
##



## agregação inicial
dt_transversais <-
  df_dwsiape_pfgp %>%
  filter(NOME_GRUPO_SIT_VINC_SERV %in% "Ativo") %>%
  mutate(efetivo = !(CARGO %in% 0 & CARGO_ORIGEM %in% 0)) %>%
  group_by(
    across(
      all_of(
        c(#agreg_min,
          "GRUPO_CARGO",
          "NOME_GRUPO_CARGO",
          "CARGO",
          "NOME_CARGO",
          "NOME2_CARGO",
          "NOME_GRUPO_SIT_VINC_SERV",
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

