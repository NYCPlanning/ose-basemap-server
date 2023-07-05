FROM maptiler/tileserver-gl:v4.4.10

COPY ./config.json /data
COPY ./basemap.mbtiles /data

COPY ./positron /usr/src/app/node_modules/tileserver-gl-styles/styles/positron

EXPOSE 8080
