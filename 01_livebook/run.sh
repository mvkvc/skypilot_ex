#! /bin/bash

sky launch -y -c lbclust ./sky.yaml --down

# Connect to the livebook
# ssh -L 8787:localhost:8787 lbclust
