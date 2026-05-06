# ui script for Changing Times
fluidPage(
    tags$head(
      tags$meta(name = "description", content = "An interactive web-based app for comparing different age models of Ediacaran-Cambrian stratigraphy"),
      tags$meta(name = "keywords", content = "Changing Times, Cambrian, Ediacaran, Stratigraphy, Carbon isotopes, App")
    ),

  # theme = shinytheme("sandstone"),
  theme = bs_theme(bootswatch = "minty", version = 5),

  navbarPage(
    id = "CT",
    title = "Changing Times",
    
    tabPanel(
      title = "About",
      page_about_ui(id = "About")
    ),
    
    tabPanel(
      title = HTML(paste0("Ediacaran-Cambrian \u03B4", tags$sup("13"), "C stratigraphy")),
      
      sidebarLayout(
        sidebarPanel(
          wellPanel(
            select_options_d13c_ui(id = "select_options_d13c")
          ),
          wellPanel(
            download_plot_ui(id = "download_plot_d13c")
          ),
          width = 3
        ),
          
        mainPanel(
          plot_d13c_age_ui(id = "plot_d13c_age"),
          width = 9
        ),
        
        fluid = TRUE
      )
    ),
    
    tabPanel(
      title = HTML(paste0("Miocene geomagnetic polarity timescale")),
      
      sidebarLayout(
        sidebarPanel(
          wellPanel(
            select_options_gpts_ui(id = "select_options_gpts")
          ),
          wellPanel(
            download_plot_ui(id = "download_plot_gpts")
          ),
          width = 3
        ),
        
        mainPanel(
          plot_gpts_age_ui(id = "plot_gpts_age"),
          width = 9
        ),
        
        fluid = TRUE
      )
    ),
    
    tabPanel(
      title = "Upload your own data",

      sidebarLayout(
        sidebarPanel(
          wellPanel(
            select_options_upload_ui(id = "select_options_upload")
          ),
          wellPanel(
            download_plot_ui(id = "download_plot_upload")
          ),
          width = 3
        ),

        mainPanel(
          h4("Example of the expected file structure"),
          p("Each row is one datum. Columns starting with ", code("Model_"),
            " hold age-in-Ma values under each age model — leave a cell blank
            (or use ", code("NA"), ") if a datum is not represented in a given model.
            Add at least one additional column for the value to plot, plus any
            extra columns to colour by. See the About tab for the full
            specification, including the magnetostratigraphy format."),
          HTML(knitr::kable(
            data.frame(
              id                 = c(1, 2, 3, 4),
              d13c               = c(2.1, -1.4,  0.8, -2.3),
              Model_A_2024       = c(540.5, 538.2, NA, 535.1),
              Model_B_2025       = c(542.3, 540.0, 539.1, 537.0),
              region             = c("Namibia", "UK", "Oman", "Australia"),
              check.names        = FALSE
            ),
            format     = "html",
            table.attr = "class='table table-sm table-striped'",
            align      = c("r", "r", "r", "r", "l")
          )),
          hr(),
          plot_upload_age_ui(id = "plot_upload_age"),
          width = 9
        ),

        fluid = TRUE
      )
    )
  )
)
