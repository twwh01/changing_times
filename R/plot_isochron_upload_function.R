# Isochron-style plot for uploaded data (generalises plot_gpts).
plot_isochron_upload <- function(
    plot_data,
    value_col,
    age_max_lim,
    age_min_lim,
    volatility_colours
  ) {
  p <- ggplot(
    data = plot_data,
    aes(
      x     = age_model_label,
      y     = age_ma,
      group = datum_id
    )
  ) +
    theme_bw(base_size = 18) +
    theme(panel.grid.major.y = element_line()) +
    theme_data_age +
    labs(
      x = "Age model",
      y = "Age (Ma)"
    ) +
    scale_y_reverse(limits = c(age_max_lim, age_min_lim)) +
    deeptime::coord_geo(pos = "left", dat = "stages")

  line_layer <- if (volatility_colours == "none") {
    geom_line(colour = "grey50", linewidth = 1)
  } else if (volatility_colours == "all-model age volatility") {
    list(
      geom_line(aes(colour = total_volatility), linewidth = 1),
      scale_colour_viridis_c(
        trans  = scales::pseudo_log_trans(sigma = 0.1, base = 10),
        breaks = c(0.1, 1, 10, 50),
        name   = "all-model\nage volatility\n(\u03B4 Myr)",
        option = "viridis"
      )
    )
  } else if (volatility_colours == "selected model age volatility") {
    list(
      geom_line(aes(colour = selected_model_volatility), linewidth = 1),
      scale_colour_viridis_c(
        trans  = scales::pseudo_log_trans(sigma = 0.1, base = 10),
        breaks = c(0.1, 1, 10, 50),
        name   = "selected model\nage volatility\n(\u03B4 Myr)",
        option = "viridis"
      )
    )
  } else if (volatility_colours == "originating age model") {
    list(
      geom_line(aes(colour = originating_model), linewidth = 1),
      scale_colour_viridis_d(
        name   = "originating\nage model",
        option = "turbo",
        drop   = FALSE,
        na.translate = FALSE
      )
    )
  } else if (volatility_colours %in% names(plot_data)) {
    if (is.numeric(plot_data[[volatility_colours]])) {
      list(
        geom_line(aes(colour = .data[[volatility_colours]]), linewidth = 1),
        scale_colour_viridis_c(name = volatility_colours, option = "viridis")
      )
    } else {
      list(
        geom_line(aes(colour = .data[[volatility_colours]]), linewidth = 1),
        scale_colour_viridis_d(name = volatility_colours, option = "turbo")
      )
    }
  } else {
    geom_line(colour = "grey50", linewidth = 1)
  }

  p <- p + line_layer

  if (value_col == "(none)" || !(value_col %in% names(plot_data))) {
    p +
      geom_point(
        shape  = 21,
        size   = 3,
        fill   = "grey70",
        colour = "black"
      )
  } else if (is.numeric(plot_data[[value_col]])) {
    p +
      geom_point(
        aes(fill = .data[[value_col]]),
        shape  = 21,
        size   = 3,
        colour = "black"
      ) +
      scale_fill_viridis_c(name = value_col, option = "plasma")
  } else {
    n_levels <- length(unique(plot_data[[value_col]]))
    fill_layers <- list(
      geom_point(
        aes(fill = .data[[value_col]]),
        shape  = 21,
        size   = 3,
        colour = "black"
      ),
      scale_fill_viridis_d(name = value_col, option = "plasma")
    )
    if (n_levels > 12) {
      fill_layers <- c(fill_layers, list(guides(fill = "none")))
    }
    p + fill_layers
  }
}
