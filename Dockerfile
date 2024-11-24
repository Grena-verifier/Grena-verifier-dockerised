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

# Set working directory
WORKDIR /app

# Set environment variables for CUDA support
ENV USE_CUDA=1

# Setup Gurobi paths (these will be used after ERAN is cloned)
ENV GUROBI_HOME=/app/ERAN/gurobi912/linux64
ENV PATH="${PATH}:/usr/lib:${GUROBI_HOME}/bin"
ENV CPATH="${CPATH}:${GUROBI_HOME}/include"
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib:/usr/local/lib:${GUROBI_HOME}/lib

# Add entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
