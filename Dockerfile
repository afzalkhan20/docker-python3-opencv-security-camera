FROM resin/armv7hf-debian
MAINTAINER Arthur Geron <johnnyblack000@hotmail.com>
USER root
RUN [ "cross-build-start" ]
RUN apt-get update && \
    apt-get install -y \
    software-properties-common \
    python-software-properties
RUN add-apt-repository -y ppa:fkrull/deadsnakes && \
        add-apt-repository -y ppa:jonathonf/python-3.6 && \
        apt-get update
RUN apt-get install -y \
        build-essential \
        cmake \
        git \
        wget \
        unzip \
        yasm \
        pkg-config \
        libswscale-dev \
        libtbb2 \
        libtbb-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libjasper-dev \
        libavformat-dev \
        libpq-dev

RUN apt-get install -y  python3.6 && \
                        pip install numpy

WORKDIR /
RUN wget https://github.com/opencv/opencv/archive/3.3.0.zip \
&& git clone https://github.com/arthurgeron/picamera \
&& unzip 3.3.0.zip \
&& cd picamera \
&& pip install -r requirements.txt \
&& cd .. \
&& sed -i 's/#if NPY_INTERNAL_BUILD/#ifndef NPY_INTERNAL_BUILD\n#define NPY_INTERNAL_BUILD/g' /usr/local/lib/python3.6/site-packages/numpy/core/include/numpy/npy_common.h \
&& mkdir /opencv-3.3.0/cmake_binary \
&& cd /opencv-3.3.0/cmake_binary \
&& cmake -DBUILD_TIFF=ON \
  -DBUILD_opencv_java=OFF \
  -DWITH_CUDA=OFF \
  -DENABLE_AVX=ON \
  -DWITH_OPENGL=ON \
  -DWITH_OPENCL=ON \
  -DWITH_IPP=ON \
  -DWITH_TBB=ON \
  -DWITH_EIGEN=ON \
  -DWITH_V4L=ON \
  -DBUILD_TESTS=OFF \
  -DBUILD_PERF_TESTS=OFF \
  -DCMAKE_BUILD_TYPE=RELEASE \
  -DCMAKE_INSTALL_PREFIX=$(python3.6 -c "import sys; print(sys.prefix)") \
  -DPYTHON_EXECUTABLE=$(which python3.6) \
  -DPYTHON_INCLUDE_DIR=$(python3.6 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
  -DPYTHON_PACKAGES_PATH=$(python3.6 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") .. \
&& make install \
&& rm /3.3.0.zip \
&& rm -r /opencv-3.3.0 \
&& cd ../.. \
&& chmod +x picamera/main.py
RUN [ "cross-build-end" ]  
#Expose port 80
EXPOSE 80
#Default command
CMD ["picamera/main.py"]
