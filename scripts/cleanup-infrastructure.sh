#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧹 Cleaning up Infrastructure${NC}"
echo "================================"

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

# Confirm deletion
echo -e "${YELLOW}⚠️  This will delete all infrastructure resources!${NC}"
read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Cleanup cancelled.${NC}"
    exit 0
fi



echo -e "${YELLOW}Starting cleanup...${NC}"

# Delete GKE cluster
echo -e "${YELLOW}Deleting GKE cluster...${NC}"
if gcloud container clusters describe $CLUSTER_NAME --zone=us-central1-c --project=$GCP_PROJECT_ID &>/dev/null; then
    gcloud container clusters delete $CLUSTER_NAME \
        --zone=us-central1-c \
        --project=$GCP_PROJECT_ID \
        --quiet
    echo -e "${GREEN}✅ Cluster deleted${NC}"
else
    echo -e "${YELLOW}⚠️  Cluster $CLUSTER_NAME not found${NC}"
fi

# Delete DNS zone
echo -e "${YELLOW}Deleting DNS zone...${NC}"
if gcloud dns managed-zones describe $ZONE_NAME --project=$GCP_PROJECT_ID &>/dev/null; then
    gcloud dns managed-zones delete $ZONE_NAME \
        --project=$GCP_PROJECT_ID \
        --quiet
    echo -e "${GREEN}✅ DNS zone deleted${NC}"
else
    echo -e "${YELLOW}⚠️  DNS zone $ZONE_NAME not found${NC}"
fi

# Delete external IP
echo -e "${YELLOW}Deleting external IP...${NC}"
if gcloud compute addresses describe $IP_NAME --region=$GCP_REGION --project=$GCP_PROJECT_ID &>/dev/null; then
    gcloud compute addresses delete $IP_NAME \
        --region=$GCP_REGION \
        --project=$GCP_PROJECT_ID \
        --quiet
    echo -e "${GREEN}✅ External IP deleted${NC}"
else
    echo -e "${YELLOW}⚠️  External IP $IP_NAME not found${NC}"
fi

echo -e "${GREEN}✅ Cleanup complete!${NC}"
echo ""
echo -e "${BLUE}Resources deleted:${NC}"
echo "  - GKE cluster: $CLUSTER_NAME"
echo "  - DNS zone: $ZONE_NAME"
echo "  - External IP: $IP_NAME"
echo ""
echo -e "${GREEN}🎉 All infrastructure removed!${NC}"
