#!/bin/bash

if [ -z $CID ]; then
    echo Must set CID env variable to specify container ID.
    exit 1
fi

docker run --rm -it -p 1337:1337 -p 34190:34197/udp $CID
