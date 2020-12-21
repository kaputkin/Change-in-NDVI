library(leaflet)
library(leaflet.extras2)

leaflet() %>%
  addMapPane("left", zIndex = 0) %>%
  addMapPane("right", zIndex = 0) %>%
  setView( -77.10542138315246, 42.749051268790645,  zoom = 13)%>%
  
  
  addProviderTiles(providers$CartoDB.PositronNoLabels, group="carto", layerId = "leftpane",
                   options = pathOptions(pane = "left")) %>%
  addProviderTiles(providers$CartoDB.PositronNoLabels, group="carto", layerId = "rightpane",
                   options = pathOptions(pane = "right")) %>%
  
  
  addTiles("https://kaputkin.github.io/tileserver/tiles/NVDI/{z}/{x}/{y}.png", group = "NVDI",
           options = pathOptions(pane = "left")) %>%  
  addTiles("https://kaputkin.github.io/tileserver/tiles/contours/{z}/{x}/{y}.png", group = "Contours",
           options = pathOptions(pane = "right")) %>%
  hideGroup("Contours")%>%
  addTiles("https://kaputkin.github.io/tileserver/tiles/grid/{z}/{x}/{y}.png", group = "Hex Grid",
           options = pathOptions(pane = "right")) %>%
  hideGroup("Hex Grid")%>%
  addTiles("https://kaputkin.github.io/tileserver/tiles/halftone/{z}/{x}/{y}.png", group = "Halftone",
           options = pathOptions(pane = "right")) %>%
  
  
  addLayersControl(baseGroups = c("Contours","Hex Grid", "Halftone"),
                   options = layersControlOptions(collapsed = FALSE)) %>%
  addSidebyside(layerId = "sidecontrols",
                rightId = "rightpane",
                leftId = "leftpane")
