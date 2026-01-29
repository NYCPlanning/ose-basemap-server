FROM nginx:1.28.1-alpine3.23-perl

RUN apk update
RUN apk add openssl
RUN apk upgrade --no-cache
RUN apk add certbot certbot-nginx
