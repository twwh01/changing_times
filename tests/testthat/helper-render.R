# Forces ggplot2 to compute the per-layer data and resolve scales, surfacing
# errors that bare construction would defer to draw time (invalid scale
# limits, missing aesthetic mappings, mis-typed columns, etc.). For patchwork
# compositions we render into a null PDF device instead, since `ggplot_build`
# on a patchwork only walks the top-level layout.
expect_builds <- function(object) {
  if (inherits(object, "patchwork")) {
    tmp <- tempfile(fileext = ".pdf")
    grDevices::pdf(file = tmp)
    on.exit(
      {
        grDevices::dev.off()
        unlink(tmp)
      },
      add = TRUE
    )
    testthat::expect_no_error(print(object))
  } else {
    testthat::expect_no_error(ggplot2::ggplot_build(object))
  }
  invisible(object)
}
