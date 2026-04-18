# Module UI for the gpts page.
plot_gpts_age_ui <- function(id) {
  ns <- NS(id)
  tagList(
    plotOutput(outputId = ns("plot"), height = "700px")
  )
}


plot_gpts_age_server <- function(
    id,
    indata,
    selections
  ) {
  moduleServer(
    id,
    function(input, output, session) {

      plot_data <- reactive({
        d <- data_gpts_plot %>%
          dplyr::filter(age_model %in% selections$age_models())

        if (isTRUE(selections$volatility_colours() == "selected model age volatility")) {
          d <- d %>%
            dplyr::group_by(datum_id_base) %>%
            dplyr::mutate(
              selected_model_volatility_base = stats::sd(
                age_ma_base,
                na.rm = TRUE
              )
            ) %>%
            dplyr::ungroup()
        }
        d
      })

      output$plot <- renderPlot({
        plot_magnetostrat_upload(
          plot_data          = plot_data(),
          age_max_lim        = selections$age_max(),
          age_min_lim        = selections$age_min(),
          volatility_colours = selections$volatility_colours(),
          show_labels        = TRUE
        )
      })
    }
  )
}
