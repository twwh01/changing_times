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
      title = "Examples",

      tabsetPanel(
        tabPanel(
          title = HTML(paste0("Ediacaran-Cambrian δ", tags$sup("13"), "C stratigraphy")),

          tabsetPanel(
            sidebar_subtab(
              title       = "Stratigraphic plot",
              options_ui  = select_options_d13c_ui,
              options_id  = "select_options_d13c",
              plot_ui     = plot_d13c_age_ui,
              plot_id     = "plot_d13c_age",
              download_id = "download_plot_d13c"
            ),
            sidebar_subtab(
              title       = "Cross-plot",
              options_ui  = select_options_d13c_crossplot_ui,
              options_id  = "select_options_d13c_crossplot",
              plot_ui     = plot_d13c_crossplot_ui,
              plot_id     = "plot_d13c_crossplot",
              download_id = "download_plot_d13c_crossplot"
            )
          )
        ),

        sidebar_subtab(
          title       = "Miocene geomagnetic polarity timescale",
          options_ui  = select_options_gpts_ui,
          options_id  = "select_options_gpts",
          plot_ui     = plot_gpts_age_ui,
          plot_id     = "plot_gpts_age",
          download_id = "download_plot_gpts"
        )
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
          uiOutput("upload_example_panel"),
          plot_upload_age_ui(id = "plot_upload_age"),
          width = 9
        ),

        fluid = TRUE
      )
    )
  )
)
