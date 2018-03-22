## vector-demo

This illustrates the workflow to serve tilesets based on the raw assets that are used by geoserver for the default_bathymetry layer. This is essentially:
- convert shapefiles (Australia, and world continents outlines) to GeoJSON
- convert Tifs to GeoTif (world bathymetry image and Australian-region bathymetry image)
- convert GeoJSON and GeoTifs to `mbtile` tileset files (sqlite)
- serve tilesets using docker
- point JS mapping APIs to a pre-prepared `style` which points to the tilesets being served

### Requirements
- Docker

#### Note on resources

Resources in `./resources` directory are as per the raw files rendered by geoserver-static. However...I couldn't find supporting _.shx_ and _.dbf_ files for the world continents shape file layer so for the puposes of this demo I've sourced a continent shape file from elsewhere then manually removed Australia.

#### Build and run Vectoriser

The Vectoriser is an docker container that has several GIS tools installed

Build the Vectoriser image
```
#from project root dir
docker build -t vectoriser ./docker/Vectoriser
```

Run the Vectoriser container (takes a few minutes)
```
#from project root dir 
docker run -v "$(pwd):/data" -i -t vectoriser ./create_tilesets.sh
```
This will output .mbtileset files to the local ./tilesets directory

#### Serve tilesets

Run `docker-compose up` in the project root dir. This will start up 4 containers each serving a different .mbtileset 

#### run web demo

Serve the `www` directory e.g. using Python in another terminal
```
cd www
python -m SimpleHTTPServer
```

Browse to localhost:8000

#### Note on vector support in JS Mapping APIs
An examination of what different mapping apis are capable of doing with vector layers is still to be completed. For demo purposes however, you will see that
- Mapbox works very well
- OpenLayers (versions 2 and 4) both load tiles as rasters

#### Next Steps
- Implement a workflow for exporting .mbtileset -> disk. Once objects are on disk and are servable via HTTP, then logically, they can be served from an S3 bucket.
- Explore more JS options

#### Understand 

Some Mapbox tools are used to produce this demo. While Mapbox.com is a subscription-based service (actually the free-tier is great), most of their suite of tools/specifications are open source https://www.mapbox.com/about/open/

Styles
- The style documents in `www/styles` conform to the [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-js/style-spec/)
- These were drafted using Mapbox Studio but can be easily produced/edited manually

MBTiles
- The files output by the Vectoriser container are SQLite files.

_TODO_ can always add more info about how it all works but let me know if there's anything that I can elaborate on.






