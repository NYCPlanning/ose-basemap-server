FROM maptiler/tileserver-gl:v4.4.10

COPY ./config.json /data
COPY ./2017-07-03_north-america_us-northeast.mbtiles /data

COPY ./positron /usr/src/app/node_modules/tileserver-gl-styles/styles/positron

EXPOSE 8080
