#Adapted From Code on Github
#https://github.com/smartinsightsfromdata/college_explorer

#setwd('C:/Xiwei/projects/RevisitingModel/visualization')
library(shiny)
library(leaflet)
library(DT)
# Choices for drop-downs

store = read.csv('All_Store_INFO.csv')
vars1 = c('Top 10','Top 50','Top 100', 'Bottom 10', 'Bottom 50', 'Bottom 100','All')
vars2 = as.character(unique(store$week_of_year))
vars3 = c('Total_Trans', 'BOT', 'Total_Revenue', 'BOS')

shinyUI(
	navbarPage("Store Map", #id="nav",
    tabPanel(title = "Interactive map", 
    	div(class="outer", 
    		tags$head(
    		# Include our custom CSS
    			includeCSS("styles.css"), includeScript("gomap.js")),

            leafletMap("map", width="100%", height="100%",
                initialTileLayer = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
                initialTileLayerAttribution = HTML('Maps by <a href="http://www.mapbox.com/">Mapbox</a>'),
                options=list(center = c(37.45, -93.85), zoom = 5, 
                	maxBounds = list(list(15.961329,-129.92981), list(52.908902,-56.80481)) # Show US only
                	)),

            absolutePanel(id = "controls", #class = "modal-body", 
                fixed = TRUE, draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                width = 330, height = "auto", h2("Please Select"), 
                selectInput(inputId = "top", label = 'Order Range', choices = vars1, selected = 'All'),
                selectInput(inputId = "week", label = "Week Of Year", choices = vars2, selected = "5"),
                selectInput(inputId = "variables", label = "Sorting Variables", choices = vars3, selected = 'BOT'),
                tags$div(id="cite")))
    ),
                                  
    tabPanel("Actual Table", tableOutput("table"))                   
))