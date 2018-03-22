#!/bin/bash

#bump any existing tilesets
rm -rf ./tilesets/*
mkdir -p ./tilesets

#create working directory
mkdir -p /tmp/vector 

#convert shape files to geojson
ogr2ogr -f GeoJSON /tmp/vector/cstauscd_r.geojson -t_srs EPSG:4326 -s_srs EPSG:4326 resources/cstauscd_r.shp
ogr2ogr -f GeoJSON /tmp/vector/continent.geojson -t_srs EPSG:4326 -s_srs EPSG:4326 resources/continent.shp

#add georeferencing data to tifs
gdal_translate -a_nodata 0 -of GTiff -a_srs EPSG:4326 -a_ullr -180.00 90.00 180.00 -90.00 resources/worldmap_large_default.tif /tmp/vector/worldmap_large_default.tif
gdal_translate -a_nodata 0 -of GTiff -a_srs EPSG:4326 -a_ullr 102.00 -8.00 172.00 -52.00 resources/bathcl500md_coloured.tif /tmp/vector/bathcl500md_coloured.tif

#create mbtiles for tifs
gdal_translate -of mbtiles /tmp/vector/bathcl500md_coloured.tif /tmp/vector/bathcl500md_coloured.mbtiles
gdal_translate -of mbtiles /tmp/vector/worldmap_large_default.tif /tmp/vector/worldmap_large_default.mbtiles

#create mbtiles for geojson 
tippecanoe -o /tmp/vector/cstauscd_r.mbtiles -Z 0 -z 10 /tmp/vector/cstauscd_r.geojson
tippecanoe -o /tmp/vector/continent.mbtiles -Z 0 -z 10 /tmp/vector/continent.geojson

cp /tmp/vector/*.mbtiles ./tilesets/
