.onAttach <- function(libname, pkgname) {
  version <- utils::packageVersion(pkgname)
  packageStartupMessage(
    paste0(
      "FrankPanel ", version,
      " | Desarrollado por Frank T. Huancollo Rivera\n",
      "Paneles RIC x periodo reproducibles desde R."
    )
  )
}
