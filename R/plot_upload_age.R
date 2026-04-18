# Module UI for the uploaded-data plot.
plot_upload_age_ui <- function(id) {
  ns <- NS(id)
  tagList(
    plotOutput(outputId = ns("plot"), height = "700px")
  )
}


plot_upload_age_server <- function(id, selections) {
  moduleServer(
    id,
    function(input, output, session) {

      plot_data_full <- reactive({
        req(selections$raw_data(), selections$model_cols(), selections$value_col())
        m_cols <- selections$model_cols()
        v_col  <- selections$value_col()

        d <- selections$raw_data() %>%
          dplyr::mutate(
            datum_id = seq_len(dplyr::n()),
            .before  = 1
          ) %>%
          dplyr::rowwise() %>%
          dplyr::mutate(
            total_volatility = stats::sd(
              dplyr::c_across(dplyr::all_of(m_cols)),
              na.rm = TRUE
            )
          ) %>%
          dplyr::ungroup() %>%
          tidyr::pivot_longer(
            cols      = dplyr::all_of(m_cols),
            names_to  = "age_model",
            values_to = "age_ma"
          ) %>%
          dplyr::mutate(
            age_ma          = as.numeric(age_ma),
            age_model_label = forcats::fct_inorder(age_model)
          ) %>%
          dplyr::filter(!is.na(age_ma))

        if (v_col != "(none)" && v_col %in% names(d)) {
          d <- dplyr::filter(d, !is.na(.data[[v_col]]))
        }
        d
      })

      plot_data <- reactive({
        req(plot_data_full(), selections$age_models(), selections$plot_type(), selections$value_col())
        d <- plot_data_full() %>%
          dplyr::filter(age_model %in% selections$age_models())

        colour_opt <- if (selections$plot_type() == "isotope") {
          selections$point_colours()
        } else {
          selections$volatility_colours()
        }

        if (isTRUE(colour_opt == "selected model age volatility")) {
          d <- d %>%
            dplyr::group_by(datum_id) %>%
            dplyr::mutate(
              selected_model_volatility = stats::sd(age_ma, na.rm = TRUE)
            ) %>%
            dplyr::ungroup()
        }

        v_col <- selections$value_col()
        if (selections$plot_type() == "isotope" &&
            isTRUE(selections$roll_mean()) &&
            v_col != "(none)" &&
            v_col %in% names(d) &&
            is.numeric(d[[v_col]])) {
          roll_n <- suppressWarnings(as.integer(selections$roll_window()))
          if (is.na(roll_n) || roll_n < 1) roll_n <- 25
          d <- d %>%
            dplyr::group_by(age_model) %>%
            dplyr::arrange(age_model, age_ma) %>%
            dplyr::mutate(
              data_roll = slider::slide_dbl(
                .x        = .data[[v_col]],
                .f        = mean,
                .before   = roll_n,
                .after    = roll_n,
                .complete = FALSE
              )
            ) %>%
            dplyr::ungroup()
        }
        d
      })

      magnetostrat_data <- reactive({
        req(selections$raw_data(), selections$model_cols(), selections$age_models())
        req(selections$has_magnetostrat_cols())

        d <- prepare_magnetostrat_data(
            df = selections$raw_data(),
            model_cols = selections$model_cols()
          ) %>%
          dplyr::filter(age_model %in% selections$age_models())

        if (isTRUE(selections$volatility_colours() == "selected model age volatility")) {
          d <- d %>%
            dplyr::group_by(datum_id_base) %>%
            dplyr::mutate(
              selected_model_volatility_base = stats::sd(
                age_ma_base,
                na.rm = TRUE
              )
            ) %>%
            dplyr::ungroup()
        }
        d
      })

      background_data <- reactive({
        req(plot_data_full(), selections$value_col())
        bg <- selections$background_model()
        if (is.null(bg) || isTRUE(bg == "none") || !(bg %in% selections$model_cols())) {
          return(NULL)
        }
        plot_data_full() %>%
          dplyr::filter(age_model == bg)
      })

      output$plot <- renderPlot({
        req(plot_data(), selections$plot_type(), selections$value_col(), selections$selected_age())
        age_min <- min(selections$selected_age())
        age_max <- max(selections$selected_age())

        if (selections$plot_type() == "isotope") {
          pc <- if (is.null(selections$point_colours())) "none" else selections$point_colours()
          rm <- isTRUE(selections$roll_mean())
          plot_isotope_upload(
            plot_data         = plot_data(),
            background_data   = background_data(),
            value_col         = selections$value_col(),
            age_max_lim       = age_max,
            age_min_lim       = age_min,
            point_colour      = pc,
            rolling_mean      = rm
          )
        } else {
          vc <- if (is.null(selections$volatility_colours())) "none" else selections$volatility_colours()
          if (isTRUE(selections$magnetostrat()) && isTRUE(selections$has_magnetostrat_cols())) {
            plot_magnetostrat_upload(
              plot_data          = magnetostrat_data(),
              age_max_lim        = age_max,
              age_min_lim        = age_min,
              volatility_colours = vc
            )
          } else {
            plot_isochron_upload(
              plot_data          = plot_data(),
              value_col          = selections$value_col(),
              age_max_lim        = age_max,
              age_min_lim        = age_min,
              volatility_colours = vc
            )
          }
        }
      })
    }
  )
}
