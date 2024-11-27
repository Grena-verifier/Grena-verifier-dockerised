#!/bin/bash
set -e
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
cd "$script_dir"

print_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -g, --gurobi-license-path PATH    Path to Gurobi license file"
    echo "  -h, --help                        Display this help message"
    exit 1
}

GUROBI_LICENSE_PATH=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -g|--gurobi-license-path)
            if [[ -n "$2" ]]; then
                GUROBI_LICENSE_PATH="$2"
                shift 2
            else
                echo "Error: Argument for $1 is missing" >&2
                print_usage
            fi
            ;;
        -h|--help)
            print_usage
            ;;
        *)
            echo "Error: Unknown parameter $1" >&2
            print_usage
            ;;
    esac
done

IMAGE_NAME="grena-image"
CONTAINER_NAME="grena-container"

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
    DOCKERFILE_MODIFIED=$(stat -c %Y Dockerfile)

    # Get the image creation timestamp
    IMAGE_CREATED=$(docker inspect -f '{{.Created}}' $IMAGE_NAME | xargs date +%s -d)

    if [ "$DOCKERFILE_MODIFIED" -gt "$IMAGE_CREATED" ]; then
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
    # Function to validate Gurobi license path
    validate_license_path() {
        local license_path="$1"
        # Expand the path if it uses ~
        license_path="${license_path/#\~/$HOME}"
        if [ -f "$license_path" ]; then
            echo "$license_path"
            return 0
        fi
        return 1
    }

    # If license path was provided as argument, validate it
    if [ -n "$GUROBI_LICENSE_PATH" ]; then
        if ! VALIDATED_PATH=$(validate_license_path "$GUROBI_LICENSE_PATH"); then
            echo "Error: File not found at $GUROBI_LICENSE_PATH"
            echo "Falling back to interactive prompt..."
            GUROBI_LICENSE_PATH=""
        else
            GUROBI_LICENSE_PATH="$VALIDATED_PATH"
        fi
    fi

    # If no valid license path yet, prompt for it
    while [ -z "$GUROBI_LICENSE_PATH" ]; do
        read -p "Please enter the path to your Gurobi license file (e.g., ~/.gurobi/gurobi.lic): " input_path
        if VALIDATED_PATH=$(validate_license_path "$input_path"); then
            GUROBI_LICENSE_PATH="$VALIDATED_PATH"
            break
        else
            echo "Error: File not found at $input_path"
            echo "Please enter a valid path"
        fi
    done

    echo "Creating and starting new container..."

    # The `--privileged --cgroupns=host` args are to work around the Gurobi error that occurs from
    # using Gurobi version <= 9.5.0 with WLS license in a Docker container.
    # Source: https://support.gurobi.com/hc/en-us/articles/4416277022353-Error-10024-Web-license-service-only-available-for-container-environments
    docker run -it \
        --privileged --cgroupns=host \
        --name $CONTAINER_NAME \
        --gpus all \
        -v "$(pwd)/app:/app" \
        -v "$GUROBI_LICENSE_PATH:/opt/gurobi/gurobi.lic" \
        -e GRB_LICENSE_FILE=/opt/gurobi/gurobi.lic \
        $IMAGE_NAME /bin/bash
fi
