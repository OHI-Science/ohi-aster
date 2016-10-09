shinyServer(function(input, output) {

  # ui_sel_output ----
  output$ui_sel_output <- renderUI({

    req(input$sel_output_goal)

    selectInput(inputId  = 'sel_output_goal_dimension',
                label    = '3. Choose dimension:',
                choices  = scores %>% filter(goal == input$sel_output_goal) %>% distinct(dimension) %>% .$dimension,
                selected = 'score'
    )
  })

  # ui_sel_input ----
  output$ui_sel_input <- renderUI({
    req(input$sel_input_target)

    sel_input_target_layer = selectInput(
      'sel_input_target_layer',
      label    = '3. Choose layer:',
      choices  = with(
        layers_by_target %>% filter(target == input$sel_input_target) %>% mutate(label = sprintf('%s: %s', layer, name)), setNames(layer, label)
      )
    )

    if (!is.null(input$sel_input_target_layer)) {
      fld_category = filter(layers, layer == input$sel_input_target_layer) %>% .$fld_category
      if (!is.na(fld_category)) {
        sel_input_target_layer_category = selectInput(
          'sel_input_target_layer_category',
          label    = sprintf('4. Choose %s:', fld_category),
          choices  = d_lyrs %>% filter(layer == input$sel_input_target_layer) %>% distinct(fld_category) %>% .$fld_category
        )

        fld_year = filter(layers, layer == input$sel_input_target_layer) %>% .$fld_year
        if (!is.na(fld_year) &
            !is.null(input$sel_input_target_layer_category)) {
          sel_input_target_layer_category_year = selectInput(
            'sel_input_target_layer_category_year',
            label    = '5. Choose year:',
            choices  = d_lyrs %>%
              filter(
                layer        == input$sel_input_target_layer,
                fld_category == input$sel_input_target_layer_category
              ) %>%
              distinct(fld_year) %>%
              .$fld_year
          )

          return(
            tagList(
              sel_input_target_layer,
              sel_input_target_layer_category,
              sel_input_target_layer_category_year
            )
          )
        } else {

          return(tagList(
            sel_input_target_layer,
            sel_input_target_layer_category
          ))
        }
      } else {

        return(sel_input_target_layer)
      }
    } else {

      return(sel_input_target_layer)
    }
  })

  # get_selected ----
  get_selected = reactive({
    req(input$sel_type)
    if (input$sel_type == 'output') {
      req(input$sel_output_goal)
      req(input$sel_output_goal_dimension)
      list(
        data = rgns@data %>%
          left_join(
            scores %>%
              filter(
                goal      == input$sel_output_goal,
                dimension == input$sel_output_goal_dimension
              ) %>%
              select(rgn_id = region_id,
                     value  = score),
            by = 'rgn_id'
          ) %>%
          select(rgn_id, value),
        label = sprintf( '%s - %s', input$sel_output_goal, input$sel_output_goal_dimension)
      )
    } else {

      req(input$sel_input_target_layer)
      d = d_lyrs %>% filter(layer == input$sel_input_target_layer)

      list(
        data = rgns@data %>% left_join(d %>% select(rgn_id = fld_id_num, value  = fld_val_num), by = 'rgn_id') %>% select(rgn_id, value),
        label = input$sel_input_target_layer
      )
    }
  })

  # map1 ----
  output$map1 <- renderLeaflet({

    # get data from selection
    selected = get_selected()

    # drop value in rgns spatial data frame if exists
    rgns@data = rgns@data[, names(rgns@data) != 'value']

    # merge value to rgns
    rgns@data = rgns@data %>% left_join(selected$data, by = 'rgn_id')

    # set color palette
    pal = colorNumeric(palette = 'RdYlBu', domain = rgns$value)

    # plot map
    leaflet(rgns) %>%

      addProviderTiles('Stamen.TonerLite', options=tileOptions(noWrap=TRUE)) %>%

      setView(lng = 0, lat = 50, zoom = 3) %>%

      addTopoJSON(topoData, weight = 1, color = "#444444", fill = FALSE)
  })

  # click
  output$click <- renderPrint ({
    input$map1_topojson_click
  })


  # add shape on hover
  observeEvent(input$map1_topojson_mouseover,{

    # indicate to console that an event was triggered
    cat("\ntopojson_mouseover event")

    # clean previously highlighted shape
    leafletProxy("map1") %>% clearGroup("highlight")

    # get id from mouse event
    id <- input$map1_topojson_mouseover$properties$rgn_id

    # match with dataset
    m  <- match(id,rgns$rgn_id)

    # add shape
    leafletProxy("map1") %>% addPolygons( group = "highlight", data = rgns[m,], stroke = FALSE, fillOpacity = 0.5, smoothFactor = 0.5)
  })

  # mouseover
  output$mouseover <- renderPrint ({
    input$map1_topojson_mouseover
  })

  # map bounds
  output$bounds <- renderPrint ({
    req(input$map1_bounds)
    input$map1_bounds
  })

  # map zoom
  output$zoom <- renderPrint ({
    req(input$map1_zoom)
    input$map1_zoom
  })

  # aster plot
  output$aster <- renderAster({
    input$map1_topojson_mouseover
    n <- runif(n = 1, min = 3, max = nrow(data))
    aster( data = data[1:n,], background_color = "transparent",
           font_color = "black", stroke = "blue", font_size_center = "12px", font_size = "8px")
  })

  # aster hover
  output$asterHover <- renderPrint ({
    req(input$aster_hoverInfo)
    input$aster_hoverInfo
  })

  # aster click
  output$asterClick <- renderPrint ({
    req(input$aster_clickInfo)
    input$aster_clickInfo
  })

  id <- reactive({
    id <- input$map1_topojson_mouseover$properties$rgn_id
    m  <- match(id,rgns$rgn_id)
    return(m)
  })


  output$hoverText <- renderText({
    req(id())
    id <- id()
    paste("name:",rgns[id,]@data$"rgn_name", ", area_km2:",round(rgns[id,]@data$"area_km2",2))
  })

})
