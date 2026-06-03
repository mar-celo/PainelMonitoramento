# ==============================================================================.
# 1. CONFIGURAÇÕES INICIAIS E BIBLIOTECAS -------
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
# 2. CONEXÃO as fontes de dados -------
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
