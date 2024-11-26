#!/bin/bash
set -e
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
cd "$script_dir"

IMAGE_NAME="eran-env"
CONTAINER_NAME="eran-container"
APP_DIR="$script_dir/app"

# Print what will be deleted
echo "The following items will be deleted:"
echo "-----------------------------------"
echo "Docker Container: $CONTAINER_NAME"
echo "Docker Image: $IMAGE_NAME"
echo "Directory: $APP_DIR"
echo "-----------------------------------"

# Ask for confirmation
read -p "Are you sure you want to proceed? (y/N) " -n 1 -r
echo    # Move to a new line

if [[ $REPLY =~ ^[Yy]$ ]]
then
    # Stop and remove container if it exists
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo "Stopping and removing container $CONTAINER_NAME..."
        docker stop $CONTAINER_NAME 2>/dev/null || true
        docker rm $CONTAINER_NAME
    else
        echo "Container $CONTAINER_NAME not found."
    fi

    # Remove image if it exists
    if docker image inspect $IMAGE_NAME >/dev/null 2>&1; then
        echo "Removing image $IMAGE_NAME..."
        docker rmi $IMAGE_NAME
    else
        echo "Image $IMAGE_NAME not found."
    fi

    # Remove app directory if it exists
    if [ -d "$APP_DIR" ]; then
        echo "Removing directory $APP_DIR..."
        rm -rf "$APP_DIR"
    else
        echo "Directory $APP_DIR not found."
    fi

    echo "Cleanup completed successfully."
else
    echo "Operation cancelled."
fi