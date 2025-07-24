# Salesman Commuting Quandary 🚗📍

This project solves the classic **Traveling Salesman Problem (TSP)** for five real-world locations in **Monaco**, using spatial data science and optimization in R. It demonstrates how geospatial data, mathematical modeling, and map visualization can be combined to solve real-world routing challenges.

## 🔍 Project Overview

- **Objective**: Find the shortest route that visits each location once and returns to the starting point.
- **Study Area**: Monaco — including locations such as Monaco City, La Condamine, Larvotto, Beausoleil, and Ravin de Sainte-Devote.
- **Result**: The model computed an optimal round-trip distance of **27.505 km**.

## 🧰 Tools & Packages Used

- **Spatial Data**: [`osmdata`](https://cran.r-project.org/package=osmdata), [`geosphere`](https://cran.r-project.org/package=geosphere)
- **Optimization**: [`ompr`](https://cran.r-project.org/package=ompr), `ROI.plugin.glpk`
- **Visualization**: `leaflet`, `ggmap`, `ggplot2`
- **Data Wrangling**: `dplyr`, `tibble`, `janitor`

## 🗺️ Key Features

- Uses real coordinates extracted from OpenStreetMap
- Constructs a distance matrix using the Haversine formula
- Solves TSP using Mixed Integer Linear Programming (MILP)
- Visualizes route on interactive maps (Leaflet) and terrain maps (ggmap)

