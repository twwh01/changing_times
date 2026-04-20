test_that("data_selected filters data_13c_plot by selections$age_models()", {
  shiny::testServer(
    app  = plot_d13c_age_server,
    args = list(
      id         = "d13c",
      indata     = NULL,
      selections = make_d13c_selections(age_models = function() "Model_A")
    ),
    expr = {
      expect_setequal(unique(data_selected()$age_model), "Model_A")
    }
  )
})

test_that("plot_data adds data_roll only when roll_mean is TRUE", {
  shiny::testServer(
    app  = plot_d13c_age_server,
    args = list(
      id         = "d13c",
      indata     = NULL,
      selections = make_d13c_selections()
    ),
    expr = {
      expect_false("data_roll" %in% names(plot_data()))
    }
  )

  shiny::testServer(
    app  = plot_d13c_age_server,
    args = list(
      id         = "d13c",
      indata     = NULL,
      selections = make_d13c_selections(roll_mean = function() TRUE)
    ),
    expr = {
      d <- plot_data()
      expect_true("data_roll" %in% names(d))
      expect_true(is.numeric(d$data_roll))
    }
  )
})

test_that("plot_data adds selected_model_volatility under that colour option", {
  shiny::testServer(
    app  = plot_d13c_age_server,
    args = list(
      id         = "d13c",
      indata     = NULL,
      selections = make_d13c_selections(
        point_colours = function() "selected model age volatility"
      )
    ),
    expr = {
      d <- plot_data()
      expect_true("selected_model_volatility" %in% names(d))
      per_datum <- d %>%
        dplyr::group_by(datum_id) %>%
        dplyr::summarise(n_unique = dplyr::n_distinct(selected_model_volatility))
      expect_true(all(per_datum$n_unique == 1))
    }
  )
})

test_that("background_data is NULL for 'none' and filters otherwise", {
  shiny::testServer(
    app  = plot_d13c_age_server,
    args = list(
      id         = "d13c",
      indata     = NULL,
      selections = make_d13c_selections()
    ),
    expr = {
      expect_null(background_data())
    }
  )

  shiny::testServer(
    app  = plot_d13c_age_server,
    args = list(
      id         = "d13c",
      indata     = NULL,
      selections = make_d13c_selections(
        background_model = function() "Model_A"
      )
    ),
    expr = {
      d <- background_data()
      expect_s3_class(d, "data.frame")
      expect_setequal(unique(d$age_model), "Model_A")
    }
  )
})
