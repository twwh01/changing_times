test_that("plot_data filters data_gpts_plot by selections$age_models()", {
  shiny::testServer(
    app  = plot_gpts_age_server,
    args = list(
      id         = "gpts",
      indata     = NULL,
      selections = make_gpts_selections(age_models = function() "GTS2011")
    ),
    expr = {
      expect_setequal(unique(plot_data()$age_model), "GTS2011")
    }
  )
})

test_that("plot_data omits selected_model_volatility_base by default", {
  shiny::testServer(
    app  = plot_gpts_age_server,
    args = list(
      id         = "gpts",
      indata     = NULL,
      selections = make_gpts_selections()
    ),
    expr = {
      expect_false("selected_model_volatility_base" %in% names(plot_data()))
    }
  )
})

test_that("plot_data adds selected_model_volatility_base under that colour option", {
  shiny::testServer(
    app  = plot_gpts_age_server,
    args = list(
      id         = "gpts",
      indata     = NULL,
      selections = make_gpts_selections(
        volatility_colours = function() "selected model age volatility"
      )
    ),
    expr = {
      d <- plot_data()
      expect_true("selected_model_volatility_base" %in% names(d))
      # Volatility should be constant per datum_id_base (one sd per chron base).
      per_datum <- d %>%
        dplyr::filter(!is.na(datum_id_base)) %>%
        dplyr::group_by(datum_id_base) %>%
        dplyr::summarise(
          n_unique = dplyr::n_distinct(selected_model_volatility_base)
        )
      expect_true(all(per_datum$n_unique == 1))
    }
  )
})
