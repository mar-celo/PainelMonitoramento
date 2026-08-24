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


# salvando lista de siglas de órgãos
lista_orgaos <- transverais_ag_tab[,unique(sg_orgao)]
save(lista_orgaos,file = "data-raw/data_pfgp.rda")

# ==============================================================================.
# Dimensão 1 -------
# ==============================================================================.


###
# 11 - Equidade de distribuição ----
##

## agregados mínimos para os indicadores
agreg_min <- c(# "CO_ORGAO",
               # "SG_ORGAO",
               # "NO_ORGAO",
               # "NO_NATUREZA_JURIDICA",
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
                    var_0048_qtd_serv_p %in% 1) %>%
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
             mutate(idade_servidor = cut(idade_servidor,
                                       breaks = c(0,18,30,45,60,120),
                                       include.lowest = T,
                                       right = F
                                       )
                    ) %>%
             group_by(
               across(
                 all_of(
                   c('compet',
                     agreg_min ,
                     "var_0001_situacao",
                     "var_0048_qtd_serv_p") %>%
                     # das colunas listadas, pegando apenas as colunas disponíveis
                     intersect(colunas_dispoiniveis)
                 )
               )
             ) %>%
             summarise(n = n()) %>%
             collect() %>%
             setDT() %>%
             setnames('idade_servidor',"faixa_etaria")
           Sys.sleep(30)
           return(ativos_equidade)
         },
         simplify = F)
(tf <- difftime(Sys.time(),ti,units = "secs"))

# juntando todas as competências
ativos_equidade_tab <- rbindlist(ativos_equidade_list,fill = T)

# transformando faixas etárias
ativos_equidade_tab[,`:=`(

  # faixa etária como fator
  faixa_etaria.f =
    ifelse(grepl("18\\]$",faixa_etaria),
           "Até 18 anos",
           ifelse(grepl("^\\[60",faixa_etaria),
                  "60 anos ou mais",
                  faixa_etaria)
           ) %>%
    gsub("\\[|\\)","",.) %>%
    gsub(","," a ",.) %>%
    factor(ordered = T),

  # sexo como 'Homens' ou 'Mulheres
  sexo = ifelse(co_sexo == "F","Mulheres","Homens")
  )]

# lendo base do censo e compatibilizando
base_censo <- readRDS('data-raw/data_pfgp/base_censo.rds') %>%
  setDT %>%
  # tirando '25 ou mais' e '65 ou mais' e variáveis
  filter(!faixa_etaria %in% c('25 anos ou mais','65 anos ou mais','25 a 64 anos')) %>%

  # limites da maior e da menor idade
  # .[,c("lim_inferior","lim_superior") :=(str_split_fixed(faixa_etaria," a ",n = 2) %>% as.data.table)]
  .[,ls := (str_split_fixed(faixa_etaria," a ",n = 2)[,2] %>%
              gsub("[[:alpha:]]","",.) %>%
              gsub("[[:space:]]","",.) %>%
              as.numeric())]
# se vazio, 80 ou mais
base_censo[,ls := ifelse(is.na(ls),80,ls)]

# recriando mesma faixa etária do tabelão
base_censo[,faixa_etaria.p := cut(ls,
                                  breaks = c(0,18,30,45,60,120),
                                  include.lowest = T,
                                  right = F
                                  )]
# somando população na nova faixa etária (só ensino superior)
base_censo[,pop.n := gsub("-","0",populacao) %>% as.numeric]
base_censo_fx <- base_censo[nivel_instrucao == "Superior completo",
                            .(populacao = sum(pop.n )),
                            .(no_cor_origem_etnica,
                              sexo,
                              no_regiao,
                              faixa_etaria.p)]

# juntando as bases
ativos_equidade_tab <-
  left_join(
    ativos_equidade_tab,
    base_censo_fx,
    by = c("no_cor_origem_etnica" = "no_cor_origem_etnica",
           "sexo" = "sexo",
           "no_regiao_naturalidade" = "no_regiao",
           "faixa_etaria" = "faixa_etaria.p")
  )

