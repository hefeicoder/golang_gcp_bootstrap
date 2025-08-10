# 🚀 Modern Go gRPC Backend for GKE

> **A complete, production-ready Go gRPC backend setup for Google Kubernetes Engine (GKE) using cutting-edge tooling and best practices.**

[![Go Version](https://img.shields.io/badge/Go-1.21+-blue.svg)](https://golang.org/dl/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Pulumi](https://img.shields.io/badge/Pulumi-3.96.1-purple.svg)](https://www.pulumi.com/)
[![Skaffold](https://img.shields.io/badge/Skaffold-2.0+-orange.svg)](https://skaffold.dev/)
[![Buf](https://img.shields.io/badge/Buf-Latest-red.svg)](https://buf.build/)

## 📋 Table of Contents

- [Overview](#-overview)
- [✨ Features](#-features)
- [🏗️ Architecture](#️-architecture)
- [🚀 Quick Start](#-quick-start)
- [📁 Project Structure](#-project-structure)
- [🛠️ Development](#️-development)
- [🚀 Deployment](#-deployment)
- [📊 Monitoring & Observability](#-monitoring--observability)
- [🔒 Security](#-security)
- [📈 Scaling](#-scaling)
- [🔄 CI/CD](#-cicd)
- [📚 API Documentation](#-api-documentation)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

## 🎯 Overview

This project provides a **complete, production-ready setup** for deploying Go gRPC services to Google Kubernetes Engine (GKE) using modern tooling and best practices. It replaces traditional YAML-based deployments with **Infrastructure as Code** and provides a **seamless development experience**.

### 🎯 Why This Stack?

- **🚀 No YAML Hell**: Everything is in Go (Pulumi) or structured Helm charts
- **⚡ Rapid Iteration**: Skaffold provides instant feedback during development
- **🔧 Single Language**: Go for both infrastructure and application code
- **🔮 Future-Proof**: Modern tooling that's actively maintained
- **🏭 Production Ready**: Includes monitoring, security, and scaling out of the box

## ✨ Features

### 🏗️ Infrastructure
- **GKE Cluster** with autoscaling and workload identity
- **Managed SSL certificates** with automatic renewal
- **DNS zone management** with Cloud DNS
- **Load balancer** with external IP
- **VPC and networking** configuration

### 🐳 Kubernetes
- **Production-ready Helm charts** with best practices
- **Horizontal Pod Autoscaler** for automatic scaling
- **Health checks, readiness probes, and resource limits**
- **Ingress configuration** with TLS termination
- **Service accounts and RBAC** setup

### 🔄 Development Workflow
- **Hot reload development** with file watching
- **Multi-environment profiles** (dev/staging/prod)
- **Port forwarding** for local development
- **One-command deployment** to any environment

### 📡 gRPC & API
- **Modern protocol buffer workflow** with Buf
- **ConnectRPC** for HTTP/2 and gRPC compatibility
- **Code generation** with proper Go modules
- **Reflection support** for debugging
- **REST API endpoints** via gRPC-Gateway

### 📊 Observability
- **Prometheus metrics** integration
- **Structured logging** with logrus
- **Health check endpoints** (gRPC and HTTP)
- **Distributed tracing** ready
- **Grafana dashboards** included

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           Development Workflow                              │
├─────────────────┬─────────────────┬─────────────────┬──────────────────────┤
│   Pulumi (Go)   │   Helm Charts   │   Skaffold      │   Buf + ConnectRPC   │
│ Infrastructure  │   K8s Manifests │   Dev Workflow  │   Proto Workflow     │
└─────────────────┴─────────────────┴─────────────────┴──────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              GKE Cluster                                    │
├─────────────────┬─────────────────┬─────────────────┬──────────────────────┤
│   Ingress       │   Service       │   Pods          │   Monitoring         │
│   (NGINX)       │   (gRPC)        │   (Go App)      │   (Prometheus)       │
│   + TLS         │   + LoadBalancer│   + Health      │   + Grafana          │
└─────────────────┴─────────────────┴─────────────────┴──────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              External Access                                │
├─────────────────┬─────────────────┬─────────────────┬──────────────────────┤
│   gRPC Client   │   HTTP Client   │   Web UI        │   Monitoring UI      │
│   (ConnectRPC)  │   (REST API)    │   (Dashboard)   │   (Grafana)          │
└─────────────────┴─────────────────┴─────────────────┴──────────────────────┘
```

## 🚀 Quick Start

### Prerequisites

Before you begin, ensure you have the following tools installed:

| Tool | Version | Installation |
|------|---------|--------------|
| [Go](https://golang.org/dl/) | 1.21+ | `brew install go` (macOS) |
| [Docker](https://docs.docker.com/get-docker/) | Latest | [Docker Desktop](https://www.docker.com/products/docker-desktop) |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | Latest | `gcloud components install kubectl` |
| [gcloud CLI](https://cloud.google.com/sdk/docs/install) | Latest | [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) |
| [Pulumi CLI](https://www.pulumi.com/docs/install/) | Latest | `curl -fsSL https://get.pulumi.com \| sh` |
| [Helm CLI](https://helm.sh/docs/intro/install/) | 3.x | `brew install helm` (macOS) |
| [Skaffold CLI](https://skaffold.dev/docs/install/) | Latest | `curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-darwin-amd64` |
| [Buf CLI](https://docs.buf.build/installation) | Latest | `brew install bufbuild/buf/buf` (macOS) |

### 🚀 One-Command Setup

```bash
# Clone the repository
git clone <your-repo-url>
cd golang-grpc-gke

# Run the quick start script (checks prerequisites and sets up everything)
./scripts/quickstart.sh
```

### 🔧 Manual Setup

If you prefer to set up manually:

```bash
# 1. Install development tools
make install-tools

# 2. Generate protobuf code
make generate

# 3. Build the application
make build

# 4. Run tests
make test

# 5. Build Docker image
make docker-build
```

### 🌐 Configure GCP

```bash
# Set your GCP project
export GOOGLE_PROJECT_ID="your-project-id"
gcloud config set project $GOOGLE_PROJECT_ID

# Enable required APIs
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable dns.googleapis.com
gcloud services enable cloudbuild.googleapis.com
```

### 🏗️ Deploy Infrastructure

```bash
# Configure Pulumi
cd infrastructure
pulumi config set gcp:project $GOOGLE_PROJECT_ID
pulumi config set gcp:region us-central1
pulumi config set domain-name your-domain.com
pulumi config set environment dev

# Deploy infrastructure
pulumi up --yes
```

### 🚀 Deploy Application

```bash
# Start development with hot reload
make dev

# Or deploy to specific environment
make deploy-staging
make deploy-prod
```

## 📁 Project Structure

```
golang-grpc-gke/
├── 📁 infrastructure/              # Pulumi infrastructure code
│   ├── 📄 main.go                 # Main Pulumi program
│   ├── 📄 go.mod                  # Go module for infrastructure
│   └── 📄 Pulumi.yaml            # Pulumi project configuration
├── 📁 helm/                       # Helm charts
│   └── 📁 grpc-service/           # Main service chart
│       ├── 📄 Chart.yaml          # Chart metadata
│       ├── 📄 values.yaml         # Default values
│       └── 📁 templates/          # Kubernetes manifests
│           ├── 📄 deployment.yaml
│           ├── 📄 service.yaml
│           ├── 📄 ingress.yaml
│           ├── 📄 hpa.yaml
│           └── 📄 _helpers.tpl
├── 📁 proto/                      # Protocol buffers
│   ├── 📄 buf.yaml               # Buf configuration
│   ├── 📄 buf.gen.yaml           # Code generation config
│   └── 📁 api/                   # .proto files
│       └── 📄 grpc_service.proto
├── 📁 cmd/                       # Go application entry points
│   └── 📁 server/                # gRPC server
│       └── 📄 main.go
├── 📁 internal/                  # Internal Go packages
│   └── 📁 server/                # Service implementation
│       ├── 📄 grpc_service.go
│       └── 📄 grpc_service_test.go
├── 📄 skaffold.yaml              # Skaffold configuration
├── 📄 Dockerfile                 # Production Docker build
├── 📄 Dockerfile.dev             # Development Docker build
├── 📄 .air.toml                  # Hot reload configuration
├── 📄 Makefile                   # Build and deployment commands
├── 📄 go.mod                     # Go module dependencies
├── 📄 .golangci.yml              # Linting configuration
├── 📄 .gitignore                 # Git ignore rules
├── 📁 .github/workflows/         # CI/CD pipelines
│   └── 📄 ci.yml
├── 📁 scripts/                   # Helper scripts
│   └── 📄 quickstart.sh
└── 📄 README.md                  # This file
```

## 🛠️ Development

### 🔄 Development Workflow

```bash
# Start development with hot reload
make dev

# This will:
# 1. Generate protobuf code with Buf
# 2. Build Docker image
# 3. Deploy to local/remote K8s cluster
# 4. Start Skaffold dev loop with file watching
# 5. Port forward services locally
```

### 🧪 Testing

```bash
# Run unit tests
make test

# Run tests with coverage
make test-coverage

# Run integration tests
make test-integration

# Run e2e tests
make test-e2e

# Run all checks (setup, generate, build, test, lint)
make all
```

### 🔍 Code Quality

```bash
# Run linters
make lint

# Format code
make fmt

# Check for security issues
make security-scan

# Run all quality checks
make quality
```

### 📦 Building

```bash
# Build application
make build

# Build Docker image
make docker-build

# Push to registry
make docker-push

# Generate protobuf code
make generate
```

## 🚀 Deployment

### 🌍 Environment Configuration

The project supports multiple environments with different configurations:

#### Development Environment
```bash
# Use development profile
skaffold dev --profile=dev

# Features:
# - Single replica
# - No autoscaling
# - Hot reload enabled
# - Local port forwarding
```

#### Staging Environment
```bash
# Deploy to staging
skaffold run --profile=staging

# Features:
# - 3 replicas
# - Autoscaling enabled
# - Ingress enabled
# - Production-like configuration
```

#### Production Environment
```bash
# Deploy to production
skaffold run --profile=prod

# Features:
# - 5+ replicas
# - Autoscaling enabled
# - Ingress with TLS
# - Higher resource limits
# - Security policies
```

### 🏗️ Infrastructure Deployment

```bash
# Deploy infrastructure
make deploy

# Or manually
cd infrastructure
pulumi up --yes

# Destroy infrastructure
make destroy
```

### 📊 Deployment Status

```bash
# Check deployment status
kubectl get pods
kubectl get services
kubectl get ingress

# View logs
kubectl logs -f deployment/grpc-service

# Check resource usage
kubectl top pods
kubectl top nodes
```

## 📊 Monitoring & Observability

### 🔍 Health Checks

The application exposes multiple health check endpoints:

| Endpoint | Type | Purpose |
|----------|------|---------|
| `/health` | HTTP | Basic health status |
| `/ready` | HTTP | Readiness probe |
| `/metrics` | HTTP | Prometheus metrics |
| `grpc.health.v1.Health/Check` | gRPC | gRPC health check |

### 📈 Metrics

Prometheus metrics are exposed at `/metrics`:

```bash
# View metrics
curl http://localhost:8080/metrics

# Key metrics:
# - grpc_server_started_total
# - grpc_server_msg_received_total
# - grpc_server_msg_sent_total
# - grpc_server_handled_total
# - process_cpu_seconds_total
# - process_resident_memory_bytes
```

### 📝 Logging

Structured JSON logging with logrus:

```json
{
  "level": "info",
  "msg": "GetHealth called",
  "time": "2024-01-15T10:30:00Z"
}
```

### 🔍 Distributed Tracing

Ready for OpenTelemetry integration:

```go
// Example tracing setup
import (
    "go.opentelemetry.io/otel"
    "go.opentelemetry.io/otel/trace"
)

func (s *GrpcService) GetHealth(ctx context.Context, req *connect.Request[apiv1.GetHealthRequest]) (*connect.Response[apiv1.GetHealthResponse], error) {
    ctx, span := otel.Tracer("").Start(ctx, "GetHealth")
    defer span.End()
    // ... implementation
}
```

## 🔒 Security

### 🔐 Authentication & Authorization

- **Workload Identity**: GKE-native service account authentication
- **RBAC**: Kubernetes role-based access control
- **Network Policies**: Pod-to-pod communication rules
- **Secrets Management**: Kubernetes secrets with encryption

### 🛡️ Network Security

```yaml
# Example NetworkPolicy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: grpc-service-network-policy
spec:
  podSelector:
    matchLabels:
      app: grpc-service
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    ports:
    - protocol: TCP
      port: 9090
```

### 🔒 Container Security

- **Non-root user**: Application runs as non-root
- **Read-only filesystem**: Container filesystem is read-only
- **Security context**: Proper security context configuration
- **Image scanning**: Trivy vulnerability scanning in CI/CD

### 🔐 Secrets Management

```bash
# Create secrets
kubectl create secret generic app-secrets \
  --from-literal=api-key=your-api-key \
  --from-literal=db-password=your-db-password

# Use in deployment
env:
- name: API_KEY
  valueFrom:
    secretKeyRef:
      name: app-secrets
      key: api-key
```

## 📈 Scaling

### 🔄 Horizontal Pod Autoscaling

Automatic scaling based on CPU and memory usage:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: grpc-service
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: grpc-service
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 80
```

### 📊 Vertical Pod Autoscaling

Automatic resource request adjustment:

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: grpc-service-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: grpc-service
  updatePolicy:
    updateMode: "Auto"
```

### 🏗️ Cluster Autoscaling

GKE cluster autoscaler for node scaling:

```yaml
# Node pool with autoscaling
autoscaling:
  enabled: true
  minNodeCount: 1
  maxNodeCount: 10
```

## 🔄 CI/CD

### 🚀 GitHub Actions Pipeline

Complete CI/CD pipeline with multiple stages:

1. **Test Stage**
   - Code linting with golangci-lint
   - Unit tests with coverage
   - Protocol buffer validation
   - Security scanning

2. **Build Stage**
   - Docker image building
   - Image vulnerability scanning
   - Push to container registry

3. **Deploy Stages**
   - Development deployment (on develop branch)
   - Staging deployment (on main branch)
   - Production deployment (manual approval)

### 🔍 Pipeline Features

- **Automated testing** on every PR
- **Security scanning** with Trivy
- **Infrastructure drift detection**
- **Rollback capabilities**
- **Environment promotion**
- **Smoke tests** after deployment

### 📊 Pipeline Status

```bash
# Check pipeline status
gh run list

# View pipeline logs
gh run view <run-id>

# Rerun failed pipeline
gh run rerun <run-id>
```

## 📚 API Documentation

### 🔌 gRPC Services

The application provides the following gRPC services:

#### Health Service
```protobuf
service GrpcService {
  rpc GetHealth(GetHealthRequest) returns (GetHealthResponse);
  rpc GetInfo(GetInfoRequest) returns (GetInfoResponse);
  rpc ProcessData(ProcessDataRequest) returns (ProcessDataResponse);
  rpc StreamData(StreamDataRequest) returns (stream StreamDataResponse);
}
```

#### Example Usage

```go
// Connect to the service
client := apiv1connect.NewGrpcServiceClient(
    http.DefaultClient,
    "https://your-domain.com",
)

// Call health check
resp, err := client.GetHealth(context.Background(), connect.NewRequest(&apiv1.GetHealthRequest{}))
if err != nil {
    log.Fatal(err)
}
fmt.Printf("Status: %s\n", resp.Msg.Status)
```

### 🌐 REST API

HTTP endpoints are automatically generated from gRPC services:

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/v1/health` | Health check |
| GET | `/v1/info` | Service information |
| POST | `/v1/data` | Process data |
| GET | `/v1/stream` | Stream data |

### 📖 Interactive Documentation

Access interactive API documentation:

```bash
# Start development server
make dev

# Access gRPC reflection
grpcurl -plaintext localhost:9090 list

# Access REST API docs
open http://localhost:9090/docs
```

## 🤝 Contributing

We welcome contributions! Please follow these steps:

### 🚀 Getting Started

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Make your changes**
4. **Add tests** for new functionality
5. **Run all checks**
   ```bash
   make all
   ```
6. **Submit a pull request**

### 📋 Development Guidelines

- **Code Style**: Follow Go conventions and use `gofmt`
- **Testing**: Maintain >80% test coverage
- **Documentation**: Update docs for new features
- **Commits**: Use conventional commit messages
- **Reviews**: All PRs require review

### 🐛 Bug Reports

When reporting bugs, please include:

- **Environment**: OS, Go version, tool versions
- **Steps to reproduce**: Clear, step-by-step instructions
- **Expected behavior**: What you expected to happen
- **Actual behavior**: What actually happened
- **Logs**: Relevant error messages and logs

### 💡 Feature Requests

For feature requests:

- **Describe the feature**: Clear description of what you want
- **Use case**: Why this feature is needed
- **Implementation ideas**: Any thoughts on how to implement
- **Priority**: How important this feature is

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Pulumi](https://www.pulumi.com/) for Infrastructure as Code
- [Skaffold](https://skaffold.dev/) for development workflow
- [Buf](https://buf.build/) for protocol buffer tooling
- [ConnectRPC](https://connectrpc.com/) for modern gRPC
- [Helm](https://helm.sh/) for Kubernetes package management

## 📞 Support

- **Documentation**: [DEPLOYMENT.md](DEPLOYMENT.md)
- **Issues**: [GitHub Issues](https://github.com/your-org/golang-grpc-gke/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-org/golang-grpc-gke/discussions)
- **Email**: your-email@example.com

---

<div align="center">

**Made with ❤️ for the Go and Kubernetes community**

[![Go](https://img.shields.io/badge/Go-00ADD8?style=for-the-badge&logo=go&logoColor=white)](https://golang.org/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Google Cloud](https://img.shields.io/badge/Google_Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)](https://cloud.google.com/)

</div>
