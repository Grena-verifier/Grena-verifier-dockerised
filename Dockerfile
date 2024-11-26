# Use Ubuntu 22.04 as base image
FROM ubuntu:22.04

# Avoid timezone prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:ubuntu-toolchain-r/test && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y \
    git \
    wget \
    m4 \
    build-essential \
    gcc-9 \
    g++-9 \
    autoconf \
    libtool \
    texlive-latex-base \
    python3.8 \
    python3.8-dev \
    python3.8-distutils \
    python3-pip \
    gnupg2 \
    curl \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 100 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 100 \
    && rm -rf /var/lib/apt/lists/*

# Install CUDA toolkit 11.3
RUN wget https://developer.download.nvidia.com/compute/cuda/11.3.1/local_installers/cuda_11.3.1_465.19.01_linux.run && \
    chmod +x cuda_11.3.1_465.19.01_linux.run && \
    ./cuda_11.3.1_465.19.01_linux.run --toolkit --silent --override && \
    rm cuda_11.3.1_465.19.01_linux.run

# Update CUDA environment variables to match 11.3
ENV PATH=/usr/local/cuda-11.3/bin:${PATH}
ENV LD_LIBRARY_PATH=/usr/local/cuda-11.3/lib64:${LD_LIBRARY_PATH}
ENV CUDA_HOME=/usr/local/cuda-11.3
ENV CUDA_PATH=/usr/local/cuda-11.3
ENV CUDA_TOOLKIT_ROOT=/usr/local/cuda-11.3

# Set Python 3.8 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1 \
    && update-alternatives --set python3 /usr/bin/python3.8 \
    && ln -sf /usr/bin/python3 /usr/bin/python

# Install CMake 3.19.7
RUN wget https://github.com/Kitware/CMake/releases/download/v3.19.7/cmake-3.19.7-Linux-x86_64.sh \
    && bash ./cmake-3.19.7-Linux-x86_64.sh --skip-license --prefix=/usr \
    && rm cmake-3.19.7-Linux-x86_64.sh

# Install GMP
RUN wget https://gmplib.org/download/gmp/gmp-6.1.2.tar.xz && \
    tar -xvf gmp-6.1.2.tar.xz && \
    cd gmp-6.1.2 && \
    ./configure --enable-cxx && \
    make && \
    make install && \
    cd .. && \
    rm gmp-6.1.2.tar.xz

# Install MPFR
RUN wget https://files.sri.inf.ethz.ch/eran/mpfr/mpfr-4.1.0.tar.xz && \
    tar -xvf mpfr-4.1.0.tar.xz && \
    cd mpfr-4.1.0 && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm mpfr-4.1.0.tar.xz

# Install CDDlib
RUN wget https://github.com/cddlib/cddlib/releases/download/0.94m/cddlib-0.94m.tar.gz && \
    tar zxf cddlib-0.94m.tar.gz && \
    cd cddlib-0.94m && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm cddlib-0.94m.tar.gz

# Update the library cache
RUN ldconfig

# Set working directory
WORKDIR /app

# Add entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
