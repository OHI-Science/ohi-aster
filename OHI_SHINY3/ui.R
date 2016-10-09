dashboardPage(

  dashboardHeader(title = "Ocean Health Index"),

  dashboardSidebar(

    selectInput(
      'sel_type',
      label = '1. Choose type:',
      choices = c('Input Layer' = 'input', 'Output Score' = 'output'),
      selected = 'output'
    ),

    conditionalPanel(
      condition = "input.sel_type == 'output'",
      selectInput(
        'sel_output_goal',
        label    = '2. Choose goal:',
        choices  = output_goals,
        selected = 'Index'
      ),
      uiOutput('ui_sel_output')
    ),

    conditionalPanel(
      condition = "input.sel_type == 'input'",
      selectInput(
        'sel_input_target',
        label    = '2. Choose target:',
        choices  = with(layer_targets, setNames(target, target_label))
      ),
      uiOutput('ui_sel_input')
    ),

    div(style = "padding: 15px",
        h3("bounds"),verbatimTextOutput("bounds")
    ),

    div(style = "padding: 15px",
        h3("zoom"),verbatimTextOutput("zoom")
    )


  ),

  dashboardBody(
    fluidRow(

      box(collapsible = TRUE, width = 12,

        div(position = "relative",

          # leaflet chart
          leafletOutput('map1', height = 550),

          # hover text showing info on hover area
          absolutePanel(bottom = 10, left = 10, style = "background-color:white",
           textOutput("hoverText")
          ),

          # aster chart
          absolutePanel(top = 10, right = 100,
                        asterOutput(outputId = "aster", width = '150px', height = '150px')
          )
        )

      )
    ),

    # leaflet hover info, aster hover and click info
    fluidRow(
      column(4, style = "max-height: 200px; min-height:200px", h3("mouseover")  ,verbatimTextOutput("mouseover")),
      column(4, style = "max-height: 200px; min-height:200px", h3("aster hover"),verbatimTextOutput("asterHover")),
      column(4, style = "max-height: 200px; min-height:200px", h3("aster click"),verbatimTextOutput("asterClick"))
    )
  )
)
