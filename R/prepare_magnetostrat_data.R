# Build long-form magnetostratigraphy data from a wide table.
#
# Expects `df` to contain `Magnetochron_base`, `Magnetochron_top`, and the
# specified `model_cols`. Returns one row per (Magnetochron, age_model) with
# paired `*_base` / `*_top` columns, a mid-age column, and a derived `polarity`
# column ("n"/"r"/NA). `age_model_label` is a factor in column-appearance order;
# callers can re-level it afterwards. If `model_names_prefix` is supplied, it is
# stripped from the `age_model` values (e.g. "Model_CK1995" -> "CK1995").
prepare_magnetostrat_data <- function(
    df,
    model_cols,
    model_names_prefix = NULL
  ) {
  df_with_meta <- df %>%
    dplyr::select(
      Magnetochron_base,
      Magnetochron_top,
      dplyr::all_of(model_cols)
    ) %>%
    dplyr::mutate(datum_id = seq_len(dplyr::n()), .before = 1) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      total_volatility = stats::sd(
        dplyr::c_across(dplyr::all_of(model_cols)),
        na.rm = TRUE
      )
    ) %>%
    dplyr::ungroup()

  long <- df_with_meta %>%
    tidyr::pivot_longer(
      cols         = c(Magnetochron_base, Magnetochron_top),
      names_to     = "position",
      names_prefix = "Magnetochron_",
      values_to    = "Magnetochron"
    ) %>%
    tidyr::pivot_longer(
      cols      = dplyr::all_of(model_cols),
      names_to  = "age_model",
      values_to = "age_ma"
    )

  if (!is.null(model_names_prefix)) {
    long <- long %>%
      dplyr::mutate(
        age_model = sub(paste0("^", model_names_prefix), "", age_model)
      )
  }

  long %>%
    dplyr::mutate(
      age_ma          = as.numeric(age_ma),
      age_model_label = forcats::fct_inorder(age_model)
    ) %>%
    dplyr::filter(!is.na(age_ma)) %>%
    tidyr::pivot_wider(
      names_from  = position,
      values_from = c(datum_id, age_ma, total_volatility),
      names_glue  = "{.value}_{position}"
    ) %>%
    dplyr::mutate(
      age_ma_mid = (age_ma_base + age_ma_top) / 2,
      polarity = dplyr::case_when(
        grepl("r$", gsub("\\s\\([^)]*\\)", "", Magnetochron)) ~ "r",
        grepl("n$", gsub("\\s\\([^)]*\\)", "", Magnetochron)) ~ "n",
        .default = NA_character_
      ),
      .after = Magnetochron
    )
}
