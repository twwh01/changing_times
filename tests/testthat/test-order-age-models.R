test_that("order_age_models sorts by embedded 4-digit year when present", {
  ord <- order_age_models(c("Model_GTS2020", "Model_CK1995", "Model_GTS2012"))
  expect_equal(ord, c(2, 3, 1))  # CK1995, GTS2012, GTS2020
})

test_that("order_age_models falls back to alphabetical when no year is present", {
  ord <- order_age_models(c("Model_C", "Model_A", "Model_B"))
  expect_equal(ord, c(2, 3, 1))  # A, B, C
})

test_that("order_age_models pushes year-less names after year-bearing ones", {
  ord <- order_age_models(c("Model_X", "Model_GTS2020", "Model_CK1995"))
  # Year-bearing first (CK1995, GTS2020), then year-less (Model_X).
  expect_equal(ord, c(3, 2, 1))
})

test_that("order_age_models handles empty input", {
  expect_equal(order_age_models(character(0)), integer(0))
})
