# OSE Basemap Server
Tileserver of basemap for applications.

## Tools
- [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/)
    - Native setup is possible for the tileserver and nginx. However, these instructions are for docker container setup.
- [Maptiler/tileserver-gl-light docker](https://hub.docker.com/r/maptiler/tileserver-gl-light)
- [OpenMapTiles Positron Style](https://github.com/openmaptiles/positron-gl-style/blob/master/style.json) & [Planning Positron Style](https://github.com/NYCPlanning/labs-gl-style/blob/master/data/style.json)
- [Nginx docker](https://hub.docker.com/_/nginx)
- [Certbot CLI](https://eff-certbot.readthedocs.io/en/stable/using.html#certbot-command-line-options)

## Setup
### Configure the Mapbox vector tiles (mbtiles)
The application is designed to serve [mapbox vector tiles](https://github.com/mapbox/vector-tile-spec). The tiles are not tracked in source because they can be hundreds or thousands of megabytes each. (Depending on the source of the files, they may also be subject to licenses which restrict their distribution.) The application is configured to look for a generic "metro-region.mbtiles" file.

#### Tile generation
The `metro-region.mbtiles` file should be created before running the rest of the application.

Download united states data into the top-level `data` folder.
```bash
curl -o data/us.osm.pbf https://download.geofabrik.de/north-america/us-latest.osm.pbf
```

Extract the NYC metro region from us data
```bash
docker compose run --rm osmium extract /data/us.osm.pbf --bbox=-79.21,37.09,-67.83,44.42 --output=/data/metro-region.osm.pbf
```

Generate tiles from region extract
```bash
docker compose run --rm planetiler --osm-path=/data/metro-region.osm.pbf --output=/data/metro-region.mbtiles --download
```

Move the tiles into the tileserver volume
```bash
mv data/metro-region.mbtiles tileserver/data/
```

### Font generation

Generate fonts by following instructions in the [`openmaptiles/fonts`](https://github.com/openmaptiles/fonts) repository. Move the generated `.pbf` files from the `_output` folder of the `fonts` repository to the `tileserver/data/fonts` folder of this `ose-basemap-server` repository. Keep the files in their folders; they are acccessed based on the name of the folder.

### Directly serve the mbtiles
For local development, the tiles may be served directly without relying on `nginx`. To start only the tileserver, run `docker compose up tileserver`. The tileserver will be available at `localhost:8080`.

### Nginx serve the mbtiles
For production and production-like environments, the tileserver should be served behind ngnix. To start both nginx and the tileserver, run `docker compose up tileserver nginx`

Nginx will try to run on port 80 and 443. This is required for production configurations. However, it may cause issues during local development. Many systems prevent applications from running on these ports by default. This issue can be resolved by either:
1) Navigating to `compose.yaml`, changing `80:80` to `8000:80`, and removing `443:443`
or
2) [Exposing root privileged ports](https://docs.docker.com/engine/security/rootless/) on the local machine
```sh
sudo setcap cap_net_bind_service=ep $(which rootlesskit)
systemctl --user restart docker
```

### Test dependent applications
The basemap server works in tandem with [labs-layers-api](https://github.com/NYCPlanning/labs-layers-api). The layers api contains references to the tile server which it then passes to its dependent applications. These references are in [public/static/v3.json](https://github.com/NYCPlanning/labs-layers-api/blob/df05f6a4695a04fa4470cf7bf9a97ed82ded866d/public/static/v3.json#L3) and [data/base/style.json](https://github.com/NYCPlanning/labs-layers-api/blob/df05f6a4695a04fa4470cf7bf9a97ed82ded866d/data/base/style.json#L21). For both of these references, `https://tiles.planninglabs.nyc` should be changed to the target url.

### Encryption for production environments

#### Creation
The Ngnix image is configured to use [certbot](https://certbot.eff.org/) for alpine linux. With the application running in docker on the production server, certification can be run with:
```sh
docker exec ${CONTAINER_ID} certbot -n -m ${CONTACT_EMAIL} -d ${DOMAINS} --nginx --agree-tos
```

#### Reinstallation
Rebuilding the nginx container reset the changes certbot applied to `default.conf` on installation. However, the certifications will persist in the docker volumes. The certificates can be reinstalled with:
```sh
docker exec -it ${CONTAINER_ID} certbot -d ${DOMAINS} --nginx
```

(This command starts an interactive terminal for installation. When in doubt about the state of the certificates, this is the safest command to run)

#### Renewal
Certificate renewal is achieved by placing a renewal script into the weekly periodic cronjob folder. However, the crond daemon needs to be started with each new container. It can be started with:
```sh
docker exec ${CONTAINER_ID} crond
```
