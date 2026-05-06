# Pure ggplot builder for the d13C model-vs-model cross-plot. Extracted
# from the renderPlot below so it can be smoke-tested directly.
plot_d13c_crossplot <- function(plot_data, x_col, y_col, colour_var) {
  x_lab <- sub("^Model[_ ]", "", x_col)
  y_lab <- sub("^Model[_ ]", "", y_col)

  p <- ggplot(
      data = plot_data,
      aes(x = .data[[x_col]], y = .data[[y_col]])
    ) +
    theme_bw(base_size = 18) +
    theme(legend.position = "right") +
    labs(
      x = paste0("Age (Ma) — ", x_lab),
      y = paste0("Age (Ma) — ", y_lab)
    ) +
    scale_x_reverse() +
    scale_y_reverse() +
    geom_abline(
      slope     = 1,
      intercept = 0,
      colour    = "grey60",
      linetype  = "dashed"
    )

  if (colour_var == "none" || !(colour_var %in% names(plot_data))) {
    return(p + geom_point(
      shape  = 21,
      fill   = "seagreen4",
      colour = "black",
      size   = 2.5
    ))
  }
  if (is.numeric(plot_data[[colour_var]])) {
    return(p +
      geom_point(
        aes(fill = .data[[colour_var]]),
        shape  = 21,
        colour = "black",
        size   = 2.5
      ) +
      scale_fill_viridis_c(name = colour_var, option = "viridis"))
  }
  p +
    geom_point(
      aes(fill = .data[[colour_var]]),
      shape  = 21,
      colour = "black",
      size   = 2.5
    ) +
    scale_fill_viridis_d(name = colour_var, option = "turbo")
}


# Module UI/server for the d13C model-vs-model cross-plot.
plot_d13c_crossplot_ui <- function(id) {
  ns <- NS(id)
  tagList(
    plotOutput(outputId = ns("plot"), height = "700px")
  )
}


plot_d13c_crossplot_server <- function(id, indata, selections) {
  moduleServer(
    id,
    function(input, output, session) {

      plot_data <- reactive({
        x <- selections$model_x()
        y <- selections$model_y()
        req(x, y)
        validate(
          need(x %in% names(indata), paste0("Model column '", x, "' not found.")),
          need(y %in% names(indata), paste0("Model column '", y, "' not found."))
        )

        d <- indata
        d[[x]] <- suppressWarnings(as.numeric(d[[x]]))
        d[[y]] <- suppressWarnings(as.numeric(d[[y]]))
        if ("d13c_carb" %in% names(d)) {
          d$d13c_carb <- suppressWarnings(as.numeric(d$d13c_carb))
        }

        age_min <- selections$age_min()
        age_max <- selections$age_max()

        d %>%
          dplyr::filter(
            !is.na(.data[[x]]),
            !is.na(.data[[y]]),
            .data[[x]] >= age_min, .data[[x]] <= age_max,
            .data[[y]] >= age_min, .data[[y]] <= age_max
          )
      })

      output$plot <- renderPlot({
        d <- plot_data()
        validate(need(
          nrow(d) > 0,
          "No data points fall within the selected age range for both models."
        ))
        plot_d13c_crossplot(
          plot_data  = d,
          x_col      = selections$model_x(),
          y_col      = selections$model_y(),
          colour_var = selections$colour_var()
        )
      })
    }
  )
}
