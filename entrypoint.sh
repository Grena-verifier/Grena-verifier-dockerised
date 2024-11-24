#!/bin/bash

# Check if ERAN directory exists and is empty
if [ ! -d "/app/Grena-verifier" ] || [ -z "$(ls -A /app/Grena-verifier 2>/dev/null)" ]; then
    echo "Cloning Grena-verifier repository..."
    git clone https://github.com/Grena-verifier/Grena-verifier.git /app/Grena-verifier
    
    cd /app/Grena-verifier
    
    # Run installation script with CUDA support
    echo "Running Grena-verifier installation script..."
    chmod +x install.sh
    ./install.sh -use-cuda
    
    # Install Python requirements
    echo "Installing Python requirements..."
    pip3 install --upgrade pip
    pip3 install -r requirements.txt
    
    # Source Gurobi setup
    if [ -f "gurobi_setup_path.sh" ]; then
        echo "source /app/Grena-verifier/gurobi_setup_path.sh" >> ~/.bashrc
    fi
fi

# Always ensure we're in the Grena-verifier directory
cd /app/Grena-verifier

# Execute the provided command
exec "$@"
