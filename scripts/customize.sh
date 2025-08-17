#!/bin/bash

# 🚀 Go gRPC Bootstrap Customization Script
# This script helps you customize the bootstrap project for your own use

set -e

echo "🚀 Go gRPC Bootstrap Customization"
echo "=================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if running in the right directory
if [ ! -f "go.mod" ] || [ ! -f "Makefile" ]; then
    print_error "This script must be run from the project root directory"
    exit 1
fi

# Get user input
echo "Please provide the following information to customize your project:"
echo ""

echo "📝 Project Information:"
echo "   Project name will be used for:"
echo "   • Docker image names"
echo "   • Kubernetes service names"
echo "   • Infrastructure resource names"
echo "   • Helm chart names"
read -p "Enter your project name (e.g., my-backend): " PROJECT_NAME
read -p "Enter your domain name (e.g., api.mycompany.com): " DOMAIN_NAME

echo ""
echo "🔧 Infrastructure Configuration:"
read -p "Enter your GCP project ID: " GCP_PROJECT_ID
read -p "Enter your Docker registry (e.g., gcr.io): " DOCKER_REGISTRY

echo ""
echo "📦 Go Module Configuration:"
echo "   Go modules use paths like: github.com/USERNAME/REPOSITORY_NAME"
echo "   This affects import statements and module resolution"
echo "   Note: Repository name can be different from project name"
read -p "Enter your GitHub username/organization: " GITHUB_USER
read -p "Enter your GitHub repository name: " REPO_NAME

# Handle case where user enters full repository path for username
if [[ "$GITHUB_USER" == *"/"* ]]; then
    # Extract username from full path (e.g., "hefeicoder/golang_gcp_bootstrap" -> "hefeicoder")
    GITHUB_USER=$(echo "$GITHUB_USER" | cut -d'/' -f1)
    print_info "Extracted GitHub username: $GITHUB_USER"
fi

# Handle case where user enters full repository path for repo name
if [[ "$REPO_NAME" == *"/"* ]]; then
    # Extract repo name from full path (e.g., "hefeicoder/golang_gcp_bootstrap" -> "golang_gcp_bootstrap")
    REPO_NAME=$(echo "$REPO_NAME" | cut -d'/' -f2)
    print_info "Extracted repository name: $REPO_NAME"
fi

# Validate inputs
if [ -z "$GITHUB_USER" ] || [ -z "$REPO_NAME" ] || [ -z "$PROJECT_NAME" ] || [ -z "$DOMAIN_NAME" ] || [ -z "$GCP_PROJECT_ID" ] || [ -z "$DOCKER_REGISTRY" ]; then
    print_error "All fields are required!"
    exit 1
fi

# Convert project name to Buf-compatible format (no underscores)
BUF_PROJECT_NAME=$(echo "$PROJECT_NAME" | sed 's/_/-/g')

echo ""
print_info "Customizing project with the following values:"
echo "  📦 Go Module: github.com/$GITHUB_USER/$REPO_NAME"
echo "  🏷️  Project Name: $PROJECT_NAME"
echo "  📁 Repository Name: $REPO_NAME"
echo "  🌐 Domain Name: $DOMAIN_NAME"
echo "  ☁️  GCP Project ID: $GCP_PROJECT_ID"
echo "  🐳 Docker Registry: $DOCKER_REGISTRY"
echo "  📋 Buf Module: buf.build/$GITHUB_USER/$BUF_PROJECT_NAME"
echo ""
print_info "This will update:"
echo "  • Go module path and import statements"
echo "  • Protocol buffer package names"
echo "  • Docker image names"
echo "  • Kubernetes service names"
echo "  • CI/CD configuration"
echo ""

read -p "Continue with these values? (y/N): " CONFIRM
if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    print_warning "Customization cancelled"
    exit 0
fi

echo ""
print_info "Starting customization..."



# Update go.mod
print_status "Updating go.mod with repository name '$REPO_NAME'..."
sed -i.bak "s|github.com/hefeicoder/golang-grpc-gke|github.com/$GITHUB_USER/$REPO_NAME|g" go.mod
sed -i.bak "s|github.com/hefeicoder/golang-grpc-gke/gen|github.com/$GITHUB_USER/$REPO_NAME/gen|g" go.mod

# Update proto files
print_status "Updating protocol buffer files with repository name '$REPO_NAME'..."
sed -i.bak "s|github.com/hefeicoder/golang-grpc-gke/gen|github.com/$GITHUB_USER/$REPO_NAME/gen|g" proto/api/grpc_service.proto
sed -i.bak "s|buf.build/hefeicoder/golang-grpc-gke|buf.build/$GITHUB_USER/$BUF_PROJECT_NAME|g" proto/buf.yaml
sed -i.bak "s|github.com/hefeicoder/golang-grpc-gke/gen|github.com/$GITHUB_USER/$REPO_NAME/gen|g" proto/buf.gen.yaml

