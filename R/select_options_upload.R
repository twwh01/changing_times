# options panel for uploaded data
select_options_upload_ui <- function(id) {
  ns <- NS(id)

  tagList(
    fileInput(
      inputId = ns("upload_file"),
      label   = "Upload Excel (.xlsx) or CSV (.csv) file",
      accept  = c(".xlsx", ".csv"),
      multiple = FALSE
    ),
    helpText(
      "File must contain one or more columns with a 'Model_' prefix ",
      "(ages in Ma) plus at least one additional numeric column."
    ),
    radioButtons(
      inputId = ns("plot_type"),
      label   = "Select plot type:",
      choices = c(
        "Isotope plot (like Ediacaran-Cambrian tab)"        = "isotope",
        "Isochron plot (like Miocene magnetostratigraphy)"  = "isochron",
        "Cross-plot (compare two models)"                   = "crossplot"
      ),
      selected = "isotope"
    ),
    uiOutput(ns("value_col_ui")),
    uiOutput(ns("age_range_ui")),
    uiOutput(ns("age_models_ui")),
    uiOutput(ns("colour_ui"))
  )
}


select_options_upload_server <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
      ns <- session$ns

      raw_data <- reactive({
        req(input$upload_file)
        file_path <- input$upload_file$datapath
        file_ext  <- tolower(tools::file_ext(input$upload_file$name))

        if (file_ext == "xlsx") {
          wb <- openxlsx2::wb_load(file = file_path)
          openxlsx2::wb_to_df(file = wb, sheet = 1, start_row = 1)
        } else if (file_ext == "csv") {
          utils::read.csv(file_path, stringsAsFactors = FALSE)
        } else {
          validate("Unsupported file type. Please upload a .xlsx or .csv file.")
        }
      })

      model_cols <- reactive({
        req(raw_data())
        cols <- names(raw_data())[startsWith(names(raw_data()), "Model_")]
        validate(
          need(
            length(cols) > 0,
            "No columns with a 'Model_' prefix were found in the uploaded file."
          )
        )
        cols
      })

      value_col_choices <- reactive({
        req(raw_data(), model_cols())
        candidates <- setdiff(names(raw_data()), model_cols())
        validate(
          need(
            length(candidates) > 0,
            "No non-'Model_' columns were found in the uploaded file."
          )
        )
        c("(none)", candidates)
      })

      has_magnetostrat_cols <- reactive({
        req(raw_data())
        all(c("Magnetochron_base", "Magnetochron_top") %in% names(raw_data()))
      })

      # dynamic UI ----
      output$value_col_ui <- renderUI({
        req(input$plot_type)
        if (input$plot_type == "crossplot") return(NULL)

        choices <- value_col_choices()
        df <- raw_data()
        numeric_candidates <- choices[choices != "(none)" &
          vapply(choices, function(x) {
            x %in% names(df) && is.numeric(df[[x]])
          }, logical(1))]
        default <- if (length(numeric_candidates) > 0) {
          numeric_candidates[1]
        } else {
          "(none)"
        }
        selectInput(
          inputId  = ns("value_col"),
          label    = "Value column to plot:",
          choices  = choices,
          selected = default
        )
      })

      output$age_models_ui <- renderUI({
        cols <- model_cols()
        if (isTRUE(input$plot_type == "crossplot")) {
          if (length(cols) < 2) {
            return(helpText(
              "Cross-plot needs at least two 'Model_' columns in the uploaded file."
            ))
          }
          tagList(
            selectInput(
              inputId  = ns("model_x"),
              label    = "Model on x-axis:",
              choices  = cols,
              selected = cols[1]
            ),
            selectInput(
              inputId  = ns("model_y"),
              label    = "Model on y-axis:",
              choices  = cols,
              selected = cols[2]
            )
          )
        } else {
          checkboxGroupInput(
            inputId  = ns("age_models"),
            label    = "Select age model versions to show:",
            choices  = cols,
            selected = cols
          )
        }
      })

      output$age_range_ui <- renderUI({
        df <- raw_data()
        req(df, model_cols())
        all_ages <- unlist(lapply(model_cols(), function(x) as.numeric(df[[x]])))
        all_ages <- all_ages[is.finite(all_ages)]
        req(length(all_ages) > 0)
        lo <- floor(min(all_ages, na.rm = TRUE))
        hi <- ceiling(max(all_ages, na.rm = TRUE))
        sliderInput(
          inputId = ns("selected_age"),
          label   = "Select minimum and maximum ages (Ma):",
          min     = lo,
          max     = hi,
          value   = c(lo, hi),
          step    = 1,
          round   = TRUE
        )
      })

      output$colour_ui <- renderUI({
        req(input$plot_type)
        df <- raw_data()
        extra_cols <- setdiff(names(df), model_cols())
        if (input$plot_type == "isotope") {
          bg_choices <- c("none", model_cols())
          point_colour_choices <- c(
            "none",
            "all-model age volatility",
            "selected model age volatility",
            extra_cols
          )
          tagList(
            selectInput(
              inputId = ns("point_colours"),
              label   = "Point colour variable:",
              choices = point_colour_choices,
              selected = "none"
            ),
            selectInput(
              inputId  = ns("background_model"),
              label    = "Plot a specific model\nas background (grey) points?",
              choices  = bg_choices,
              selected = "none"
            ),
            checkboxInput(
              inputId = ns("roll_mean"),
              label   = "Add moving average\nto each model?",
              value   = FALSE
            ),
            numericInput(
              inputId = ns("roll_window"),
              label   = "Moving average window\n(± N points):",
              value   = 25,
              min     = 1,
              max     = NA,
              step    = 1
            )
          )
        } else if (input$plot_type == "crossplot") {
          df <- raw_data()
          candidates <- setdiff(names(df), model_cols())
          choices <- c("none" = "none", stats::setNames(candidates, candidates))
          numeric_candidates <- candidates[vapply(candidates, function(x) {
            is.numeric(df[[x]]) ||
              any(!is.na(suppressWarnings(as.numeric(df[[x]]))))
          }, logical(1))]
          default <- if (length(numeric_candidates) > 0) numeric_candidates[1] else "none"
          selectInput(
            inputId  = ns("crossplot_colour"),
            label    = "Variable for point colour:",
            choices  = choices,
            selected = default
          )
        } else {
          volatility_colour_choices <- c(
            "none",
            "all-model age volatility",
            "selected model age volatility",
            extra_cols
          )
          iso_controls <- list(
            selectInput(
              inputId = ns("volatility_colours"),
              label   = "Line colour variable:",
              choices = volatility_colour_choices,
              selected = "all-model age volatility"
            )
          )
          if (isTRUE(has_magnetostrat_cols())) {
            iso_controls <- c(
              iso_controls,
              list(
                checkboxInput(
                  inputId = ns("magnetostrat"),
                  label   = paste0(
                    "Render as magnetostratigraphy\n",
                    "(black 'n' / white 'r' polarity bars)?"
                  ),
                  value   = FALSE
                ),
                checkboxInput(
                  inputId = ns("show_magnetostrat_labels"),
                  label   = "Show magnetochron labels on the side?",
                  value   = FALSE
                )
              )
            )
          }
          do.call(tagList, iso_controls)
        }
      })

      list(
        raw_data              = raw_data,
        has_uploaded          = reactive(!is.null(input$upload_file)),
        model_cols            = model_cols,
        has_magnetostrat_cols = has_magnetostrat_cols,
        plot_type             = reactive(input$plot_type),
        value_col             = reactive(input$value_col),
        age_models            = reactive(input$age_models),
        selected_age          = reactive(input$selected_age),
        background_model      = reactive(input$background_model),
        point_colours         = reactive(input$point_colours),
        roll_mean             = reactive(input$roll_mean),
        roll_window           = reactive(input$roll_window),
        volatility_colours       = reactive(input$volatility_colours),
        magnetostrat             = reactive(input$magnetostrat),
        show_magnetostrat_labels = reactive(input$show_magnetostrat_labels),
        model_x                  = reactive(input$model_x),
        model_y                  = reactive(input$model_y),
        crossplot_colour         = reactive(input$crossplot_colour)
      )
    }
  )
}
