#!/usr/bin/env bash
set -e

# Build static dependencies
docker build -t numpycicddependencies:manylinux1_x86_64 - < Dockerfile.dependencies
#docker build -t numpycicddependencies:manylinux2010_x86_64 --build-arg BASEIMAGE=quay.io/pypa/manylinux2010_x86_64 - < Dockerfile.dependencies

# Build a spceific version of numpy (you can specify master)
docker build --no-cache -t numpycicdbuild:manylinux1_x86_64 --build-arg CHECKOUT=v1.16.4 --build-arg BASEIMAGE=numpycicddependencies:manylinux1_x86_64 - < Dockerfile.build
#docker build --no-cache -t numpycicdbuild:manylinux2010_x86_64 --build-arg CHECKOUT=v1.16.4 --build-arg BASEIMAGE=numpycicddependencies:manylinux2010_x86_64 - < Dockerfile.build

# Dump the resulting wheels to the output dir
mkdir -p out
docker run --rm numpycicdbuild:manylinux1_x86_64 | tar -C out -xv

# Check the resulting wheels on a clean ubuntu version
docker build -t numpycicdtest:manylinux1_x86_64 -f Dockerfile.test --build-arg WHL2FILE=numpy-1.16.4-cp27-cp27mu-manylinux1_x86_64.whl --build-arg WHL3FILE=numpy-1.16.4-cp35-cp35m-manylinux1_x86_64.whl .
#docker run -it --rm numpycicdtest:manylinux1_x86_64 python -c "import numpy; numpy.test()"
docker run -it --rm numpycicdtest:manylinux1_x86_64 python3 -c "import numpy; numpy.test()"