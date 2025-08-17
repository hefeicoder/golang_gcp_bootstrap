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
- **Go Module Path**: `github.com/YOUR_USERNAME/YOUR_PROJECT` (for import statements)
- **Service Name**: Used in Kubernetes, Docker, and Helm charts
- **Domain Name**: For SSL certificates and ingress configuration
- **GCP Project**: Your Google Cloud project ID
- **Docker Registry**: Where to push container images

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
gcloud auth application-default login --no-browser
gcloud config set project YOUR_PROJECT_ID

# Deploy infrastructure and application
make deploy-dev
```

**Note**: Follow the URL provided in the terminal to complete authentication. This method works reliably in all environments.

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
| **Infrastructure** | gcloud scripts | Infrastructure deployment |
| **Container Orchestration** | GKE | Kubernetes cluster |
| **Package Management** | Helm | Kubernetes manifests |
| **Development** | Skaffold | Local-to-GKE development loop |
| **CI/CD** | GitHub Actions | Automated testing and deployment |
| **Monitoring** | Prometheus + Cloud Logging | Observability |
| **Security** | Trivy | Vulnerability scanning |

## 🔧 Customization Explained

### **Why GitHub Username/Organization?**
The GitHub username is used to create **Go module paths** that follow Go's convention:

```
github.com/USERNAME/PROJECT_NAME
```

This affects:
- **Import statements** in your Go code
- **Module resolution** when `go mod` runs
- **Generated code** from protobuf definitions
- **CI/CD workflows** that reference your repository

**Example:**
- Original: `github.com/hefeicoder/golang-grpc-gke`
- After customization: `github.com/your-company/my-backend`

### **What Gets Updated**
The customization script replaces placeholders across all files:
- `go.mod` - Module path and dependencies
- `*.go` files - Import statements
- `proto/*` - Package names and generated code paths
- `helm/*` - Service names and configurations
- `Dockerfile*` - Image names
- `.github/workflows/*` - Repository references

**Note:** Project names with underscores (e.g., `my_backend`) will be converted to hyphens (e.g., `my-backend`) in Buf module names to comply with Buf's naming requirements.

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
├── infrastructure/            # Infrastructure configuration
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
make deploy-infrastructure

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
   - Infrastructure deployment with gcloud scripts
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
- [gcloud CLI](https://cloud.google.com/sdk/docs/install) for infrastructure deployment
- [Skaffold](https://skaffold.dev/) for development workflow
- [Helm](https://helm.sh/) for Kubernetes package management

## 🆘 Support

- **Issues**: Create an issue in your forked repository
- **Documentation**: Check the inline code comments
- **Community**: Join Go and Kubernetes communities

---

**Ready to build your next backend? Fork this template and start coding! 🚀**
