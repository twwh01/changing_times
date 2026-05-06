test_that("plot_data_full attaches total_volatility and pivots to long form", {
  set.seed(1)
  shiny::testServer(
    app  = plot_upload_age_server,
    args = list(selections = make_upload_selections()),
    expr = {
      d <- plot_data_full()
      expect_true(all(c(
        "datum_id", "age_ma", "age_model", "age_model_label",
        "value", "total_volatility"
      ) %in% names(d)))
      expect_s3_class(d$age_model_label, "factor")
      expect_false(any(is.na(d$age_ma)))
    }
  )
})

test_that("plot_data filters by selections$age_models()", {
  set.seed(2)
  shiny::testServer(
    app  = plot_upload_age_server,
    args = list(selections = make_upload_selections(
      age_models = function() "Model_A"
    )),
    expr = {
      expect_setequal(unique(plot_data()$age_model), "Model_A")
    }
  )
})

test_that("plot_data adds data_roll when isotope + roll_mean is TRUE", {
  set.seed(3)
  shiny::testServer(
    app  = plot_upload_age_server,
    args = list(selections = make_upload_selections(
      roll_mean   = function() TRUE,
      roll_window = function() 3
    )),
    expr = {
      d <- plot_data()
      expect_true("data_roll" %in% names(d))
      expect_true(is.numeric(d$data_roll))
    }
  )
})

test_that("plot_data omits data_roll for the isochron plot type", {
  set.seed(4)
  shiny::testServer(
    app  = plot_upload_age_server,
    args = list(selections = make_upload_selections(
      plot_type = function() "isochron",
      roll_mean = function() TRUE
    )),
    expr = {
      expect_false("data_roll" %in% names(plot_data()))
    }
  )
})

test_that("plot_data attaches selected_model_volatility under that colour option", {
  set.seed(5)
  shiny::testServer(
    app  = plot_upload_age_server,
    args = list(selections = make_upload_selections(
      point_colours = function() "selected model age volatility"
    )),
    expr = {
      d <- plot_data()
      expect_true("selected_model_volatility" %in% names(d))
      # One volatility value per datum_id (constant across age_model rows).
      per_datum <- d %>%
        dplyr::group_by(datum_id) %>%
        dplyr::summarise(n_unique = dplyr::n_distinct(selected_model_volatility))
      expect_true(all(per_datum$n_unique == 1))
    }
  )
})

test_that("background_data is NULL when background_model is 'none'", {
  set.seed(6)
  shiny::testServer(
    app  = plot_upload_age_server,
    args = list(selections = make_upload_selections()),
    expr = {
      expect_null(background_data())
    }
  )
})

test_that("background_data filters to the chosen model when set", {
  set.seed(7)
  shiny::testServer(
    app  = plot_upload_age_server,
    args = list(selections = make_upload_selections(
      background_model = function() "Model_A"
    )),
    expr = {
      d <- background_data()
      expect_s3_class(d, "data.frame")
      expect_setequal(unique(d$age_model), "Model_A")
    }
  )
})

test_that("background_data is NULL when the chosen model is not in model_cols", {
  set.seed(8)
  shiny::testServer(
    app  = plot_upload_age_server,
    args = list(selections = make_upload_selections(
      background_model = function() "Model_DOES_NOT_EXIST"
    )),
    expr = {
      expect_null(background_data())
    }
  )
})

test_that("crossplot_data filters to non-NA in both selected models and within age range", {
  set.seed(10)
  raw <- synth_upload_raw(n_rows = 20)
  raw$Model_A[1:3] <- NA
  shiny::testServer(
    app  = plot_upload_age_server,
    args = list(selections = make_upload_selections(
      raw_data     = function() raw,
      plot_type    = function() "crossplot",
      selected_age = function() c(8, 18)
    )),
    expr = {
      d <- crossplot_data()
      expect_false(any(is.na(d$Model_A)))
      expect_false(any(is.na(d$Model_B)))
      expect_true(all(d$Model_A >= 8 & d$Model_A <= 18))
      expect_true(all(d$Model_B >= 8 & d$Model_B <= 18))
    }
  )
})

test_that("crossplot_data coerces character model and colour columns to numeric", {
  set.seed(11)
  raw <- synth_upload_raw(n_rows = 12)
  raw$Model_A <- as.character(raw$Model_A)
  raw$value   <- as.character(raw$value)
  shiny::testServer(
    app  = plot_upload_age_server,
    args = list(selections = make_upload_selections(
      raw_data     = function() raw,
      plot_type    = function() "crossplot",
      selected_age = function() c(0, 50)
    )),
    expr = {
      d <- crossplot_data()
      expect_true(is.numeric(d$Model_A))
      expect_true(is.numeric(d$Model_B))
      expect_true(is.numeric(d$value))
    }
  )
})

test_that("crossplot_data validates that the selected model columns exist", {
  set.seed(12)
  raw <- synth_upload_raw(n_rows = 8)
  shiny::testServer(
    app  = plot_upload_age_server,
    args = list(selections = make_upload_selections(
      raw_data  = function() raw,
      plot_type = function() "crossplot",
      model_x   = function() "Model_DOES_NOT_EXIST"
    )),
    expr = {
      expect_error(crossplot_data(), "Model_DOES_NOT_EXIST")
    }
  )
})

test_that("magnetostrat_data prepares long-form data when magnetostrat columns are present", {
  set.seed(9)
  raw     <- synth_magnetostrat_wide(n_boundaries = 5, n_models = 2)
  m_cols  <- grep("^Model_", names(raw), value = TRUE)
  shiny::testServer(
    app  = plot_upload_age_server,
    args = list(selections = make_upload_selections(
      raw_data              = function() raw,
      model_cols            = function() m_cols,
      age_models            = function() m_cols,
      value_col             = function() "(none)",
      plot_type             = function() "isochron",
      magnetostrat          = function() TRUE,
      has_magnetostrat_cols = function() TRUE
    )),
    expr = {
      d <- magnetostrat_data()
      expect_true(all(c(
        "Magnetochron", "polarity", "age_model", "age_model_label",
        "age_ma_base", "age_ma_top", "age_ma_mid", "total_volatility_base"
      ) %in% names(d)))
    }
  )
})
