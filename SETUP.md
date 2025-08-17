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

### 4. Install Google Cloud SDK (gcloud)

#### Option 1: Using Homebrew (Recommended)
```bash
# Install Homebrew if you don't have it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Google Cloud SDK
brew install --cask google-cloud-sdk
```

#### Option 2: Manual Installation
```bash
# Download and install the SDK
curl https://sdk.cloud.google.com | bash

# Restart your shell or run
exec -l $SHELL

# Initialize gcloud
gcloud init
```

#### Option 3: Using the Official Installer
1. Visit [Google Cloud SDK Download Page](https://cloud.google.com/sdk/docs/install)
2. Download the macOS installer
3. Run the installer and follow the prompts

### 5. Configure GCP
```bash
# Login to GCP
gcloud auth login

# Set your project
gcloud config set project YOUR_PROJECT_ID

# Enable required APIs
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable dns.googleapis.com
# Note: cloudbuild.googleapis.com is NOT enabled to avoid costs
# The project uses local Docker builds instead of Google Cloud Build
```

### 6. Set Up Local Configuration (RECOMMENDED)

For **local development**, use local configuration instead of GitHub Secrets:

```bash
# Run the local configuration setup script
./scripts/setup-local-config.sh
```

This will create:
- `.env` file with your local settings
- `helm/grpc-service/values.local.yaml` for local Helm overrides
- `~/.config/golang-grpc-bootstrap/config.env` for shell integration
- Pulumi configuration for infrastructure

**Benefits:**
- ✅ **No secrets in repo** - sensitive data stays local
- ✅ **Easy to manage** - simple environment variables
- ✅ **Development-friendly** - fast iteration
- ✅ **Secure** - credentials never leave your machine

### 6b. GitHub Secrets (Alternative for CI/CD)

If you need CI/CD with GitHub Actions, go to your repository Settings → Secrets and add:
- `GCP_PROJECT_ID`: Your GCP project ID

## 🔐 **Local Configuration Management**

### **Local Configuration (RECOMMENDED)** ⭐

**Best for**: Local development and testing

#### **Method 1: Environment Variables (Simplest)**

Create a local `.env` file (NOT in repo):

```bash
# Create .env file (add to .gitignore)
cat > .env << EOF
GCP_PROJECT_ID=your-project-id
GCP_REGION=us-central1
DOMAIN_NAME=your-domain.com
DOCKER_REGISTRY=gcr.io
EOF

# Load in your shell
source .env
```

#### **Method 2: Local Config Directory**

Create a local config directory:

```bash
# Create local config directory
mkdir -p ~/.config/golang-grpc-bootstrap

# Store configuration
cat > ~/.config/golang-grpc-bootstrap/config.env << EOF
GCP_PROJECT_ID=your-project-id
GCP_REGION=us-central1
DOMAIN_NAME=your-domain.com
DOCKER_REGISTRY=gcr.io
EOF

# Load in your shell
source ~/.config/golang-grpc-bootstrap/config.env
```

#### **Method 3: Shell Profile Integration**

Add to your `~/.zshrc` or `~/.bashrc`:

```bash
# Add to your shell profile
echo 'export GCP_PROJECT_ID="your-project-id"' >> ~/.zshrc
echo 'export GCP_REGION="us-central1"' >> ~/.zshrc
echo 'export DOMAIN_NAME="your-domain.com"' >> ~/.zshrc

# Reload shell
source ~/.zshrc
```

#### **Method 4: Infrastructure Configuration**

Store infrastructure settings locally:

```bash
# Create infrastructure configuration
mkdir -p infrastructure
cat > infrastructure/config.env << EOF
CLUSTER_NAME=grpc-cluster-dev
ZONE_NAME=grpc-zone
IP_NAME=grpc-external-ip
EOF
```

#### **Method 5: Local Helm Values**

Create local Helm values override:

```bash
# Create local values file (add to .gitignore)
cat > helm/grpc-service/values.local.yaml << EOF
# Local development overrides
replicaCount: 1
resources:
  limits:
    cpu: 200m
    memory: 256Mi
  requests:
    cpu: 50m
    memory: 64Mi

# Local-specific settings
image:
  repository: localhost:5000/test-backend
  tag: "latest"
EOF

# Use with Helm
helm install my-app ./helm/grpc-service -f values.local.yaml
```

### **Local Development Setup (No Secrets Needed)**

For **completely local development**:

```bash
# 1. Set up local environment
export GCP_PROJECT_ID="your-project-id"
export GCP_REGION="us-central1"

# 2. Use local authentication
gcloud auth application-default login
gcloud config set project $GCP_PROJECT_ID

# 3. Use local Docker builds
make dev  # Uses local Docker, no cloud costs

# 4. Use local Kubernetes (optional)
minikube start  # Free local cluster
kind create cluster  # Free local cluster
```

### **Benefits of Local Configuration:**

- ✅ **No secrets in repo** - sensitive data stays local
- ✅ **Easy to manage** - simple environment variables
- ✅ **Development-friendly** - fast iteration
- ✅ **Secure** - credentials never leave your machine
- ✅ **Flexible** - different configs for different environments
- ✅ **Version control safe** - no accidental commits

### **Security Best Practices for Local Config:**

1. **Never commit sensitive files**:
   ```bash
   # Add to .gitignore
   echo ".env" >> .gitignore
   echo "*.local.yaml" >> .gitignore
   echo "~/.config/golang-grpc-bootstrap/" >> .gitignore
   ```

2. **Use environment-specific files**:
   ```bash
   .env.dev      # Development settings
   .env.staging  # Staging settings  
   .env.prod     # Production settings
   ```

3. **Rotate credentials regularly**:
   ```bash
   # Refresh gcloud credentials
   gcloud auth application-default login
   ```

4. **Use least privilege**:
   ```bash
   # Create development-only service account
   gcloud iam service-accounts create dev-user \
     --display-name="Development User"
   ```

### 7. Deploy Infrastructure
```bash
# Deploy infrastructure using gcloud
make deploy-infrastructure

# Or deploy manually
./scripts/deploy-infrastructure.sh
```

### 8. Deploy Application
```bash
# Deploy application using Skaffold
make deploy-dev
```

## 💰 Cost Considerations

### Free Setup (Current Configuration)
This project is configured to use **local Docker builds** to avoid costs:
- ✅ **No Cloud Build charges** - builds run locally
- ✅ **No image storage costs** - images built locally
- ⚠️ **Requires Docker Desktop** or Docker daemon running locally
- ⚠️ **Slower builds** - depends on your local machine

### If You Want Cloud Build (Optional)
If you prefer faster cloud builds and don't mind the cost:

1. **Enable Cloud Build API:**
   ```bash
   gcloud services enable cloudbuild.googleapis.com
   ```

2. **Update skaffold.yaml:**
   ```yaml
   build:
     googleCloudBuild:
       projectId: your-project-id
   ```

3. **Costs:**
   - Free tier: 120 build-minutes/day
   - After free tier: ~$0.003/minute
   - Storage: ~$0.026/GB/month

### Current Free Configuration
The project is set up to be **completely free** for development and testing. You only pay for:
- GKE cluster (if you deploy to production)
- Load balancer (if you deploy to production)
- DNS (if you use Cloud DNS)

## 💰 **Complete Cost Optimization Guide**

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
cd infrastructure
pulumi config set environment prod
pulumi up --yes

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
cd infrastructure
pulumi destroy --yes

# Or just scale down
kubectl scale deployment --replicas=0 --all
```

## 🔧 Development Workflow

### Local Development
```
```