# server script for Changing Times
function(input, output, session){
  selected_options_d13c <- select_options_d13c_server(
    id = "select_options_d13c"
  )
  
  selected_options_gpts <- select_options_gpts_server(
    id = "select_options_gpts"
  )
  
  plot_d13c_age_server(
    id = "plot_d13c_age",
    data_13c_plot, # from global.R
    selected_options_d13c
  )
  
  download_plot_d13c <- download_plot_server(
    id = "download_plot_d13c"
  )
  
  plot_gpts_age_server(
    id = "plot_gpts_age",
    data_gpts_plot, # from global.R
    selected_options_gpts
  )
  
  download_plot_gpts <- download_plot_server(
    id = "download_plot_gpts"
  )
  
  page_about_server(id = "About")

  selected_options_upload <- select_options_upload_server(
    id = "select_options_upload"
  )

  plot_upload_age_server(
    id = "plot_upload_age",
    selections = selected_options_upload
  )

  download_plot_upload <- download_plot_server(
    id = "download_plot_upload"
  )

}
