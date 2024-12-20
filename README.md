# GRENA-verifier dockerised

Dockerised implementation of [GRENA-verifier](https://github.com/Grena-verifier/Grena-verifier).

<br>

# Prerequisites

Ensure you have the following requirements:

1. Docker installed on your system
1. NVIDIA GPU(s) available on your machine
1. NVIDIA Container Toolkit installed _(instructions below)_
1. A Gurobi Web License Service (WLS) license file
1. Internet access _(for Gurobi WLS license to authenticate)_

<br>

## Installing NVIDIA Container Toolkit

To enable GPU support with Docker containers, the NVIDIA Container Toolkit needs to be installed. Follow the steps at: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html#installing-with-apt

Then restart the Docker daemon:

```bash
sudo systemctl restart docker
```

<br>

## Obtaining Gurobi License

You need to obtain a Gurobi Web License Service (WLS) license file `gurobi.lic` before running the container.

> _**:warning: NOTE:** WLS license needs internet access to authenticate._

<br>

# Usage

The repository provides two main scripts:

-   `run_container.sh`: Sets up and runs the GRENA-verifier container
-   `cleanup.sh`: Removes all resources created by the container

<br>

## Running the Docker Container

The `run_container.sh` will perform all the setup needed _(eg. build Docker image, install all dependencies, download all models, etc)_.

You'll need to provide it the path to your Gurobi WLS license file either with the `-g` / `--gurobi-license-path` flag, or simply run the script and it'll prompt for the path when needed.

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

and it will enter the Docker container in the `Grena-verifer` repo directory. You should see something like this:

```
root@a352bcaa6b22:/app/Grena-verifier#
```

<br>

### Troubleshooting

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

## Re-running / Re-entering the Docker Container

If you've exited or deleted the container, you may re-run / re-enter the container by:

```bash
bash run_container.sh
```

<br>

## Running the Experiments (in the Docker container)

All the models are downloaded to the `/model` directory by the `run_container.sh` script. If the download somehow failed, try running the `/Grena-verifier/download_model.sh` script.

> :warning: _**NOTE:** Below is a snippet from [Grena-verifier](https://github.com/Grena-verifier/Grena-verifier)'s README. For more info, refer to our Grena-verifier's README._

<br>

Each model has two scripts in the `/experiment_scripts` directory:

-   `[C|M][MODEL_NAME]_verify.py` — Perform abstract refinement based verification on 30 selected images per model
-   `[C|M][MODEL_NAME]_bounds.py` — Compare bounds tightening on 1 image using Gurobi vs our tailored solver

Scripts for CIFAR-10 models are prefixed with `C`, MNIST are prefixed with `M`.

To run any of the experiments, simply run the corresponding script with Python.

```bash
cd experiment_scripts
python CConvBig_verify.py   # for CIFAR10 ConvBig verification exp.
```

> :warning: _**NOTE:** The scripts will save all console logs to `terminal.log` in the results directory instead of printing to terminal._

The experiment results will be saved to the `experiment_scripts/results/[MODEL_NAME]/[verify|bounds]/` directory:

```
# For example:
.
├── tf_verify/
├── experiment_scripts/
│   └── results/
|       ├── M6x256
│       │   ├── bounds/  <---
│       │   └── verify/  <---
|       └── MConvSmall
│           ├── bounds/  <---
│           └── verify/  <---
├── README.md
├── download_models.sh
├── install_libraries.sh
├── install.sh
└── requirements.txt
```

The main result files are:

-   `bounds/RESULT_bounds_improvement_plot.jpg`
-   `bounds/RESULT_solver_runtimes.csv`
-   `verify/RESULT_GRENA_verification.csv`

<br>

## Cleaning Up

To all resources created by Docker, run `cleanup.sh` with root privileges:

```bash
sudo bash cleanup.sh
```
