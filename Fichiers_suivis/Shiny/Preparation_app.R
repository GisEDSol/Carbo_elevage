# Description: Script pour préparer les données à cartographier dans shiny
# Version : 1.0
# O/S: any
# Date: 06/12/2016
# Auteur: Paroissien Jean-Baptiste

# Load the necessary packages
library(shiny)
library(plotly)
library(RODBC)
library(leafletR)
library(dplyr)
library(rgdal)
library(leaflet)
library(reshape2)


# Paramètres #################
tablecarto <- "dm_vecteurs.canton" #Nom de la table utilisée pour la cartographie (table postgis)
dsn <- "PG:dbname='sol_elevage' host='localhost' port='5432' user='jb'" #Paramètre de connexion vers la base de données
period <- c("9094","9599","0004","0509") #
variable <- "corgox_med"#variable à cartographier
variablecarto <- paste(variable,period,sep="")
xlabel <- "Carbone organique (g/kg)" #Nom de la légende
dep <- c("17,16,86,79") #Voir pour la sélection de plusieurs département.
reg <- "54" #code de la région à cartographier
nclasse <- 5 #Nombre de classes de valeurs pour la cartographie
couleur <- "YlGnBu" #Nom de la palette couleur (selon RColorBrewer)display.brewer.all() pour connaître les différentes palettes
l_variable <- "Teneur en carbone organique (g/kg)" #label de la variable
##############################

# Lecture du postgis
map <- readOGR(dsn = dsn, tablecarto)

# Transformation pour leaflet
map <- spTransform(map, CRS("+init=epsg:4326"))

# Voir comment gérer les classes de valeurs

classe_valeur <- classIntervals(mapcanton@data$corgox_med9094,n=5,style="quantile",digits=2,na.rm=TRUE)[[2]]
mapcanton@data$corgox_med9094 <- cut(mapcanton@data$corgox_med9094,breaks = data.frame(classe_valeur)[,1],include.lowest=T)  

addPolygons(color = heat.colors(NLEV, NULL)[LEVS]) %>%


# Test
leaflet() %>% 
  addPolygons(data = map, 
              #fillColor = ~palette(map@data$corgox_med9599),  ## we want the polygon filled with 
              ## one of the palette-colors
              ## according to the value in student1$Anteil
              fillOpacity = 0.6,         ## how transparent do you want the polygon to be?
              color = "darkgrey",       ## color of borders between districts
              weight = 1.5)            ## width of borders
              

              popup = popup1,         ## which popup?
              group="<span style='color: #7f0000; font-size: 11pt'><strong>2000</strong></span>")%>%  
  ## which group?
  ## the group's name has to be the same as later in "baseGroups", where we define 
  ## the groups for the Layerscontrol. Because for this layer I wanted a specific 
  ## color and size, the group name includes some font arguments.  


























# Variables de travail
rep_shiny <- "/media/sf_GIS_ED/Dev/test/"

# Préparation des fichiers
dsn <- "PG:dbname='sol_elevage' host='localhost' port='5432' user='jb'"
reg <- "54"

# Lecture du postgis
mapcanton <- readOGR(dsn = dsn, "canton")
# Sélection de la zone d'étude
mapcanton <- mapcanton[mapcanton@data$code_reg==reg,]

# Sélection des variables d'intérêts

variable.carto <- c("code_canton","corgox_med9094","corgox_med9599","corgox_med0004","corgox_med0509")
mapcanton@data <- mapcanton@data[,variable.carto]

## Melt du fichier
mapmelt <- melt(mapcanton@data,id="code_canton") # A partir de là, on pourrait créer une colonne année avec une expression régulière (voir préparation BDELEvage_sol)

## Export csv et GeoJSon
toGeoJSON(data=mapcanton, dest=rep_shiny)
write.csv(mapmelt,file=paste(rep_shiny,"canton_table.csv",sep=""))

## Test avec leaflet ## (https://rstudio.github.io/leaflet/shiny.html)

