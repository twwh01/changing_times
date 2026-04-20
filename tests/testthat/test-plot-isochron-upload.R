test_that("plot_isochron_upload renders with no value column", {
  set.seed(1)
  d <- synth_isotope_data()
  p <- plot_isochron_upload(
    plot_data          = d,
    value_col          = "(none)",
    age_max_lim        = 650,
    age_min_lim        = 450,
    volatility_colours = "none"
  )
  expect_s3_class(p, "ggplot")
  expect_builds(p)
})

test_that("plot_isochron_upload renders with a numeric value column and all-model volatility", {
  set.seed(2)
  d <- synth_isotope_data()
  p <- plot_isochron_upload(
    plot_data          = d,
    value_col          = "value",
    age_max_lim        = 650,
    age_min_lim        = 450,
    volatility_colours = "all-model age volatility"
  )
  expect_s3_class(p, "ggplot")
  expect_builds(p)
})

test_that("plot_isochron_upload renders with a categorical value column", {
  set.seed(3)
  d <- synth_isotope_data()
  d$category <- sample(c("A", "B", "C"), nrow(d), replace = TRUE)
  p <- plot_isochron_upload(
    plot_data          = d,
    value_col          = "category",
    age_max_lim        = 650,
    age_min_lim        = 450,
    volatility_colours = "selected model age volatility"
  )
  expect_s3_class(p, "ggplot")
  expect_builds(p)
})
