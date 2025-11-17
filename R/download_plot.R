download_plot_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    selectInput(
      inputId = ns("plot_units"), 
      label = "Units for downloaded plot dimensions:",
      choices = c("mm", "cm", "in", "px"),
      selected = "mm",
      multiple = FALSE
    ), 
    
    numericInput(
      inputId = ns("plot_width"), 
      label = "Download plot width\n(in units specified above):",
      value = 350, 
      min = 0,
      max = NA,
      step = 1
    ),
    
    numericInput(
      inputId = ns("plot_height"), 
      label = "Download plot height\n(in units specified above):",
      value = 450, 
      min = 0,
      max = NA,
      step = 1
    ),
    
    numericInput(
      inputId = ns("plot_res"), 
      label = "Download plot resolution (dpi):",
      value = 450, 
      min = 0,
      max = NA,
      step = 1
    ),

    downloadButton(
      outputId = ns("download_plot_button"), 
      label = "Download plot as .png"
    )
  )
}


download_plot_server <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
      
      chosen_units <- reactive({
        input$plot_units %>% as.character()
      }) 
      
      chosen_width <- reactive({
        input$plot_width %>% as.integer()
      })
      
      chosen_height <- reactive({
        input$plot_height %>% as.integer()
      })
      
      chosen_res <- reactive({
        input$plot_res %>% as.integer()
      })
      
      output$download_plot_button <- downloadHandler(
        filename = "d13C_age_plot.png",
        content = function(file) {
          ggsave(
            filename = file, 
            plot = last_plot(), 
            device = "png",  
            width = chosen_width(),
            height = chosen_height(), 
            units = chosen_units(), 
            dpi = chosen_res()
          )
        }, 
        contentType = "image/png"
      )
    }
)}
