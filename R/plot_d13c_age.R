# Module UI for the d13C page.
plot_d13c_age_ui <- function(id) {
  ns <- NS(id)
  tagList(
    # textOutput(outputId = ns("background")), 
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
      
      data_selections <- reactive({
        data_13c_plot %>%
          dplyr::filter(
            age_model %in% selections$age_models()
          )
      })
      
      rolling_mean <- reactive({
        selections$roll_mean()
      })
      
      point_colour <- reactive({
        selections$point_colours()
      })
      
      # add rolling mean if requested
      data_selected <- reactive({
        if(isTRUE(rolling_mean())){
          data_selections() %>%
            dplyr::group_by(age_model) %>%
            dplyr::arrange(age_model, age_ma) %>%
            dplyr::mutate(
              data_roll = slider::slide_dbl(
                .x = d13c_carb,
                .f = mean,
                .before = 25, # 25 points before
                .after  = 25, # 25 points after
                .complete = FALSE
              )
            ) %>%
            dplyr::ungroup()
        }else{
          data_selections()
        }
      })
      
      # check for point colours
      plot_data <- reactive({
        if(point_colour() == "selected model age volatility") {
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

      # make background dataset for ggplot annotation
      background_dataset <- reactive({
        data_13c_plot %>% 
            dplyr::filter(
              age_model %in% selections$background_model()
            )
      })
        
      age_max_lim <- reactive({
        selections$age_max()
      })
      age_min_lim <- reactive({
        selections$age_min()
      })
      
      x_max_lim <- reactive({
        plot_data() %>%
          dplyr::filter(
            age_ma >= age_min_lim() &
              age_ma <= age_max_lim()
          ) %>%
          dplyr::pull(d13c_carb) %>%
          max(., na.rm = TRUE)
      })
      x_min_lim <- reactive({
        plot_data() %>%
          dplyr::filter(
            age_ma >= age_min_lim() &
              age_ma <= age_max_lim()
          ) %>%
          dplyr::pull(d13c_carb) %>%
          min(., na.rm = TRUE)
      })

      output$plot <- renderPlot({
        plot_d13c(
          plot_data(), 
          background_dataset(), 
          age_max_lim(), 
          age_min_lim(), 
          x_max_lim(), 
          x_min_lim(),
          rolling_mean(), 
          point_colour()
        )
      })
    }
  )
}
