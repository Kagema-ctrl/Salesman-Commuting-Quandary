library(shiny)
library(leaflet)
library(dplyr)
library(readr)
library(geosphere)
library(ompr)
library(ompr.roi)
library(ROI.plugin.glpk)

# Load location data
locations <- read_csv("data/locations.csv")

# Calculate distance matrix
df_coords <- locations %>% select(longitude, latitude)
distance_matrix <- as.matrix(
  distm(df_coords, fun = distHaversine)
) / 1000

n <- nrow(locations)

# TSP model
model <- MILPModel() %>%
  add_variable(x[i, j], i = 1:n, j = 1:n, type = "integer", lb = 0, ub = 1) %>%
  add_variable(u[i], i = 1:n, lb = 1, ub = n) %>%
  set_objective(sum_expr(distance_matrix[i, j] * x[i, j], i = 1:n, j = 1:n), "min") %>%
  set_bounds(x[i, i], ub = 0, i = 1:n) %>%
  add_constraint(sum_expr(x[i, j], j = 1:n) == 1, i = 1:n) %>%
  add_constraint(sum_expr(x[i, j], i = 1:n) == 1, j = 1:n) %>%
  add_constraint(u[i] >= 2, i = 2:n) %>%
  add_constraint(u[i] - u[j] + 1 <= (n - 1) * (1 - x[i, j]), i = 2:n, j = 2:n)

result <- solve_model(model, with_ROI(solver = "glpk", verbose = FALSE))
solution <- get_solution(result, x[i, j]) %>% filter(value > 0.5)

# Build route order
route <- numeric(n + 1)
route[1] <- 1
for (k in 2:(n + 1)) {
  next_city <- solution$j[solution$i == route[k - 1]]
  if (length(next_city) == 0) break
  route[k] <- next_city
}
route <- route[!duplicated(route)]

# Prepare route data for leaflet
route_df <- locations[route, ]

# Define UI
ui <- fluidPage(
  titlePanel("Salesman Commuting Quandary"),
  leafletOutput("map"),
  sidebarLayout(
    sidebarPanel(
      h4("Location Information"),
      textOutput("location_info")
    ),
    mainPanel(
      h4("Map Controls"),
      helpText("Click on a marker to see location details.")
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  output$map <- renderLeaflet({
    leaflet(data = locations) %>%
      addTiles() %>%
      addMarkers(~longitude, ~latitude,
                 popup = ~paste("<strong>", location_name, "</strong><br>",
                                "Latitude: ", latitude, "<br>",
                                "Longitude: ", longitude),
                 label = ~location_name) %>%
      addPolylines(data = route_df, lng = ~longitude, lat = ~latitude, color = "red", weight = 3)
  })

  output$location_info <- renderText({
    req(input$map_marker_click)
    clicked_location <- input$map_marker_click
    paste("You clicked on:", clicked_location$id)
  })
}

shinyApp(ui = ui, server = server)