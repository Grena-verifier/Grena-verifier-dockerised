# GRENA-verifier dockerised

Dockerised implementation of [GRENA-verifier](https://github.com/Grena-verifier/Grena-verifier).

<br>

## Prerequisites

Ensure you have the following requirements:

1. Docker installed on your system
2. NVIDIA GPU(s) available on your machine
3. NVIDIA Container Toolkit installed _(instructions below)_
4. A Gurobi Web License Service (WLS) license file

<br>

### Installing NVIDIA Container Toolkit

To enable GPU support with Docker containers, the NVIDIA Container Toolkit needs to be installed. Follow the steps at: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html#installing-with-apt

Then restart the Docker daemon:

```bash
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

### Running the Docker Container

The `run_container.sh` will perform all the setup needed _(eg. build Docker image, start container)_.

```bash
bash run_container.sh -g /path/to/wls/gurobi.lic
# OR
bash run_container.sh  # will prompted for the license path
```

The script will clone _(if needed)_ and mount the GRENA-verifier repo at the `app/` directory:

```
.
├── app
│   └── Grena-verifier  <---
├── Dockerfile
├── README.md
├── run_container.sh
└── cleanup.sh
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
