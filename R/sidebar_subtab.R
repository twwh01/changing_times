# Helper for sub-tabs that share the same sidebarLayout shape: an options
# panel and a download panel in the sidebar, and a single plot in the main
# panel. Used by the d13C strat-vs-crossplot sub-tabs and by the Examples
# tabs (Ediacaran-Cambrian, Miocene).
sidebar_subtab <- function(title, options_ui, options_id, plot_ui, plot_id, download_id) {
  tabPanel(
    title = title,

    sidebarLayout(
      sidebarPanel(
        wellPanel(options_ui(id = options_id)),
        wellPanel(download_plot_ui(id = download_id)),
        width = 3
      ),

      mainPanel(
        plot_ui(id = plot_id),
        width = 9
      ),

      fluid = TRUE
    )
  )
}
