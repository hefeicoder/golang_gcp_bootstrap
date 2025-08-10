# 🚀 Setup Guide

This guide will help you get started with the Go gRPC Bootstrap project.

## 🎯 Quick Start

### 1. Fork and Clone
```bash
# 1. Click "Fork" on GitHub
# 2. Clone your fork
git clone https://github.com/YOUR_USERNAME/golang_gcp_bootstrap.git
cd golang_gcp_bootstrap
```

### 2. Customize the Project
```bash
# Run the customization script
./scripts/customize.sh
```

The script will ask for:
- Your GitHub username/organization
- Your project name
- Your domain name
- Your GCP project ID
- Your Docker registry

### 3. Set Up Your Environment
```bash
# Install required tools
make install-tools

# Generate protobuf code
make generate

# Run tests to verify everything works
make test
```

### 4. Configure GCP
```bash
# Login to GCP
gcloud auth login

# Set your project
gcloud config set project YOUR_PROJECT_ID

# Enable required APIs
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable dns.googleapis.com
gcloud services enable cloudbuild.googleapis.com
```

### 5. Configure GitHub Secrets
Go to your repository Settings → Secrets and add:
- `GCP_SA_KEY`: Your GCP service account JSON key
- `GCP_PROJECT_ID`: Your GCP project ID

### 6. Deploy
```bash
# Deploy infrastructure and application
make deploy-dev
```

## 🔧 Development Workflow

### Local Development
```bash
# Start development with hot reload
make dev
```

### Testing
```bash
# Run all tests
make test

# Run tests with coverage
make test-coverage

# Run linters
make lint
```

### Building
```bash
# Build application
make build

# Build Docker image
make docker-build
```

## 📁 Project Structure

```
golang_gcp_bootstrap/
├── cmd/server/                 # Application entry point
├── internal/server/            # gRPC service implementation
├── proto/                      # Protocol buffer definitions
├── gen/                        # Generated Go code
├── infrastructure/             # Pulumi infrastructure code
├── helm/                       # Helm charts
├── .github/workflows/          # CI/CD pipelines
├── scripts/                    # Utility scripts
└── README.md                   # Project documentation
```

## 🎨 Customization Points

### 1. Service Definition
Edit `proto/api/grpc_service.proto` to define your API:
```protobuf
service YourService {
  rpc YourMethod(YourRequest) returns (YourResponse);
}
```

### 2. Business Logic
Implement your service in `internal/server/`:
```go
func (s *YourService) YourMethod(ctx context.Context, req *connect.Request[YourRequest]) (*connect.Response[YourResponse], error) {
    // Your business logic here
}
```

### 3. Infrastructure
Modify `infrastructure/main.go` for your cloud resources:
```go
// Add databases, caches, message queues, etc.
```

### 4. Configuration
Update Helm values in `helm/grpc-service/values.yaml`:
```yaml
replicaCount: 3
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
```

## 🔐 Security Checklist

- [ ] Review and update security policies
- [ ] Configure network policies
- [ ] Set up secrets management
- [ ] Enable vulnerability scanning
- [ ] Configure RBAC
- [ ] Set up monitoring and alerting

## 📊 Monitoring Setup

- [ ] Configure Prometheus endpoints
- [ ] Set up Grafana dashboards
- [ ] Configure alerting rules
- [ ] Set up log aggregation
- [ ] Configure distributed tracing

## 🚀 Production Deployment

### 1. Review Configuration
- Update resource limits
- Configure autoscaling
- Set up monitoring
- Review security settings

### 2. Deploy to Production
```bash
# Deploy infrastructure
cd infrastructure
pulumi up

# Deploy application
skaffold run --profile prod
```

### 3. Verify Deployment
```bash
# Check deployment status
kubectl get pods
kubectl get services
kubectl get ingress

# Check logs
kubectl logs -f deployment/YOUR_SERVICE_NAME
```

## 🆘 Troubleshooting

### Common Issues

1. **Protobuf Generation Fails**
   ```bash
   # Regenerate protobuf code
   make generate
   ```

2. **Docker Build Fails**
   ```bash
   # Clean and rebuild
   make docker-clean
   make docker-build
   ```

3. **Kubernetes Deployment Fails**
   ```bash
   # Check pod status
   kubectl describe pod <pod-name>
   kubectl logs <pod-name>
   ```

4. **Infrastructure Deployment Fails**
   ```bash
   # Check Pulumi status
   pulumi preview
   pulumi logs
   ```

### Getting Help

- Check the [README.md](README.md) for detailed documentation
- Review inline code comments
- Check GitHub Actions logs for CI/CD issues
- Join Go and Kubernetes communities

## 🎉 Next Steps

1. **Start Coding**: Add your business logic
2. **Add Tests**: Write comprehensive tests
3. **Set Up Monitoring**: Configure observability
4. **Deploy**: Get your service running
5. **Iterate**: Continuously improve

Happy coding! 🚀
