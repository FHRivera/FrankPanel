# Publicar FrankPanel en GitHub

## Opcion A: desde RStudio

```r
install.packages(c("usethis", "devtools", "roxygen2", "testthat"))

# Abrir FrankPanel.Rproj y ejecutar:
devtools::document()
devtools::test()
devtools::check()

# Si git ya esta configurado:
usethis::use_git()
usethis::use_github()
```

## Opcion B: repositorio creado manualmente

1. Crear un repositorio llamado `FrankPanel` en GitHub.
2. Subir todo el contenido de esta carpeta.
3. En cualquier computador instalar con:

```r
install.packages("remotes")
remotes::install_github("FHRivera/FrankPanel")
library(FrankPanel)
```
