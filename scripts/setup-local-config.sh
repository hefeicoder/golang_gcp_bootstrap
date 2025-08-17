#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Setting up Local Configuration${NC}"
echo "======================================"

# Function to get value from .env file
get_env_value() {
    local key="$1"
    local default="$2"
    
    if [ -f .env ]; then
        local value=$(grep "^${key}=" .env | cut -d'=' -f2- | tr -d '"' | tr -d "'")
        if [ ! -z "$value" ]; then
            echo "$value"
            return
        fi
    fi
    echo "$default"
}

# Function to prompt for input with default
prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"
    
    echo -e "${YELLOW}$prompt${NC}"
    read -p "Enter value (default: $default): " input
    
    if [ -z "$input" ]; then
        eval "$var_name=\"$default\""
    else
        eval "$var_name=\"$input\""
    fi
}

# Check if .env already exists
if [ -f .env ]; then
    echo -e "${YELLOW}📁 Found existing .env file. Reading current values as defaults...${NC}"
    EXISTING_ENV=true
else
    echo -e "${YELLOW}📝 Creating new .env file...${NC}"
    EXISTING_ENV=false
fi

# Get user configuration with defaults from .env if it exists
echo -e "${YELLOW}Let's set up your local development environment...${NC}"

prompt_with_default "What's your GCP project ID?" "$(get_env_value 'GCP_PROJECT_ID' 'your-project-id')" GCP_PROJECT_ID
prompt_with_default "What GCP region do you want to use?" "$(get_env_value 'GCP_REGION' 'us-central1')" GCP_REGION
prompt_with_default "What's your domain name?" "$(get_env_value 'DOMAIN_NAME' 'your-domain.com')" DOMAIN_NAME
prompt_with_default "What Docker registry do you want to use?" "$(get_env_value 'DOCKER_REGISTRY' 'gcr.io')" DOCKER_REGISTRY

# Create .env file
if [ "$EXISTING_ENV" = true ]; then
    echo -e "${YELLOW}Backing up existing .env file...${NC}"
    cp .env .env.backup.$(date +%Y%m%d_%H%M%S)
    echo -e "${GREEN}✅ Backup created${NC}"
fi

echo -e "${YELLOW}Creating .env file...${NC}"
cat > .env << EOF
# Local development configuration
# Generated on $(date)

# GCP Configuration
GCP_PROJECT_ID=$GCP_PROJECT_ID
GCP_REGION=$GCP_REGION
GCP_ZONE=${GCP_REGION}-a

# Domain Configuration
DOMAIN_NAME=$DOMAIN_NAME
SUBDOMAIN=api

# Docker Configuration
DOCKER_REGISTRY=$DOCKER_REGISTRY
DOCKER_IMAGE_NAME=test-backend
DOCKER_TAG=latest

# Application Configuration
GRPC_PORT=9090
HTTP_PORT=8080
LOG_LEVEL=debug

# Development Settings
ENVIRONMENT=dev
DEBUG=true
HOT_RELOAD=true

# Kubernetes Configuration (for local development)
K8S_NAMESPACE=default
K8S_CONTEXT=minikube

# Infrastructure Configuration
CLUSTER_NAME=grpc-cluster-dev
ZONE_NAME=grpc-zone
IP_NAME=grpc-external-ip
EOF

echo -e "${GREEN}✅ Created .env file${NC}"

# Create local Helm values
echo -e "${YELLOW}Creating local Helm values...${NC}"
cat > helm/grpc-service/values.local.yaml << EOF
# Local development overrides for Helm
# Generated on $(date)

# Override replica count for local development
replicaCount: 1

# Reduce resource usage for local development
resources:
  limits:
    cpu: 200m
    memory: 256Mi
  requests:
    cpu: 50m
    memory: 64Mi

# Local image settings
image:
  repository: localhost:5000/test-backend
  tag: "latest"
  pullPolicy: IfNotPresent

# Disable autoscaling for local development
autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 1

# Local service configuration
service:
  type: NodePort  # Use NodePort for local access
  port: 9090
  nodePort: 30090  # Access via localhost:30090

# Disable ingress for local development
ingress:
  enabled: false

# Local environment variables
env:
  - name: GRPC_PORT
    value: "9090"
  - name: HEALTH_PORT
    value: "8080"
  - name: LOG_LEVEL
    value: "debug"
  - name: ENVIRONMENT
    value: "local"

# Local monitoring (optional)
monitoring:
  enabled: false  # Disable for local development

# Local logging
logging:
  level: debug
  format: text  # Use text format for local development
EOF

echo -e "${GREEN}✅ Created helm/grpc-service/values.local.yaml${NC}"

# Create local config directory
echo -e "${YELLOW}Creating local config directory...${NC}"
mkdir -p ~/.config/golang-grpc-bootstrap

cat > ~/.config/golang-grpc-bootstrap/config.env << EOF
# Local configuration for golang-grpc-bootstrap
# Generated on $(date)

export GCP_PROJECT_ID="$GCP_PROJECT_ID"
export GCP_REGION="$GCP_REGION"
export DOMAIN_NAME="$DOMAIN_NAME"
export DOCKER_REGISTRY="$DOCKER_REGISTRY"
export ENVIRONMENT="dev"
export DEBUG="true"
EOF

echo -e "${GREEN}✅ Created ~/.config/golang-grpc-bootstrap/config.env${NC}"

# Create infrastructure configuration
echo -e "${YELLOW}Creating infrastructure configuration...${NC}"
mkdir -p infrastructure

cat > infrastructure/config.env << EOF
# Infrastructure configuration
# Generated on $(date)

CLUSTER_NAME=grpc-cluster-${ENVIRONMENT:-dev}
ZONE_NAME=grpc-zone
IP_NAME=grpc-external-ip
EOF

echo -e "${GREEN}✅ Infrastructure configuration ready${NC}"

# Create shell profile integration
echo -e "${YELLOW}Setting up shell profile integration...${NC}"

# Detect shell
if [ -n "$ZSH_VERSION" ]; then
    SHELL_PROFILE="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_PROFILE="$HOME/.bashrc"
else
    SHELL_PROFILE="$HOME/.profile"
fi

# Add to shell profile if not already there
if ! grep -q "golang-grpc-bootstrap" "$SHELL_PROFILE"; then
    echo "" >> "$SHELL_PROFILE"
    echo "# golang-grpc-bootstrap local configuration" >> "$SHELL_PROFILE"
    echo "if [ -f ~/.config/golang-grpc-bootstrap/config.env ]; then" >> "$SHELL_PROFILE"
    echo "    source ~/.config/golang-grpc-bootstrap/config.env" >> "$SHELL_PROFILE"
    echo "fi" >> "$SHELL_PROFILE"
    echo -e "${GREEN}✅ Added configuration to $SHELL_PROFILE${NC}"
else
    echo -e "${YELLOW}⚠️  Configuration already exists in $SHELL_PROFILE${NC}"
fi

echo ""
echo -e "${GREEN}✅ Local configuration setup complete!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Load your configuration:"
echo "   source .env"
echo ""
echo "2. Set up GCP authentication:"
echo "   gcloud auth application-default login"
echo "   gcloud config set project $GCP_PROJECT_ID"
echo ""
echo "3. Start local development:"
echo "   make dev"
echo ""
echo "4. For local Kubernetes (optional):"
echo "   minikube start"
echo "   kind create cluster"
echo ""
echo -e "${GREEN}🎉 You're ready for local development!${NC}"
