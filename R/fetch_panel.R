#' Construir y completar un panel mediante un proveedor externo
#'
#' `fetch_panel()` desacopla FrankPanel de la fuente de datos. El argumento
#' `fetcher` debe ser una funcion que reciba, como minimo, `request` y `fields`.
#' `request` contiene las columnas RIC, year y FY. La funcion debe devolver un
#' data.frame con RIC y year (o FY), mas las variables solicitadas.
#'
#' @param df Data frame con RICs.
#' @param fields Vector de nombres de variables/campos a solicitar.
#' @param start_year Primer anio.
#' @param end_year Ultimo anio. Si se omite, usa `start_year`.
#' @param fetcher Funcion que realiza la consulta al proveedor de datos.
#' @param ric_col Nombre de la columna RIC del data frame de entrada.
#' @param period_format Formato final: `"both"`, `"year"` o `"FY"`.
#' @param keep_metadata Conservar columnas adicionales del input.
#' @param ... Argumentos adicionales enviados a `fetcher`.
#'
#' @return Un data.frame de clase `frank_panel` con los datos descargados.
#' @export
fetch_panel <- function(df,
                        fields,
                        start_year,
                        end_year = start_year,
                        fetcher,
                        ric_col = "RIC",
                        period_format = c("both", "year", "FY"),
                        keep_metadata = TRUE,
                        ...) {
  period_format <- match.arg(period_format)

  if (!is.function(fetcher)) {
    stop("`fetcher` debe ser una funcion.", call. = FALSE)
  }
  if (missing(fields) || !length(fields)) {
    stop("Debe indicar al menos un campo en `fields`.", call. = FALSE)
  }

  request <- build_panel(
    df = df,
    ric_col = ric_col,
    start_year = start_year,
    end_year = end_year,
    period_format = "both",
    keep_metadata = FALSE
  )
  request <- unclass(request)
  class(request) <- "data.frame"

  downloaded <- fetcher(
    request = request,
    fields = fields,
    ...
  )

  if (!is.data.frame(downloaded)) {
    stop("`fetcher` debe devolver un data.frame.", call. = FALSE)
  }
  if (!"RIC" %in% names(downloaded)) {
    stop("El resultado de `fetcher` debe contener una columna `RIC`.", call. = FALSE)
  }
  if (!"year" %in% names(downloaded) && !"FY" %in% names(downloaded)) {
    stop("El resultado de `fetcher` debe contener `year` o `FY`.", call. = FALSE)
  }

  if (!"year" %in% names(downloaded)) {
    downloaded$year <- suppressWarnings(as.integer(sub("^FY", "", downloaded$FY)))
  }
  if (!"FY" %in% names(downloaded)) {
    downloaded$FY <- as_fy(downloaded$year)
  }

  base <- build_panel(
    df = df,
    ric_col = ric_col,
    start_year = start_year,
    end_year = end_year,
    period_format = "both",
    keep_metadata = keep_metadata
  )
  base_df <- unclass(base)
  class(base_df) <- "data.frame"

  duplicated_keys <- duplicated(downloaded[c("RIC", "year")])
  if (any(duplicated_keys)) {
    stop(
      "El `fetcher` devolvio mas de una fila por combinacion RIC-year. ",
      "Agregue o transforme los datos antes de devolverlos.",
      call. = FALSE
    )
  }

  downloaded$FY <- NULL
  out <- merge(base_df, downloaded, by = c("RIC", "year"), all.x = TRUE, sort = FALSE)
  out <- out[order(out$RIC, out$year), , drop = FALSE]
  out$FY <- as_fy(out$year)

  # Colocar las llaves al inicio.
  key_cols <- c("RIC", "year", "FY")
  out <- out[, c(key_cols, setdiff(names(out), key_cols)), drop = FALSE]

  if (identical(period_format, "year")) {
    out$FY <- NULL
  } else if (identical(period_format, "FY")) {
    out$year <- NULL
  }

  rownames(out) <- NULL
  class(out) <- c("frank_panel", "data.frame")
  attr(out, "period_format") <- period_format
  attr(out, "ric_col_original") <- ric_col
  out
}
