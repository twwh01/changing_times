# Helper: build the long-form plot_data the magnetostrat plot expects from a
# wide synthetic input, optionally injecting `selected_model_volatility_base`
# (which the real app computes inside the Shiny module, not in
# `prepare_magnetostrat_data`).
build_magnetostrat_plot_data <- function(df, with_selected_volatility = FALSE) {
  d <- prepare_magnetostrat_data(
    df                 = df,
    model_cols         = grep("^Model_", names(df), value = TRUE),
    model_names_prefix = "Model_"
  )
  if (with_selected_volatility) {
    d <- d %>%
      dplyr::group_by(Magnetochron) %>%
      dplyr::mutate(
        selected_model_volatility_base = stats::sd(age_ma_base, na.rm = TRUE)
      ) %>%
      dplyr::ungroup()
  }
  d
}

test_that("plot_magnetostrat_upload renders without volatility colouring or labels", {
  set.seed(1)
  pd <- build_magnetostrat_plot_data(synth_magnetostrat_wide())
  p <- plot_magnetostrat_upload(
    plot_data          = pd,
    age_max_lim        = 25,
    age_min_lim        = 0,
    volatility_colours = "none"
  )
  expect_s3_class(p, "ggplot")
  expect_builds(p)
})

test_that("plot_magnetostrat_upload renders with all-model volatility colouring", {
  set.seed(2)
  pd <- build_magnetostrat_plot_data(synth_magnetostrat_wide())
  p <- plot_magnetostrat_upload(
    plot_data          = pd,
    age_max_lim        = 25,
    age_min_lim        = 0,
    volatility_colours = "all-model age volatility"
  )
  expect_s3_class(p, "ggplot")
  expect_builds(p)
})

test_that("plot_magnetostrat_upload renders with selected-model volatility colouring", {
  set.seed(3)
  pd <- build_magnetostrat_plot_data(
    synth_magnetostrat_wide(),
    with_selected_volatility = TRUE
  )
  p <- plot_magnetostrat_upload(
    plot_data          = pd,
    age_max_lim        = 25,
    age_min_lim        = 0,
    volatility_colours = "selected model age volatility"
  )
  expect_s3_class(p, "ggplot")
  expect_builds(p)
})

test_that("plot_magnetostrat_upload returns a patchwork composition when show_labels = TRUE", {
  set.seed(4)
  pd <- build_magnetostrat_plot_data(synth_magnetostrat_wide())
  p <- plot_magnetostrat_upload(
    plot_data          = pd,
    age_max_lim        = 25,
    age_min_lim        = 0,
    volatility_colours = "all-model age volatility",
    show_labels        = TRUE
  )
  expect_s3_class(p, "patchwork")
  # Boundary chrons (the youngest and oldest in the synth) have NA on one
  # age edge, so `age_ma_mid` is NA and `geom_text` drops them with this
  # warning. Real magnetostrat data has the same shape at its boundaries.
  expect_warning(
    expect_builds(p),
    "Removed .* rows containing missing values"
  )
})
