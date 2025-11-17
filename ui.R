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
      title = HTML(paste0("\u03B4", tags$sup("13"), "C stratigraphy")),
      
      sidebarLayout(
        sidebarPanel(
          wellPanel(
            select_options_ui(id = "select_options")
          ),
          wellPanel(
            download_plot_ui(id = "download_plot")
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
      title = "About",
      page_about_ui(id = "About")
    ),

    tabPanel(
      title = "References",
      page_refs_ui(id = "Refs")
    )
  )
)
