#! /bin/bash

set +a
source .env
set -a

sky launch -c buildclust ./sky.yaml --down --env DOCKER_TOKEN=$DOCKER_TOKEN
