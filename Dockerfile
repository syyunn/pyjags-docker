FROM amazonlinux:latest

WORKDIR /app

RUN curl -s https://bootstrap.pypa.io/get-pip.py | python

# requirements for compiling JAGs
RUN yum install -y \
  gcc \
  gcc-gfortran \
  lapack-devel \
  gcc-c++ \
  findutils \
  python27-devel
COPY JAGS-4.3.0.tar.gz .
RUN /bin/tar xf JAGS-4.3.0.tar.gz
# compile JAGs
WORKDIR JAGS-4.3.0/
RUN F77=gfortran ./configure --libdir=/usr/local/lib64
RUN make
RUN make install

# install python deps
WORKDIR /app
COPY requirements.txt .

ENV PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig/:$PKG_CONFIG_PATH

# numpy needs to be installed globally first as pyjags
# checks the regular path for numpy as a requirement
RUN pip install numpy
RUN pip install -t ./lib -r requirements.txt
