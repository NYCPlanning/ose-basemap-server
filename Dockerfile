FROM maptiler/tileserver-gl-light:v4.5.0

COPY ./config.json /data

ARG STORAGE_URL
ARG FILE_NAME
ADD --chown=node $STORAGE_URL/$FILE_NAME /data/basemap.mbtiles

COPY ./positron /usr/src/app/node_modules/tileserver-gl-styles/styles/positron


EXPOSE 8080
