test_that("prepare_magnetostrat_data returns long-form with paired base/top columns", {
  set.seed(1)
  df <- synth_magnetostrat_wide(n_boundaries = 5, n_models = 2)
  out <- prepare_magnetostrat_data(
    df                 = df,
    model_cols         = grep("^Model_", names(df), value = TRUE),
    model_names_prefix = "Model_"
  )

  expect_true(all(c(
    "Magnetochron", "polarity", "age_model", "age_model_label",
    "age_ma_base", "age_ma_top", "age_ma_mid",
    "total_volatility_base", "total_volatility_top"
  ) %in% names(out)))

  expect_s3_class(out$age_model_label, "factor")
  expect_false(any(grepl("^Model_", out$age_model)))

  # Middle chrons appear as both base (older boundary) and top (younger
  # boundary) so they should have non-NA base and top ages with base > top.
  middle <- out %>%
    dplyr::filter(!is.na(age_ma_base), !is.na(age_ma_top))
  expect_gt(nrow(middle), 0)
  expect_true(all(middle$age_ma_base > middle$age_ma_top))
})
