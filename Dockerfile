#docker build -t cinia/tesseract-3.05 .
#docker run -v "$PWD"/notebooks/:/home/jovyan/notebooks  -p 28888:8888 cinia/tesseract-3.05
# Based on https://github.com/otiai10/docker-tesseract

FROM jupyter/scipy-notebook:latest

USER root

# Tesseract
#
# VERSION 3.05.01

ARG TESS="3.05.00"
ARG LEPTO="1.74.0"

# Prepare dependencies
RUN apt-get update
RUN apt-get install -y \
  wget \
  make \
  autoconf \
  automake \
  libtool \
  autoconf-archive \
  pkg-config \
  libpng-dev \
  libjpeg-dev \
  libtiff-dev \
  zlib1g-dev \
  libicu-dev \
  libpango1.0-dev \
  libcairo2-dev

ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib

# Compile Leptonica
WORKDIR /
RUN mkdir -p /tmp/leptonica \
  && wget https://github.com/DanBloomberg/leptonica/archive/${LEPTO}.tar.gz \
  && tar -xzvf ${LEPTO}.tar.gz -C /tmp/leptonica \
  && mv /tmp/leptonica/* /leptonica
WORKDIR /leptonica

RUN autoreconf -i \
  && ./autobuild \
  && ./configure \
  && make \
  && make install

# Compile Tesseract
WORKDIR /
RUN mkdir -p /tmp/tesseract \
  && wget https://github.com/tesseract-ocr/tesseract/archive/${TESS}.tar.gz \
  && tar -xzvf ${TESS}.tar.gz -C /tmp/tesseract \
  && mv /tmp/tesseract/* /tesseract
WORKDIR /tesseract

RUN ./autogen.sh \
  && ./configure \
  && make \
  && make install

# Recover location
WORKDIR /

# Training data for version 3.05 same as for 3.04
# Supported languages https://github.com/tesseract-ocr/tessdata/tree/3.04.00
RUN wget https://github.com/tesseract-ocr/tessdata/raw/3.04.00/eng.traineddata -P /usr/local/share/tessdata
RUN wget https://github.com/tesseract-ocr/tessdata/raw/3.04.00/deu.traineddata -P /usr/local/share/tessdata
RUN wget https://github.com/tesseract-ocr/tessdata/raw/3.04.00/fin.traineddata -P /usr/local/share/tessdata
RUN wget https://github.com/tesseract-ocr/tessdata/raw/3.04.00/est.traineddata -P /usr/local/share/tessdata
RUN wget https://github.com/tesseract-ocr/tessdata/raw/3.04.00/swe.traineddata -P /usr/local/share/tessdata

USER jovyan

RUN pip install pillow
RUN pip install pytesseract
# RUN pip install opencv-contrib-python

WORKDIR /home/jovyan
