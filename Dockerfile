FROM maptiler/tileserver-gl:v4.4.10

COPY ./2017-07-03_north-america_us-northeast.mbtiles /data

EXPOSE 8080
