# Melhores Práticas para R: Guia Rápido (Cheat Sheet)

Este documento resume as melhores práticas essenciais para a programação em R baseadas na "Cheat Sheet", cobrindo desde a configuração do ambiente até ao estilo de código, estruturação de projetos e criação de funções. Sendo o R uma ferramenta crucial na estatística e na análise avançada de dados, adotar um fluxo de trabalho rigoroso garante resultados mais robustos e facilmente reprodutíveis.

## 1. Software

* **RStudio:** Escreva o seu código no RStudio IDE.
* **Quarto:** Utilize o Quarto para programação literata (relatórios reprodutíveis).
* **Git:** Use o Git para o controlo de versões do seu código e das suas análises.
* **GitHub:** Use o GitHub para colaborar com outras pessoas.

## 2. Projetos

### Criação de Projetos
* Crie um novo projeto no RStudio usando `File > New Project > New Directory`.
* Coloque os projetos numa única pasta local (ex: `C:\\Users\\o-seu-nome\\Documents`).
* **Aviso:** Não coloque os projetos em localizações controladas pelo OneDrive ou iCloud (estes serviços não interagem bem com o Git).

### Estrutura do Projeto
Uma estrutura de projeto recomendada:
* `.gitignore`: indica ao git quais os ficheiros que não deve rastrear.
* `.Rprofile`: código R para correr no arranque.
* `R/`: pasta para scripts em R (deve definir funções aqui para usar noutros locais).
    * `01-import.R`
    * `02-tidy.R`
* `SQL/`: use pastas como esta para guardar dados ou outros tipos de ficheiros.
    * `costs.sql`
* `run-all.R`: use um script de nível superior para correr todo o código do projeto.
* `renv/` e `renv.lock`: registos de versões de dependências; criados com `renv::init()`.
* `meu-projeto.Rproj`: o ficheiro `.Rproj` transforma esta diretoria num projeto do RStudio.
* `README.md`: escreva os factos principais sobre o seu projeto aqui.

*Nota:* Utilizar `usethis::use_description()` e `usethis::use_namespace()` irá transformar esta estrutura num pacote de R.

## 3. Pacotes

Os pacotes devem ser carregados num único local através de chamadas sucessivas à função `library()`.
* **tidyverse:** para manipulação normal de dados, visualização, etc.
* **tidymodels:** para modelação e machine learning.
* **shiny, bslib e bs4Dash:** para o desenvolvimento de aplicações.
* **rlang e glue:** para programação de baixo nível.
* **renv:** usar em projetos de longo prazo para rastrear as dependências dos pacotes.

*Dica:* O número de estrelas no GitHub é um bom indicador da qualidade de um pacote. Se tiver >200 estrelas, provavelmente é bom!

## 4. Bases de Dados

* Utilize os pacotes `{DBI}` e `{odbc}` para se conectar a bases de dados SQL.
* Use funções auxiliares para criar ligações de forma limpa: