# Helper compartilhado: spinner Gov.br para qualquer output
.spin <- function(x) {
  shinycssloaders::withSpinner(
    x,
    type             = 6,
    color            = "#1351b4",
    color.background = "#ffffff",
    size             = 0.7
  )
}
