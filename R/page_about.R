# Module UI for the About page.
page_about_ui <- function(id) {
  div(
    h2(
      "About",
      align = "left"
    ),
    
    h4("What is ", em("Changing Times"), "?"),
    p(em("Changing Times"), " is an interactive tool for understanding, quantifying, and visualising the
      differences between stratigraphic age models.
      I initially developed this tool to provide an intuitive way of seeing how age models for the Ediacaran-Cambrian
      transition (~580 to 510 million years ago) have changed in recent years.
      This beta release of ", em("Changing Times"), " is still in development and may change without notice until
      a first major version is released. "),
    p(em("Changing Times"), " has two built-in datasets: one for Ediacaran-Cambrian carbon isotope chronostratigraphy
      developed by Fred Bowyer, and one for the Miocene geomagnetic polarity timescale provided by Anna Joy Drury.
      The app is designed to be flexible and adaptable to other types of data and age models.
      If you find that your data do not work in the way you expect, please ",
      tags$a("contact me", href = "mailto:twonghearing@gmail.com"), "."),

    h4("How can ", em("Changing Times"), " help me?"),
    p("When working with temporal data it is important to make sure you are measuring datasets in the same temporal reference frame.
      However, age models change over time as new data and methods become available.
      Both acknowledged and unknown uncertainties associated with age models can be large, especially when working
      with deep time data, and can significantly affect dataset interpretations (e.g. Westerhold ", em("et al."), " 2024). ",
      em("Changing Times"), " helps to visualise and quantify the changes between different age model iterations, showing which
      time intervals have been most affected from one version to another.
      Overall, this can help show how stable age models are, and which time intervals may be subject to reinterpretation as
      chronostratigraphic methods and frameworks develop."),

    h4("Who's behind", em("Changing Times"), "?"),
    p(tags$a("Thomas Wong Hearing", href = "https://twwh01.github.io", target = "_blank", rel = "noopener noreferrer"),
      " developed the Shiny app and R code. Claude Code was used to refactor and write tests for the app.
      Fred Bowyer developed the Ediacaran-Cambrian stratigraphic age models (see Bowyer ", em("et al."), " 2023; 2024).
      Anna Joy Drury provided the Miocene geomagnetic polarity timescale data and age models."),

    h4("What's coming next?"),
    p(em("Changing Times"), " is still in development and this should be regarded as a beta release.
      Please ", tags$a("contact me", href = "mailto:twonghearing@gmail.com"), " if there are specific features you'd like to see.
      I am planning to include an option for saving out tables of datapoint/event age volatility, as well as options to download
      the code used for specific calculations and plot rendering. "),

    h4("References"),
    tags$ul(

      tags$li(
        "Bowyer, F.T., Uahengo, C.-I., et al. 2023.
        Constraining the onset and environmental setting of metazoan biomineralization: The Ediacaran Nama Group of the Tsaus Mountains, Namibia.
        Earth and Planetary Science Letters, 620, 118336, ",
        tags$a(href = "https://doi.org/10.1016/j.epsl.2023.118336", target = "_blank", "https://doi.org/10.1016/j.epsl.2023.118336"),
        "."
      ),

      tags$li(
        "Bowyer, F.T., Wood, R.A. and Yilales, M. 2024.
        Sea level controls on Ediacaran-Cambrian animal radiations.
        Science Advances, 10, eado6462, ",
        tags$a(href = "https://doi.org/10.1126/sciadv.ado6462", target = "_blank", "https://doi.org/10.1126/sciadv.ado6462"),
        "."
      ),

      tags$li(
        "Westerhold, T., Agnini, C., et al. 2024.
        Timing Is Everything.
        Paleoceanography and Paleoclimatology, 39, e2024PA004932, ",
        tags$a(href = "https://doi.org/10.1029/2024PA004932", target = "_blank", "https://doi.org/10.1029/2024PA004932"),
        "."
      )
    )
  )
}

# Module server for the About page.
page_about_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # static web page
    # do nothing
  })
}