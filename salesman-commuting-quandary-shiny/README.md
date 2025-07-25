# Salesman Commuting Quandary Shiny Web App

## Overview
This project implements a Shiny web application that visualizes the Salesman Commuting Quandary problem using an interactive map. The application allows users to explore various locations and the optimal routes between them.

## Project Structure
- **app.R**: The main application file containing the server and UI logic for the Shiny web app.
- **data/locations.csv**: A CSV file containing location data used in the web map, including location names, latitude, longitude, and other relevant attributes.
- **www/custom.css**: A CSS file for custom styling of the Shiny app's UI elements.

## Installation
To run this Shiny app, you need to have R and the following packages installed:
- shiny
- leaflet
- dplyr
- ggplot2
- readr

You can install the required packages using the following command in R:
```R
install.packages(c("shiny", "leaflet", "dplyr", "ggplot2", "readr"))
```

## Running the App
1. Open R or RStudio.
2. Set your working directory to the location of the project files.
3. Run the app using the following command:
```R
shiny::runApp("app.R")
```

## Usage
Once the app is running, you will see an interactive map displaying the locations specified in the `data/locations.csv` file. You can interact with the map to explore different routes and visualize the commuting problem.

## Contributing
If you would like to contribute to this project, please fork the repository and submit a pull request with your changes.

## License
This project is licensed under the MIT License. See the LICENSE file for more details.