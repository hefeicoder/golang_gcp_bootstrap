# 🚀 Modern Go gRPC Backend Bootstrap

> **A production-ready Go gRPC backend template for GKE deployment with interactive web demo**

This is a **bootstrap project** designed to be forked and customized for your own backend services. It provides a complete, modern Go gRPC stack with infrastructure as code, Kubernetes deployment, CI/CD pipeline, and an interactive web demo interface.

## 🎯 Quick Start

### 1. **Fork and Clone**
**⚠️ Important:** After forking, you MUST run the customization script before doing anything else!
```bash
# Click "Fork" button on GitHub, then clone your fork
git clone https://github.com/hefeicoder/golang_gcp_bootstrap.git
cd golang_gcp_bootstrap

# Or clone with a custom name:
# git clone https://github.com/hefeicoder/golang_gcp_bootstrap.git my-custom-name
# cd my-custom-name
```

### 2. **Customize the Project (REQUIRED)**
```bash
# IMPORTANT: Run this BEFORE doing anything else!
# This updates all import paths and configurations for your specific project
./scripts/customize.sh
```

**⚠️ Critical:** You MUST run the customization script immediately after forking. The project contains hardcoded paths that will break if you try to use it without customization.

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

### 4. **Install Google Cloud SDK (gcloud)**

```bash
# Install Homebrew if you don't have it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Google Cloud SDK
brew install --cask google-cloud-sdk
```

### 5. **Configure GCP**

**IMPORTANT**: Authentication is required for all GCP operations.

```bash
# Authenticate with Google Cloud
gcloud auth application-default login

# Set your project
gcloud config set project YOUR_PROJECT_ID

# Enable required APIs
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable dns.googleapis.com
# Note: cloudbuild.googleapis.com is NOT enabled to avoid costs
# The project uses local Docker builds instead of Google Cloud Build
```

**Authentication Process:**
- Follow the URL provided in the terminal to complete authentication
- Make sure to consent to all required scopes when prompted
- This method works reliably in all environments

### 6. **Set Up Local Configuration (RECOMMENDED)**

For **local development**, use local configuration instead of GitHub Secrets:

```bash
# Run the local configuration setup script
./scripts/setup-local-config.sh
```

This will create:
- `.env` file with your local settings
- `helm/grpc-service/values.local.yaml` for local Helm overrides
- `~/.config/golang-grpc-bootstrap/config.env` for shell integration
- `infrastructure/config.env` for infrastructure settings

**Benefits:**
- ✅ **No secrets in repo** - sensitive data stays local
- ✅ **Easy to manage** - simple environment variables
- ✅ **Development-friendly** - fast iteration
- ✅ **Secure** - credentials never leave your machine

### 7. **Deploy to GKE**
```bash
# Deploy infrastructure and application
make deploy-infrastructure  # Deploy GKE cluster
make deploy-dev            # Deploy application
```

### 8. **Test Your Deployment**
```bash
# Run end-to-end tests
make test-e2e

# Access the web demo
# Get your service URL
kubectl get service example-backend-grpc-service

# Open in browser (replace with your actual NodePort URL)
open http://34.45.81.145:30951/
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
| **Infrastructure** | gcloud scripts | Infrastructure deployment |
| **Container Orchestration** | GKE | Kubernetes cluster |
| **Package Management** | Helm | Kubernetes manifests |
| **Development** | Skaffold | Local-to-GKE development loop |
| **CI/CD** | GitHub Actions | Automated testing and deployment |
| **Monitoring** | Prometheus + Cloud Logging | Observability |
| **Security** | Trivy | Vulnerability scanning |
| **Web Demo** | HTML + JavaScript | Interactive API testing interface |

## 🌐 Web Demo Interface

The project includes an **interactive web demo** that allows you to test your gRPC service directly from a browser. This provides a user-friendly way to verify your deployment and showcase your API.

### **Features:**
- 🎲 **Random Number Generator** - Test the ProcessData endpoint
- 🏥 **Health Check** - Verify service health status
- ℹ️ **Service Information** - Get detailed service metadata
- 🔄 **Complete Test Suite** - Run all endpoints at once

### **Access the Demo:**
```bash
# Deploy your service
make deploy-dev

# Get your service URL
kubectl get service example-backend-grpc-service

