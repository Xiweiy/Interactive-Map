#Adapted From Code on Github
#https://github.com/smartinsightsfromdata/college_explorer

#setwd('C:/Xiwei/projects/RevisitingModel/visualization')
library(shiny)
library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)

store = read.csv('All_Store_INFO.csv')

shinyServer(function(input, output, session) {
  
  ## Interactive Map ###########################################
  
  # Create the map
  map <- createLeafletMap(session, "map")
  
  # A reactive expression that returns the set of zips that are
  # in bounds right now
  zipsInBounds <- reactive({
    if (is.null(input$map_bounds))
    	return(store[FALSE,])
    bounds <- input$map_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)
  })

  # session$onFlushed is necessary to work around a bug in the Shiny/Leaflet
  # integration; without it, the addCircle commands arrive in the browser
  # before the map is created.
  session$onFlushed(once=TRUE, function() {
    paintObs <- observe({
    time_store = store[store$week_of_year == input$week, ]
    orderby = unlist(strsplit(input$top," "))
    toptail = ifelse(orderby[1] == 'Top', TRUE, FALSE)
    sortrange = ifelse(!is.na(orderby[2]), as.numeric(orderby[2]), 475)
    sort_variable = input$variables
    selected_store = head(time_store[order(time_store[,sort_variable], decreasing=toptail),], sortrange)

    # Clear existing circles before drawing
    map$clearShapes()
	for (i in 1:nrow(selected_store)) {
		onestore = selected_store[i,]
		try(
			map$addCircle(lng = onestore$Longitude, lat = onestore$Latitude, radius = 30000,
				layerId = onestore$zipcode, list(stroke = FALSE, fill = TRUE, fillOpacity = .4),
				list(color = "#C00"))	
#			map$addMarker(lng = onestore$Longitude, lat = onestore$Latitude, 
#				layerId = onestore$zipcode)
			)
	}
	})   
    # TIL this is necessary in order to prevent the observer from
    # attempting to write to the websocket after the session is gone.
    session$onSessionEnded(paintObs$suspend)
  })

  ## Actual Table ###########################################
    
  output$table = renderTable({
    time_store = store[store$week_of_year == input$week, 1:14]
    orderby = unlist(strsplit(input$top," "))
    toptail = ifelse(orderby[1] == 'Top', TRUE, FALSE)
    sortrange = ifelse(!is.na(orderby[2]), as.numeric(orderby[2]), 475)
    sort_variable = input$variables
    selected_store = head(time_store[order(time_store[,sort_variable], decreasing=toptail),], sortrange)
  })
})
