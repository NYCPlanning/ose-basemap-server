FROM nginx:1.27.5-alpine3.21-slim

RUN apk update
RUN apk add openssl
RUN apk upgrade --no-cache
RUN apk add certbot certbot-nginx
