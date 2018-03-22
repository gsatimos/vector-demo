FROM geodata/gdal:latest

#tippecanoe
RUN apt update 
RUN apt install -y git build-essential libsqlite3-dev zlib1g-dev
RUN git clone https://github.com/mapbox/tippecanoe.git /tmp/tippecanoe 
WORKDIR /tmp/tippecanoe
RUN make
RUN make install

VOLUME /data
WORKDIR /data

ENTRYPOINT ./create_tilesets.sh

