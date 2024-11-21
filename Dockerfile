# Use Ubuntu 20.04 as base image
FROM ubuntu:20.04

# Avoid timezone prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    m4 \
    build-essential \
    gcc-11 \
    g++-11 \
    autoconf \
    libtool \
    texlive-latex-base \
    software-properties-common \
    python3.8 \
    python3.8-dev \
    python3-pip \
    gnupg2 \
    curl \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 100 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 100 \
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

# Clone ERAN repository
RUN git clone https://github.com/eth-sri/ERAN.git
WORKDIR /app/ERAN

# Set environment variables for CUDA support
ENV USE_CUDA=1

# Run installation script with CUDA support
RUN chmod +x install.sh && \
    ./install.sh -use-cuda

# Setup Gurobi paths
ENV GUROBI_HOME=/app/ERAN/gurobi912/linux64
ENV PATH="${PATH}:/usr/lib:${GUROBI_HOME}/bin"
ENV CPATH="${CPATH}:${GUROBI_HOME}/include"
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib:/usr/local/lib:${GUROBI_HOME}/lib

# Source Gurobi setup
RUN echo "source gurobi_setup_path.sh" >> ~/.bashrc

# Install Python requirements
RUN pip3 install --upgrade pip && \
    pip3 install -r requirements.txt

# Set default command to bash
CMD ["/bin/bash"]
