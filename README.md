# OSE Basemap Server
Tileserver of basemap for applications.

## Tools
- [Maptiler/tileserver-gl docker](https://hub.docker.com/r/maptiler/tileserver-gl)
- [OpenMapTiles Positron Style](https://github.com/openmaptiles/positron-gl-style/blob/master/style.json) & [Planning Positron Style](https://github.com/NYCPlanning/labs-gl-style/blob/master/data/style.json)
    - OpenMapTiles version is used in application
    - Planning version is kept for reference
- [Nginx docker](https://hub.docker.com/_/nginx)
- [Certbot CLI](https://eff-certbot.readthedocs.io/en/stable/using.html#certbot-command-line-options)
- [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/)
    - Native setup is possible for the tileserver and nginx. However, these instructions are for docker container setup.

## Setup
### Configure the Mapbox vector tiles (mbtiles)
The application is designed to serve [mapbox vector tiles](https://github.com/mapbox/vector-tile-spec). The tiles are not tracked in source because they can be hundreds or thousands of megabytes each. (Depending on the source of the files, they may also be subject to licenses which restrict their distribution.) The application is configured to look for a generic "basemap.mbtiles" file. For general users, the mbtiles should be sourced, loaded into the `tileserver` folder, and renamed to `basemap.mbtiles`. For DCP uses, these data are stored in a private Digital Ocean space. As of 05 July 2023, the application uses northeast data from 2017.

The `basemap.mbtiles` file should be created before running the rest of the application.

### Directly serve the mbtiles
For local development, the tiles may be served directly without relying on `nginx`. To start only the tileserver, run `docker compose up tileserver`. The tileserver will be available at `localhost:8080`. 

### Nginx serve the mbtiles
For production and production-like environments, the tileserver should be served behind ngnix. To start both nginx and the tileserver, run `docker compose up`

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
