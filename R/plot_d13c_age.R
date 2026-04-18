# Module UI for the d13C page.
plot_d13c_age_ui <- function(id) {
  ns <- NS(id)
  tagList(
    plotOutput(outputId = ns("plot"), height = "700px")
  )
}


plot_d13c_age_server <- function(
    id,
    indata,
    selections
  ) {
  moduleServer(
    id,
    function(input, output, session) {

      data_selected <- reactive({
        data_13c_plot %>%
          dplyr::filter(age_model %in% selections$age_models())
      })

      plot_data <- reactive({
        d <- data_selected()

        if (isTRUE(selections$roll_mean())) {
          d <- d %>%
            dplyr::group_by(age_model) %>%
            dplyr::arrange(age_model, age_ma) %>%
            dplyr::mutate(
              data_roll = slider::slide_dbl(
                .x        = d13c_carb,
                .f        = mean,
                .before   = 25,
                .after    = 25,
                .complete = FALSE
              )
            ) %>%
            dplyr::ungroup()
        }

        if (selections$point_colours() == "selected model age volatility") {
          d <- d %>%
            dplyr::group_by(datum_id) %>%
            dplyr::mutate(
              selected_model_volatility = stats::sd(age_ma, na.rm = TRUE)
            ) %>%
            dplyr::ungroup()
        }

        d
      })

      background_data <- reactive({
        bg <- selections$background_model()
        if (is.null(bg) || isTRUE(bg == "none")) {
          return(NULL)
        }
        data_13c_plot %>%
          dplyr::filter(age_model %in% bg)
      })

      output$plot <- renderPlot({
        plot_isotope_upload(
          plot_data       = plot_data(),
          background_data = background_data(),
          value_col       = "d13c_carb",
          age_max_lim     = selections$age_max(),
          age_min_lim     = selections$age_min(),
          point_colour    = selections$point_colours(),
          rolling_mean    = isTRUE(selections$roll_mean()),
          x_label         = expression(delta^13 * "C"[carb] * " (\u2030)")
        )
      })
    }
  )
}
