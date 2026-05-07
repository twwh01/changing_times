# Magnetostratigraphy-style plot for uploaded data (mirrors plot_gpts bars).
# When `show_labels = TRUE`, a text side-panel with Magnetochron labels is
# added using patchwork — the labels are taken from the last age-model level
# in `plot_data`.
plot_magnetostrat_upload <- function(
    plot_data,
    age_max_lim,
    age_min_lim,
    volatility_colours,
    show_labels = FALSE
  ) {
  bar_half_width <- 0.2

  # Drop unused age-model levels so the x-axis and label panel only reflect
  # what is actually present in `plot_data`.
  plot_data <- plot_data %>%
    dplyr::mutate(age_model_label = forcats::fct_drop(age_model_label))

  model_levels <- levels(plot_data$age_model_label)
  plot_data <- plot_data %>%
    dplyr::mutate(x_num = as.integer(age_model_label))

  seg_data <- plot_data %>%
    dplyr::filter(!is.na(age_ma_base)) %>%
    dplyr::select(
      Magnetochron,
      x_num,
      age_ma_base,
      dplyr::any_of(c("total_volatility_base", "selected_model_volatility_base"))
    ) %>%
    dplyr::arrange(Magnetochron, x_num) %>%
    dplyr::group_by(Magnetochron) %>%
    dplyr::mutate(
      x_next = dplyr::lead(x_num),
      y_next = dplyr::lead(age_ma_base)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::filter(!is.na(x_next), !is.na(y_next)) %>%
    dplyr::mutate(
      seg_x    = x_num  + bar_half_width,
      seg_xend = x_next - bar_half_width,
      seg_y    = age_ma_base,
      seg_yend = y_next
    )

  p <- ggplot(
    data = plot_data,
    aes(
      x     = x_num,
      y     = age_ma_base,
      group = Magnetochron,
      fill  = polarity
    )
  ) +
    theme_bw(base_size = 18) +
    theme(panel.grid.major.y = element_line()) +
    theme_data_age +
    labs(
      x = "Age model",
      y = "Age (Ma)"
    ) +
    scale_x_continuous(
      breaks = seq_along(model_levels),
      labels = model_levels,
      limits = c(0.5, length(model_levels) + 0.5),
      expand = c(0, 0)
    ) +
    scale_y_reverse(limits = c(age_max_lim, age_min_lim)) +
    scale_fill_manual(
      values   = c("r" = "white", "n" = "black"),
      na.value = "grey50"
    ) +
    deeptime::coord_geo(pos = "left", dat = "stages")

  # Magnetostrat data does not carry arbitrary columns through
  # prepare_magnetostrat_data(), so for any colour option that isn't one of
  # the known volatility variables, draw plain grey segments.
  known_volatility_options <- c(
    "none", "all-model age volatility", "selected model age volatility"
  )
  if (!volatility_colours %in% known_volatility_options) {
    volatility_colours <- "none"
  }

  line_layer <- if (volatility_colours == "none") {
    geom_segment(
      data = seg_data,
      aes(x = seg_x, xend = seg_xend, y = seg_y, yend = seg_yend),
      colour      = "grey50",
      linewidth   = 1,
      inherit.aes = FALSE
    )
  } else if (volatility_colours == "all-model age volatility") {
    list(
      geom_segment(
        data = seg_data,
        aes(
          x      = seg_x,
          xend   = seg_xend,
          y      = seg_y,
          yend   = seg_yend,
          colour = total_volatility_base
        ),
        linewidth   = 1,
        inherit.aes = FALSE
      ),
      scale_colour_viridis_c(
        trans  = scales::pseudo_log_trans(sigma = 0.1, base = 10),
        breaks = c(0.1, 1, 10, 50),
        name   = "all-model\nage volatility\n(\u03B4 Myr)",
        option = "viridis"
      )
    )
  } else if (volatility_colours == "selected model age volatility") {
    list(
      geom_segment(
        data = seg_data,
        aes(
          x      = seg_x,
          xend   = seg_xend,
          y      = seg_y,
          yend   = seg_yend,
          colour = selected_model_volatility_base
        ),
        linewidth   = 1,
        inherit.aes = FALSE
      ),
      scale_colour_viridis_c(
        trans  = scales::pseudo_log_trans(sigma = 0.1, base = 10),
        breaks = c(0.1, 1, 10, 50),
        name   = "selected model\nage volatility\n(\u03B4 Myr)",
        option = "viridis"
      )
    )
  }

  p <- p +
    line_layer +
    geom_rect(
      aes(
        xmin = after_stat(x) - bar_half_width,
        xmax = after_stat(x) + bar_half_width,
        ymin = age_ma_top,
        ymax = age_ma_base
      ),
      colour = "black"
    )

  if (!isTRUE(show_labels)) {
    return(p)
  }

  # Build label side-panel from the last age-model level in the data.
  label_level <- tail(levels(plot_data$age_model_label), 1)
  labels_data <- plot_data %>%
    dplyr::filter(age_model_label == label_level) %>%
    dplyr::select(
      Magnetochron,
      age_ma_mid,
      dplyr::any_of(c("total_volatility_base", "selected_model_volatility_base"))
    ) %>%
    dplyr::distinct()

  p2 <- ggplot(data = labels_data) +
    theme_void(base_size = 18) +
    theme_data_age +
    labs(x = NULL, y = "Age (Ma)") +
    scale_y_reverse(limits = c(age_max_lim, age_min_lim)) +
    deeptime::coord_geo(pos = "right", dat = "stages")

  p2 <- p2 + if (volatility_colours == "none") {
    geom_text(
      aes(label = Magnetochron, x = 1, y = age_ma_mid),
      hjust = 0
    )
  } else if (volatility_colours == "all-model age volatility") {
    list(
      geom_text(
        aes(
          label  = Magnetochron,
          x      = 1,
          y      = age_ma_mid,
          colour = total_volatility_base
        ),
        hjust = 0
      ),
      scale_colour_viridis_c(
        trans  = scales::pseudo_log_trans(sigma = 0.1, base = 10),
        breaks = c(0.1, 1, 10, 50),
        option = "viridis",
        guide  = "none"
      )
    )
  } else if (volatility_colours == "selected model age volatility") {
    list(
      geom_text(
        aes(
          label  = Magnetochron,
          x      = 1,
          y      = age_ma_mid,
          colour = selected_model_volatility_base
        ),
        hjust = 0
      ),
      scale_colour_viridis_c(
        trans  = scales::pseudo_log_trans(sigma = 0.1, base = 10),
        breaks = c(0.1, 1, 10, 50),
        option = "viridis",
        guide  = "none"
      )
    )
  }

  ((p + patchwork::plot_spacer() + p2) +
    patchwork::plot_layout(
      guides = "collect",
      widths = c(5, -1.1, 2)
    )) & theme(legend.position = "right")
}
