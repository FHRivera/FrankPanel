#' Construir la grilla base de un panel RIC por periodo
#'
#' Parte de un data.frame que contiene RICs y crea una observacion por RIC y
#' anio. Los periodos pueden quedar expresados como `year`, `FY` o ambos.
#'
#' @param df Data frame con una columna de RICs.
#' @param ric_col Nombre de la columna que contiene los RICs. Por defecto `RIC`.
#' @param start_year Primer anio del panel.
#' @param end_year Ultimo anio del panel. Si se omite, usa `start_year`.
#' @param period_format Uno de `"both"`, `"year"` o `"FY"`.
#' @param keep_metadata Si es TRUE, conserva las columnas adicionales del
#'   data.frame original, tomando la primera observacion de cada RIC.
#'
#' @return Un data.frame de clase `frank_panel`.
#' @export
build_panel <- function(df,
                        ric_col = "RIC",
                        start_year,
                        end_year = start_year,
                        period_format = c("both", "year", "FY"),
                        keep_metadata = TRUE) {
  period_format <- match.arg(period_format)
  years <- .validate_years(start_year, end_year)
  rics <- .extract_rics(df, ric_col)

  panel <- expand.grid(
    RIC = rics,
    year = years,
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  panel <- panel[order(panel$RIC, panel$year), , drop = FALSE]
  panel$FY <- as_fy(panel$year)

  if (isTRUE(keep_metadata)) {
    input_ric <- trimws(as.character(df[[ric_col]]))
    idx <- match(rics, input_ric)
    metadata <- df[idx, setdiff(names(df), ric_col), drop = FALSE]
    metadata$RIC <- rics
    metadata <- metadata[, c("RIC", setdiff(names(metadata), "RIC")), drop = FALSE]
    panel <- merge(panel, metadata, by = "RIC", all.x = TRUE, sort = FALSE)
    panel <- panel[order(panel$RIC, panel$year), , drop = FALSE]
  }

  if (identical(period_format, "year")) {
    panel$FY <- NULL
  } else if (identical(period_format, "FY")) {
    panel$year <- NULL
  }

  rownames(panel) <- NULL
  class(panel) <- c("frank_panel", "data.frame")
  attr(panel, "period_format") <- period_format
  attr(panel, "ric_col_original") <- ric_col
  panel
}

#' Resumen de un panel FrankPanel
#'
#' @param x Objeto creado por [build_panel()] o [fetch_panel()].
#' @return Lista con numero de RICs, periodos y observaciones.
#' @export
panel_summary <- function(x) {
  if (!inherits(x, "frank_panel")) {
    stop("`x` debe ser un objeto de clase `frank_panel`.", call. = FALSE)
  }

  periods <- if ("year" %in% names(x)) x$year else x$FY
  list(
    n_rics = length(unique(x$RIC)),
    n_periods = length(unique(periods)),
    n_rows = nrow(x),
    period_format = attr(x, "period_format")
  )
}

#' @export
print.frank_panel <- function(x, ...) {
  s <- panel_summary(x)
  cat("<FrankPanel>\n")
  cat("  RICs:         ", s$n_rics, "\n", sep = "")
  cat("  Periodos:     ", s$n_periods, "\n", sep = "")
  cat("  Observaciones:", s$n_rows, "\n", sep = "")
  cat("  Formato:      ", s$period_format, "\n\n", sep = "")
  print.data.frame(utils::head(x, 10L), row.names = FALSE)
  if (nrow(x) > 10L) cat("...\n")
  invisible(x)
}
