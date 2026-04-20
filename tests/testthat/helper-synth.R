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
