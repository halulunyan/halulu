M cuda:7.5_cudnn70

COPY Anaconda2-2.4.1-Linux-x86_64.sh /opt

# caffe makefile:use anaconda2 / use cudnn3
COPY Makefile.config /opt

# install anaconda2
RUN echo 'export PATH=/opt/anaconda2/bin:$PATH' > /etc/profile.d/conda.sh && \
    cd /opt && \
    /bin/bash /opt/Anaconda2-2.4.1-Linux-x86_64.sh -b -p /opt/anaconda2 && \
    rm /opt/Anaconda2-2.4.1-Linux-x86_64.sh

# prepare caffe
RUN apt-get update && apt-get install -y \
    libatlas-base-dev libprotobuf-dev libleveldb-dev libsnappy-dev libopencv-dev libboost-all-dev libhdf5-serial-dev libgflags-dev libgoogle-glog-dev liblmdb-dev protobuf-compiler git wget && \
    rm -rf /var/lib/apt/lists/*

# solution "libdc1394 error: Failed to initialize libdc1394"
# ref) http://stackoverflow.com/questions/12689304/ctypes-error-libdc1394-error-failed-to-initialize-libdc1394
RUN ln -s /dev/null /dev/raw1394

# solution "Error loading shared library libhdf5_hl.so"
# ref) https://github.com/BVLC/caffe/issues/1463
RUN cp /opt/anaconda2/pkgs/hdf5-1.8.15.1-2/lib/libhdf5.so.10.0.1 /lib/x86_64-linux-gnu/ && \
    cp /opt/anaconda2/pkgs/hdf5-1.8.15.1-2/lib/libhdf5_hl.so.10.0.1 /lib/x86_64-linux-gnu/ && \
    ldconfig

# make caffe
RUN cd /opt && \
    git clone https://github.com/BVLC/caffe.git && \
    cd caffe && \
    cp /opt/Makefile.config .  && \
    make all -j4 && \
    make test -j4

# ref) https://hub.docker.com/r/eduwass/face-the-internet-worker/~/dockerfile/
CMD sh -c 'ln -s /dev/null /dev/raw1394'; bash

