# Work In Progress (workdflow and instructions are incomplete)

### Install tools
###### tippercanoe 
https://github.com/mapbox/tippecanoe
###### ogr2ogr
###### docker
###### libtiff (maybe)
http://www.linuxfromscratch.org/blfs/view/7.10-systemd/general/libtiff.html

###### gdal2mbtiles
https://github.com/ecometrica/gdal2mbtiles
May require additional ubuntu packages as listed on github plus `sudo apt install gdal-bin python3-gdal` 
You also might need to run this with Python3 e.g. in a python 3 virtualenv


#### note on resources

Resources in `./resources` directory are as per geoserver-static. However...I couldn't find supporting _.shx_ and _.dbf_ files for the world continents shape file layer so for the puposes of this demo I've sourced a continent shape file from elsewhere.

### Convert shape files to geojson 
```
cd resources
ogr2ogr -f GeoJSON ./prepped/cstauscd_r.geojson -t_srs EPSG:4326 -s_srs EPSG:4326 cstauscd_r.shp 
ogr2ogr -f GeoJSON ./prepped/continent.geojson -t_srs EPSG:4326 -s_srs EPSG:4326 continent.shp
cd ../
```
### Convert tif files to RGBA 

(TODO - this isn't working atm)
tiff2rgba -c none resources/prepped/bathcl500md_coloured.tif resources/prepped/bathcl500md_coloured_rgba.tif


### Add georeferencing to tif files

The tif files need to have embedded georeferencing i.e. the coordinates corresponding to the 4 corners of the image need to be included in the tif itself (thus making it a 'geotif').

Please note that the coordinates below are approximate. For production use, these would need to be verified.

World bathymetry
```
gdal_translate -a_nodata 0 -of GTiff -a_srs EPSG:4326 \
  -a_ullr -180.00 90.00 180.00 -90.00 \
  resources/worldmap_large_default.tif \
  resources/prepped/worldmap_large_default.tif
```

Australia region bathymetry
```
gdal_translate -a_nodata 0 -of GTiff -a_srs EPSG:4326 \
  -a_ullr 102.00 -8.00 172.00 -52.00 \
  resources/prepped/bathcl500md_coloured.tif \
  resources/prepped/bathcl500md_coloured_geo.tif
mv resources/prepped/bathcl500md_coloured_geo.tif resources/prepped/bathcl500md_coloured.tif
```

### Create mbiles from geojson

You can change the zoom levels but be careful - bigger zooms increase the tippecanoe processing time
```
# -Z = minZoom
# -z = maxZoom 
tippecanoe -o tilesets/cstauscd_r.mbtiles -Z 0 -z 10 resources/prepped/cstauscd_r.geojson
tippecanoe -o tilesets/continent.mbtiles -Z 0 -z 10 resources/prepped/continent.geojson
```
### Create mbtiles from tifs
```
gdal2mbt resources/prepped/bathcl500md_coloured.tif -z 0-11 -w none -o xyz tilesets/bathcl500md_coloured.mbtiles
```

### serve tilesets 

Run from separate terminals
```
docker run -it -v $(pwd):/data -p 1111:80 klokantech/tileserver-gl tilesets/cstauscd_r.mbtiles
docker run -it -v $(pwd):/data -p 3333:80 klokantech/tileserver-gl tilesets/continent.mbtiles
```

Note that links in www/style.json reference these endpoints so if you need to choose different ports then update www/style.json

You should now be able to browse to http://localhost:1111 and http://localhost:3333 and click 'inspect' to see the tilesets in action

### run demo
```
cd www
python -m SimpleHTTPServer
```
Browse to localhost:8000
