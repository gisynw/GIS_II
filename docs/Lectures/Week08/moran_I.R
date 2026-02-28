setwd("O:\\data")

packages <- c("spData", "sf", "mapview", "tmap")

installed <- packages %in% rownames(installed.packages())

if (any(!installed)) {
  install.packages(packages[!installed], repos = "https://cloud.r-project.org")
}

library(spData)
library(sf)
library(mapview)
library(spdep)
library(tmap)

# 1) read data
map <- sf::st_read(system.file("shapes/boston_tracts.gpkg", package="spData")[1], quiet = TRUE)
map$`Median Value` <- map$MEDV

# 2) 为了做 KNN 距离更合理：投影到米单位（Boston: NAD83 / Massachusetts Mainland）
map_m <- st_transform(map, 26986)

# 3) 用每个多边形的“中心点”来画连线
cent <- st_centroid(map_m)
xy <- st_coordinates(cent)

# --- 一个通用“把邻接列表 nb 变成 sf 线”的小段代码（不写成函数，直接复制用） ---
make_edges_sf <- function(nb, xy, crs) {
  pairs <- do.call(rbind, lapply(seq_along(nb), function(i) {
    if (length(nb[[i]]) == 0) return(NULL)
    cbind(i, nb[[i]])
  }))
  # pairs <- pairs[pairs[,1] < pairs[,2], , drop = FALSE]  # 去重：只保留 i<j
  
  lines <- lapply(seq_len(nrow(pairs)), function(r) {
    i <- pairs[r, 1]; j <- pairs[r, 2]
    st_linestring(rbind(xy[i, ], xy[j, ]))
  })
  st_sf(geometry = st_sfc(lines, crs = crs))
}

# 4) 三种 weights
# (A) Rook：共享边（edges only）
nb_rook  <- poly2nb(map_m, queen = FALSE)

# (B) Queen：共享边或角（edges + corners）
nb_queen <- poly2nb(map_m, queen = TRUE)

# (C) KNN：每个区域连到最近的 K 个中心点（这里示例 K=4，可改 6/8）
k <- 4
knn <- knearneigh(xy, k = k)
nb_knn <- knn2nb(knn)

# 5) 转成可画的线
edges_rook  <- make_edges_sf(nb_rook,  xy, st_crs(map_m))
edges_queen <- make_edges_sf(nb_queen, xy, st_crs(map_m))
edges_knn   <- make_edges_sf(nb_knn,   xy, st_crs(map_m))

# 6) 画图（3 张图分别输出；你可以截图放 PPT）
map_wgs  <- st_transform(map_m, 4326)
rook_wgs <- st_transform(edges_rook, 4326)
queen_wgs <- st_transform(edges_queen, 4326)
knn_wgs  <- st_transform(edges_knn, 4326)

# 交互式地图：面 + 红线（权重连接）
m1 <- mapview(map_wgs, zcol = "Median Value", layer.name = "Median Value") +
  mapview(rook_wgs, color = "red", lwd = 2, layer.name = "Contiguity edges only)")

m2 <- mapview(map_wgs, zcol = "Median Value", layer.name = "Median Value") +
  mapview(queen_wgs, color = "red", lwd = 2, layer.name = "Contiguity edges corners")

m3 <- mapview(map_wgs, zcol = "Median Value", layer.name = "Median Value") +
  mapview(knn_wgs, color = "red", lwd = 2, layer.name = paste0("K Nearest neighbors (K=", k, ")"))

m1
m2
m3
