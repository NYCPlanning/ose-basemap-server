# OSE Basemap Server
Tileserver of basemap for applications.

## Tools
- [Maptiler/tileserver-gl-light docker](https://hub.docker.com/r/maptiler/tileserver-gl-light)
- [OpenMapTiles Positron Style](https://github.com/openmaptiles/positron-gl-style/blob/master/style.json) & [Planning Positron Style](https://github.com/NYCPlanning/labs-gl-style/blob/master/data/style.json)
    - OpenMapTiles version is used in application
    - Planning version is kept for reference
- [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/)
    - Native setup is possible for the tileserver and nginx. However, these instructions are for docker container setup.

## Setup
### Configure the Mapbox vector tiles (mbtiles)
The application is designed to serve [mapbox vector tiles](https://github.com/mapbox/vector-tile-spec). The tiles are not tracked in source because they can be hundreds or thousands of megabytes each. (Depending on the source of the files, they may also be subject to licenses which restrict their distribution.) Instead, they are downloaded directly into the docker image from a web resource. As of 05 July 2023, the application uses northeast data from 2017. Configure the appropriate url with the STORAGE_URL variable.

### Configure the mbtiles remote location
- Configure the webpage where the tiles are stored
    - Copy the .example-env and set the STORAGE_URL and FILE_NAME.
    - `cp .example-env .env`
### Test dependent applications
The basemap server works in tandem with [labs-layers-api](https://github.com/NYCPlanning/labs-layers-api). The layers api contains references to the tile server which it then passes to its dependent applications. These references are in [public/static/v3.json](https://github.com/NYCPlanning/labs-layers-api/blob/df05f6a4695a04fa4470cf7bf9a97ed82ded866d/public/static/v3.json#L3) and [data/base/style.json](https://github.com/NYCPlanning/labs-layers-api/blob/df05f6a4695a04fa4470cf7bf9a97ed82ded866d/data/base/style.json#L21). For both of these references, `https://tiles.planninglabs.nyc` should be changed to the target url.
