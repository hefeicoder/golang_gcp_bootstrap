#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Modern Go gRPC Backend for GKE - Quick Start${NC}"
echo "=================================================="

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}❌ $1 is not installed. Please install it first.${NC}"
        exit 1
    else
        echo -e "${GREEN}✅ $1 is installed${NC}"
    fi
}

check_command "go"
check_command "docker"
check_command "kubectl"
check_command "gcloud"
check_command "pulumi"
check_command "helm"
check_command "skaffold"
check_command "buf"

# Set up environment
echo -e "${YELLOW}Setting up environment...${NC}"

# Check if we're in a GCP project
if [ -z "$GOOGLE_PROJECT_ID" ]; then
    echo -e "${YELLOW}Please set your GCP project ID:${NC}"
    read -p "Enter your GCP project ID: " GOOGLE_PROJECT_ID
    export GOOGLE_PROJECT_ID
fi

# Configure gcloud
echo -e "${YELLOW}Configuring gcloud...${NC}"
gcloud config set project $GOOGLE_PROJECT_ID

# Install tools
echo -e "${YELLOW}Installing development tools...${NC}"
make install-tools

# Generate protobuf code
echo -e "${YELLOW}Generating protobuf code...${NC}"
make generate

# Build the application
echo -e "${YELLOW}Building the application...${NC}"
make build

# Run tests
echo -e "${YELLOW}Running tests...${NC}"
make test

# Build Docker image
echo -e "${YELLOW}Building Docker image...${NC}"
make docker-build

echo -e "${GREEN}✅ Quick start setup complete!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Configure Pulumi:"
echo "   cd infrastructure"
echo "   pulumi config set gcp:project $GOOGLE_PROJECT_ID"
echo "   pulumi config set domain-name your-domain.com"
echo ""
echo "2. Deploy to GKE:"
echo "   make deploy"
echo ""
echo "3. Start development:"
echo "   make dev"
echo ""
echo -e "${GREEN}Happy coding! 🎉${NC}"
