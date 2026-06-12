# Correções aplicadas em `mod_pfgp.R` para deploy no shinyapps.io

## 1. Operador pipe `%>%` → `|>`

**Problema:** O operador `%>%` do pacote `magrittr` não estava disponível no servidor — `magrittr` não está listado nos `Imports` do `DESCRIPTION`.

**Correção:** Todos os 24 usos de `%>%` foram substituídos pelo pipe nativo do R (`|>`), disponível desde R 4.1 (servidor usa R 4.4.1).

---

## 2. Pipe nativo sem parênteses: `|> as.numeric` → `|> as.numeric()`

**Problema:** O pipe nativo do R exige uma **chamada de função** (com parênteses) no lado direito. `|> as.numeric` sem `()` é sintaticamente inválido e causa erro em runtime.

**Correção:** Substituídas as 3 ocorrências de `substr(MES,1,4) |> as.numeric` por `substr(MES,1,4) |> as.numeric()`.

---

## 3. Funções `dplyr` sem prefixo de namespace

**Problema:** Funções como `filter()`, `mutate()`, `group_by()`, `summarise()` eram chamadas sem o prefixo `dplyr::`. Localmente `devtools::load_all()` resolve isso, mas no servidor o pacote não é instalado — as funções ficam inacessíveis e o app desconecta com `could not find function "mutate"`.

**Correção:** Adicionado prefixo `dplyr::` em todas as 18 ocorrências via script Python (para evitar falsos positivos do `sed` com word boundaries).

**Funções afetadas:** `filter`, `mutate`, `group_by`, `summarise`, `summarize`, `select`, `arrange`, `left_join`, `inner_join`, `rename`, `distinct`, `pull`, `ungroup`, `count`.

---

## 4. Variável `dt_liderancas` → `df_liderancas`

**Problema:** O dado é carregado na linha 160 como `df_liderancas` mas referenciado em 3 trechos como `dt_liderancas` — mismatch de nome que causava `object 'dt_liderancas' not found` e disconnected imediato.

**Correção:** Renomeadas as 3 ocorrências de `dt_liderancas` para `df_liderancas`.

---

## 5. Funções auxiliares `ggplot_cat()` e `ggplotly_c()` não disponíveis no servidor

**Problema:** As funções `ggplot_cat()` e `ggplotly_c()` estavam definidas em `data/setup_rmd.R`, que **não é incluído no bundle de deploy**. O servidor não encontrava as funções e lançava `could not find function "ggplot_cat"`.

**Correção:** Criado o arquivo `R/utils_pfgp.R` com as definições dessas funções e seus objetos dependentes (paletas de cores, tema `.plot_config`, escalas ggplot2), usando prefixos `ggplot2::` em todas as chamadas.

---

## 6. `scale_fill_manual`/`scale_color_manual` quebrando `ggplotly()`

**Problema:** A versão inicial de `ggplot_cat()` em `utils_pfgp.R` aplicava escalas manuais de cor (`scale_fill_manual`, `scale_color_manual`). Essas escalas causavam erro `subscript out of bounds` na conversão `ggplotly()` → `gg2list()`.

**Correção:** Removidas as escalas manuais de `ggplot_cat()`. A função agora aplica apenas o tema (`.plot_config`), deixando o ggplot2 usar suas escalas discretas padrão, totalmente suportadas pelo plotly.

---

## 7. `geom_line(size = .8)` → `geom_line(linewidth = .8)`

**Problema:** O parâmetro `size` para espessura de linhas foi **depreciado no ggplot2 3.4.0**, substituído por `linewidth`. No servidor (ggplot2 ≥ 3.4), o uso de `size` em `geom_line` gera warning e pode causar comportamento inesperado na conversão para plotly.

**Correção:** Substituído `size = .8` por `linewidth = .8` nas 3 ocorrências de `geom_line`.

---

## Arquivo criado

| Arquivo | Descrição |
|---|---|
| `R/utils_pfgp.R` | Funções `ggplot_cat()`, `ggplotly_c()`, paletas e tema base extraídos de `data/setup_rmd.R` para disponibilização no pacote deployado |
