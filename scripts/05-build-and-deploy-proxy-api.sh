#!/bin/bash

# Build and deploy Proxy API script
# This script builds the Docker image and deploys it to AKS

set -e

# Source utility functions and environment variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.sh"
source "${SCRIPT_DIR}/exports.sh"

# Configuration
APP_NAME="proxy-api"
APP_PATH="${SCRIPT_DIR}/../backend/proxyapi"
VERSION="${PROXY_API_VERSION:-latest}"
ACR_NAME="${ACR_NAME:-regkitstarter}"
NAMESPACE="${K8S_NAMESPACE:-omni-streaming}"

log_info "Starting build and deployment of Proxy API"

# Check prerequisites
if [ -z "$ACR_NAME" ]; then
    log_error "ACR_NAME environment variable is not set"
    exit 1
fi

if [ -z "$AKS_CLUSTER_NAME" ]; then
    log_error "AKS_CLUSTER_NAME environment variable is not set"
    exit 1
fi

if [ -z "$RESOURCE_GROUP_NAME" ]; then
    log_error "RESOURCE_GROUP_NAME environment variable is not set"
    exit 1
fi

# Build Docker image
log_info "Building Docker image for ${APP_NAME}:${VERSION}"
cd "${APP_PATH}"

docker build -t "${ACR_NAME}.azurecr.io/${APP_NAME}:${VERSION}" .

# Push to ACR
log_info "Pushing image to Azure Container Registry"
az acr login --name "${ACR_NAME}"
docker push "${ACR_NAME}.azurecr.io/${APP_NAME}:${VERSION}"

# Get AKS credentials
log_info "Getting AKS credentials"
az aks get-credentials --resource-group "${RESOURCE_GROUP_NAME}" --name "${AKS_CLUSTER_NAME}" --overwrite-existing

# Apply Kubernetes manifests
log_info "Deploying to AKS cluster"
cd "${SCRIPT_DIR}/../k8s/templates/proxy-api"

# Replace environment variables in manifests
export ACR_NAME="${ACR_NAME}"
export VERSION="${VERSION}"
export PROXY_API_HOSTNAME="${PROXY_API_HOSTNAME:-proxy-api.local}"

# Apply ConfigMap first
envsubst < configmap.yaml | kubectl apply -n "${NAMESPACE}" -f -

# Apply main manifest
envsubst < manifest.yaml | kubectl apply -n "${NAMESPACE}" -f -

# Wait for deployment to be ready
log_info "Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/proxy-api -n "${NAMESPACE}"

# Get service information
log_info "Deployment completed successfully!"
kubectl get pods -l app=proxy-api -n "${NAMESPACE}"
kubectl get services proxy-api-service -n "${NAMESPACE}"

# Show ingress information if available
if kubectl get ingress proxy-api-ingress -n "${NAMESPACE}" >/dev/null 2>&1; then
    log_info "Ingress configuration:"
    kubectl get ingress proxy-api-ingress -n "${NAMESPACE}"
fi

log_info "Proxy API is now deployed and running!"
log_info "Health check endpoint: http://${PROXY_API_HOSTNAME}/health"
log_info "API endpoint: http://${PROXY_API_HOSTNAME}/api/hello"
