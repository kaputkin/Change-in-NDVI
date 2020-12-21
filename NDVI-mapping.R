library(raster)
library(rgdal)
library(rgeos)
library(osmdata)
library(sf)

# turn off factors
options(stringsAsFactors = FALSE)

#import data
st_11_band4 <- stack("C:/Users/Ari/Desktop/Waywiser/Multi Spectral/S2B_MSIL2A_20201015T160149_N0214_R097_T18TUN_20201015T202139.SAFE/GRANULE/L2A_T18TUN_A018856_20201015T160723/IMG_DATA/R10m/T18TUN_20201015T160149_B04_10m.jp2")
st_11_band8 <- stack("C:/Users/Ari/Desktop/Waywiser/Multi Spectral/S2B_MSIL2A_20201015T160149_N0214_R097_T18TUN_20201015T202139.SAFE/GRANULE/L2A_T18TUN_A018856_20201015T160723/IMG_DATA/R10m/T18TUN_20201015T160149_B08_10m.jp2")
st_06_band4 <- stack("C:/Users/Ari/Desktop/Waywiser/Multi Spectral/S2B_MSIL2A_20200617T155829_N0214_R097_T18TUN_20200617T202806.SAFE/GRANULE/L2A_T18TUN_A017140_20200617T160623/IMG_DATA/R10m/T18TUN_20200617T155829_B04_10m.jp2")
st_06_band8 <- stack("C:/Users/Ari/Desktop/Waywiser/Multi Spectral/S2B_MSIL2A_20200617T155829_N0214_R097_T18TUN_20200617T202806.SAFE/GRANULE/L2A_T18TUN_A017140_20200617T160623/IMG_DATA/R10m/T18TUN_20200617T155829_B08_10m.jp2")

raster.stack <- stack(st_11_band4,st_11_band8,st_06_band4,st_06_band8)
names(raster.stack) <-c("st_11_band4", "st_11_band8", "st_06_band4", "st_06_band8") 


#NDVI formula
ndvi06 <- (raster.stack[[4]] - raster.stack[[3]]) / 
  (raster.stack[[4]] + raster.stack[[3]]) 

ndvi11 <- (raster.stack[[2]] - raster.stack[[1]]) / 
  (raster.stack[[2]] + raster.stack[[1]]) 

#get crs info
raster.stack

#getbb and reproject
my.box <- getbb("Yates County, New York", format_out ="sf_polygon", limit = 1) 
crs <- "+proj=utm +zone=18 +datum=WGS84 +units=m +no_defs" 
my.box <- st_transform(my.box, crs) 

#raster clip
ndvi06 <- crop(ndvi06, my.box)
ndvi11 <- crop(ndvi11, my.box)

#plot NDVI values
hist(ndvi11,
     main = "NDVI Distribution",
     col = "#00ff7f",
     alpha = .5,
     xlab = "value")

hist(ndvi06,
     main = "NDVI Distribution",
     col = "#0df1ff",
     xlab = "value",
     alpha = .5,
     add = T)

#get difference between rasters
diff <- function(a,b){b-a}
#calculate differnce
band_diff <- brick(overlay(ndvi06, ndvi11,
                     fun = diff))


#import lakes from OSM
my_box <- getbb("Yates County, New York", format_out ="sf_polygon", limit = 1)

#pull water for plot
        water1 <- my_box %>%
          opq()%>%
          add_osm_feature(key = "waterway",
                          value = c("riverbank", "dock"
                          )) %>%
          osmdata_sf()
        water1_p <- water1$osm_polygons
        water1_mp <- water1$osm_multipolygons
        
        water2 <- my_box %>%
          opq()%>%
          add_osm_feature(key = "water",
                          value = c("river", "lake", "canal"
                          )) %>%
          osmdata_sf()
        water2_p <- water2$osm_polygons
        water2_mp <- water2$osm_multipolygons
        
        water3 <- my_box %>%
          opq()%>%
          add_osm_feature(key = "natural",
                          value = c("bay", "strait", "wetland", "water"
                          )) %>%
          
          osmdata_sf()
        water3_p <- water3$osm_polygons
        water3_mp <- water3$osm_multipolygons
        
        
        water4 <- my_box %>%
          opq()%>%
          add_osm_feature(key = "landuse",
                          value = c("resevoir"
                          )) %>%
          
          osmdata_sf()
        water4_p <- water4$osm_polygons
        water4_mp <- water4$osm_multipolygons


        #remove all columns except geometry
        reqd <- "geometry"
        water1_p <- water1_p[,reqd]
        water1_mp <- water1_mp[,reqd]
        water2_p <- water2_p[,reqd]
        water2_mp <- water2_mp[,reqd]
        water3_p <- water3_p[,reqd]
        water3_mp <- water3_mp[,reqd]
        water4_p <- water4_p[,reqd]
        water4_mp <- water4_mp[,reqd]
        
        #combine all water features
        water_combined <- rbind(water1_p, water1_mp, water2_p, water2_mp, water3_p, water3_mp, water4_p, water4_mp)
        
        #check geometries and make valid
        st_is_valid(water_combined, reason = TRUE)
        water_combined<- st_make_valid(water_combined)
        
        #water2_mp %>% st_buffer(0)
        total_water <- st_union(water_combined)
        total_water <- as(total_water, 'Spatial')
        my_box <- as(my_box, 'Spatial')
        total_water <- gIntersection(my_box, total_water)
        
        #convert back to sf
        total_water <- st_as_sf(total_water)
        total_water <- st_transform(total_water, crs) 
        
#remove lake cells
band_diff <- mask(band_diff,total_water, inverse = T)

#plot diff raster
hist(band_diff,
     main = "NDVI DIfference",
     col = "#00ff7f",
     xlab = "value")
plot(band_diff)






setwd('C:/Users/Ari/Desktop/Waywiser/Multi Spectral')
writeRaster(band_diff, "band_diff.tif", overwrite = T)
