suppressPackageStartupMessages({
  library(shiny)
  library(ggplot2)
  library(dplyr)
  library(tidyr)
  library(forcats)
  library(deeptime)
  library(patchwork)
  library(slider)
  library(scales)
})

r_dir <- normalizePath(file.path("..", "..", "R"))
for (f in list.files(r_dir, pattern = "\\.R$", full.names = TRUE)) {
  source(f)
}

# Mirrors the definition in global.R so plot helpers can find it without
# sourcing global.R (which loads the real data files). Assigned to globalenv()
# because the R/ helpers are sourced into globalenv() and look up
# `theme_data_age` via lexical scoping from there.
assign(
  "theme_data_age",
  ggplot2::theme(
    strip.background = ggplot2::element_rect(colour = "black", fill = "white"),
    legend.position  = "bottom"
  ),
  envir = globalenv()
)
