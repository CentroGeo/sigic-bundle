#!/bin/bash
set -e  # Exit on any error

# Set default env file based on platform
PLATFORM=$1
ENVIRONMENT=$2
export COMPOSE_PROJECT_NAME="${PLATFORM}-${ENVIRONMENT}"
ENV_FILE=".env.$COMPOSE_PROJECT_NAME"

# Function to check and build specific services
build_service() {
    local service_name="$3"
    local build_cmd="COMPOSE_PROFILES=geonode,frontend docker compose --env-file '$ENV_FILE' -f docker-compose.yml -f docker-compose.platform.yml build"

    echo "🏗️  Building $service_name..."

    case "$service_name" in
        frontend)
            $build_cmd frontend-admin frontend-app
            ;;
        django)
            $build_cmd django celery
            ;;
        all)
            $build_cmd frontend-admin frontend-app django celery
            ;;
        *)
            echo "No service name given, using default: all"
            $build_cmd frontend-admin frontend-app django celery
            ;;
    esac

    echo "✅ $service_name build completed"
}

# Function to start services
start_services() {
    local start_cmd="COMPOSE_PROFILES=geonode,frontend docker compose --env-file '$ENV_FILE' -f docker-compose.yml -f docker-compose.platform.yml up -d"

    echo "🚀 Starting services..."
    $start_cmd

    # Wait a bit for services to initialize
    sleep 5

    echo "✅ Services started"
}

# Main script logic
main() {
    build_service "$1"
    start_services
}

# Execute main function with all arguments
main "$@"
