# Module UI for the About page.
page_about_ui <- function(id) {
  div(
    h2(
      "About",
      align = "left"
    ),
    
    h4("What is ", em("Evolving Age Models"), "?"),
    p(em("Evolving Age Models"), " is an interactive web-based tool for visualising 
      the differences between stratigraphic age models. 
      I developed it initially to easily visualise the rapid change that age models 
      for the Ediacaran-Cambrian transition has gone through in the last few years. ", 
      em("Evolving Age Models"), " is in early development at present and is subject 
      to change substantially and without warning until a first major version is released.
      The app has two in-built datasets: one for Ediacaran-Cambrian carbon isotope 
      chronostratigraphy developed by Fred Bowyer, and one for the Miocene geomagnetic 
      polarity timescale. 
      The app is designed to be flexible and adaptable to other datasets and age models, 
      and I hope to add the option of uploading your own data in the future."),
    
    h4("Why bother with ", em("Evolving Age Models"), "?"),
    p("When working with temporal data it is important to make sure you are measuring 
      datasets against the same standard. However, age models change over time as 
      new data and methods become available. Especially when working with deep time 
      data, age model uncertainties can be very large, and can significantly affect 
      dataset interpretations (e.g. Westerhold ", em("et al."), " 2024). ", 
      em("Evolving Age Models"), " is being developed to help compare successive 
      iterations of age models in a visual and quantitative fashion, and to see 
      how the temporal stability of an age model has changed over time."),
    
    h4("Who's behind", em("Evolving Age Models"), "?"),
    p("Thomas Wong Hearing developed the Shiny app and R code. Fred Bowyer developed 
      the Ediacaran-Cambrian stratigraphic age models (see Bowyer ", em("et al."), 
      " 2023; 2024) on which this is based, including the carbon isotope stratigraphic 
      compilations. 
      Anna Joy Drury provided the Miocene geomagnetic polarity timescale data and 
      age models."),
    
    h4("What's coming next?"),
    p(em("Evolving Age Models"), " is in early development. 
      New features to be added include the option of uploading your own data, new 
      variables to display and compare, and more options to download the code used 
      as well as the figures produced.")
  )
}

# Module server for the About page.
page_about_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # static web page
    # do nothing
  })
}