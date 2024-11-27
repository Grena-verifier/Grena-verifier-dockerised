#!/bin/bash

# Path to flag file that indicates this container has been initialized
INIT_FLAG_FILE="/.container_initialized"

# If initialization flag file and repo exists, skip initialisation
if [ -f "$INIT_FLAG_FILE" ] \
    && ([ -d "/app/Grena-verifier" ] && [ ! -z "$(ls -A /app/Grena-verifier 2>/dev/null)" ])
then
    echo "Container already initialized, skipping container initialization..."
    exec "$@"
    exit 0
fi


echo "Initializating container..."

# Check if Grena-verifier directory doesn't exist or is empty
if [ ! -d "/app/Grena-verifier" ] || [ -z "$(ls -A /app/Grena-verifier 2>/dev/null)" ]; then
    echo "Cloning Grena-verifier repository..."
    git clone https://github.com/Grena-verifier/Grena-verifier.git /app/Grena-verifier
    cd /app/Grena-verifier
    git submodule update --init --recursive

    # Download all the neural-network models
    bash download_models.sh
fi

cd /app/Grena-verifier

# Run installation script with CUDA support
echo "Running Grena-verifier installation script..."
chmod +x install.sh
./install.sh --use-cuda

# Create flag file to indicate that this container has been initialized
echo "This file is to indicate that this Docker container has already been initialized." > "$INIT_FLAG_FILE"
echo "Initialization complete"

# Execute the provided command
exec "$@"