# marcando registros de não-informação (não se aplica, nao informado, etc)
categorias_interesse <-
  c("no_cor_origem_etnica",
    "sexo",
    "faixa_etaria.f",
    "no_regiao_naturalidade")
ativos_equidade_tab[,any_vazio :=
                      eval(
                        parse(
                          text =
                            paste0(
                              # "grepl(",
                              "(",
                              categorias_interesse,
                              " %in% c(NA,'NEGRA','NAO_SE_APLICA','N�O INFORMADO'))",
                              collapse = "|"
                              )
                          )
                        )]

## registrando vazios a serem excluídos
ativos_equidade_tab[,.(tot_siape = sum(n),
                       sum_vazio_ziape = sum(any_vazio*n),
                       mean_vazio_siape = 100*sum(any_vazio*n)/sum(n)),
                    .(compet)] -> vazios_excluidos

ativos_equidade_tab <- filter(ativos_equidade_tab,!any_vazio)

## percentuais dos grupos cruazdos e total 'NÃO-SIAPE', mês a mes
ativos_equidade_tab[,`:=`(n_fora_siape = populacao-n,
                          p_siape = 100*n/sum(n),
                          p_censo = 100*populacao/sum(populacao)),
                    .(compet)]

## razões de equidade nos grupos cruzados, mês a mes
ativos_equidade_tab[,equidade_cruzados := p_siape/p_censo]

## razões de equidade marginais, mês a mes
sapply(categorias_interesse,
       function(ct){
         ativos_equidade_tab %>%
           copy %>%
           .[,variavel := ct] %>%
           .[,.(n = sum(n),
                n_fora_siape = sum(n_fora_siape),
                populacao = sum(populacao)),
             by = c("compet","variavel",ct)] %>%
           .[,`:=`(p_siape = 100*n/sum(n),
                   p_censo = 100*populacao/sum(populacao)),
             .(compet)] %>%
           .[,equidade_marginais := p_siape/p_censo] %>%
           setnames(ct,"categoria")
       },
       simplify = F) %>%
  rbindlist(fill = T) -> ativos_equidade_marginais

## função chi-quadrado
calcula_chisq <- function(n_g1,n_g2){
  M <- as.table(rbind(n_g1,n_g2))
  chisq.test(M)$statistic
}


## medidas qui-quadrado cruzadas, mês a mês
ativos_equidade_tab[compet > 201912,.(total_geral = sum(populacao),
                                      qui_quadrado = calcula_chisq(n,n_fora_siape)),
                    .(compet)] -> equidade_chisq_cruzados

## contingência
equidade_chisq_cruzados[,coef_contin := sqrt(qui_quadrado/(qui_quadrado +total_geral ))/sqrt(1/2)]



## qui-quadrado marginais, mês a mês
ativos_equidade_marginais[,.(total_geral = sum(populacao),
                             qui_quadrado = calcula_chisq(n,n_fora_siape)),
                          .(variavel,compet)] -> equidade_chisq_marginais

## contingência
equidade_chisq_marginais[,coef_contin := sqrt(qui_quadrado/(qui_quadrado +total_geral ))/sqrt(1/2)]


equidade_chisq_marginais %>%
  ggplot(aes(x = compet,y = qui_quadrado/1e+3,color = variavel)) +
  geom_line() +
  geom_point(size = 2) +
  geom_line(data = equidade_chisq_cruzados,
            aes(x = compet,y = qui_quadrado/1e+3,col = "geral")
            )


equidade_chisq_marginais %>%
  ggplot_cat(aes(x = compet,y = coef_contin,color = variavel)) +
  ylim(c(0,0.23))+
  geom_line(size = 1.3) +
  geom_point(size = 2) +
  geom_text(aes(label = round(coef_contin,2)),
            vjust = -3) +
  geom_line(data = equidade_chisq_cruzados,
            aes(x = compet,y = coef_contin,col = "geral"),
            size = 1.3
  ) +
  geom_point(data = equidade_chisq_cruzados,
            aes(x = compet,y = coef_contin,col = "geral"),
            size = 2
  )  +
  geom_text(data = equidade_chisq_cruzados,
            aes(x = compet,
                y = coef_contin,
                label = round(coef_contin,2),
                col = "geral"),
            vjust = -3) +
  labs(col = NULL)


