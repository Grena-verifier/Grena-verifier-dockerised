#!/bin/bash
set -e
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
cd "$script_dir"

IMAGE_NAME="eran-env"
CONTAINER_NAME="eran-container"
APP_DIR="$script_dir/app"

# Check if user ran this script with sudo/root permission
if [ "$EUID" -ne 0 ]; then
    echo "WARNING: Not running with sudo/root permission."
    read -p "You may encounter problems deleting the mounted dir at $APP_DIR. Continue? (Y/N) " -n 1 -r
    echo    # Move to a new line
    while ! [[ $REPLY =~ ^[YyNn]$ ]]; do
        read -p "Please enter Y or N: " -n 1 -r
        echo
    done

    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo "Operation cancelled."
        exit 1
    fi
fi

# Print what will be deleted
echo "The following items will be deleted:"
echo "-----------------------------------"
echo "Docker Container: $CONTAINER_NAME"
echo "Docker Image: $IMAGE_NAME"
echo "Directory: $APP_DIR"
echo "-----------------------------------"

# Ask for confirmation
read -p "Are you sure you want to proceed? (Y/N) " -n 1 -r
echo    # Move to a new line
while ! [[ $REPLY =~ ^[YyNn]$ ]]; do
    read -p "Please enter Y or N: " -n 1 -r
    echo
done

if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "Operation cancelled."
    exit 1
fi

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
    echo "Found image $IMAGE_NAME"
    read -p "Do you want to remove build cache layers for this image as well? (Y/N) " -n 1 -r
    echo    # Move to a new line
    while ! [[ $REPLY =~ ^[YyNn]$ ]]; do
        read -p "Please enter Y or N: " -n 1 -r
        echo
    done

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Removing image and its build cache layers..."
        # Get the image ID
        IMAGE_ID=$(docker images --format "{{.ID}}" $IMAGE_NAME)
        # Remove the image
        docker rmi $IMAGE_NAME
        # Remove build cache layers specific to this image
        docker builder prune --filter "id=$IMAGE_ID" -f
    else
        echo "Removing only the image $IMAGE_NAME..."
        docker rmi $IMAGE_NAME
    fi
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
