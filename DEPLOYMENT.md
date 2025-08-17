# Deployment Guide

This guide will walk you through deploying the modern Go gRPC backend to Google Kubernetes Engine (GKE).

## Prerequisites

Before you begin, ensure you have the following tools installed:

- [Go 1.21+](https://golang.org/dl/)
- [Docker](https://docs.docker.com/get-docker/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [gcloud CLI](https://cloud.google.com/sdk/docs/install)

- [Helm CLI](https://helm.sh/docs/intro/install/)
- [Skaffold CLI](https://skaffold.dev/docs/install/)
- [Buf CLI](https://docs.buf.build/installation)

## Quick Start

### 1. Clone and Setup

```bash
# Clone the repository
git clone <your-repo-url>
cd golang-gcp-bootstrap

# Run the local configuration setup script
./scripts/setup-local-config.sh
```

### 2. Set Up Local Configuration

```bash
# Run the local configuration setup script
./scripts/setup-local-config.sh

# This will create:
# - .env file with your local settings
# - helm/grpc-service/values.local.yaml for local Helm overrides
# - ~/.config/golang-grpc-bootstrap/config.env for shell integration
# - Infrastructure configuration files

# Load your configuration
source .env
```

### 3. Configure GCP

**IMPORTANT**: Authentication is required for all GCP operations.

```bash
# Authenticate with GCP
gcloud auth application-default login --no-browser
gcloud config set project $GCP_PROJECT_ID

# Enable required APIs
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable dns.googleapis.com
# Note: cloudbuild.googleapis.com is NOT needed - we use local builds
```

**Authentication Process:**
- Follow the URL provided in the terminal to complete authentication
- Make sure to consent to all required scopes when prompted
- This method works reliably in all environments

### 4. Deploy Infrastructure

```bash
# Deploy infrastructure using gcloud
make deploy-infrastructure

# Or deploy manually
./scripts/deploy-infrastructure.sh
```

This will create:
- GKE cluster with autoscaling (e2-micro, FREE)
- DNS zone and managed SSL certificates
- Load balancer with external IP
- Kubernetes resources via Helm

### 5. Deploy Application

```bash
# Deploy the entire infrastructure
make deploy

# Or deploy manually
./scripts/deploy-infrastructure.sh
```

This will create:
- GKE cluster with autoscaling
- DNS zone and managed SSL certificates
- Load balancer with external IP
- Kubernetes resources via Helm

### 6. Deploy Application

```bash
# Deploy the application using Skaffold
make dev

# Or deploy to specific environment
make deploy-staging
make deploy-prod
```

### 7. Cleanup (Optional)

```bash
# Clean up infrastructure when done
make cleanup-infrastructure

# Or cleanup manually
./scripts/cleanup-infrastructure.sh
```

## Development Workflow

### Local Development (RECOMMENDED)

```bash
# Start development with hot reload
make dev

# This will:
# 1. Build Docker image locally (no cloud costs)
# 2. Deploy to local/remote cluster
# 3. Start file watching for hot reload
# 4. Port forward services locally
```

### Local Kubernetes (Optional)

For completely local development:

```bash
# Use minikube (free local cluster)
minikube start
make dev

# Or use kind (free local cluster)
kind create cluster
make dev
```

### Benefits of Local Development

- ✅ **No cloud costs** - everything runs locally
- ✅ **Fast iteration** - no upload/download time
- ✅ **Secure** - credentials never leave your machine
- ✅ **Offline capable** - works without internet
- ✅ **Easy debugging** - direct access to logs and services

### Testing

```bash
# Run all tests
make test

# Run tests with coverage
make test-coverage

# Run linters
make lint

# Run all checks
make all
```

### Building and Pushing

```bash
# Build Docker image
make docker-build

# Push to registry
make docker-push
```

## Environment Configuration

### Development Environment

```bash
# Use development profile
skaffold dev --profile=dev

# Or with custom values
skaffold dev --profile=dev --set=replicaCount=1
```

### Staging Environment

```bash
# Deploy to staging
skaffold run --profile=staging

# Or with custom image tag
skaffold run --profile=staging --tag=latest
```

### Production Environment

```bash
# Deploy to production
skaffold run --profile=prod

# Or with specific version
skaffold run --profile=prod --tag=v1.0.0
```

## Monitoring and Observability

### Health Checks

The application exposes health check endpoints:

- **gRPC Health**: `grpc://your-domain.com:9090/grpc.health.v1.Health/Check`
- **HTTP Health**: `http://your-domain.com:8080/health`
- **Readiness**: `http://your-domain.com:8080/ready`
- **Metrics**: `http://your-domain.com:8080/metrics`

### Logs

```bash
# View application logs
kubectl logs -f deployment/grpc-service

# View logs from specific pod
kubectl logs -f pod/grpc-service-xxxxx
```

### Metrics

The application exposes Prometheus metrics at `/metrics`. You can:

1. Set up Prometheus to scrape these metrics
2. Use Grafana for visualization
3. Set up alerting rules

## Troubleshooting

### Common Issues

#### 1. Infrastructure Deployment Fails

```bash
# Check cluster status
gcloud container clusters describe grpc-cluster-dev --region=us-central1

# Check cluster logs
gcloud container clusters get-credentials grpc-cluster-dev --region=us-central1
kubectl get nodes
kubectl get pods

# Recreate infrastructure
make cleanup-infrastructure
make deploy-infrastructure
```

#### 2. Kubernetes Pods Not Starting

```bash
# Check pod status
kubectl get pods

# Describe pod for details
kubectl describe pod <pod-name>

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp
```

#### 3. Service Not Accessible

```bash
# Check service status
kubectl get svc

# Check ingress status
kubectl get ingress

# Test connectivity
kubectl port-forward svc/grpc-service 9090:9090
```

#### 4. SSL Certificate Issues

```bash
# Check certificate status
kubectl describe managedcertificate

# Verify DNS records
nslookup your-domain.com

# Check certificate provisioning
gcloud compute ssl-certificates list
```

### Debugging Commands

```bash
# Get cluster info
kubectl cluster-info

# Check node status
kubectl get nodes

# View all resources
kubectl get all

# Check resource usage
kubectl top pods
kubectl top nodes

# Access pod shell
kubectl exec -it <pod-name> -- /bin/sh
```

## Security Considerations

### Network Policies

The deployment includes network policies to restrict pod-to-pod communication. Review and adjust as needed:

```bash
# View network policies
kubectl get networkpolicies

# Apply custom policies
kubectl apply -f k8s/network-policies/
```

### RBAC

The application uses a dedicated ServiceAccount with minimal permissions:

```bash
# Check RBAC
kubectl get serviceaccounts
kubectl get roles
kubectl get rolebindings
```

### Secrets Management

For production, use Kubernetes secrets or external secret management:

```bash
# Create secrets
kubectl create secret generic app-secrets \
  --from-literal=api-key=your-api-key \
  --from-literal=db-password=your-db-password
```

## Scaling

### Horizontal Pod Autoscaling

The deployment includes HPA for automatic scaling:

```bash
# Check HPA status
kubectl get hpa

# View HPA details
kubectl describe hpa grpc-service
```

### Manual Scaling

```bash
# Scale manually
kubectl scale deployment grpc-service --replicas=5

# Or via Helm
helm upgrade grpc-service helm/grpc-service --set replicaCount=5
```

## Backup and Recovery

### Backup Strategy

1. **Application Data**: Use persistent volumes with regular snapshots
2. **Configuration**: Store in Git with version control
3. **Infrastructure**: Infrastructure scripts are versioned and backed up

### Recovery Procedures

```bash
# Restore from backup
kubectl apply -f backup/

# Recreate infrastructure
make deploy-infrastructure

# Redeploy application
skaffold run --profile=prod
```

## Cost Optimization

### Current Cost-Optimized Configuration

This project is **pre-configured for minimal costs**:

- ✅ **GKE**: e2-micro machines (FREE in GCP free tier)
- ✅ **Nodes**: 1 node (down from 3 = saves ~$156/month)
- ✅ **Resources**: Optimized CPU/memory limits
- ✅ **Builds**: Local Docker builds (no Cloud Build costs)
- ✅ **Registry**: Local builds (no GCR storage costs)

### Resource Optimization

1. **Right-size requests/limits**: Monitor actual usage and adjust
2. **Use spot instances**: Configure node pools with spot instances
3. **Enable cluster autoscaler**: Automatically scale nodes based on demand

### Monitoring Costs

```bash
# Check GCP billing
gcloud billing accounts list

# Monitor resource usage
kubectl top nodes
kubectl top pods
```

### Cost Breakdown

| Component | Cost |
|-----------|------|
| **GKE Nodes** | $0/month (FREE with e2-micro) |
| **Load Balancer** | $0/month (disabled by default) |
| **Cloud Build** | $0/month (local builds) |
| **GCR Storage** | $0/month (local builds) |
| **DNS Zone** | ~$0.40/month |
| **Total** | **~$0.40/month** |

## Support

For issues and questions:

1. Check the troubleshooting section above
2. Review logs and metrics
3. Check GitHub Issues
4. Contact the development team

## Next Steps

After successful deployment:

1. Set up monitoring and alerting
2. Configure CI/CD pipelines
3. Implement backup strategies
4. Set up cost monitoring
5. Plan for disaster recovery
6. Document runbooks for common operations