dsn <- "PG:dbname='sol_elevage' host='localhost' port='5432' user='jb'"
# Sélection de la région d'étude 
reg <- "54" #54pour région Poitou Charentes 
# Lecture du postgis
mapcanton <- readOGR(dsn = dsn, "canton")
mapcanton <- mapcanton[mapcanton@data$code_dept==45,]
mapcanton <- mapcanton[complete.cases(mapcanton@data$corgox_med9094),]

# Transformation pour leaflet
mapcanton <- spTransform(mapcanton, CRS("+init=epsg:4326"))


classe_valeur <- classIntervals(mapcanton@data$corgox_med9094,n=5,style="quantile",digits=2,na.rm=TRUE)[[2]]
mapcanton@data$corgox_med9094 <- cut(mapcanton@data$corgox_med9094,breaks = data.frame(classe_valeur)[,1],include.lowest=T)  

addPolygons(color = heat.colors(NLEV, NULL)[LEVS]) %>%


# Test
leaflet() %>% 
  addPolygons(data = mapcanton, 
              fillColor = ~palette(mapcanton@data$corgox_med9599),  ## we want the polygon filled with 
              ## one of the palette-colors
              ## according to the value in student1$Anteil
              fillOpacity = 0.6,         ## how transparent do you want the polygon to be?
              color = "darkgrey",       ## color of borders between districts
              weight = 1.5)            ## width of borders
              

              popup = popup1,         ## which popup?
              group="<span style='color: #7f0000; font-size: 11pt'><strong>2000</strong></span>")%>%  
  ## which group?
  ## the group's name has to be the same as later in "baseGroups", where we define 
  ## the groups for the Layerscontrol. Because for this layer I wanted a specific 
  ## color and size, the group name includes some font arguments.  



palette(student1$Anteil)






setwd("/home/jb/Bureau/")
dortmund <- readOGR("Statistische Bezirke.kml", #name of file
                    #if your browser adds a .txt after downloading the file
                    #you can add it here, too!
                    "Statistische_Bezirke",     #name of layer
                    encoding="utf-8"           #if our data contains german Umlauts like ä, ö and ü
)

student1 <- read.csv("student1.csv", encoding="latin1", sep=",", dec=".")
student2 <- read.csv("student2.csv", encoding="latin1", sep=",", dec=".")

palette <- colorBin(c('#fee0d2',  #an example color scheme. you can substitute your own colors
                      '#fcbba1',
                      '#fc9272',
                      '#fb6a4a',
                      '#ef3b2c',
                      '#cb181d',
                      '#a50f15',
                      '#67000d'), 
                    bins = c(0, 5, 8, 10, 12, 14, 18, 24, 26))

popup1 <- paste0("<span style='color: #7f0000'><strong>18-25 year olds 2000</strong></span>",
                 "<br><span style='color: salmon;'><strong>District: </strong></span>", 
                 student1$Bezirk, 
                 "<br><span style='color: salmon;'><strong>relative amount: </strong></span>", 
                 student1$Anteil
                 ,"<br><span style='color: salmon;'><strong>absolute amount: </strong></span>", 
                 student1$X2000   
)

popup2 <- paste0("18-25 year olds 2014",
                 "<br>District: ",             
                 student2$Bezirk,         #column containing the district names
                 "<br>relative amount: ", 
                 student2$Anteil          #column that contains the relative amount data
                 ,"<br>absolute amount: ", 
                 student2$X2014           #column that contains the absolute amount data
)

