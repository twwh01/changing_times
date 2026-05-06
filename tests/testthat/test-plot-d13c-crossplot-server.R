test_that("plot_data drops rows where either selected model is NA", {
  set.seed(1)
  indata <- synth_d13c_wide(n_points = 10, n_models = 2)
  shiny::testServer(
    app  = plot_d13c_crossplot_server,
    args = list(
      id         = "cross",
      indata     = indata,
      selections = make_d13c_crossplot_selections()
    ),
    expr = {
      d <- plot_data()
      expect_false(any(is.na(d$Model_A)))
      expect_false(any(is.na(d$Model_B)))
      # synth fixture sets Model_A NA for the first two rows
      expect_lt(nrow(d), nrow(indata))
    }
  )
})

test_that("plot_data filters by selections age range on both models", {
  set.seed(2)
  indata <- synth_d13c_wide(n_points = 30, n_models = 2)
  shiny::testServer(
    app  = plot_d13c_crossplot_server,
    args = list(
      id         = "cross",
      indata     = indata,
      selections = make_d13c_crossplot_selections(
        age_min = function() 540,
        age_max = function() 560
      )
    ),
    expr = {
      d <- plot_data()
      expect_true(all(d$Model_A >= 540 & d$Model_A <= 560))
      expect_true(all(d$Model_B >= 540 & d$Model_B <= 560))
    }
  )
})

test_that("plot_data returns no rows when the age range excludes all data", {
  set.seed(3)
  indata <- synth_d13c_wide(n_points = 10, n_models = 2)
  shiny::testServer(
    app  = plot_d13c_crossplot_server,
    args = list(
      id         = "cross",
      indata     = indata,
      selections = make_d13c_crossplot_selections(
        age_min = function() 0,
        age_max = function() 1
      )
    ),
    expr = {
      expect_equal(nrow(plot_data()), 0L)
    }
  )
})

test_that("plot_data coerces character d13c_carb to numeric", {
  set.seed(4)
  indata <- synth_d13c_wide(n_points = 10, n_models = 2)
  expect_type(indata$d13c_carb, "character")
  shiny::testServer(
    app  = plot_d13c_crossplot_server,
    args = list(
      id         = "cross",
      indata     = indata,
      selections = make_d13c_crossplot_selections()
    ),
    expr = {
      expect_true(is.numeric(plot_data()$d13c_carb))
    }
  )
})

test_that("plot_data coerces non-numeric model columns to numeric", {
  set.seed(5)
  indata <- synth_d13c_wide(n_points = 10, n_models = 2)
  indata$Model_A <- as.character(indata$Model_A)
  shiny::testServer(
    app  = plot_d13c_crossplot_server,
    args = list(
      id         = "cross",
      indata     = indata,
      selections = make_d13c_crossplot_selections()
    ),
    expr = {
      d <- plot_data()
      expect_true(is.numeric(d$Model_A))
      expect_true(is.numeric(d$Model_B))
    }
  )
})

test_that("plot_data validates that the selected model columns exist", {
  set.seed(6)
  indata <- synth_d13c_wide(n_points = 10, n_models = 2)
  shiny::testServer(
    app  = plot_d13c_crossplot_server,
    args = list(
      id         = "cross",
      indata     = indata,
      selections = make_d13c_crossplot_selections(
        model_x = function() "Model_DOES_NOT_EXIST"
      )
    ),
    expr = {
      expect_error(plot_data(), "Model_DOES_NOT_EXIST")
    }
  )
})

test_that("plot_d13c_crossplot builds with default numeric colour (d13c_carb)", {
  set.seed(7)
  indata <- synth_d13c_wide(n_points = 10, n_models = 2)
  indata$d13c_carb <- suppressWarnings(as.numeric(indata$d13c_carb))
  expect_builds(plot_d13c_crossplot(
    plot_data  = indata[!is.na(indata$Model_A), ],
    x_col      = "Model_A",
    y_col      = "Model_B",
    colour_var = "d13c_carb"
  ))
})

test_that("plot_d13c_crossplot builds with categorical colour (region)", {
  set.seed(8)
  indata <- synth_d13c_wide(n_points = 10, n_models = 2)
  expect_builds(plot_d13c_crossplot(
    plot_data  = indata[!is.na(indata$Model_A), ],
    x_col      = "Model_A",
    y_col      = "Model_B",
    colour_var = "region"
  ))
})

test_that("plot_d13c_crossplot builds with numeric colour (total_volatility)", {
  set.seed(9)
  indata <- synth_d13c_wide(n_points = 10, n_models = 2)
  expect_builds(plot_d13c_crossplot(
    plot_data  = indata[!is.na(indata$Model_A), ],
    x_col      = "Model_A",
    y_col      = "Model_B",
    colour_var = "total_volatility"
  ))
})

test_that("plot_d13c_crossplot builds with colour_var = 'none'", {
  set.seed(10)
  indata <- synth_d13c_wide(n_points = 10, n_models = 2)
  expect_builds(plot_d13c_crossplot(
    plot_data  = indata[!is.na(indata$Model_A), ],
    x_col      = "Model_A",
    y_col      = "Model_B",
    colour_var = "none"
  ))
})

test_that("plot_d13c_crossplot falls back to the no-colour layer when colour_var is missing", {
  set.seed(11)
  indata <- synth_d13c_wide(n_points = 10, n_models = 2)
  expect_builds(plot_d13c_crossplot(
    plot_data  = indata[!is.na(indata$Model_A), ],
    x_col      = "Model_A",
    y_col      = "Model_B",
    colour_var = "not_a_real_column"
  ))
})

test_that("select_options_d13c_crossplot_server exposes the expected reactives", {
  shiny::testServer(
    app = select_options_d13c_crossplot_server,
    expr = {
      session$setInputs(
        model_x      = "Model_X",
        model_y      = "Model_Y",
        colour_var   = "region",
        selected_age = c(530, 560)
      )
      sel <- session$returned
      expect_equal(sel$model_x(), "Model_X")
      expect_equal(sel$model_y(), "Model_Y")
      expect_equal(sel$colour_var(), "region")
      expect_equal(sel$age_min(), 530)
      expect_equal(sel$age_max(), 560)
    }
  )
})
