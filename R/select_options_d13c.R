# options panel for d13C data selection
select_options_d13c_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    sliderInput(
      inputId = ns("selected_age"), 
      label = "Select minimum and maximum ages (Ma):",
      min = 485,
      max = 635,
      value = c(525, 575),
      round = TRUE,
      step = 1
    ),

    checkboxGroupInput(
      inputId = ns("age_models"),
      label = "Select which age model versions to show",
      choices = age_models_list,
      selected = age_models_list[1]
    ),
    
    selectInput(
      inputId = ns("background_model"),
      label = "Plot a specific model\nas background (grey) points?",
      choices = age_models_background_list,
      selected = age_models_background_list[1]
    ),
    
    selectInput(
      inputId = ns("point_colours"),
      label = "Select which variable\nto use for point colour:", 
      choices = c(
        "none", 
        "region", 
        "all-model age volatility",
        "selected model age volatility"
      ),
      selected = "none"
    ),
    
    checkboxInput(
      inputId = ns("roll_mean"),
      label = "Add ±25 point moving\naverage to each model?",
      value = FALSE
    )
  )
}


select_options_d13c_server <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
      
      # observe for choosing a model to include
      observeEvent(input$age_models, {
        print(paste0("You have chosen to compare: ", input$age_models))
      })
      
      # observe for choosing a background model to include
      observeEvent(input$background_model, {
        print(paste0("Your chosen background model is: ", input$background_model))
      })
      
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
        
        background_model = reactive({
          input$background_model
        }),
        
        point_colours = reactive({
          input$point_colours
        }),
        
        roll_mean = reactive({
          input$roll_mean
        })
      )
    }
  )
}
