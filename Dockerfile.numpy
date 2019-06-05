FROM numpycicddependencies

WORKDIR /opt

# TODO make sure this is not cached!
ARG CHECKOUT=master
RUN git clone https://github.com/numpy/numpy && cd numpy && git checkout $CHECKOUT

WORKDIR numpy

# TODO make this tests run and pass ?
#RUN /opt/python/cp37-cp37m/bin/python runtests.py --show-build-log -- -rsx \
#      --junitxml=junit/test-results.xml --durations 10

#RUN /opt/python/cp27-cp27m/bin/pip wheel -w /io .
#RUN /opt/python/cp27-cp27mu/bin/pip wheel -w /io .
#RUN /opt/python/cp34-cp34m/bin/pip wheel -w /io .
#RUN /opt/python/cp35-cp35m/bin/pip wheel -w /io .
#RUN /opt/python/cp36-cp36m/bin/pip wheel -w /io .
RUN /opt/python/cp37-cp37m/bin/pip wheel -w /io .

RUN for whl in /io/*.whl; do auditwheel repair "$whl" --plat manylinux2010_x86_64 -w /io/wheelhouse; done

CMD tar -c /io/wheelhouse/*