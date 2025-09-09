#!/bin/bash

# Local development script for Proxy API
# This script helps with local development tasks

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_PATH="${SCRIPT_DIR}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  run         Run the application locally"
    echo "  build       Build the application"
    echo "  test        Run tests"
    echo "  docker      Build and run Docker container"
    echo "  clean       Clean build artifacts"
    echo "  restore     Restore NuGet packages"
    echo "  help        Show this help message"
}

# Function to run the application
run_app() {
    log_info "Running Proxy API locally..."
    cd "${APP_PATH}"
    dotnet run
}

# Function to build the application
build_app() {
    log_info "Building Proxy API..."
    cd "${APP_PATH}"
    dotnet build -c Release
}

# Function to run tests
run_tests() {
    log_info "Running tests..."
    cd "${APP_PATH}"
    dotnet test --verbosity normal
}

# Function to build and run Docker container
run_docker() {
    log_info "Building Docker image..."
    cd "${APP_PATH}"
    docker build -t proxy-api:local .
    
    log_info "Running Docker container..."
    echo "Container will be available at http://localhost:8080"
    echo "Press Ctrl+C to stop"
    docker run --rm -p 8080:8080 proxy-api:local
}

# Function to clean build artifacts
clean_app() {
    log_info "Cleaning build artifacts..."
    cd "${APP_PATH}"
    dotnet clean
    rm -rf bin/ obj/
}

# Function to restore packages
restore_packages() {
    log_info "Restoring NuGet packages..."
    cd "${APP_PATH}"
    dotnet restore
}

# Main script logic
case "${1:-help}" in
    "run")
        run_app
        ;;
    "build")
        build_app
        ;;
    "test")
        run_tests
        ;;
    "docker")
        run_docker
        ;;
    "clean")
        clean_app
        ;;
    "restore")
        restore_packages
        ;;
    "help"|*)
        show_usage
        ;;
esac
