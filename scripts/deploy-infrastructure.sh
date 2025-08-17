#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Deploying Infrastructure with gcloud${NC}"
echo "======================================"

# Load environment variables
if [ -f .env ]; then
    source .env
else
    echo -e "${RED}❌ .env file not found. Run ./scripts/setup-local-config.sh first.${NC}"
    exit 1
fi

# Load infrastructure configuration
if [ -f infrastructure/config.env ]; then
    source infrastructure/config.env
else
    echo -e "${YELLOW}⚠️  infrastructure/config.env not found. Using default values.${NC}"
    CLUSTER_NAME="grpc-cluster-${ENVIRONMENT:-dev}"
    ZONE_NAME="grpc-zone"
    IP_NAME="grpc-external-ip"
fi

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

check_command "gcloud"
check_command "kubectl"
check_command "helm"

# Authenticate with GCP
echo -e "${YELLOW}Authenticating with GCP...${NC}"
gcloud auth application-default login
gcloud config set project $GCP_PROJECT_ID

# Enable required APIs
echo -e "${YELLOW}Enabling required APIs...${NC}"
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable dns.googleapis.com

# Create GKE cluster
echo -e "${YELLOW}Creating GKE cluster...${NC}"

# Check if cluster already exists
if gcloud container clusters describe $CLUSTER_NAME --zone=us-central1-c --project=$GCP_PROJECT_ID &>/dev/null; then
    echo -e "${YELLOW}⚠️  Cluster $CLUSTER_NAME already exists. Skipping creation...${NC}"
else
    echo -e "${YELLOW}Creating new cluster $CLUSTER_NAME...${NC}"
    gcloud container clusters create $CLUSTER_NAME \
        --project=$GCP_PROJECT_ID \
        --zone=us-central1-c \
        --num-nodes=1 \
        --machine-type=e2-micro \
        --disk-size=20 \
        --workload-pool=$GCP_PROJECT_ID.svc.id.goog \
        --addons=HttpLoadBalancing \
        --release-channel=regular
fi

# Get cluster credentials
echo -e "${YELLOW}Getting cluster credentials...${NC}"
gcloud container clusters get-credentials $CLUSTER_NAME \
    --zone=us-central1-c \
    --project=$GCP_PROJECT_ID

# Create DNS zone (if domain is provided)
if [ ! -z "$DOMAIN_NAME" ] && [ "$DOMAIN_NAME" != "your-domain.com" ]; then
    echo -e "${YELLOW}Creating DNS zone for $DOMAIN_NAME...${NC}"
    
    # Check if zone already exists
    if ! gcloud dns managed-zones describe $ZONE_NAME --project=$GCP_PROJECT_ID &>/dev/null; then
        gcloud dns managed-zones create $ZONE_NAME \
            --project=$GCP_PROJECT_ID \
            --dns-name="$DOMAIN_NAME." \
            --description="DNS zone for gRPC service" \
            --visibility=public
    else
        echo -e "${YELLOW}⚠️  DNS zone $ZONE_NAME already exists.${NC}"
    fi
fi

# Create external IP for load balancer (optional)
echo -e "${YELLOW}Creating external IP...${NC}"

# Check if IP already exists
if ! gcloud compute addresses describe $IP_NAME --region=$GCP_REGION --project=$GCP_PROJECT_ID &>/dev/null; then
    gcloud compute addresses create $IP_NAME \
        --project=$GCP_PROJECT_ID \
        --region=$GCP_REGION
else
    echo -e "${YELLOW}⚠️  External IP $IP_NAME already exists.${NC}"
fi

# Get the external IP
EXTERNAL_IP=$(gcloud compute addresses describe $IP_NAME \
    --region=$GCP_REGION \
    --project=$GCP_PROJECT_ID \
    --format="value(address)")

echo -e "${GREEN}✅ Infrastructure deployment complete!${NC}"
echo ""
echo -e "${BLUE}Cluster Details:${NC}"
echo "  Name: $CLUSTER_NAME"
echo "  Region: $GCP_REGION"
echo "  Project: $GCP_PROJECT_ID"
echo "  External IP: $EXTERNAL_IP"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Deploy your application:"
echo "   make dev"
echo ""
echo "2. Check cluster status:"
echo "   kubectl get nodes"
echo "   kubectl get pods"
echo ""
echo -e "${GREEN}🎉 Ready to deploy your application!${NC}"
