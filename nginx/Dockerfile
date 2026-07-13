FROM nginx:1.30.3-alpine-perl

RUN apk update
RUN apk add openssl
RUN apk upgrade --no-cache
RUN apk add certbot certbot-nginx
