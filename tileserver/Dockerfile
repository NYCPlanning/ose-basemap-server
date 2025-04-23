FROM maptiler/tileserver-gl:v5.3.0

COPY ./config.json /data
COPY ./basemap.mbtiles /data

COPY ./positron /usr/src/app/node_modules/tileserver-gl-styles/styles/positron

EXPOSE 8080
