# 🚀 Modern Go gRPC Backend Bootstrap

> **A production-ready Go gRPC backend template for GKE deployment**

This is a **bootstrap project** designed to be forked and customized for your own backend services. It provides a complete, modern Go gRPC stack with infrastructure as code, Kubernetes deployment, and CI/CD pipeline.

## 🎯 Quick Start (Fork & Customize)

### 1. **Fork This Repository**
```bash
# Click "Fork" button on GitHub, then clone your fork
git clone https://github.com/YOUR_USERNAME/golang_gcp_bootstrap.git
cd golang_gcp_bootstrap
```

### 2. **Customize for Your Project**
```bash
# Replace placeholder values with your own
./scripts/customize.sh
```

**What gets customized:**
- Module name (`github.com/YOUR_USERNAME/YOUR_PROJECT`)
- Service name and descriptions
- Domain names and environment variables
- Docker image names and tags

### 3. **Set Up Your Environment**
```bash
# Install required tools
make install-tools

# Generate protobuf code
make generate

# Run tests
make test
```

### 4. **Deploy to GKE**
```bash
# Configure GCP credentials
gcloud auth login
gcloud config set project YOUR_PROJECT_ID

# Deploy infrastructure and application
make deploy-dev
```

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Load Balancer │    │   GKE Cluster   │
│   (Any)         │───▶│   (Cloud Load   │───▶│   (Kubernetes)  │
│                 │    │   Balancer)     │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                       │
                                                       ▼
                                              ┌─────────────────┐
                                              │   gRPC Service  │
                                              │   (Go + Connect)│
                                              └─────────────────┘
```

## 🛠️ Tech Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Language** | Go 1.21+ | Backend service language |
| **gRPC** | ConnectRPC | Modern gRPC with HTTP/2 support |
| **Protocol Buffers** | Buf | Schema definition and code generation |
| **Infrastructure** | Pulumi (Go) | Infrastructure as Code |
| **Container Orchestration** | GKE | Kubernetes cluster |
| **Package Management** | Helm | Kubernetes manifests |
| **Development** | Skaffold | Local-to-GKE development loop |
| **CI/CD** | GitHub Actions | Automated testing and deployment |
| **Monitoring** | Prometheus + Cloud Logging | Observability |
| **Security** | Trivy | Vulnerability scanning |

## 📁 Project Structure

```
golang_gcp_bootstrap/
├── cmd/server/                 # Application entry point
├── internal/server/            # gRPC service implementation
├── proto/                      # Protocol buffer definitions
│   ├── api/                   # Service API definitions
│   ├── buf.yaml              # Buf configuration
│   └── buf.gen.yaml          # Code generation config
├── gen/                       # Generated Go code (gitignored)
├── infrastructure/            # Pulumi infrastructure code
├── helm/                      # Helm charts for deployment
├── .github/workflows/         # CI/CD pipelines
├── scripts/                   # Utility scripts
├── Dockerfile                 # Production container
├── Dockerfile.dev            # Development container
├── skaffold.yaml             # Development workflow
├── Makefile                  # Build automation
└── README.md                 # This file
```

## 🔧 Development Workflow

### **Local Development**
```bash
# Start development environment with hot reload
make dev

# Or use Skaffold for GKE development
skaffold dev --profile dev
```

### **Testing**
```bash
# Run all tests
make test

# Run tests with coverage
make test-coverage

# Run linters
make lint
```

### **Building**
```bash
# Build application
make build

# Build Docker image
make docker-build

# Build and push to registry
make docker-push
```

## 🚀 Deployment

### **Environments**
- **Development**: `skaffold dev --profile dev`
- **Staging**: `skaffold run --profile staging`
- **Production**: `skaffold run --profile prod`

### **Infrastructure**
```bash
# Deploy GKE cluster and infrastructure
cd infrastructure
pulumi up

# Configure kubectl
gcloud container clusters get-credentials YOUR_CLUSTER_NAME
```

## 🔐 Security Features

- **TLS/SSL**: Automatic certificate management
- **RBAC**: Kubernetes role-based access control
- **Network Policies**: Pod-to-pod communication rules
- **Secrets Management**: Kubernetes secrets for sensitive data
- **Vulnerability Scanning**: Trivy integration in CI/CD
- **Non-root Containers**: Security-hardened Docker images

## 📊 Monitoring & Observability

- **Metrics**: Prometheus endpoints and custom metrics
- **Logging**: Structured logging with Cloud Logging
- **Tracing**: OpenTelemetry integration (ready for implementation)
- **Health Checks**: gRPC health probe and HTTP endpoints
- **Alerts**: Prometheus alerting rules (configurable)

## 🔄 CI/CD Pipeline

The GitHub Actions workflow includes:

1. **Test Stage**
   - Code linting with golangci-lint
   - Unit tests with coverage
   - Security scanning with Trivy

2. **Build Stage**
   - Docker image building
   - Multi-architecture support
   - Image vulnerability scanning

3. **Deploy Stage**
   - Automatic deployment to dev/staging/prod
   - Infrastructure updates with Pulumi
   - Helm chart deployment

## 🎨 Customization Guide

### **1. Service Definition**
Edit `proto/api/grpc_service.proto` to define your API:
```protobuf
service YourService {
  rpc YourMethod(YourRequest) returns (YourResponse);
}
```

### **2. Business Logic**
Implement your service in `internal/server/`:
```go
func (s *YourService) YourMethod(ctx context.Context, req *connect.Request[YourRequest]) (*connect.Response[YourResponse], error) {
    // Your business logic here
}
```

### **3. Infrastructure**
Modify `infrastructure/main.go` for your cloud resources:
```go
// Add databases, caches, message queues, etc.
```

### **4. Configuration**
Update Helm values in `helm/grpc-service/values.yaml`:
```yaml
replicaCount: 3
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
```

## 🤝 Contributing

This is a bootstrap template, but if you find improvements that would benefit the community:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Buf](https://buf.build/) for modern protobuf tooling
- [ConnectRPC](https://connect.build/) for gRPC over HTTP/2
- [Pulumi](https://www.pulumi.com/) for infrastructure as code
- [Skaffold](https://skaffold.dev/) for development workflow
- [Helm](https://helm.sh/) for Kubernetes package management

## 🆘 Support

- **Issues**: Create an issue in your forked repository
- **Documentation**: Check the inline code comments
- **Community**: Join Go and Kubernetes communities

---

**Ready to build your next backend? Fork this template and start coding! 🚀**