# Update Go source files
print_status "Updating Go source files with repository name '$REPO_NAME'..."
find . -name "*.go" -type f -exec sed -i.bak "s|github.com/hefeicoder/golang-grpc-gke|github.com/$GITHUB_USER/$REPO_NAME|g" {} \;

# Update infrastructure files
print_status "Updating infrastructure configuration with project name '$PROJECT_NAME'..."
if [ -f infrastructure/config.env ]; then
    sed -i.bak "s|golang-grpc-gke|$PROJECT_NAME|g" infrastructure/config.env
fi

# Update Helm values
print_status "Updating Helm configuration with project name '$PROJECT_NAME'..."
sed -i.bak "s|grpc-service|$PROJECT_NAME|g" helm/grpc-service/values.yaml
sed -i.bak "s|your-domain.com|$DOMAIN_NAME|g" helm/grpc-service/values.yaml

# Update CI/CD workflow
print_status "Updating CI/CD configuration with repository name '$REPO_NAME'..."
sed -i.bak "s|hefeicoder/golang_gcp_bootstrap|$GITHUB_USER/$REPO_NAME|g" .github/workflows/ci.yml
sed -i.bak "s|GCP_PROJECT_ID|$GCP_PROJECT_ID|g" .github/workflows/ci.yml
sed -i.bak "s|gcr.io|$DOCKER_REGISTRY|g" .github/workflows/ci.yml

# Update Chart.yaml
print_status "Updating Helm Chart configuration with repository name '$REPO_NAME'..."
sed -i.bak "s|hefeicoder/golang_gcp_bootstrap|$GITHUB_USER/$REPO_NAME|g" helm/grpc-service/Chart.yaml
sed -i.bak "s|Your Name|$GITHUB_USER|g" helm/grpc-service/Chart.yaml
sed -i.bak "s|your-email@example.com||g" helm/grpc-service/Chart.yaml

# Update golangci-lint configuration
print_status "Updating golangci-lint configuration with repository name '$REPO_NAME'..."
sed -i.bak "s|hefeicoder/golang_gcp_bootstrap|$GITHUB_USER/$REPO_NAME|g" .golangci.yml

# Update deployment documentation
print_status "Updating deployment documentation with project name '$PROJECT_NAME'..."
sed -i.bak "s|golang-grpc-gke|$PROJECT_NAME|g" DEPLOYMENT.md

# Update Docker files
print_status "Updating Docker configuration with project name '$PROJECT_NAME'..."
sed -i.bak "s|grpc-service|$PROJECT_NAME|g" Dockerfile
sed -i.bak "s|grpc-service|$PROJECT_NAME|g" Dockerfile.dev

# Update Skaffold configuration
print_status "Updating Skaffold configuration with project name '$PROJECT_NAME'..."
sed -i.bak "s|test-backend|$PROJECT_NAME|g" skaffold.yaml

# Update Makefile
print_status "Updating Makefile with project name '$PROJECT_NAME'..."
sed -i.bak "s|test-backend|$PROJECT_NAME|g" Makefile

# Clean up temporary .bak files created by sed
print_status "Cleaning up temporary files..."
find . -name "*.bak" -delete

# Regenerate protobuf code
print_status "Regenerating protobuf code..."
make generate

# Update go.mod
print_status "Updating Go module dependencies..."
go mod tidy

echo ""
print_status "Customization complete! 🎉"
echo ""
print_info "Summary of changes made:"
echo "  ✅ Go module path: github.com/$GITHUB_USER/$REPO_NAME"
echo "  ✅ Project name: $PROJECT_NAME (for Docker, K8s, infrastructure)"
echo "  ✅ Repository name: $REPO_NAME (for GitHub, imports)"
echo "  ✅ Docker images: $PROJECT_NAME"
echo "  ✅ Kubernetes services: $PROJECT_NAME"
echo "  ✅ Infrastructure resources: $PROJECT_NAME-*"
echo "  ✅ Helm charts: $PROJECT_NAME"
echo "  ✅ Protocol buffers: $REPO_NAME"
echo "  ✅ CI/CD workflows: $REPO_NAME"
echo ""
print_info "Next steps:"
echo "1. Review the changes: git diff"
echo "2. If you don't like the changes: git checkout . (reverts everything)"
echo "3. If you like the changes: git add . && git commit -m 'Customize project for $PROJECT_NAME'"
echo "4. Set up your GCP project and enable required APIs"
echo "5. Configure GitHub Secrets for CI/CD"
echo "6. Start developing: make dev"
echo ""
print_warning "Don't forget to:"
echo "- Update the README.md with your project-specific information"
echo "- Configure your domain DNS settings"
echo "- Set up monitoring and alerting"
echo "- Review security settings"
echo ""
print_info "Happy coding! 🚀"
