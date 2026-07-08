# ── Base: rocker/shiny com R 4.4 + shiny-server pré-instalado ────────────────
# --platform linux/amd64: necessário em Macs Apple Silicon (M1/M2/M3);
# garante também compatibilidade com o servidor Linux de produção.
FROM --platform=linux/amd64 rocker/shiny:4.4.2

# ── Dependências de sistema (necessárias para sf, plotly, etc.) ───────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    libudunits2-dev \
    libv8-dev \
    && rm -rf /var/lib/apt/lists/*

# ── Instala remotes para gerenciar dependências R ─────────────────────────────
RUN R -e "install.packages('remotes', \
    repos = 'https://packagemanager.posit.co/cran/__linux__/jammy/latest', \
    quiet = TRUE)"

# ── Camada de dependências R (cache: só reexecuta se DESCRIPTION mudar) ───────
COPY DESCRIPTION NAMESPACE /tmp/pkg/
RUN R -e "remotes::install_deps('/tmp/pkg', \
    dependencies = TRUE, \
    repos = 'https://packagemanager.posit.co/cran/__linux__/jammy/latest', \
    upgrade = 'never', \
    quiet = TRUE)"

# ── Copia o projeto completo ───────────────────────────────────────────────────
WORKDIR /app
COPY . /app/

# Ancora here::here() na raiz /app (necessário porque o pacote é instalado
# em /usr/local/lib/R/library, mas os dados ficam em /app/data-raw/)
RUN touch /app/.here

# ── Instala o pacote golem diretamente no library do sistema ──────────────────
RUN R CMD INSTALL /app

# ── Expõe a porta padrão do Shiny ────────────────────────────────────────────
EXPOSE 3838

# ── Entrypoint de produção ────────────────────────────────────────────────────
CMD ["Rscript", "/app/prod.R"]
