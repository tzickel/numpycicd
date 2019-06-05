#!/usr/bin/env bash
set -e

# Build static dependencies
docker build -t numpycicddependencies:manylinux1_x86_64 - < Dockerfile.dependencies
#docker build -t numpycicddependencies:manylinux2010_x86_64 --build-arg BASEIMAGE=quay.io/pypa/manylinux2010_x86_64 - < Dockerfile.dependencies

# Build a spceific version of numpy (you can specify master)
docker build --no-cache -t numpycicd:manylinux1_x86_64 --build-arg CHECKOUT=v1.16.4 --build-arg BASEIMAGE=numpycicddependencies:manylinux1_x86_64 - < Dockerfile.numpy
#docker build --no-cache -t numpycicd:manylinux2010_x86_64 --build-arg CHECKOUT=v1.16.4 --build-arg BASEIMAGE=numpycicddependencies:manylinux2010_x86_64 - < Dockerfile.numpy

# Dump the resulting wheels to the output dir
mkdir -p out
docker run --rm numpycicd:manylinux1_x86_64 | tar -C out -xv

# Check the resulting wheels on a clean ubuntu version (if this finishes correctly the tests passed)
docker build -f Dockerfile.checkclean --build-arg WHL2FILE=numpy-1.16.4-cp27-cp27m-manylinux1_x86_64.whl --build-arg WHL3FILE=numpy-1.16.4-cp35-cp35m-manylinux1_x86_64.whl .