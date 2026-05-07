# Return an integer order for `model_names` that places "earlier" age models
# first. If any name contains a 4-digit year (e.g. "Model_CK1995",
# "Model_GTS2020"), order by that year — names without a year are pushed to
# the end, then sorted alphabetically among themselves. If no name contains a
# year (e.g. "Model_A", "Model_B"), fall back to plain alphabetical order.
order_age_models <- function(model_names) {
  if (length(model_names) == 0) return(integer(0))
  years <- suppressWarnings(as.integer(stringr::str_extract(model_names, "\\d{4}")))
  if (any(!is.na(years))) {
    order(is.na(years), years, model_names)
  } else {
    order(model_names)
  }
}
