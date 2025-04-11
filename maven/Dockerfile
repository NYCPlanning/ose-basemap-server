FROM maven:latest

RUN git clone https://github.com/protomaps/basemaps
WORKDIR  /basemaps/tiles
RUN mvn clean package