# Open in browser (replace with your actual NodePort URL)
open http://34.45.81.145:30951/
```

### **How It Works:**
- **Single Server**: HTML page and gRPC API served from the same container
- **No CORS Issues**: Same origin for frontend and backend
- **Path-Based Routing**: 
  - `/` → HTML demo page
  - `/api.v1.GrpcService/*` → gRPC endpoints
  - `/health`, `/ready` → Health checks
- **Connect Protocol**: gRPC over HTTP/1.1 for browser compatibility

## 🚀 Deployment Commands

### **Deployment Commands Comparison**

| Command | Hot Reload | Ingress | Target | Purpose | Cost |
|---------|------------|---------|--------|---------|------|
| `make dev` | ✅ Yes | ❌ No | GCP | Development with live updates | ~$6/month |
| `make deploy-dev` | ❌ No | ❌ No | GCP | One-time deployment | ~$6/month |
| `make deploy-prod` | ❌ No | ✅ Yes | GCP | Production with external access | ~$24/month |

### **Development Deployment**
```bash
make deploy-dev
```

### **Production Deployment**
```bash
make deploy-prod
```

### **Testing**
```bash
make test-e2e
```

### **Local Development (RECOMMENDED)**
```bash
# Start development with hot reload
make dev

# This will:
# 1. Build Docker image locally (no cloud costs)
# 2. Deploy to local/remote cluster
# 3. Start file watching for hot reload
# 4. Port forward services locally
```

### **Benefits of Local Development**
- ✅ **No cloud costs** - everything runs locally
- ✅ **Fast iteration** - no upload/download time
- ✅ **Secure** - credentials never leave your machine
- ✅ **Offline capable** - works without internet
- ✅ **Easy debugging** - direct access to logs and services

## 💰 Cost Optimization

### **Current Cost-Optimized Configuration**

This project has been **pre-configured for minimal costs**:

#### **1. GKE Cluster Optimizations** ✅
- **Machine Type**: `e2-micro` (FREE in GCP free tier! vs $52/month for e2-standard-2)
- **Node Count**: 1 node (down from 3 = saves ~$156/month)
- **Disk Size**: 20GB (down from 50GB = saves ~$0.60/month)
- **Max Autoscaling**: 3 nodes (down from 10 = prevents runaway costs)

#### **2. Application Optimizations** ✅
- **Replicas**: 1 (down from 3 = saves resources)
- **CPU Limits**: 500m (down from 1000m = fits on e2-micro)
- **Memory Limits**: 512Mi (down from 1Gi = fits on e2-micro)
- **Autoscaling**: Disabled (prevents unexpected scaling costs)

#### **3. Infrastructure Optimizations** ✅
- **Load Balancer**: Disabled by default (saves ~$25/month)
- **Ingress**: Disabled (no external traffic costs)
- **Local Builds**: No Cloud Build costs
- **Local Registry**: No GCR storage costs

### **Cost Breakdown (Optimized vs Original)**

| Component | Original Cost | Optimized Cost | Savings |
|-----------|---------------|----------------|---------|
| **GKE Nodes** | ~$156/month (3×e2-standard-2) | $0/month (1×e2-micro = FREE!) | **$156/month** |
| **Load Balancer** | ~$25/month | $0/month (disabled) | **$25/month** |
| **Cloud Build** | ~$10-50/month | $0/month (local) | **$10-50/month** |
| **GCR Storage** | ~$5-20/month | $0/month (local) | **$5-20/month** |
| **DNS Zone** | ~$0.40/month | ~$0.40/month | $0 |
| **SSL Certificate** | $0/month | $0/month | $0 |
| **Total** | **~$196-251/month** | **~$0.40/month** | **$196-251/month** |

### **GCP Free Tier Details** 🎉

**Great news!** This project is now **completely FREE** to run in production thanks to GCP's free tier:

- ✅ **1 e2-micro instance**: FREE forever
- ✅ **1 GKE cluster**: FREE (includes the e2-micro node)
- ✅ **Cloud DNS**: 1 zone FREE
- ✅ **SSL Certificates**: FREE
- ✅ **Cloud Build**: 120 minutes/day FREE
- ✅ **Container Registry**: 0.5GB storage FREE

**Only cost**: ~$0.40/month for DNS zone (after free tier)

### **Free Development Setup**

For **completely free development**, use local tools:

```bash
# Local development (FREE)
make dev          # Uses local Docker, no cloud costs
make test         # Runs locally
make build        # Builds locally

# Local Kubernetes (FREE with minikube/kind)
minikube start    # Free local cluster
kind create cluster # Free local cluster
```

### **Production Cost Optimization**

If you need production deployment, use these settings:

```bash
# Deploy with cost optimizations
make deploy-infrastructure

# The cluster will use:
# - e2-micro machines (FREE in GCP free tier!)
# - 1-3 nodes only
# - Minimal resources
```

### **Monitoring Costs**

```bash
# Check your GCP billing
gcloud billing accounts list
gcloud billing projects describe YOUR_PROJECT_ID

# Monitor resource usage
kubectl top nodes
kubectl top pods
```

### **Cost Alerts Setup**

1. **Set up billing alerts** in GCP Console
2. **Set budget limits** (e.g., $10/month)
3. **Monitor usage** regularly

### **Emergency Cost Control**

If costs get out of control:

```bash
# Stop all resources
make cleanup-infrastructure

# Or just scale down
kubectl scale deployment --replicas=0 --all
```

## 🔧 Development Workflow

### **Testing**

```bash
# Run all tests
make test

# Run tests with coverage
make test-coverage

# Run linters
make lint

# Run all checks
make all

# Run end-to-end tests
make test-e2e
```

### **Building and Pushing**

```bash
# Build Docker image
make docker-build

# Push to registry
make docker-push
```

### **Environment Configuration**

```bash
# Development environment
skaffold dev --profile=dev

# Staging environment
skaffold run --profile=staging

# Production environment
skaffold run --profile=prod
```

## 🔍 Monitoring and Observability

### **Health Checks**

The application exposes health check endpoints:

- **gRPC Health**: `grpc://your-domain.com:9090/grpc.health.v1.Health/Check`
- **HTTP Health**: `http://your-domain.com:8080/health`
- **Readiness**: `http://your-domain.com:8080/ready`
- **Metrics**: `http://your-domain.com:8080/metrics`

### **Logs**

```bash
# View application logs
kubectl logs -f deployment/grpc-service

# View logs from specific pod
kubectl logs -f pod/grpc-service-xxxxx
```

### **Metrics**

The application exposes Prometheus metrics at `/metrics`. You can:

1. Set up Prometheus to scrape these metrics
2. Use Grafana for visualization
3. Set up alerting rules

## 🛠️ Troubleshooting

### **Common Issues**

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

#### 4. Web Demo Not Working

```bash
# Check if the service is running
kubectl get pods

# Check service URL
kubectl get service example-backend-grpc-service

# Test the endpoint directly
curl http://34.45.81.145:30951/
```

### **Debugging Commands**

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

## 🔐 Security Considerations

### **Network Policies**

The deployment includes network policies to restrict pod-to-pod communication. Review and adjust as needed:

```bash
# View network policies
kubectl get networkpolicies

# Apply custom policies
kubectl apply -f k8s/network-policies/
```

### **RBAC**

The application uses a dedicated ServiceAccount with minimal permissions:

```bash
# Check RBAC
kubectl get serviceaccounts
kubectl get roles
kubectl get rolebindings
```

### **Secrets Management**

For production, use Kubernetes secrets or external secret management:

```bash
# Create secrets
kubectl create secret generic app-secrets \
  --from-literal=api-key=your-api-key \
  --from-literal=db-password=your-db-password
```

## 📈 Scaling

### **Horizontal Pod Autoscaling**

The deployment includes HPA for automatic scaling:

```bash
# Check HPA status
kubectl get hpa

# View HPA details
kubectl describe hpa grpc-service
```

### **Manual Scaling**

```bash
# Scale manually
kubectl scale deployment grpc-service --replicas=5

# Or via Helm
helm upgrade grpc-service helm/grpc-service --set replicaCount=5
```

## 🔄 Backup and Recovery

### **Backup Strategy**

1. **Application Data**: Use persistent volumes with regular snapshots
2. **Configuration**: Store in Git with version control
3. **Infrastructure**: Infrastructure scripts are versioned and backed up

### **Recovery Procedures**

```bash
# Restore from backup
kubectl apply -f backup/

# Recreate infrastructure
make deploy-infrastructure

# Redeploy application
skaffold run --profile=prod
```

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
- After customization: `github.com/yourusername/your-project`

### **What Gets Customized:**

| **Component** | **Before** | **After** |
|---------------|------------|-----------|
| **Go Module** | `github.com/hefeicoder/golang-grpc-gke` | `github.com/yourusername/your-project` |
| **Service Name** | `grpc-service` | `your-service-name` |
| **Docker Image** | `gcr.io/project/grpc-service` | `gcr.io/yourproject/your-service` |
| **Kubernetes** | `grpc-service` | `your-service-name` |
| **Helm Chart** | `grpc-service` | `your-service-name` |
| **Domain** | `grpc.example.com` | `your-domain.com` |

## 🚀 Next Steps

After successful deployment:

1. **Set up monitoring and alerting**
2. **Configure CI/CD pipelines**
3. **Implement backup strategies**
4. **Set up cost monitoring**
5. **Plan for disaster recovery**
6. **Document runbooks for common operations**
7. **Customize the web demo for your specific API**
8. **Add authentication and authorization**
9. **Implement rate limiting**
10. **Set up logging aggregation**

## 📚 Additional Resources

- [Go Documentation](https://golang.org/doc/)
- [gRPC Documentation](https://grpc.io/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Google Cloud Documentation](https://cloud.google.com/docs/)
- [Buf Documentation](https://docs.buf.build/)
- [Connect Documentation](https://connect.build/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For issues and questions:

1. Check the troubleshooting section above
2. Review logs and metrics
3. Check [GitHub Issues](https://github.com/hefeicoder/golang_gcp_bootstrap/issues)
4. Contact the development team

---

**Happy coding! 🚀**
