# Builds the "Example of the expected file structure" UI shown on the
# Upload tab before a file has been uploaded. Pure UI — no inputs, just
# returns a tagList for embedding in the main panel.
upload_example_ui <- function() {
  tagList(
    h4("Example of the expected file structure"),
    p("Each row is one datum. Columns starting with ", code("Model_"),
      " hold age-in-Ma values under each age model — leave a cell blank
      (or use ", code("NA"), ") if a datum is not represented in a given model.
      Add at least one additional column for the value to plot, plus any
      extra columns to colour by. See the About tab for the full
      specification, including the magnetostratigraphy format."),
    HTML(knitr::kable(
      data.frame(
        id           = c(1, 2, 3, 4),
        d13c         = c(2.1, -1.4,  0.8, -2.3),
        Model_A_2024 = c(540.5, 538.2, NA, 535.1),
        Model_B_2025 = c(542.3, 540.0, 539.1, 537.0),
        region       = c("Namibia", "UK", "Oman", "Australia"),
        check.names  = FALSE
      ),
      format     = "html",
      table.attr = "class='table table-sm table-striped'",
      align      = c("r", "r", "r", "r", "l")
    )),
    hr()
  )
}
