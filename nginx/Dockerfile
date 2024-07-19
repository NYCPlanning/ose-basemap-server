FROM nginx:1.26.1-alpine3.19-slim

RUN apk update 
RUN apk add openssl 
RUN apk upgrade --no-cache
RUN apk add certbot certbot-nginx

COPY ./conf.d/ /etc/nginx/conf.d/
COPY ./cron/cert_renew /etc/periodic/weekly/
