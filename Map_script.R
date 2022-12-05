#Map out the capitals of all countries bordering the mediterranean sea
# this will visualize whether or not their capitals border the mediterranean

# Activate the libraries
library(leaflet)
library(htmlwidgets)
library(tidyverse)
library(googlesheets4)
gs4_deauth()

# Create a basic basemap
l_Medi <- leaflet() %>%   
  setView(14.3754, 35.9375, zoom = 3)

# Now, prepare to select backgrounds
esri <- grep("^Esri", providers, value = TRUE)

# Select backgrounds from among provider tiles.  
for (provider in esri) {
  l_Medi <- l_Medi %>% addProviderTiles(provider, group = provider)}

# run this command to check that you printed something
l_Medi

### Map of the Mediterranean Sea
Medimap <- l_Medi %>%
  addLayersControl(baseGroups = names(esri),
                   options = layersControlOptions(collapsed = TRUE)) %>%
  addMiniMap(tiles = esri[[1]], toggleDisplay = TRUE,
             position = "bottomright") %>%
  addMeasure(
    position = "bottomleft",
    primaryLengthUnit = "meters",
    primaryAreaUnit = "sqmeters",
    activeColor = "#3D535D",
    completedColor = "#7D4479") %>% 
  htmlwidgets::onRender("
                        function(el, x) {
                        var myMap = this;
                        myMap.on('baselayerchange',
                        function (e) {
                        myMap.minimap.changeLayer(L.tileLayer.provider(e.name));
                        })
                        }") %>% 
  addControl("", position = "topright")

# run this to see your product
Medimap
  

#Create a spreadsheet with countries and capitals 


# Read in a Google sheet
places <- read_sheet("https://docs.google.com/spreadsheets/d/1OKKfpUcqvKRM5aoDSMzAA3RzxiWDb2NWS_PMiRDjVUI/edit?usp=sharing",
                     col_types = "cccnn",range = "SA2022")
#Check the data
glimpse(places)

# add the markers to the map
Medi_marker <- Medimap %>% 
  addMarkers(lng = places$Longitude, 
             lat = places$Latitude,
             label = places$Country,
             clusterOptions = markerClusterOptions(),
             popup = paste("Capital:",places$Capital))

#Check the results
Medi_marker

#Save the map as a HTML- file
saveWidget(Medi_marker, "Medi_marker.html", selfcontained = TRUE)

#the map clearly shows that not all countries have capitals bordering the mediterranean
#and I suspect that this might be an indicator to how important the mediterranean has been
# in that countrys history. Further research is ofcourse needed as this alone tells us  
# little to nothing.