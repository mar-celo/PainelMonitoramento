#!/usr/bin/env Rscript
# Entrypoint de producao — usado pelo Docker (nao editar app.R de desenvolvimento)

options(golem.app.prod = TRUE)

port <- as.integer(Sys.getenv("PORT", "3838"))
host <- Sys.getenv("HOST", "0.0.0.0")

message("Iniciando PainelMonitoramento na porta ", port)

shiny::runApp(
  PainelMonitoramento::run_app(),
  host = host,
  port = port
)
