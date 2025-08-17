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
read -p "Enter your project name (e.g., my-backend): " PROJECT_NAME
read -p "Enter your domain name (e.g., api.mycompany.com): " DOMAIN_NAME

echo ""
echo "🔧 Infrastructure Configuration:"
read -p "Enter your GCP project ID: " GCP_PROJECT_ID
read -p "Enter your Docker registry (e.g., gcr.io): " DOCKER_REGISTRY

echo ""
echo "📦 Go Module Configuration:"
echo "   Go modules use paths like: github.com/USERNAME/PROJECT_NAME"
echo "   This affects import statements and module resolution"
read -p "Enter your GitHub username/organization (for Go module path): " GITHUB_USER

# Validate inputs
if [ -z "$GITHUB_USER" ] || [ -z "$PROJECT_NAME" ] || [ -z "$DOMAIN_NAME" ] || [ -z "$GCP_PROJECT_ID" ] || [ -z "$DOCKER_REGISTRY" ]; then
    print_error "All fields are required!"
    exit 1
fi

# Convert project name to Buf-compatible format (no underscores)
BUF_PROJECT_NAME=$(echo "$PROJECT_NAME" | sed 's/_/-/g')

echo ""
print_info "Customizing project with the following values:"
echo "  📦 Go Module: github.com/$GITHUB_USER/$PROJECT_NAME"
echo "  🏷️  Project Name: $PROJECT_NAME"
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

# Backup original files
print_status "Creating backups..."
cp go.mod go.mod.backup
cp proto/api/grpc_service.proto proto/api/grpc_service.proto.backup
cp proto/buf.yaml proto/buf.yaml.backup
cp proto/buf.gen.yaml proto/buf.gen.yaml.backup
cp infrastructure/Pulumi.yaml infrastructure/Pulumi.yaml.backup
cp helm/grpc-service/values.yaml helm/grpc-service/values.yaml.backup
cp .github/workflows/ci.yml .github/workflows/ci.yml.backup

# Update go.mod
print_status "Updating go.mod..."
sed -i.bak "s|github.com/hefeicoder/golang-grpc-gke|github.com/$GITHUB_USER/$PROJECT_NAME|g" go.mod
sed -i.bak "s|github.com/hefeicoder/golang-grpc-gke/gen|github.com/$GITHUB_USER/$PROJECT_NAME/gen|g" go.mod

# Update proto files
print_status "Updating protocol buffer files..."
sed -i.bak "s|github.com/hefeicoder/golang-grpc-gke/gen|github.com/$GITHUB_USER/$PROJECT_NAME/gen|g" proto/api/grpc_service.proto
sed -i.bak "s|buf.build/hefeicoder/golang-grpc-gke|buf.build/$GITHUB_USER/$BUF_PROJECT_NAME|g" proto/buf.yaml
sed -i.bak "s|github.com/hefeicoder/golang-grpc-gke/gen|github.com/$GITHUB_USER/$PROJECT_NAME/gen|g" proto/buf.gen.yaml

# Update Go source files
print_status "Updating Go source files..."
find . -name "*.go" -type f -exec sed -i.bak "s|github.com/hefeicoder/golang-grpc-gke|github.com/$GITHUB_USER/$PROJECT_NAME|g" {} \;

# Update infrastructure files
print_status "Updating infrastructure configuration..."
sed -i.bak "s|golang-grpc-gke|$PROJECT_NAME|g" infrastructure/Pulumi.yaml
sed -i.bak "s|grpc-service|$PROJECT_NAME|g" infrastructure/main.go

# Update Helm values
print_status "Updating Helm configuration..."
sed -i.bak "s|grpc-service|$PROJECT_NAME|g" helm/grpc-service/values.yaml
sed -i.bak "s|your-domain.com|$DOMAIN_NAME|g" helm/grpc-service/values.yaml

# Update CI/CD workflow
print_status "Updating CI/CD configuration..."
sed -i.bak "s|hefeicoder/golang_gcp_bootstrap|$GITHUB_USER/$PROJECT_NAME|g" .github/workflows/ci.yml
sed -i.bak "s|GCP_PROJECT_ID|$GCP_PROJECT_ID|g" .github/workflows/ci.yml
sed -i.bak "s|gcr.io|$DOCKER_REGISTRY|g" .github/workflows/ci.yml

# Update Docker files
print_status "Updating Docker configuration..."
sed -i.bak "s|grpc-service|$PROJECT_NAME|g" Dockerfile
sed -i.bak "s|grpc-service|$PROJECT_NAME|g" Dockerfile.dev

# Update Skaffold configuration
print_status "Updating Skaffold configuration..."
sed -i.bak "s|grpc-service|$PROJECT_NAME|g" skaffold.yaml

# Update Makefile
print_status "Updating Makefile..."
sed -i.bak "s|grpc-service|$PROJECT_NAME|g" Makefile

# Clean up backup files
print_status "Cleaning up backup files..."
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
print_info "Next steps:"
echo "1. Review the changes: git diff"
echo "2. Commit your changes: git add . && git commit -m 'Customize project for $PROJECT_NAME'"
echo "3. Set up your GCP project and enable required APIs"
echo "4. Configure GitHub Secrets for CI/CD"
echo "5. Start developing: make dev"
echo ""
print_warning "Don't forget to:"
echo "- Update the README.md with your project-specific information"
echo "- Configure your domain DNS settings"
echo "- Set up monitoring and alerting"
echo "- Review security settings"
echo ""
print_info "Happy coding! 🚀"
