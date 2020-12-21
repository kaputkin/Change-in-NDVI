library(leaflet)

#BUILD MAP  
leaflet() %>%
  addProviderTiles(providers$CartoDB.PositronNoLabels) %>% 
  setView( -77.10542138315246, 42.749051268790645,  zoom = 13)%>%
  addTiles("https://kaputkin.github.io/tileserver/tiles/NVDI/{z}/{x}/{y}.png", group = "NVDI")%>%  
  hideGroup("NVDI")%>%  
  addTiles("https://kaputkin.github.io/tileserver/tiles/grid/{z}/{x}/{y}.png", group = "Grid")%>%  
  hideGroup("Grid")%>%
  addTiles("https://kaputkin.github.io/tileserver/tiles/contours/{z}/{x}/{y}.png", group = "Contours")%>%  
  hideGroup("Contours")%>%
  addTiles("https://kaputkin.github.io/tileserver/tiles/halftone/{z}/{x}/{y}.png", group = "Halftone")%>%  

  
#add legend
addLayersControl(baseGroups = c("NVDI", "Grid", "Contours", "Halftone"),
                 options = layersControlOptions(collapsed = FALSE))



?layersControlOptions
