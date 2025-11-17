# load packages ----
library(shiny)
library(shinythemes)
library(bslib)
library(openxlsx2)
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)
library(deeptime)
# library(tidyquant) ## if using geom_ma() for moving avg
library(slider) # to calculate rolling average
library(scales) # for log-transforming colour scales


# define custom themes and scales ----
theme_13C_age <- theme(
  strip.background = element_rect(colour = "black", fill = "white"),
  legend.position = "bottom"
)


# load data ----
infile <- openxlsx2::wb_load(
  file = file.path("data", "Bowyer2024_SciAdv_SD1_simplified.xlsx")
)

indata <- openxlsx2::wb_to_df(
  file = infile,
  sheet = "d13Ccarb_combined",
  start_row = 1
)

indata_d13c <- indata %>%
  dplyr::select(
    region, 
    d13c_carb,
    starts_with("Model"), 
    crude_lithofacies_association,
  ) %>%
  # add data point index before making longform
  dplyr::mutate(
    datum_id = c(1:nrow(.)),
    .before = region
  ) %>%
  # dplyr::rename_with(
  #   ~ gsub("].*", "", .x),
  #   starts_with("[Model")
  # ) %>%
  # dplyr::rename_with(
  #   ~ gsub("\\[", "", .x),
  #   starts_with("[Model")
  # ) %>%
  dplyr::mutate(
    region = ifelse(
      str_detect(region, "^Morocco"), 
      "Morocco", 
      ifelse(
        str_detect(region, "^Laurentia. Mexico."),
        "Laurentia (Mexico)", 
        ifelse(
          str_detect(region, "^northern Namibia Congo craton"),
          "Namibia",
          ifelse(
            str_detect(region, "^Arabia"),
            "Oman",
            region
          )
        )
      )
    )
  ) %>%
  # add volatility index using all data points
  dplyr::rowwise() %>%
  dplyr::mutate(
    total_volatility = sd(dplyr::c_across(dplyr::starts_with("Model")), na.rm = TRUE)
  )

data_13c_plot <- indata_d13c %>%
  tidyr::pivot_longer(
    cols = starts_with("Model"),
    names_to = "age_model",
    values_to = "age_ma"
  ) %>%
  dplyr::mutate(
    d13c_carb = as.numeric(d13c_carb),
    age_ma = as.numeric(age_ma)
  ) %>%
  dplyr::mutate(
    age_model_label = gsub("(\\s\\[.*)$", "", age_model),
    .after = age_model
  ) %>%
  dplyr::filter(
    !is.na(d13c_carb),
    !is.na(age_ma)
  )

age_models_list <- data_13c_plot$age_model %>% unique() %>% sort(., decreasing = TRUE)
