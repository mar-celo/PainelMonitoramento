rsconnect::deployApp(
  appDir    = '.',
  appFiles  = c(
    'app.R', 'data-raw', 'DESCRIPTION', 'NAMESPACE',
    'R/app_config.R', 'R/app_server.R', 'R/app_ui.R',
    'R/mod_capa.R', 'R/mod_etnia_lideranca.R',
    'R/mod_indigenas.R',
    'R/mod_pfgp.R',
    'R/mod_pfgp_dim1.R', 'R/mod_pfgp_dim2.R', 'R/mod_pfgp_dim3.R',
    'R/mod_pfgp_dim4.R', 'R/mod_pfgp_dim5.R', 'R/mod_pfgp_dim6.R',
    'R/run_app.R', 'R/utils_ui.R', 'R/utils_pfgp.R', 'inst'
  ),
  forceUpdate = TRUE
)

rsconnect::showLogs(appName = "painelmonitoramento")
devtools::load_all()
run_app()
