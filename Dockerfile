FROM ubuntu:16.04

# setup the game server
WORKDIR /opt/factorio
COPY ./bin/factorio/ .
WORKDIR /opt/factorio/bin/x64/
RUN ./factorio --create map

# add the mod
WORKDIR /opt/mods/factorio-iot_1.0.0
COPY mod .

# add the settings
WORKDIR /var/factorio
COPY server-settings.json .

WORKDIR /opt/factorio/bin/x64

EXPOSE 34197

CMD ./factorio \
  --mod-directory /opt/mods \
  --rcon-port 1337 \
  --rcon-password secret \
  --server-settings /var/factorio/server-settings.json \
  --start-server map.zip
