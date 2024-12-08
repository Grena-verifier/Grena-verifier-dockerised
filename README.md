# GRENA-verifier dockerised

Dockerised implementation of GRENA-verifier.

<br>

## Prerequisites

Ensure you have the following requirements:

1. Docker installed on your system
2. NVIDIA GPU(s) available on your machine
3. NVIDIA Container Toolkit installed _(instructions below)_
4. A Gurobi Web License Service (WLS) license file

<br>

### Installing NVIDIA Container Toolkit

To enable GPU support with Docker containers, install the NVIDIA Container Toolkit by running these commands:

> _Steps taken from: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html#installing-with-apt_

```bash
# Add NVIDIA package repositories
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# Update package listing
sudo apt-get update

# Install nvidia-container-toolkit
sudo apt-get install -y nvidia-container-toolkit

# Restart Docker daemon
sudo systemctl restart docker
```

<br>

### Obtaining Gurobi License

You need to obtain a Web License Service (WLS) Gurobi license file `gurobi.lic` before running the container.

<br>

## Usage

The repository provides two main scripts:

-   `run_container.sh`: Sets up and runs the GRENA-verifier container
-   `cleanup.sh`: Removes all resources created by the container

<br>

### Running the Container

The `run_container.sh` will perform all the setup needed _(eg. build Docker image, start container)_.

```bash
bash run_container.sh -g /path/to/wls/gurobi.lic
# OR
bash run_container.sh  # will prompted for the license path
```

#### Troubleshooting

If you get this error:

```
ERROR: permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get "http://%2Fvar%2Frun%2Fdocker.sock/_ping": dial unix /var/run/docker.sock: connect: permission denied
```

Run these commands to give docker permissions to your user account:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

<br>

### Cleaning Up

To all resources created by Docker, run `cleanup.sh` with root privileges:

```bash
sudo bash cleanup.sh
```
