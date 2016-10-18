library(shiny)
library(htmlwidgets)
library(jsonlite)
#library(aster)
#library(devtools); load_all()
library(ohiaster)
library(readr)

# angola
angola = read_csv('../data/angola.csv')
ohiaster(angola, 59.1,
  background_color = "transparent",
  font_color = "black", stroke = "blue", font_size_center = "12px", font_size = "8px",
  margin_top=5, margin_right=5, margin_bottom=5, margin_left=5)

# set wd
setwd("C:/Users/hsontrop/Desktop/aster/")
setwd("~/github/ohi-aster")

# data
data <- read.csv("data/aster_data.csv")

# toy app
runApp(list(
  ui = fluidPage(

    h3("aster HTMLWidget test"),

    fluidRow( style = "min-height:700px",
      column(6,asterOutput(outputId = "aster1", width = '100%', height = '600px')),

      # note the height is a bit longer, as the default margins of the chart should be taken into account
      column(6,asterOutput(outputId = "aster2", width = '500px', height = '600px'))
    ),

    br(),

    fluidRow(
      column(6,tableOutput("info1")),
      column(6,tableOutput("info2"))
    ),

    br(),

    fluidRow(
      column(6,textOutput("clickText1")),
      column(6,textOutput("clickText2"))
    )
  ),
  server = function(input, output){

    # aster chart 2
    output$aster1 <- renderAster({
      #invalidateLater(2000)
      n <- runif(n = 1, min = 3, max = nrow(data))
      aster( data = data[1:n,], margin_left = 0, margin_right = 0)
    })

    # aster chart 2
    output$aster2 <- renderAster({
      #invalidateLater(2000)
      n <- runif(n = 1, min = 3, max = nrow(data))
      aster( data = data[1:n,], background_color = "gray", font_color = "white", stroke = "black")
    })

    # hover info from aster chart 1
    HoverInfo1 <- reactive({
      data.frame(input$aster1_hoverInfo)
    })

    # hover info from aster chart 2
    HoverInfo2 <- reactive({
      data.frame(input$aster2_hoverInfo)
    })

    # display hover data aster chart 1
    output$info1 <- renderTable({
      HoverInfo1()
    })

    # display hover data aster chart 2
    output$info2 <- renderTable({
      HoverInfo2()
    })

    # observe click info chart 1
    output$clickText1 <- renderText({
      req(input$aster1_clickInfo$id)
      paste("\nyou last clicked on id:",input$aster1_clickInfo$id)
    })

    # observe click info chart 2
    output$clickText2 <- renderText({
      req(input$aster2_clickInfo$id)
      paste("\nyou last clicked on id:",input$aster2_clickInfo$id)
    })
  }
))
