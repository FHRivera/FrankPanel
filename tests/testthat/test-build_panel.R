test_that("build_panel crea RIC x year correctamente", {
  x <- data.frame(RIC = c("AAA.SN", "BBB.O"))
  p <- build_panel(x, start_year = 2024, end_year = 2025)

  expect_s3_class(p, "frank_panel")
  expect_equal(nrow(p), 4L)
  expect_true(all(c("RIC", "year", "FY") %in% names(p)))
  expect_equal(sort(unique(p$FY)), c("FY2024", "FY2025"))
})

test_that("build_panel elimina RICs duplicados", {
  x <- data.frame(RIC = c("AAA.SN", "AAA.SN", "BBB.O"))
  p <- build_panel(x, start_year = 2025)
  expect_equal(nrow(p), 2L)
})

test_that("fetch_panel combina datos del proveedor", {
  x <- data.frame(RIC = c("AAA.SN", "BBB.O"))
  fake <- function(request, fields, ...) {
    data.frame(
      RIC = request$RIC,
      year = request$year,
      valor = seq_len(nrow(request))
    )
  }

  p <- fetch_panel(
    x,
    fields = "valor",
    start_year = 2024,
    end_year = 2025,
    fetcher = fake
  )

  expect_equal(nrow(p), 4L)
  expect_true("valor" %in% names(p))
})
