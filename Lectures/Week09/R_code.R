data("boston.c", package = "spData")

# Peek variables
str(boston.c)

# Convert to sf points (WGS84)
boston_sf <- st_as_sf(
  boston.c,
  coords = c("LON", "LAT"),
  crs = 4326, remove = FALSE
)

map <- sf::st_read(system.file("shapes/boston_tracts.gpkg", package="spData")[1], quiet = TRUE)

# Choose where to save (change this path if needed)
output_path <- "E:\\ConwayTeaching\\GIS_II\\GIS_II_Github\\docs\\Lectures\\Week09\\boston_housing.shp"

# Write shapefile
st_write(map, output_path, delete_layer = TRUE)
