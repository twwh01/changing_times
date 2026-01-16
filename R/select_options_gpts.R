# options panel for d13C data selection
select_options_gpts_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    sliderInput(
      inputId = ns("selected_age"), 
      label = "Select minimum and maximum ages (Ma):",
      min = min(data_gpts_plot$age_ma_top - 2, na.rm = TRUE), 
      max = max(data_gpts_plot$age_ma_base + 2, na.rm = TRUE),
      value = c(min(data_gpts_plot$age_ma_top - 2, na.rm = TRUE), 
                max(data_gpts_plot$age_ma_base + 2, na.rm = TRUE)),
      round = TRUE,
      step = 1
    ),

    checkboxGroupInput(
      inputId = ns("age_models"),
      label = "Select which age model versions to show",
      choices = gpts_age_models_list, # from global.R
      selected = gpts_age_models_list
    ),
    
    selectInput(
      inputId = ns("volatility_colours"),
      label = "Select which variable\nto use for line and text colour:", 
      choices = c(
        "none", 
        "all-model age volatility",
        "selected model age volatility"
      ),
      selected = "all-model age volatility"
    )
  )
}


select_options_gpts_server <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
      
      # observe for choosing a model to include
      # observeEvent(input$age_models, {
      #   print(paste0("You have chosen to compare: ", input$age_models))
      # })
      
      list(
        age_min = reactive({
          input$selected_age %>% as.numeric() %>% min(., na.rm = TRUE)
        }),

        age_max = reactive({
          input$selected_age %>% as.numeric() %>% max(., na.rm = TRUE)
        }),

        age_models = reactive({
          input$age_models
        }),
        
        volatility_colours = reactive({
          input$volatility_colours
        })
      )
    }
  )
}
