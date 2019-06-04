#!/usr/bin/env bash
set -e

docker build - -t numpycicddependencies < Dockerfile.dependencies
docker build - -t numpycicd < Dockerfile.numpy
mkdir -p out
docker run --rm numpycicd | tar -C out -xv
