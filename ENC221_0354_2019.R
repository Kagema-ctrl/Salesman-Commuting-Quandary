library(knitr)
install.packages("tidygraph")


library(dplyr)
library(sf)
library(tidygraph)
library(igraph)
library(tibble)
library(ggplot2)
library(units)
library(osmdata)
install.packages('rgrass7')
library(rgrass7)
library(link2GI)
library(nabor)
library(janitor)
library(dodgr)
install.packages('tidyverse')
library(tidyverse) 

library(leaflet)
library(geosphere)
install.packages('TSP')
library(TSP)
install.packages('ompr')
install.packages('ROI.plugin.glpk')
library(ompr)
library(ROI.plugin.glpk)
install.packages('ompr.roi')
library(ompr.roi)
library(magrittr)
library(ggmap)
library(gmapsdistance)
install.packages("knitr")
library(knitr)

#to dave the map in a pdf

#pdf(file = 'C:/Users/dell/Desktop/4.2/GIS Applications/Assignments')

#Creating Monaco dataframe

df=as.data.frame(matrix(nrow = 5,ncol = 4))
colnames(df)=c('location','lat','long','values')

#adding Monaco`s city name as locations
df$location=c('Monaco,Monaco','La Condamine,Monaco','Larvotto,Monaco',
              "Beausoleil, Monaco",'Ravin de Sainte-Devote,Monaco')



for(i in 1:nrow(df)){
  coordinates=getbb(df$location[i])
  df$long[i]=(coordinates[1,1]+coordinates[1,2])/2
  df$lat[i]=(coordinates[2,1]+coordinates[2,2])/2
}

#adding randomly distributed values by location
df$values=runif(n=5,min = 0,max=100)
id<-c(1,2,3,4,5)
df$id<-id
print(df)
df%>%
  leaflet() %>% 
  addTiles() %>%
  addProviderTiles(providers$OpenStreetMap.DE)%>%
  setView(mean(df$long),mean(df$lat),6)%>%
  addMarkers(lng=~long,lat = ~lat,
             popup = ~values,label = ~location )


df_coords <- df %>% 
  select(long, lat)
distance_matrix <- as.matrix(
  distm(df_coords, fun = distHaversine)
)/1000

rownames(distance_matrix) <- df$location
colnames(distance_matrix) <- df$location

n <- length(df$id)
print(n)
dist_fun <- function(i, j) {
  vapply(seq_along(i), function(k) distance_matrix[i[k], j[k]], numeric(1L))
}

n<-5

model <- MILPModel() %>%
  # we create a variable that is 1 iff we travel from city i to j
  add_variable(x[i, j], i = 1:n, j = 1:n, 
               type = "integer", lb = 0, ub = 1) %>%
  
  # a helper variable for the MTZ formulation of the tsp
  add_variable(u[i], i = 1:n, lb = 1, ub = n) %>% 
  
  # minimize travel distance
  set_objective(sum_expr(colwise(dist_fun(i, j)) * x[i, j], i = 1:n, j = 1:n), "min") %>%
  
  # you cannot go to the same city
  set_bounds(x[i, i], ub = 0, i = 1:n) %>%
  
  # leave each city
  add_constraint(sum_expr(x[i, j], j = 1:n) == 1, i = 1:n) %>%
  
  # visit each city
  add_constraint(sum_expr(x[i, j], i = 1:n) == 1, j = 1:n) %>%
  
  # ensure no subtours (arc constraints)
  add_constraint(u[i] >= 2, i = 2:n) %>% 
  add_constraint(u[i] - u[j] + 1 <= (n - 1) * (1 - x[i, j]), i = 2:n, j = 2:n)
model

result <- solve_model(model, with_ROI(solver = "glpk", verbose = TRUE))

result_val <- round(objective_value(result), 2)
result_val

#RESULTS

solution <- get_solution(result, x[i, j]) %>% 
  filter(value > 0)
kable(head(solution, 15))

paths <- select(solution, i, j) %>%
  rename(from = i, to = j) %>%
  mutate(trip_id = row_number()) %>%
  tidyr::gather(property, idx_val, from:to) %>%
  mutate(idx_val = as.integer(idx_val)) %>%
  inner_join(df, by = c("idx_val" = "id"))
kable(head(arrange(paths, trip_id), 3))

#World Map

world <- get_stamenmap(
  bbox = c(left = -4.745, bottom = 42.278, right = 8.514, top = 51.268), 
  maptype = "terrain",
  zoom = 7)
ggmap(world)+
  geom_point(data=paths,aes(long,lat),shape=21,size=3,fill='blue',color='blue')+
  geom_line(data = paths, aes(group = trip_id,long),color='red',lwd=.8) +
  ggtitle(paste0("SALESMAN COMMUTING QUANDARY  ",
                 round(objective_value(result), 3)))+ 
  labs(caption = "BY KAGEMA ABIGAIL WAMBUI\ENC221-0354/2019")

#ADDING A BASEMAP

paths <- select(solution, i, j) %>% 
  rename(from = i, to = j) %>% 
  mutate(trip_id = row_number()) %>% 
  inner_join(df, by = c("from" = "id"))



print(df)
paths_leaflet <- paths[1,]
paths_row <- paths[1,]
# print(paths_row)

for (i in 1:n) {
  paths_row <- paths %>% filter(from == paths_row$to[1])
  
  paths_leaflet <- rbind(paths_leaflet, paths_row)
}

leaflet() %>% 
  addTiles() %>%
  addMarkers(data = df, ~long, ~lat, popup = ~values, label = ~location) %>% 
  addPolylines(data = paths_leaflet, ~long, ~lat, weight = 2,color = 'red')


dev.off()

