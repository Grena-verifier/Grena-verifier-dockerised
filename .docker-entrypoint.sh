#!/bin/bash

# Check if Grena-verifier directory doesn't exist or is empty
if [ ! -d "/app/Grena-verifier" ] || [ -z "$(ls -A /app/Grena-verifier 2>/dev/null)" ]; then
    echo "Cloning Grena-verifier repository..."
    git clone https://github.com/Grena-verifier/Grena-verifier.git /app/Grena-verifier
    cd /app/Grena-verifier
    git submodule update --init --recursive
fi

cd /app/Grena-verifier

# Run installation script with CUDA support
echo "Running Grena-verifier installation script..."
chmod +x install.sh
./install.sh --use-cuda

# Download all the neural-network models
bash download_models.sh

# Execute the provided command
exec "$@"
