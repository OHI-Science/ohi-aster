suppressPackageStartupMessages({
  library(rgdal)
  library(leaflet)
  library(magrittr)
  library(dplyr)
  library(readr)
  library(tidyr)
  library(shiny)
  library(shinydashboard)
})

library(htmlwidgets)
library(jsonlite)
library(aster)

load("appData.RData")

ToyData <- function(data){
  data$order  <- runif(nrow(data),1,10)
  data$score  <- runif(nrow(data),20,100)
  data$weight <- runif(nrow(data),0.1,0.5)
  data
}

data <- read.csv("aster_data.csv")