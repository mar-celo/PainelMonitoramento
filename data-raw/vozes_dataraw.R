## code to prepare `teste_datarow` dataset goes here

## carregando dados ----
etl_vozes1 <- readRDS("data-raw/data_pfgp/etl_vozes1.rds")
etl_vozes2 <- readRDS("data-raw/data_pfgp/etl_vozes2.rds")
pfgp_vozes_itens <- readRDS("data-raw/data_pfgp/pfgp_vozes_itens.rds")

### inserindo relação com indicadores PFGP ----

### opção como fatores ----

# vozes1
etl_vozes1 <-
  dplyr::mutate(etl_vozes1,
                opcao.f = factor(opcao,
                                 levels = 1:5,
                                 labels = names(.likert_values),
                                 ordered = T)
                )


etl_vozes2 <-
  dplyr::mutate(etl_vozes2,
                opcao.f = factor(opcao,
                                 levels = 1:5,
                                 labels = names(.likert_values),
                                 ordered = T)
  )

usethis::use_data(etl_vozes1, overwrite = TRUE)
usethis::use_data(etl_vozes2, overwrite = TRUE)
usethis::use_data(pfgp_vozes_itens,overwrite = TRUE)
