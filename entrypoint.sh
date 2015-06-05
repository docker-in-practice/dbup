#!/bin/bash
set -o errexit
set -o pipefail

usage() {
    echo "Usage:"
    echo "    dbup save IMAGE"
    echo "    dbup load IMAGE"
}

if [ $# != 2 ]; then
    echo "Incorrect number of arguments"
    usage
    exit 1
fi
OP="$1"
if [ "$OP" = add ]; then
    # Book typo, can remove on release
    echo "Apologies for the incorrect instructions, please use 'save' instead of 'add'!"
    exit 1
fi
if [ ! -d /pool ]; then
    echo "Please volume mount a folder to /pool"
    exit 1
fi
if [ ! -e /var/run/docker.sock ]; then
    echo "Please mount the docker socket into the container"
    exit 1
fi
IMAGE="$2"
BNAME="$(echo -n "$IMAGE" | base64)"

export BUP_DIR=/pool
if ! bup init >/tmp/initlog 2>&1; then
    cat /tmp/initlog
    echo "Could not initialise /pool!"
fi

if [ "$OP" = save ]; then
    echo "Saving image!"
    /docker save "$IMAGE" | bup split -n "$BNAME"
    echo "Done!"
elif [ "$OP" = load ]; then
    echo "Loading image!"
    bup join "$BNAME" | /docker load
    echo "Done!"
else
    echo "Invalid operation: $OP"
    usage
    exit 1
fi
