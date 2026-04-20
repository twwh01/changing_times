test_that("plot_isotope_upload renders with no point colouring", {
  set.seed(1)
  d <- synth_isotope_data()
  p <- plot_isotope_upload(
    plot_data    = d,
    value_col    = "value",
    age_max_lim  = 650,
    age_min_lim  = 450,
    point_colour = "none"
  )
  expect_s3_class(p, "ggplot")
})

test_that("plot_isotope_upload renders with all-model age volatility colouring", {
  set.seed(2)
  d <- synth_isotope_data()
  p <- plot_isotope_upload(
    plot_data    = d,
    value_col    = "value",
    age_max_lim  = 650,
    age_min_lim  = 450,
    point_colour = "all-model age volatility"
  )
  expect_s3_class(p, "ggplot")
})

test_that("plot_isotope_upload renders with selected-model age volatility colouring", {
  set.seed(3)
  d <- synth_isotope_data()
  p <- plot_isotope_upload(
    plot_data    = d,
    value_col    = "value",
    age_max_lim  = 650,
    age_min_lim  = 450,
    point_colour = "selected model age volatility"
  )
  expect_s3_class(p, "ggplot")
})

test_that("plot_isotope_upload renders with a categorical column for point colour", {
  set.seed(4)
  d <- synth_isotope_data()
  d$category <- sample(c("A", "B", "C"), nrow(d), replace = TRUE)
  p <- plot_isotope_upload(
    plot_data    = d,
    value_col    = "value",
    age_max_lim  = 650,
    age_min_lim  = 450,
    point_colour = "category"
  )
  expect_s3_class(p, "ggplot")
})

test_that("plot_isotope_upload renders with rolling mean overlay", {
  set.seed(5)
  d <- synth_isotope_data() %>%
    dplyr::group_by(age_model) %>%
    dplyr::arrange(age_ma, .by_group = TRUE) %>%
    dplyr::mutate(
      data_roll = slider::slide_dbl(value, mean, .before = 3, .after = 3, .complete = FALSE)
    ) %>%
    dplyr::ungroup()
  p <- plot_isotope_upload(
    plot_data    = d,
    value_col    = "value",
    age_max_lim  = 650,
    age_min_lim  = 450,
    point_colour = "none",
    rolling_mean = TRUE
  )
  expect_s3_class(p, "ggplot")
})

test_that("plot_isotope_upload renders with background data overlay", {
  set.seed(6)
  d  <- synth_isotope_data()
  bg <- synth_isotope_data()
  p <- plot_isotope_upload(
    plot_data       = d,
    background_data = bg,
    value_col       = "value",
    age_max_lim     = 650,
    age_min_lim     = 450,
    point_colour    = "none"
  )
  expect_s3_class(p, "ggplot")
})
