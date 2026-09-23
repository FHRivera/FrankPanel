# FrankPanel

**FrankPanel** es un paquete de R para construir paneles reproducibles a partir
de un `data.frame` de RICs.

> Desarrollado por **Frank T. Huancollo Rivera**.

## Instalacion desde GitHub

Una vez que el repositorio este publicado:

```r
install.packages("remotes")
remotes::install_github("FHRivera/FrankPanel")

library(FrankPanel)
```

Al cargarlo se mostrara:

```text
FrankPanel 0.1.0 | Desarrollado por Frank T. Huancollo Rivera
Paneles RIC x periodo reproducibles desde R.
```

## 1. Crear un panel base

```r
library(FrankPanel)

empresas <- data.frame(
  RIC = c("COPEC.SN", "CENCOSUD.SN", "MSFT.O"),
  Company = c("Copec", "Cencosud", "Microsoft"),
  Country = c("Chile", "Chile", "United States")
)

panel <- build_panel(
  empresas,
  start_year = 2020,
  end_year = 2025,
  period_format = "both"
)

panel
```

El resultado contiene una fila por `RIC x year` e incluye:

- `RIC`
- `year`
- `FY` (`FY2020`, `FY2021`, ...)
- metadata original, si existe.

## 2. Conectar cualquier proveedor de datos

El proveedor se conecta mediante una funcion `fetcher`. Esto permite utilizar
LSEG Workspace, una API propia, archivos locales u otra fuente sin modificar el
motor de FrankPanel.

Ejemplo simulado:

```r
mi_fetcher <- function(request, fields, ...) {
  data.frame(
    RIC = request$RIC,
    year = request$year,
    TotalRevenue = seq_len(nrow(request)) * 100,
    TotalAssets = seq_len(nrow(request)) * 250
  )
}

panel_datos <- fetch_panel(
  empresas,
  fields = c("TR.F.TotRevenue", "TR.F.TotAssets"),
  start_year = 2020,
  end_year = 2025,
  fetcher = mi_fetcher
)
```

## Arquitectura recomendada para LSEG

En una segunda etapa se puede agregar una funcion, por ejemplo:

```r
lseg_fetcher <- function(request, fields, ...) {
  # 1. autenticar contra LSEG
  # 2. transformar request$year a parametros FY
  # 3. descargar los campos
  # 4. devolver RIC + year + variables
}
```

Luego:

```r
panel <- fetch_panel(
  empresas,
  fields = c("TR.F.TotRevenue", "TR.F.NetIncome"),
  start_year = 2020,
  end_year = 2025,
  fetcher = lseg_fetcher
)
```

## Desarrollo

Desde RStudio, abrir `FrankPanel.Rproj` y ejecutar:

```r
install.packages(c("devtools", "roxygen2", "testthat"))
devtools::document()
devtools::test()
devtools::check()
```

Despues puede publicarse en GitHub y cualquier computador con acceso al
repositorio puede instalarlo con `remotes::install_github()`.
