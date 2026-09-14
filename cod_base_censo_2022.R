library(dplyr)
library(purrr)
library(data.table) #necessária para rodar o setnames

ler_censo <- function(arquivo) {

  dados <- read.csv(
    arquivo,
    sep = ";",
    encoding = "UTF-8"
  )

  dados |>
    select(
      P0010,
      P0020,
      P0110,
      P0150,
      P0180,
      P0210,
      P0470,
      P0480,
      P0490,
      P0760

    )
}

arquivos <- list.files(
  path = "C:/Documentos/PFGP/base_censo_2022",
  pattern = "\\.csv$",
  recursive = TRUE,
  full.names = TRUE
)

censo_pessoas <- map_dfr(
  arquivos,
  ler_censo
)

pessoas_censo <-
  censo_pessoas |>
  group_by(
    P0010,
    P0020,
    P0150,
    P0180,
    P0210,
    P0470,
    P0480,
    P0490,
    P0760
  ) |>
  summarise(
    populacao_estimada = sum(P0110, na.rm = TRUE),
    .groups = "drop"
  )


setnames(pessoas_censo,
         c( "P0010",
            "P0020",
            "P0150",
            "P0180",
            "P0210",
            "P0470",
            "P0480",
            "P0490",
            "P0760"),
         c("grande_regiao",
           "UF",
           "sexo",
           "faixa_etaria",
           "cor_raca",
           "deficiencia",
           "local_nascimento",
           "UF_nascimento",
           "nivel_instrucao")
         )

#library(writexl)
#write_xlsx(pessoas_censo, "C:/Documentos/PFGP/pessoas_censo.xlsx")
saveRDS(pessoas_censo,"data-raw/data_pfgp/agregado_microdado_censo.rds" )
