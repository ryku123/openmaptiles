# OpenMapTiles workshop, FOSS4G Hokkaido

- [Presentation](https://docs.google.com/presentation/d/1VAGQKfViLYuL8Ca9nyfjF70-bEH0M9Ho4JSNlw42Sqg/edit?usp=sharing)


## Import docker images
```bash
docker load -i generate-vectortiles.tar
docker load -i import-osmborder.tar
docker load -i import-water.tar
docker load -i tileserver-gl.tar
docker load -i import-lakelines.tar
docker load -i import-osm.tar
docker load -i omt-tools.tar
docker load -i import-natural-earth.tar
docker load -i import-sql.tar
docker load -i postgres.tar
```

## Download and serve raster and vector tiles from your server
- https://openmaptiles.org/downloads/

```bash
cd path/to/downloaded/file
```

**Linux**
```bash
docker run -it --rm -v $(pwd):/data -p 8080:80 klokantech/tileserver-gl:v1.7.0 <name of your mbtiles file>
```

**Windows**
```bash
docker run -it --rm -v %cd%:/data -p 8080:80 klokantech/tileserver-gl:v1.7.0 <name of your mbtiles file>
```


## Generate your own vector tiles

```
git clone https://github.com/openmaptiles/openmaptiles.git openmaptiles
cd openmaptiles
git checkout v3.6
```

```
docker-compose up mapbox-studio
```

- https://github.com/mapbox/tippecanoe


## Generate your own OpenMapTiles
```
### Download Albania
docker-compose run --rm import-osm  ./download-geofabrik.sh albania
```

```
### Prepare import configuration
docker-compose run --rm openmaptiles-tools make clean
docker-compose run --rm openmaptiles-tools make
```

```
### Start DB
docker-compose up   -d postgres
```

```
### Import data
docker-compose run --rm import-water
docker-compose run --rm import-osmborder
docker-compose run --rm import-natural-earth
docker-compose run --rm import-lakelines
docker-compose run --rm import-osm
docker-compose run --rm import-sql
```

```
### Connect to DB
docker-compose run --rm postgres psql postgresql://openmaptiles@postgres/openmaptiles
```

```
### Analyze (reporting), vacuum analyze (lower DB size)
docker-compose run --rm import-osm /usr/src/app/psql.sh  -P pager=off  -c "ANALYZE VERBOSE;"
docker-compose run --rm import-osm /usr/src/app/psql.sh  -P pager=off  -c "VACUUM ANALYZE VERBOSE;"
```

```
### Render tiles
docker-compose -f docker-compose.yml -f ./data/docker-compose-config.yml  run --rm generate-vectortiles
```

```
### Add metadata
docker-compose run --rm openmaptiles-tools  generate-metadata ./data/tiles.mbtiles
docker-compose run --rm openmaptiles-tools  chmod 666         ./data/tiles.mbtiles
```


**Linux**
```bash
### Serve MBTiles
docker run -it --rm -v $(pwd)/data:/data -p 8080:80 klokantech/tileserver-gl:v1.7.0
```

**Windows**
```bash
### Serve MBTiles
docker run -it --rm -v %cd%/data:/data -p 8080:80 klokantech/tileserver-gl:v1.7.0
```


## Prepare visual style for vector tiles
- http://maputnik.com/editor/
- https://github.com/maputnik/editor/releases

```
### Download map style
cd ..
git clone https://github.com/openmaptiles/osm-bright-gl-style
cd klokantech-openmaptiles
```

**Linux**
```bash
### Edit style locally
docker run -it --rm -v $(pwd)/data:/data -p 8080:80 klokantech/tileserver-gl:v1.7.0
maputnik --watch --file ..\osm-bright-gl-style\style.json
```

**Windows**
```bash
### Edit style locally
docker run -it --rm -v %cd%/data:/data -p 8080:80 klokantech/tileserver-gl:v1.7.0
maputnik_windows.exe --watch --file ..\osm-bright-gl-style\style.json
```

## Display raster and vector map in a web browser
- https://openmaptiles.org/docs/website/mapbox-gl-js/
- https://openmaptiles.org/docs/website/openlayers/
- https://openmaptiles.org/docs/website/leaflet/



## OpenMapTiles [![Build Status](https://travis-ci.org/openmaptiles/openmaptiles.svg?branch=master)](https://travis-ci.org/openmaptiles/openmaptiles)

OpenMapTiles is an extensible and open vector tile schema for a OpenStreetMap basemap. It is used to generate vector tiles for [openmaptiles.org](http://openmaptiles.org/) and [openmaptiles.com](http://openmaptiles.com/).

We encourage you to collaborate, reuse and adapt existing layers and add your own layers or use our approach for your own vector tile project. The repository is built on top of the [openmaptiles/tools](https://github.com/openmaptiles/openmaptiles-tools) to simplify vector tile creation.

- :link: Docs http://openmaptiles.org/docs
- :link: Schema: http://openmaptiles.org/schema
- :link: Production package: http://openmaptiles.com/

## Styles

You can start from several GL styles supporting the OpenMapTiles vector schema.

:link: [Learn how to create Mapbox GL styles with Maputnik and OpenMapTiles](http://openmaptiles.org/docs/style/maputnik/).


- [OSM Bright](https://github.com/openmaptiles/osm-bright-gl-style)
- [Positron](https://github.com/openmaptiles/positron-gl-style)
- [Dark Matter](https://github.com/openmaptiles/dark-matter-gl-style)
- [Klokantech Basic](https://github.com/openmaptiles/klokantech-basic-gl-style)
- [Klokantech 3D](https://github.com/openmaptiles/klokantech-3d-gl-style)
- [Fiord Color](https://github.com/openmaptiles/fiord-color-gl-style)
- [Toner](https://github.com/openmaptiles/toner-gl-style)

We also ported over our favorite old raster styles (TM2).

:link: [Learn how to create TM2 styles with Mapbox Studio Classic and OpenMapTiles](http://openmaptiles.org/docs/style/mapbox-studio-classic/).

- [Light](https://github.com/openmaptiles/mapbox-studio-light.tm2/)
- [Dark](https://github.com/openmaptiles/mapbox-studio-dark.tm2/)
- [OSM Bright](https://github.com/openmaptiles/mapbox-studio-osm-bright.tm2/)
- [Pencil](https://github.com/openmaptiles/mapbox-studio-pencil.tm2/)
- [Woodcut](https://github.com/openmaptiles/mapbox-studio-woodcut.tm2/)
- [Pirates](https://github.com/openmaptiles/mapbox-studio-pirates.tm2/)
- [Wheatpaste](https://github.com/openmaptiles/mapbox-studio-wheatpaste.tm2/)

## Schema

OpenMapTiles consists out of a collection of documented and self contained layers you can modify and adapt.
Together the layers make up the OpenMapTiles tileset.

:link: [Study the vector tile schema](http://openmaptiles.org/schema)

- [aeroway](https://openmaptiles.org/schema/#aeroway)
- [boundary](https://openmaptiles.org/schema/#boundary)
- [building](https://openmaptiles.org/schema/#building)
- [housenumber](https://openmaptiles.org/schema/#housenumber)
- [landcover](https://openmaptiles.org/schema/#landcover)
- [landuse](https://openmaptiles.org/schema/#landuse)
- [mountain_peak](https://openmaptiles.org/schema/#mountain_peak)
- [park](https://openmaptiles.org/schema/#park)
- [place](https://openmaptiles.org/schema/#place)
- [poi](https://openmaptiles.org/schema/#poi)
- [transportation](https://openmaptiles.org/schema/#transportation)
- [transportation_name](https://openmaptiles.org/schema/#transportation_name)
- [water](https://openmaptiles.org/schema/#water)
- [water_name](https://openmaptiles.org/schema/#water_name)
- [waterway](https://openmaptiles.org/schema/#waterway)

## Develop

To work on OpenMapTiles you need Docker and Python.

- Install [Docker](https://docs.docker.com/engine/installation/). Minimum version is 1.12.3+.
- Install [Docker Compose](https://docs.docker.com/compose/install/). Minimum version is 1.7.1+.
- Install [OpenMapTiles tools](https://github.com/openmaptiles/openmaptiles-tools) with `pip install openmaptiles-tools`

### Build

Build the tileset.

```bash
git clone git@github.com:openmaptiles/openmaptiles.git
cd openmaptiles
# Build the imposm mapping, the tm2source project and collect all SQL scripts
make
# You can also run the build process inside a Docker container
docker run -v $(pwd):/tileset openmaptiles/openmaptiles-tools make
```

You can execute the following manual steps (for better understanding)
or use the provided `quickstart.sh` script.

```
./quickstart.sh
```

### Prepare the Database

Now start up the database container.

```bash
docker-compose up -d postgres
```

Import external data from [OpenStreetMapData](http://openstreetmapdata.com/), [Natural Earth](http://www.naturalearthdata.com/) and  [OpenStreetMap Lake Labels](https://github.com/lukasmartinelli/osm-lakelines).

```bash
docker-compose run import-water
docker-compose run import-natural-earth
docker-compose run import-lakelines
docker-compose run import-osmborder
```

[Download OpenStreetMap data extracts](http://download.geofabrik.de/) and store the PBF file in the `./data` directory.

```bash
cd data
wget http://download.geofabrik.de/europe/albania-latest.osm.pbf
```

Import [OpenStreetMap](http://wiki.openstreetmap.org/wiki/Osm2pgsql) data with the mapping rules from
`build/mapping.yaml` (which has been created by `make`).

```bash
docker-compose run import-osm
```

### Work on Layers

Each time you modify layer SQL code run `make` and `docker-compose run import-sql`.

```
make clean && make && docker-compose run import-sql
```

Now you are ready to **generate the vector tiles**. Using environment variables
you can limit the bounding box and zoom levels of what you want to generate (`docker-compose.yml`).

```
docker-compose run generate-vectortiles
```

## License

All code in this repository is under the [BSD license](./LICENSE.md) and the cartography decisions encoded in the schema and SQL are licensed under [CC-BY](./LICENSE.md).

Products or services using maps derived from OpenMapTiles schema need to visibly credit "OpenMapTiles.org" or reference "OpenMapTiles" with a link to http://openmaptiles.org/. Exceptions to attribution requirement can be granted on request.

For a browsable electronic map based on OpenMapTiles and OpenStreetMap data, the
credit should appear in the corner of the map. For example:

[© OpenMapTiles](http://openmaptiles.org/) [© OpenStreetMap contributors](http://www.openstreetmap.org/copyright)

For printed and static maps a similar attribution should be made in a textual
description near the image, in the same fashion as if you cite a photograph.
