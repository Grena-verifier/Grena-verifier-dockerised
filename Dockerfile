# Use Ubuntu 22.04 as base image
FROM ubuntu:22.04

# To ensuring deterministic GPU computations for reproducibility
ENV CUBLAS_WORKSPACE_CONFIG=:4096:8

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

# Install Grena-verifier's other library dependencies
RUN wget https://raw.githubusercontent.com/Grena-verifier/Grena-verifier/master/install_libraries.sh && \
    chmod +x install_libraries.sh && \
    ./install_libraries.sh

# Install Grena-verifier's Python dependencies
RUN wget https://raw.githubusercontent.com/Grena-verifier/Grena-verifier/master/requirements.txt && \
    pip install --upgrade pip && \
    pip install -r requirements.txt

# Set working directory
WORKDIR /app

# Add entrypoint script
COPY .docker-entrypoint.sh /.docker-entrypoint.sh
RUN chmod +x /.docker-entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/.docker-entrypoint.sh"]
CMD ["/bin/bash"]
