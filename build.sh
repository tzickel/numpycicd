#!/usr/bin/env bash
set -e

NUMPY_CHECKOUT=v1.16.4

# Build OpenBLAS
## manylinux1_x86_64
#docker build -t openblas:manylinux1_x86_64 --build-arg EXTRA_MAKEOPTIONS=-j4 - < Dockerfile.openblas
#docker run --rm opeblas:manylinux1_x86_64 | tar -C out -xv
## manylinux2010_x86_64
#docker build -t openblas:manylinux2010_x86_64 --build-arg PLATFORM=manylinux2010_x86_64 --build-arg EXTRA_MAKEOPTIONS=-j4 - < Dockerfile.openblas
#docker run --rm openblas:manylinux2010_x86_64 | tar -C out -xv

# Build static dependencies
## manylinux1_x86_64
#docker build -t numpycicddependencies:manylinux1_x86_64 - < Dockerfile.dependencies
## manylinux2010_x86_64 (A different dockerfile to take openblas from local disk instead from HTTP)
#docker build -f Dockerfile.dependencies_with_openblas -t numpycicddependencies:manylinux2010_x86_64 --build-arg BASEIMAGE=quay.io/pypa/manylinux2010_x86_64 --build-arg OPENBLAS=out/openblas-v0.2.20-2-g5f998efd-manylinux2010_x86_64.tar.gz .

# Build a spceific version of numpy (you can specify master)
## manylinux1_x86_64
#docker build --no-cache -t numpycicdbuild:manylinux1_x86_64 --build-arg CHECKOUT=${NUMPY_CHECKOUT} --build-arg BASEIMAGE=numpycicddependencies:manylinux1_x86_64 - < Dockerfile.build
## manylinux2010_x86_64
docker build --no-cache -t numpycicdbuild:manylinux2010_x86_64 --build-arg CHECKOUT=${NUMPY_CHECKOUT} --build-arg PLATFORM=manylinux2010_x86_64 --build-arg BASEIMAGE=numpycicddependencies:manylinux2010_x86_64 - < Dockerfile.build

# Dump the resulting wheels to the output dir
## manylinux1_x86_64
#mkdir -p out
#docker run --rm numpycicdbuild:manylinux1_x86_64 | tar -C out -xv
## manylinux2010_x86_64
mkdir -p out
docker run --rm numpycicdbuild:manylinux2010_x86_64 | tar -C out -xv

# Check the resulting wheels on a clean ubuntu version
## manylinux1_x86_64
#docker build -t numpycicdtest:manylinux1_x86_64 -f Dockerfile.test --build-arg WHL2FILE=numpy-1.16.4-cp27-cp27mu-manylinux1_x86_64.whl --build-arg WHL3FILE=numpy-1.16.4-cp35-cp35m-manylinux1_x86_64.whl .
#docker run -it --rm numpycicdtest:manylinux1_x86_64 python -c "import numpy; numpy.test()"
#docker run -it --rm numpycicdtest:manylinux1_x86_64 python3 -c "import numpy; numpy.test()"
## manylinux2010_x86_64
docker build -t numpycicdtest:manylinux2010_x86_64 -f Dockerfile.test --build-arg BASEIMAGE=ubuntu:18.04 --build-arg WHL2FILE=numpy-1.16.4-cp27-cp27mu-manylinux1_x86_64.whl --build-arg WHL3FILE=numpy-1.16.4-cp36-cp36m-manylinux1_x86_64.whl .
docker run -it --rm numpycicdtest:manylinux2010_x86_64 python -c "import numpy; numpy.test()"
docker run -it --rm numpycicdtest:manylinux2010_x86_64 python3 -c "import numpy; numpy.test()"