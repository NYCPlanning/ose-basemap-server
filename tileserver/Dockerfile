FROM maptiler/tileserver-gl:v4.4.10

COPY ./config.json /data
# COPY ./basemap.mbtiles /data
ADD https://ose-basemap-server.nyc3.digitaloceanspaces.com/2017/2017-07-03_north-america_us-northeast.mbtiles /data
RUN mv /data/2017-07-03_north-america_us-northeast.mbtiles /data/basemap.mbtiles

COPY ./positron /usr/src/app/node_modules/tileserver-gl-styles/styles/positron

EXPOSE 8080
