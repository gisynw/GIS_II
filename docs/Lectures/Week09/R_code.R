data("boston.c", package = "spData")

# Peek variables
str(boston.c)

# Convert to sf points (WGS84)
boston_sf <- st_as_sf(
  boston.c,
  coords = c("LON", "LAT"),
  crs = 4326, remove = FALSE
)

# Choose where to save (change this path if needed)
output_path <- "E:\\ConwayTeaching\\GIS_II\\GIS_II_Github\\docs\\Lectures\\Week09boston_housing.shp"

# Write shapefile
st_write(boston_sf, output_path, delete_layer = TRUE)
