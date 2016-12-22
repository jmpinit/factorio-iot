# Factorio IoT

Connect your Factorio factories to the Internet.

## Setup

1. Download the [headless form of the game](https://www.factorio.com/download-headless) for Linux and unpack it in the bin folder so you end up with **bin/factorio/<game-stuff>**.
2. `docker build .`. Grab the container ID when finished.
3. `CID=<that container ID> ./run.sh` to start the server.

