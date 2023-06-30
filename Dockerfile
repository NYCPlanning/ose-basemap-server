FROM maptiler/tileserver-gl:v4.4.10

COPY ./config.json /data
COPY ./maptiler-osm-2020-02-10-v3.11-us_new-york.mbtiles /data

COPY ./positron /usr/src/app/node_modules/tileserver-gl-styles/styles/positron

EXPOSE 8080
