# OSE Basemap Server
Tileserver of basemap for applications.

## Tools
- [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/)
    - Native setup is possible for the tileserver . However, these instructions are for docker container setup.
- [Maptiler/tileserver-gl-light docker](https://hub.docker.com/r/maptiler/tileserver-gl-light)
- [OpenMapTiles Positron Style](https://github.com/openmaptiles/positron-gl-style/blob/master/style.json) & [Planning Positron Style](https://github.com/NYCPlanning/labs-gl-style/blob/master/data/style.json)

## Setup
### Configure the Mapbox vector tiles (mbtiles)
The application is designed to serve [mapbox vector tiles](https://github.com/mapbox/vector-tile-spec). The tiles are not tracked in source because they can be hundreds or thousands of megabytes each. (Depending on the source of the files, they may also be subject to licenses which restrict their distribution.) The application is configured to look for a generic "basemap.mbtiles" file. The `basemap.mbtiles` file should be created before running the rest of the application.

#### Tile generation

Download united states data
```bash
wget -O data/us.osm.pbf https://download.geofabrik.de/north-america/us-latest.osm.pbf
```

Extract the metro region from us
```bash
docker compose run --rm -v $(pwd)/data:/data osmium extract /data/us.osm.pbf --bbox=-79.21,37.09,-67.83,44.42 --output=/data/metro-region-osmium.osm.pbf
```

Generate tiles from local regional extract
```bash
docker compose run --rm planetiler --osm-path=/data/metro-region-osmium.osm.pbf --output=/data/planetiler-regional-viz.mbtiles --download
```

### Font generation

Generate fonts by following instructions in the [`openmaptiles\fonts`](https://github.com/openmaptiles/fonts) repository. Move the generated `.pbf` files from the `_output` folder of the `fonts` repository to the `tileserver/data/fonts` folder of this `ose-basemap-server` repository. Keep the files in their folders; they are acccessed based on the name of the folder.


### Serve the mbtiles
```bash
docker compose up tileserver
```

### Test dependent applications
The basemap server works in tandem with [labs-layers-api](https://github.com/NYCPlanning/labs-layers-api). The layers api contains references to the tile server which it then passes to its dependent applications. These references are in [public/static/v3.json](https://github.com/NYCPlanning/labs-layers-api/blob/df05f6a4695a04fa4470cf7bf9a97ed82ded866d/public/static/v3.json#L3) and [data/base/style.json](https://github.com/NYCPlanning/labs-layers-api/blob/df05f6a4695a04fa4470cf7bf9a97ed82ded866d/data/base/style.json#L21). For both of these references, `https://tiles.planninglabs.nyc` should be changed to the target url.
