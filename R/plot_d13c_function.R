plot_d13c <- function(
    plot_data, 
    background_dataset, 
    age_max_lim, 
    age_min_lim,
    x_max_lim, 
    x_min_lim,
    rolling_mean
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
    scale_colour_viridis_d(name = "Region", option = "turbo") +
    deeptime::coord_geo(pos = "left", dat = "stages") +
    annotate(
      geom = "point",
      x = background_dataset$d13c_carb,
      y = background_dataset$age_ma,
      colour = "grey80"
    ) +
    geom_point(
      data = plot_data, 
      aes(
        x = d13c_carb,
        y = age_ma,
        colour = region
      ),
      shape = 21
    ) +
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