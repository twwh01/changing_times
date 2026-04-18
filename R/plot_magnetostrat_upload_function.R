# Magnetostratigraphy-style plot for uploaded data (mirrors plot_gpts bars).
plot_magnetostrat_upload <- function(
    plot_data,
    age_max_lim,
    age_min_lim,
    volatility_colours
  ) {
  bar_half_width <- 0.2

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

  p +
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
}
