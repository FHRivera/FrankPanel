#' Convertir un anio a etiqueta FY
#'
#' @param year Vector de anios enteros o convertibles a entero.
#' @return Un vector de caracteres con formato FY2025, FY2026, etc.
#' @export
as_fy <- function(year) {
  year_int <- suppressWarnings(as.integer(year))
  if (anyNA(year_int)) {
    stop("`year` contiene valores que no pueden convertirse a entero.", call. = FALSE)
  }
  paste0("FY", year_int)
}

.validate_years <- function(start_year, end_year) {
  start_year <- suppressWarnings(as.integer(start_year))
  end_year <- suppressWarnings(as.integer(end_year))

  if (length(start_year) != 1L || is.na(start_year)) {
    stop("`start_year` debe ser un unico anio valido.", call. = FALSE)
  }
  if (length(end_year) != 1L || is.na(end_year)) {
    stop("`end_year` debe ser un unico anio valido.", call. = FALSE)
  }
  if (start_year > end_year) {
    stop("`start_year` no puede ser mayor que `end_year`.", call. = FALSE)
  }

  seq.int(start_year, end_year)
}

.extract_rics <- function(df, ric_col) {
  if (!is.data.frame(df)) {
    stop("El insumo debe ser un data.frame.", call. = FALSE)
  }
  if (!ric_col %in% names(df)) {
    stop(sprintf("No existe la columna `%s` en el data.frame.", ric_col), call. = FALSE)
  }

  rics <- trimws(as.character(df[[ric_col]]))
  rics <- rics[!is.na(rics) & nzchar(rics)]
  rics <- unique(rics)

  if (!length(rics)) {
    stop("No se encontraron RICs validos.", call. = FALSE)
  }
  rics
}
