plot_gpts <- function(
    plot_data,
    age_max_lim,
    age_min_lim,
    # x_max_lim, # not needed for this version
    # x_min_lim, # not needed for this version
    volatility_colours
  ) {

  bar_half_width <- 0.2
  model_levels <- levels(plot_data$age_model_label)
  plot_data <- plot_data %>%
    dplyr::mutate(x_num = as.integer(age_model_label))

  seg_data <- plot_data %>%
    dplyr::filter(!is.na(age_ma_base)) %>%
    dplyr::select(Magnetochron, x_num, age_ma_base, total_volatility_base) %>%
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

  # make the palaeomag plot ----
  p1 <- plot_data %>%
    ggplot(
      aes(
        x = x_num,
        y = age_ma_base,
        # yend = age_ma_top,
        group = Magnetochron,
        fill = polarity
      )
    ) +
    theme_bw(base_size = 18) +
    theme(
      panel.grid.major.y = element_line()
    ) +
    theme_data_age +
    labs(
      x = "Age model",
      y = "Age (Ma)",
      colour = "Age volatility\n(Ma)"
    ) +
    scale_x_continuous(
      breaks = seq_along(model_levels),
      labels = model_levels,
      limits = c(0.5, length(model_levels) + 0.5),
      expand = c(0, 0)
    ) +
    scale_y_reverse(limits = c(age_max_lim, age_min_lim)) +
    scale_fill_manual(values = c("r" = "white", "n" = "black"), na.value = "grey50") +
    scale_colour_viridis_c() +
    deeptime::coord_geo(
      pos = "left",
      dat = "stages"
    ) +
    geom_segment(
      data = seg_data,
      aes(x = seg_x, xend = seg_xend, y = seg_y, yend = seg_yend, colour = total_volatility_base),
      linewidth   = 1,
      inherit.aes = FALSE
    ) +
    geom_rect(
      aes(
        xmin = after_stat(x)-0.2,
        xmax = after_stat(x)+0.2,
        ymin = age_ma_top,
        ymax = age_ma_base
      ),
      colour = "black"
    )
  
  # make the text annotations plot ----
  p2 <- magnetochron_labels %>%
    ggplot(
      aes(
        label = Magnetochron, 
        x = 1,
        y = age_ma_mid, 
        colour = total_volatility_base
      )
    ) +
    labs(
      x = NULL, 
      y = "Age (Ma)", 
      colour = "Age volatility\n(Ma)"
    ) +
    scale_y_reverse(limits = c(age_max_lim, age_min_lim)) +
    scale_colour_viridis_c(guide = "none") + 
    geom_text(hjust = 0) +
    deeptime::coord_geo(
      pos = "right",
      dat = "stages"
    ) +
    theme_void(base_size = 18) +
    theme_data_age
  
  # make the combined plot ----
  p3 <- ((p1 + plot_spacer() + p2) + 
      plot_layout(
        guides = "collect",
        widths = c(5, -1.1, 2)
      )) & theme(legend.position = "right")
  
  # return the combined plot ----
  return(p3)
}