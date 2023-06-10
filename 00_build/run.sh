#! /bin/bash

set +a
source .env
set -a

sky launch -y -c buildclust ./sky.yaml --env DOCKER_TOKEN=$DOCKER_TOKEN --down
