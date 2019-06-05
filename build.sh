#!/usr/bin/env bash
set -e

# Build static dependencies
docker build -t numpycicddependencies - < Dockerfile.dependencies

# Build a spceific version of numpy
docker build --no-cache -t numpycicd --build-arg CHECKOUT=v1.16.4 - < Dockerfile.numpy
mkdir -p out

# Dump the resulting wheels to the output dir
docker run --rm numpycicd | tar -C out -xv

# Check the resulting wheels on a clean ubuntu version
#docker build -t numpycicdcheck -f Dockerfile.checkclean --build-arg . 