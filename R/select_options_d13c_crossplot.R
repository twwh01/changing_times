# options panel for the d13C model-vs-model cross-plot
select_options_d13c_crossplot_ui <- function(id) {
  ns <- NS(id)

  default_x <- if (length(age_models_list) >= 2) age_models_list[2] else age_models_list[1]
  default_y <- age_models_list[1]

  tagList(
    sliderInput(
      inputId = ns("selected_age"),
      label   = "Restrict to ages between (Ma):",
      min     = 485,
      max     = 635,
      value   = c(525, 575),
      round   = TRUE,
      step    = 1
    ),

    selectInput(
      inputId  = ns("model_x"),
      label    = "Model on x-axis:",
      choices  = age_models_list,
      selected = default_x
    ),
    selectInput(
      inputId  = ns("model_y"),
      label    = "Model on y-axis:",
      choices  = age_models_list,
      selected = default_y
    ),
    selectInput(
      inputId  = ns("colour_var"),
      label    = "Variable for point colour:",
      choices  = c(
        "d13C value"               = "d13c_carb",
        "region"                   = "region",
        "lithofacies association"  = "crude_lithofacies_association",
        "all-model age volatility" = "total_volatility",
        "none"                     = "none"
      ),
      selected = "d13c_carb"
    )
  )
}


select_options_d13c_crossplot_server <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
      list(
        age_min    = reactive(min(input$selected_age, na.rm = TRUE)),
        age_max    = reactive(max(input$selected_age, na.rm = TRUE)),
        model_x    = reactive(input$model_x),
        model_y    = reactive(input$model_y),
        colour_var = reactive(input$colour_var)
      )
    }
  )
}
