library(readxl)
library(dplyr)
library(tidyr)
library(zoo)
library(writexl)

# Ler arquivo
dados <- read_excel("C:/Users/aline.ramos/Downloads/tabela10061_br_uf.xlsx",col_names = FALSE)

# Cabeçalho multinível
cab <- dados[4:8, ]

# Preencher vazios horizontalmente
cab <- t(apply(cab, 1, zoo::na.locf, na.rm = FALSE))

cab <- as.data.frame(cab)

# Montar nomes completos
nomes <- apply(cab, 2, function(x){

  x <- x[!is.na(x)]

  paste(x, collapse = "|")

})

# Dados
base <- dados[-c(1:8,37), ]

names(base) <- nomes

# Primeira coluna = localidade
names(base)[1] <- "localidade"

# Formato longo
base_long <- base %>%
  pivot_longer(
    cols = -localidade,
    names_to = "categoria",
    values_to = "populacao"
  )

# Separar dimensões
base_final <- base_long %>%
  separate(
    categoria,
    into = c(
      "ano",
      "nivel_instrucao",
      "faixa_etaria",
      "sexo",
      "raca"
    ),
    sep = "\\|",
    fill = "right"
  )

base_final



tabela_censo <- base_final %>%
  filter(localidade != "Brasil",
         nivel_instrucao != "Total",
         !faixa_etaria %in% c("Total", "18 a 19 anos"),
         sexo != "Total",
         raca != "Total")

saveRDS(tabela_censo,"data-raw/data_pfgp/base_censo.rds")

#write_xlsx(tabela_censo, "C:/Users/aline.ramos/Documents/tabela_censo.xlsx")
