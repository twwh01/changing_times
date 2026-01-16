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
      
      data_selections <- reactive({
        data_gpts_plot %>%
          dplyr::filter(
            age_model %in% selections$age_models()
          )
      })
      
      # currently rolled together in volatility_colours
      # line_colour <- reactive({
      #   selections$volatility_colours()
      # })
      # text_colour <- reactive({
      #   selections$volatility_colours()
      # })
      volatility_colours <- reactive({
        selections$volatility_colours()
      })
      
      data_selected <- reactive({
        data_selections()
      })
      
      # check for colours
      plot_data <- reactive({
        if(volatility_colours() == "selected model age volatility") {
          data_selected() %>%
            dplyr::group_by(datum_id) %>%
            dplyr::mutate(
              selected_model_volatility = sd(age_ma, na.rm = TRUE)
            )
        } else {
          # all other options are covered in the data already
          data_selected()
        }
      })

      age_max_lim <- reactive({
        selections$age_max()
      })
      age_min_lim <- reactive({
        selections$age_min()
      })
      
      # not needed for gpts at present as this is done by age model selection for this plot
      # x_max_lim <- reactive({
      #   plot_data() %>%
      #     dplyr::filter(
      #       age_ma >= age_min_lim() &
      #         age_ma <= age_max_lim()
      #     ) %>%
      #     dplyr::pull(d13c_carb) %>%
      #     max(., na.rm = TRUE)
      # })
      # x_min_lim <- reactive({
      #   plot_data() %>%
      #     dplyr::filter(
      #       age_ma >= age_min_lim() &
      #         age_ma <= age_max_lim()
      #     ) %>%
      #     dplyr::pull(d13c_carb) %>%
      #     min(., na.rm = TRUE)
      # })

      output$plot <- renderPlot({
        plot_gpts(
          plot_data(), 
          age_max_lim(), 
          age_min_lim(), 
          # x_max_lim(), 
          # x_min_lim(),
          volatility_colours()
        )
      })
    }
  )
}