## razões de EQUIDADE X coeficientes de contingência
var_graph <- "no_cor_origem_etnica"

grafs_categ <-
  lapply(ativos_equidade_marginais$variavel %>% unique,
         function(var_graph){

           dt_var <- ativos_equidade_marginais[variavel == var_graph]
           dt_var_contin <- equidade_chisq_marginais[variavel == var_graph,]
           codf <- max(dt_var$equidade_marginais)/max(equidade_chisq_cruzados$coef_contin,na.rm = T)

           dt_var %>%
             ggplot_cat(
               aes(x = zoo::as.yearmon(as.character(compet),format = "%Y%m"))
             ) +
             geom_hline(aes(yintercept = 1)) +
             geom_line(
               aes(
                 y = equidade_marginais,
                 col = as.character(categoria)
               ),
               size = 1) +
             geom_point(
               aes(
                 y = equidade_marginais,
                 col = as.character(categoria)
               ),size = 2) +
             geom_line(
               data = dt_var_contin,
               aes(
                 x = zoo::as.yearmon(as.character(compet),format = "%Y%m"),
                 y = codf*coef_contin,
                 linetype = "Coef.Contingência\n da variável"),
               size = 1.3
             ) +
             geom_text(
               data = dt_var_contin,
               aes(
                 x = zoo::as.yearmon(as.character(compet),format = "%Y%m"),
                 y = codf*coef_contin,
                 label = round(coef_contin,2),
                 linetype = "Coef.Contingência\n da variável"),
               vjust = -2
               # size = 1.3
             ) +
             geom_line(
               data = equidade_chisq_cruzados,
               aes(
                 x = zoo::as.yearmon(as.character(compet),format = "%Y%m"),
                 y = codf*coef_contin,
                 linetype = "Coef.Contingência\n geral"),
               size = 1.3
             ) +
             scale_linetype_manual(
               values = c("Coef.Contingência\n da variável" = 2,
                          "Coef.Contingência\n geral" = 3)
             ) +
             scale_y_continuous(
               name = "Índide de equidade",
               sec.axis = sec_axis(coef_contin ~./codf,name = "Coef. de Contingência")
             ) +
             labs(title = var_graph,
                  y = "Índice equidade",
                  col = NULL,
                  x = NULL,
                  linetype = NULL)
         }
         )

library(patchwork)
plot_layout(grafs_categ[[1]] + grafs_categ[[2]] + grafs_categ[[3]] + grafs_categ[[4]],ncol = 2)

# salvando base
saveRDS(ativos_equidade_tab,'data-raw/data_pfgp/ativos_equidade.rds')
saveRDS(vazios_excluidos,'data-raw/data_pfgp/ativos_equidade_vazios.rds')



###
# 17 - Equidade de ingressos ----
##


library(data.table)
library(dplyr)
library(janitor)

src_tabelao <- "Y:/Temp/VW001_TABELAO_SERV_202604.csv"

colunas_tabelao <- fread(file.path(src_tabelao),nrows = 1) %>% names()

colunas_filtro_pep <- c("CO_NATUREZA_JURIDICA",
                        "CO_ORGAO",
                        "SG_REGIME_JURIDICO",
                        "REGIME_JUR_E_SIT",
                        "VAR_0001_SITUACAO")

agreg_min <- c("CO_ORGAO",
               "SG_ORGAO",
               "NO_ORGAO",
               "NO_NATUREZA_JURIDICA",
               'NO_COR_ORIGEM_ETNICA',
               'CO_SEXO',
               'NO_REGIAO_NATURALIDADE')

df_tabelao_202604 <- fread(file.path(src_tabelao),
                           select = c(colunas_filtro_pep,
                                      agreg_min,
                                      "DT_OCOR_INGR_SPUB_SERV") %>%
                             unique) %>%
  janitor::clean_names() %>%
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
  filter(dt_ocor_ingr_spub_serv != "") %>%
  mutate(
    dt_ingresso = format(as.Date(dt_ocor_ingr_spub_serv, "%d/%m/%Y"), "%Y%m"),
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
  filter(dt_ingresso >= 201600)

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

