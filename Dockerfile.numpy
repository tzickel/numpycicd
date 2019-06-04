FROM numpycicddependencies

WORKDIR /opt

# TODO make sure this is not cached!
RUN git clone https://github.com/numpy/numpy

WORKDIR numpy

# TODO make this tests run and pass ?
#RUN /opt/python/cp37-cp37m/bin/python runtests.py --show-build-log -- -rsx \
#      --junitxml=junit/test-results.xml --durations 10

RUN /opt/python/cp37-cp37m/bin/pip wheel -w /io .

RUN for whl in /io/*.whl; do auditwheel repair "$whl" --plat manylinux2010_x86_64 -w /io/wheelhouse; done

CMD tar -c /io/wheelhouse/*