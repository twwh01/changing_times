plot_d13c <- function(
    plot_data, 
    background_dataset, 
    age_max_lim, 
    age_min_lim,
    x_max_lim, 
    x_min_lim,
    rolling_mean,
    point_colour
  ) {
  ggplot() +
    theme_bw(base_size = 18) +
    theme_13C_age +
    labs(
      x = expression(delta^13 * "C"[carb] * " (\u2030)"), # "d13C (permille)",
      y = "Age (Ma)"
    ) +
    scale_x_continuous(
      limits = c(x_min_lim-2, x_max_lim+2)
    ) +
    scale_y_reverse(
      limits = c(age_max_lim, age_min_lim)
    ) +
    deeptime::coord_geo(pos = "left", dat = "stages") +
    annotate(
      geom = "point",
      x = background_dataset$d13c_carb,
      y = background_dataset$age_ma,
      colour = "grey80"
    ) +
    {
      if (point_colour == "none") {
        geom_point(
          data = plot_data, 
          aes(
            x = d13c_carb,
            y = age_ma
          ),
          colour = "seagreen4",
          shape = 21
        )
      } else if (point_colour == "region") {
        list(
          scale_colour_viridis_d(name = "Region", option = "turbo"), 
          geom_point(
            data = plot_data, 
            aes(
              x = d13c_carb,
              y = age_ma,
              colour = region
            ),
            shape = 21
          )
        )
      } else if (point_colour == "all-model age volatility") {
        list(
          scale_colour_viridis_c(
            trans = scales::pseudo_log_trans(sigma = 0.1, base = 10),
            breaks = c(0.1, 1, 10, 50),
            name = "all-model\nage volatility\n(\u03B4 Myr)", 
            option = "viridis"
          ), 
          guides(colour = guide_colourbar(position = "right")), 
          geom_point(
            data = plot_data, 
            aes(
              x = d13c_carb,
              y = age_ma,
              colour = total_volatility
            ),
            shape = 21
          )
        )
      } else if (point_colour == "selected model age volatility") {
        list(
          scale_colour_viridis_c(
            trans = scales::pseudo_log_trans(sigma = 0.1, base = 10),
            breaks = c(0.1, 1, 10, 50),
            name = "selected model\nage volatility\n(\u03B4 Myr)", 
            option = "viridis"
          ), 
          guides(colour = guide_colourbar(position = "right")), 
          geom_point(
            data = plot_data,
            aes(
              x = d13c_carb,
              y = age_ma,
              colour = selected_model_volatility
            ),
            shape = 21
          )
        )
      }
    } +
    {
      if (isTRUE(rolling_mean)) {
        geom_line(
          data = plot_data,
          aes(
            x = data_roll,
            y = age_ma
          ),
          orientation = "y",
          colour = "black",
          linewidth = 2 / .pt
        )
      }
    } +
    facet_grid(~ age_model_label)
}