# Isotope-style plot for uploaded data (generalises plot_d13c).
plot_isotope_upload <- function(
    plot_data,
    background_data = NULL,
    value_col,
    age_max_lim,
    age_min_lim,
    point_colour,
    rolling_mean = FALSE,
    x_label = NULL
  ) {
  validate(
    need(
      value_col != "(none)" && value_col %in% names(plot_data),
      "Select a value column to show an isotope plot."
    ),
    need(
      is.numeric(plot_data[[value_col]]),
      paste0(
        "Isotope plot requires a numeric value column. '", value_col,
        "' is not numeric \u2014 choose a numeric column or switch to the isochron plot."
      )
    )
  )
  x_vals <- plot_data[[value_col]]
  if (!is.null(background_data) && value_col %in% names(background_data)) {
    x_vals <- c(x_vals, background_data[[value_col]])
  }
  x_max  <- max(x_vals, na.rm = TRUE)
  x_min  <- min(x_vals, na.rm = TRUE)
  x_pad  <- max((x_max - x_min) * 0.05, 0.1)

  p <- ggplot(
    data = plot_data,
    aes(
      x = .data[[value_col]],
      y = age_ma
    )
  ) +
    theme_bw(base_size = 18) +
    theme_data_age +
    labs(
      x = if (is.null(x_label)) value_col else x_label,
      y = "Age (Ma)"
    ) +
    scale_x_continuous(limits = c(x_min - x_pad, x_max + x_pad)) +
    scale_y_reverse(limits = c(age_max_lim, age_min_lim)) +
    deeptime::coord_geo(pos = "left", dat = "stages")

  if (!is.null(background_data) &&
      nrow(background_data) > 0 &&
      value_col %in% names(background_data)) {
    p <- p + annotate(
      geom   = "point",
      x      = background_data[[value_col]],
      y      = background_data$age_ma,
      colour = "grey80"
    )
  }

  p <- p + {
    if (point_colour == "none") {
      geom_point(colour = "seagreen4", shape = 21)
    } else if (point_colour == "all-model age volatility") {
      list(
        scale_colour_viridis_c(
          trans   = scales::pseudo_log_trans(sigma = 0.1, base = 10),
          breaks  = c(0.1, 1, 10, 50),
          name    = "all-model\nage volatility\n(\u03B4 Myr)",
          option  = "viridis"
        ),
        guides(
          colour = guide_colourbar(
            theme    = theme(legend.text = element_text(hjust = 1)),
            position = "right"
          )
        ),
        geom_point(aes(colour = total_volatility), shape = 21)
      )
    } else if (point_colour == "selected model age volatility") {
      list(
        scale_colour_viridis_c(
          trans   = scales::pseudo_log_trans(sigma = 0.1, base = 10),
          breaks  = c(0.1, 1, 10, 50),
          name    = "selected model\nage volatility\n(\u03B4 Myr)",
          option  = "viridis"
        ),
        guides(
          colour = guide_colourbar(
            theme    = theme(legend.text = element_text(hjust = 1)),
            position = "right"
          )
        ),
        geom_point(aes(colour = selected_model_volatility), shape = 21)
      )
    } else if (point_colour == "originating age model") {
      list(
        scale_colour_viridis_d(
          name   = "originating\nage model",
          option = "turbo",
          drop   = FALSE,
          na.translate = FALSE
        ),
        geom_point(aes(colour = originating_model), shape = 21)
      )
    } else if (point_colour %in% names(plot_data)) {
      if (is.numeric(plot_data[[point_colour]])) {
        list(
          scale_colour_viridis_c(name = point_colour, option = "plasma"),
          geom_point(aes(colour = .data[[point_colour]]), shape = 21)
        )
      } else {
        list(
          scale_colour_viridis_d(name = point_colour, option = "turbo"),
          geom_point(aes(colour = .data[[point_colour]]), shape = 21)
        )
      }
    }
  }

  if (isTRUE(rolling_mean) && "data_roll" %in% names(plot_data)) {
    p <- p + geom_line(
      data  = plot_data,
      aes(
        x = data_roll,
        y = age_ma
      ),
      orientation = "y",
      colour      = "black",
      linewidth   = 2 / .pt
    )
  }

  p + facet_grid(~ age_model_label)
}