mymap <- leaflet() %>% 

  
  addPolygons(data = dortmund, 
              fillColor = ~palette(student1$Anteil),  ## we want the polygon filled with 
              ## one of the palette-colors
              ## according to the value in student1$Anteil
              fillOpacity = 0.6,         ## how transparent do you want the polygon to be?
              color = "darkgrey",       ## color of borders between districts
              weight = 1.5,            ## width of borders
              popup = popup1,         ## which popup?
              group="<span style='color: #7f0000; font-size: 11pt'><strong>2000</strong></span>")%>%  
  ## which group?
  ## the group's name has to be the same as later in "baseGroups", where we define 
  ## the groups for the Layerscontrol. Because for this layer I wanted a specific 
  ## color and size, the group name includes some font arguments.  
  
  ## for the second layer we mix things up a little bit, so you'll see the difference in the map!
  addPolygons(data = dortmund, 
              fillColor = ~palette(student2$Anteil), 
              fillOpacity = 0.2, 
              color = "white", 
              weight = 2.0, 
              popup = popup2, 
              group="2014")%>%

  addLayersControl(
    baseGroups = c("<span style='color: #7f0000; font-size: 11pt'><strong>2000</strong></span>", ## group 1
                   "2014" ## group 2
    ),
    options = layersControlOptions(collapsed = FALSE))%>% ## we want our control to be seen right away

  addLegend(position = 'topleft', ## choose bottomleft, bottomright, topleft or topright
            colors = c('#fee0d2',
                       '#fcbba1',
                       '#fc9272',
                       '#fb6a4a',
                       '#ef3b2c',
                       '#cb181d',
                       '#a50f15',
                       '#67000d'), 
            labels = c('0%',"","","","","","",'26%'),  ## legend labels (only min and max)
            opacity = 0.6,      ##transparency again
            title = "relative<br>amount")   ## title of the legend

print(mymap)
















# From https://www.census.gov/geo/maps-data/data/cbf/cbf_state.html
states <- readOGR("shp/cb_2013_us_state_20m.shp",
                  layer = "cb_2013_us_state_20m", verbose = FALSE)

neStates <- subset(states, states$STUSPS %in% c(
  "CT","ME","MA","NH","RI","VT","NY","NJ","PA"
))

leaflet(neStates) %>%
  addPolygons(
    stroke = FALSE, fillOpacity = 0.5, smoothFactor = 0.5,
    color = ~colorQuantile("YlOrRd", states$AWATER)(AWATER)
  )






library(shiny)
library(leaflet)
library(RColorBrewer)

ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(top = 10, right = 10,
                sliderInput("range", "Magnitudes", min(quakes$mag), max(quakes$mag),
                            value = range(quakes$mag), step = 0.1
                ),
                selectInput("colors", "Color Scheme",
                            rownames(subset(brewer.pal.info, category %in% c("seq", "div")))
                ),
                checkboxInput("legend", "Show legend", TRUE)
  )
)

server <- function(input, output, session) {
  
  # Reactive expression for the data subsetted to what the user selected
  filteredData <- reactive({
    quakes[quakes$mag >= input$range[1] & quakes$mag <= input$range[2],]
  })
  
  # This reactive expression represents the palette function,
  # which changes as the user makes selections in UI.
  colorpal <- reactive({
    colorNumeric(input$colors, quakes$mag)
  })
  
  output$map <- renderLeaflet({
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    leaflet(quakes) %>% addTiles() %>%
      fitBounds(~min(long), ~min(lat), ~max(long), ~max(lat))
  })
  
  # Incremental changes to the map (in this case, replacing the
  # circles when a new color is chosen) should be performed in
  # an observer. Each independent set of things that can change
  # should be managed in its own observer.
  observe({
    pal <- colorpal()
    
    leafletProxy("map", data = filteredData()) %>%
      clearShapes() %>%
      addCircles(radius = ~10^mag/10, weight = 1, color = "#777777",
                 fillColor = ~pal(mag), fillOpacity = 0.7, popup = ~paste(mag)
      )
  })
  
  # Use a separate observer to recreate the legend as needed.
  observe({
    proxy <- leafletProxy("map", data = quakes)
    
    # Remove any existing legend, and only if the legend is
    # enabled, create a new one.
    proxy %>% clearControls()
    if (input$legend) {
      pal <- colorpal()
      proxy %>% addLegend(position = "bottomright",
                          pal = pal, values = ~mag
      )
    }
  })
}

shinyApp(ui, server)
