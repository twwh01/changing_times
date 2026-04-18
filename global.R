# global script for the evolving_age_models work
# author: TWWH

# load packages ----
library(shiny)
library(shinythemes)
library(bslib)
library(openxlsx2)
library(dplyr)
library(tidyr)
library(stringr)
library(forcats)
library(ggplot2)
library(deeptime)
library(patchwork)
library(slider) # to calculate rolling average
library(scales) # for log-transforming colour scales


# load helpers needed during startup (R/ is auto-sourced by Shiny *after* global.R) ----
source(file.path("R", "prepare_magnetostrat_data.R"))


# define custom themes and scales ----
theme_data_age <- theme(
  strip.background = element_rect(colour = "black", fill = "white"),
  legend.position = "bottom"
)


# load d13C data ----
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
  dplyr::mutate(
    region = dplyr::case_when(
      stringr::str_detect(region, "^Morocco")                        ~ "Morocco",
      stringr::str_detect(region, "^Laurentia. Mexico.")             ~ "Laurentia (Mexico)",
      stringr::str_detect(region, "^northern Namibia Congo craton")  ~ "Namibia",
      stringr::str_detect(region, "^Arabia")                         ~ "Oman",
      .default = region
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
age_models_background_list <- c("none", age_models_list)


# load gpts data ----
infile <- openxlsx2::wb_load(
  file = file.path("data", "Miocene_GPTS_reversals_GTS_age_models.xlsx")
)

indata <- openxlsx2::wb_to_df(
  file = infile,
  sheet = "mio_ocean_gpts",
  start_row = 1
)

gpts_model_cols <- grep("^Model", names(indata), value = TRUE)

# re-order age_model levels by the year embedded in each model name (e.g. GTS2020 -> 2020)
data_gpts_plot <- prepare_magnetostrat_data(
    df = indata,
    model_cols = gpts_model_cols,
    model_names_prefix = "Model_"
  ) %>%
  dplyr::mutate(
    age_model_year  = as.numeric(gsub("[A-Za-z]", "", age_model)),
    age_model_label = forcats::fct_reorder(age_model, age_model_year)
  )

gpts_age_models_list <- data_gpts_plot$age_model %>% unique() %>% sort(., decreasing = TRUE)

magnetochron_labels <- data_gpts_plot %>%
  dplyr::select(
    age_model_label, 
    Magnetochron,
    age_ma_base,
    age_ma_mid,
    total_volatility_base
  ) %>%
  dplyr::filter(
    as.integer(age_model_label) == max(as.integer(age_model_label))
  )
