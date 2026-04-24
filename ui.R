# ui script for Evolving Age Models
fluidPage(
    tags$head(
      tags$meta(name = "description", content = "An interactive web-based app for comparing different age models of Ediacaran-Cambrian stratigraphy"),
      tags$meta(name = "keywords", content = "Evolving Age Models, Cambrian, Ediacaran, Stratigraphy, Carbon isotopes, App")
    ),
  
  # theme = shinytheme("sandstone"),
  theme = bs_theme(bootswatch = "minty", version = 5),
  
  navbarPage(
    id = "EAM",
    title = "Evolving Age Models",
    
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
          plot_upload_age_ui(id = "plot_upload_age"),
          width = 9
        ),

        fluid = TRUE
      )
    )
  )
)
