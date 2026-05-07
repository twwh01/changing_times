# Synthesised fixtures for plot-rendering smoke tests.
# Only includes columns the plot functions actually read. Column names that
# the plot functions hard-code (age_ma, age_model, age_model_label, datum_id,
# total_volatility, selected_model_volatility) must match exactly; the value
# column (`value`) is arbitrary and is passed in via `value_col`.

synth_isotope_data <- function(n_points = 20, n_models = 2) {
  models <- paste0("Model_", LETTERS[seq_len(n_models)])
  grid <- expand.grid(
    datum_id  = seq_len(n_points),
    age_model = models,
    stringsAsFactors = FALSE
  )
  grid$age_ma                    <- stats::runif(nrow(grid), 500, 600)
  grid$value                     <- stats::rnorm(nrow(grid))
  grid$total_volatility          <- stats::runif(nrow(grid), 0.1, 5)
  grid$selected_model_volatility <- stats::runif(nrow(grid), 0.1, 5)
  grid$age_model_label           <- forcats::fct_inorder(grid$age_model)
  grid$originating_model         <- factor(
    sample(models, nrow(grid), replace = TRUE),
    levels = models
  )
  grid
}

# Builds a wide magnetostrat table in the same shape as the real Miocene GPTS
# file: each row is one reversal boundary. Following the convention in the
# real data, `Magnetochron_base` is the chron whose base (older edge) sits at
# this boundary — i.e. the younger chron above it — and `Magnetochron_top` is
# the chron whose top (younger edge) sits at this boundary — the older chron
# below it. Rows are ordered young -> old so adjacent rows share a chron and
# `prepare_magnetostrat_data` can pair up base/top ages, with age_ma_base >
# age_ma_top for the middle chrons.
synth_magnetostrat_wide <- function(n_boundaries = 6, n_models = 3) {
  models <- paste0("Model_GTS", 2010 + seq_len(n_models))
  polarities <- rep(c("n", "r"), length.out = n_boundaries + 1)
  chrons     <- paste0("C", seq_len(n_boundaries + 1), polarities)

  df <- data.frame(
    Magnetochron_base = chrons[-length(chrons)],
    Magnetochron_top  = chrons[-1],
    stringsAsFactors  = FALSE
  )
  base_ages <- seq(5, 20, length.out = n_boundaries)
  for (m in models) {
    df[[m]] <- base_ages + stats::rnorm(n_boundaries, sd = 0.05)
  }
  df
}

# Minimal raw-table fixture for `plot_upload_age_server`: two model columns
# and one numeric value column. Mirrors the shape the user uploads via the
# Shiny app's file picker.
synth_upload_raw <- function(n_rows = 12) {
  data.frame(
    Model_A = stats::runif(n_rows, 5, 20),
    Model_B = stats::runif(n_rows, 5, 20),
    value   = stats::rnorm(n_rows),
    stringsAsFactors = FALSE
  )
}

# Builds the `selections` list `plot_upload_age_server` expects — a named
# list of zero-arg functions, one per upstream widget reactive. Defaults give
# a happy-path isotope render; pass overrides via `...`, e.g.
#   make_upload_selections(roll_mean = function() TRUE)
make_upload_selections <- function(...) {
  raw <- synth_upload_raw()
  defaults <- list(
    raw_data                 = function() raw,
    model_cols               = function() c("Model_A", "Model_B"),
    value_col                = function() "value",
    age_models               = function() c("Model_A", "Model_B"),
    plot_type                = function() "isotope",
    point_colours            = function() "none",
    volatility_colours       = function() "none",
    roll_mean                = function() FALSE,
    roll_window              = function() 5,
    background_model         = function() "none",
    selected_age             = function() c(0, 50),
    has_magnetostrat_cols    = function() FALSE,
    magnetostrat             = function() FALSE,
    show_magnetostrat_labels = function() FALSE,
    model_x                  = function() "Model_A",
    model_y                  = function() "Model_B",
    crossplot_colour         = function() "value"
  )
  utils::modifyList(defaults, list(...))
}

# Long-form d13C fixture matching the shape of `data_13c_plot` built in
# global.R — only the columns `plot_d13c_age_server` reads.
synth_d13c_plot <- function(n_points = 20, n_models = 2) {
  d <- synth_isotope_data(n_points, n_models)
  d$d13c_carb <- d$value
  d$value     <- NULL
  d
}

# Prepared-magnetostrat fixture matching the shape of `data_gpts_plot`.
# Mirrors the extra age_model_year / age_model_label reordering that
# global.R applies on top of prepare_magnetostrat_data().
synth_gpts_plot <- function(n_boundaries = 6, n_models = 3) {
  wide <- synth_magnetostrat_wide(n_boundaries, n_models)
  m_cols <- grep("^Model_", names(wide), value = TRUE)
  prepare_magnetostrat_data(
    df                 = wide,
    model_cols         = m_cols,
    model_names_prefix = "Model_"
  ) %>%
    dplyr::mutate(
      age_model_year  = as.numeric(gsub("[A-Za-z]", "", age_model)),
      age_model_label = forcats::fct_reorder(age_model, age_model_year)
    )
}

# Selections contract for `plot_d13c_age_server`. Defaults reference the
# `data_13c_plot` global (injected in setup.R) so `age_models` matches what
# the module will see.
make_d13c_selections <- function(...) {
  defaults <- list(
    age_models       = function() unique(data_13c_plot$age_model),
    roll_mean        = function() FALSE,
    point_colours    = function() "none",
    background_model = function() "none",
    age_max          = function() 650,
    age_min          = function() 450
  )
  utils::modifyList(defaults, list(...))
}

# Wide-form d13C fixture matching the shape of `indata_d13c` built in
# global.R — one row per datum, with one column per age model. Mirrors the
# fact that the source xlsx stores `d13c_carb` as character (some non-numeric
# values get coerced to NA) so the cross-plot module can be exercised against
# the same input shape.
synth_d13c_wide <- function(n_points = 12, n_models = 3) {
  models <- paste0("Model_", LETTERS[seq_len(n_models)])
  d <- data.frame(
    datum_id                      = seq_len(n_points),
    region                        = sample(c("Namibia", "Oman", "Morocco"),
                                           n_points, replace = TRUE),
    d13c_carb                     = as.character(round(stats::rnorm(n_points), 3)),
    crude_lithofacies_association = sample(c("inner", "outer"),
                                           n_points, replace = TRUE),
    stringsAsFactors              = FALSE
  )
  for (m in models) {
    d[[m]] <- stats::runif(n_points, 500, 600)
  }
  if (n_points >= 2) {
    d[[models[1]]][1:2] <- NA
  }
  d$total_volatility <- stats::runif(n_points, 0.1, 5)
  d
}

# Selections contract for `plot_d13c_crossplot_server`. Defaults assume the
# `synth_d13c_wide()` fixture (Model_A / Model_B columns, ages in 500–600 Ma).
make_d13c_crossplot_selections <- function(...) {
  defaults <- list(
    model_x    = function() "Model_A",
    model_y    = function() "Model_B",
    colour_var = function() "d13c_carb",
    age_min    = function() 500,
    age_max    = function() 600
  )
  utils::modifyList(defaults, list(...))
}

# Selections contract for `plot_gpts_age_server`.
make_gpts_selections <- function(...) {
  defaults <- list(
    age_models         = function() unique(data_gpts_plot$age_model),
    volatility_colours = function() "none",
    age_max            = function() 25,
    age_min            = function() 0
  )
  utils::modifyList(defaults, list(...))
}
