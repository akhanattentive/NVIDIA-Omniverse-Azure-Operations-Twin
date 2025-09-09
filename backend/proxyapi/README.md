# Proxy API

A simple Hello World C# API application designed for deployment to Azure Kubernetes Service (AKS).

## Overview

This is a .NET 8 Web API that provides simple endpoints for testing and health monitoring. It's containerized and ready for deployment to AKS as part of the NVIDIA Omniverse Azure Operations Twin project.

## Features

- **Health Check Endpoint**: `/health` for Kubernetes health probes
- **Hello World API**: `/api/hello` returns a JSON response with system information
- **Status Endpoint**: `/api/status` provides runtime status information
- **Swagger Documentation**: Available in development mode
- **CORS Support**: Configured for Azure environments
- **Security**: Runs as non-root user in container

## Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Simple "Hello World" text response |
| `/api/hello` | GET | JSON response with message and system info |
| `/api/status` | GET | Runtime status and system information |
| `/health` | GET | Health check endpoint for Kubernetes |

## Local Development

### Prerequisites

- .NET 8 SDK
- Docker (for containerization)

### Running Locally

```bash
cd backend/proxyapi
dotnet run
```

The API will be available at `http://localhost:5000`

### Building Docker Image

```bash
cd backend/proxyapi
docker build -t proxy-api .
docker run -p 8080:8080 proxy-api
```

## Deployment to AKS

### Deployment Prerequisites

- Azure CLI installed and logged in
- kubectl configured for your AKS cluster
- Access to Azure Container Registry (ACR)

### Environment Variables

Set the following environment variables before deployment:

```bash
export ACR_NAME="your-acr-name"
export AKS_CLUSTER_NAME="your-aks-cluster"
export RESOURCE_GROUP_NAME="your-resource-group"
export PROXY_API_VERSION="1.0.0"
export PROXY_API_HOSTNAME="proxy-api.yourdomain.com"
```

### Deploy

Run the deployment script:

```bash
./scripts/05-build-and-deploy-proxy-api.sh
```

This script will:

1. Build the Docker image
2. Push it to Azure Container Registry
3. Deploy to AKS using Kubernetes manifests
4. Wait for the deployment to be ready

### Kubernetes Resources

The deployment creates the following Kubernetes resources:

- **Deployment**: `proxy-api` with 2 replicas
- **Service**: `proxy-api-service` (ClusterIP)
- **Ingress**: `proxy-api-ingress` (with TLS support)
- **ConfigMap**: `proxy-api-config` for configuration

## Configuration

The application can be configured using:

- Environment variables
- `appsettings.json` files
- Kubernetes ConfigMaps

Key configuration options:

- `ASPNETCORE_ENVIRONMENT`: Set to `Development` or `Production`
- `ASPNETCORE_URLS`: URL bindings (default: `http://+:8080`)

## Security Features

- Runs as non-root user (UID 1001)
- Read-only root filesystem
- No privilege escalation
- Resource limits configured
- Health checks for proper lifecycle management

## Monitoring

The application includes:

- Health check endpoint at `/health`
- Kubernetes liveness and readiness probes
- Structured logging
- Resource monitoring through Kubernetes metrics

## Testing

Test the deployment:

```bash
# Test health endpoint
curl http://your-proxy-api-hostname/health

# Test API endpoint
curl http://your-proxy-api-hostname/api/hello

# Test status endpoint
curl http://your-proxy-api-hostname/api/status
```

## Scaling

Scale the deployment:

```bash
kubectl scale deployment proxy-api --replicas=5
```

## Troubleshooting

Check deployment status:

```bash
kubectl get pods -l app=proxy-api
kubectl logs -l app=proxy-api
kubectl describe deployment proxy-api
```

## Project Integration

This Proxy API is part of the NVIDIA Omniverse Azure Operations Twin project and follows the established patterns for:

- Docker containerization
- Kubernetes deployment
- Azure Container Registry integration
- AKS cluster management
- Environment variable substitution
- Script-based deployment automation
