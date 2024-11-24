#!/bin/bash

# Check if ERAN directory exists and is empty
if [ ! -d "/app/ERAN" ] || [ -z "$(ls -A /app/ERAN 2>/dev/null)" ]; then
    echo "Cloning ERAN repository..."
    git clone https://github.com/eth-sri/ERAN.git /app/ERAN
    
    cd /app/ERAN
    
    # Run installation script with CUDA support
    echo "Running ERAN installation script..."
    chmod +x install.sh
    ./install.sh -use-cuda
    
    # Install Python requirements
    echo "Installing Python requirements..."
    pip3 install --upgrade pip
    pip3 install -r requirements.txt
    
    # Source Gurobi setup
    if [ -f "gurobi_setup_path.sh" ]; then
        echo "source /app/ERAN/gurobi_setup_path.sh" >> ~/.bashrc
    fi
fi

# Always ensure we're in the ERAN directory
cd /app/ERAN

# Execute the provided command
exec "$@"
