#Mapping out the Unesco world heritage sites map

# Activate the libraries
library(leaflet)
library(htmlwidgets)
library(tidyverse)
library(googlesheets4)
library(xlsx)
library(readxl)
gs4_deauth()

# Create a basic basemap
Base_map <- leaflet() %>% 
  #Base groups
  setView(lng = 1, lat = 50, zoom = 1.8) %>% 
 addTiles() %>% 
 addProviderTiles(providers$Esri.WorldPhysical,
                  group="Physical") %>%
 addProviderTiles(providers$Esri,
                  group="Base") %>%
#Layer control
addLayersControl(
  baseGroups = c("Physical", "Base"),
  options = layersControlOptions(collapsed = TRUE)) %>% 
#avoid panning out of bounds to map without the pins 
  setMaxBounds(-180,-90,180,90)
  

#Check your base map
Base_map


#Load in the World heritage sites list 
#that was downloaded from the official website
Heritage_list <- read_excel("data/whc-sites-2021.xls")


#check that is loaded in correctly
head(Heritage_list)


# add the markers to the map

Marker_map <- Base_map %>% 
  addMarkers(lng = Heritage_list$longitude, 
             lat = Heritage_list$latitude)

#Check the results
Marker_map

#Get the tacks colored
getColor <- function(Heritage_list) {
  sapply(Heritage_list$Category_nummerical, function(Category_nummerical) {
    if(Category_nummerical > 77) {
      "green"
    } else if(Category_nummerical <= 68) {
      "orange"
    } else if(Category_nummerical < 77){
      "red"
    } })
}

#design the marker icons
icons <- awesomeIcons(
  icon = 'NULL',
  iconColor = 'black',
  library = 'fa',
  markerColor = getColor(Heritage_list))


#apply the colored markers
Colored_tacks_map<-leaflet(Heritage_list) %>% 
  #apply the code from the base map
  setView(lng = 1, lat = 50, zoom = 1.8) %>% 
  addTiles() %>% 
  addProviderTiles(providers$Esri.WorldPhysical,group="Physical") %>%
  addProviderTiles(providers$Esri,group="Base") %>%
  #Layer control
  addLayersControl(
    baseGroups = c("Physical", "Base"),
    options = layersControlOptions(collapsed = TRUE)) %>% 
  #avoid panning out of bounds to map without the pins 
  setMaxBounds(-180,-90,180,90) %>%
  #here the colored markers are added
  addAwesomeMarkers(Heritage_list$longitude, 
                    Heritage_list$latitude, 
                    icon=icons, 
                    label=~as.character(name_en),
                    popup = paste("Category:",Heritage_list$category,
                                  "Country:",Heritage_list$states_name_en))
  

#view the product 
Colored_tacks_map

#time to add the slider :)



#Save the map as a HTML- file
saveWidget(Colored_tacks_map, "recreation.html", selfcontained = TRUE)

