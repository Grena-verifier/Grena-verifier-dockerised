#!/bin/bash
set -e
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
cd "$script_dir"


IMAGE_NAME="eran-env"
CONTAINER_NAME="eran-container"

# Create app directory if it doesn't exist
if [ ! -d "app" ]; then
    echo "Creating app directory..."
    mkdir -p app
fi

# Check if image exists
if ! docker image inspect $IMAGE_NAME >/dev/null 2>&1; then
    echo "Image doesn't exist. Building..."
    docker build -t $IMAGE_NAME .
else
    # Check if Dockerfile has changed since last build
    DOCKERFILE_MODIFIED=$(stat -f %m Dockerfile 2>/dev/null || stat -c %Y Dockerfile)
    
    # Get the image creation timestamp
    IMAGE_CREATED=$(docker inspect -f '{{.Created}}' $IMAGE_NAME | xargs date +%s -d)
    
    if [ $DOCKERFILE_MODIFIED -gt $IMAGE_CREATED ]; then
        echo "Dockerfile has been modified. Rebuilding..."
        docker build -t $IMAGE_NAME .
    else
        echo "Image is up to date."
    fi
fi

# Check if container already exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    # Check if container is running
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo "Container is already running. Attaching..."
        docker attach $CONTAINER_NAME
    else
        echo "Starting existing container..."
        docker start -i $CONTAINER_NAME
    fi
else
    echo "Creating and starting new container..."
    docker run -it --name $CONTAINER_NAME --gpus all -v "$(pwd)/app:/app" $IMAGE_NAME /bin/bash
fi
