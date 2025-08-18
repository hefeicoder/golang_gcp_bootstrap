# Variables
PROJECT_NAME := golang-gcp-bootstrap
IMAGE_NAME := example-backend
# Use free registry to avoid costs
REGISTRY ?= docker.io
PROJECT_ID ?= your-project-id
VERSION ?= $(shell git describe --tags --always --dirty)
GOOS ?= $(shell go env GOOS)
GOARCH ?= $(shell go env GOARCH)

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

.PHONY: help
help: ## Show this help message
	@echo "$(BLUE)Available commands:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

.PHONY: setup
setup: ## Setup development environment
	@echo "$(YELLOW)Setting up development environment...$(NC)"
	go mod download
	go install github.com/bufbuild/buf/cmd/buf@latest
	go install github.com/cosmtrek/air@latest
	@echo "$(GREEN)Setup complete!$(NC)"

.PHONY: generate
generate: ## Generate protobuf code
	@echo "$(YELLOW)Generating protobuf code...$(NC)"
	cd proto && buf generate
	@echo "$(GREEN)Code generation complete!$(NC)"

.PHONY: build
build: generate ## Build the application
	@echo "$(YELLOW)Building application...$(NC)"
	CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o bin/server ./cmd/server
	@echo "$(GREEN)Build complete!$(NC)"

.PHONY: test
test: ## Run tests
	@echo "$(YELLOW)Running tests...$(NC)"
	go test -v ./...
	@echo "$(GREEN)Tests complete!$(NC)"

.PHONY: test-coverage
test-coverage: ## Run tests with coverage
	@echo "$(YELLOW)Running tests with coverage...$(NC)"
	go test -v -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html
	@echo "$(GREEN)Coverage report generated: coverage.html$(NC)"

.PHONY: lint
lint: ## Run linters
	@echo "$(YELLOW)Running linters...$(NC)"
	golangci-lint run
	@echo "$(GREEN)Linting complete!$(NC)"

.PHONY: fmt
fmt: ## Format code
	@echo "$(YELLOW)Formatting code...$(NC)"
	go fmt ./...
	@echo "$(GREEN)Code formatting complete!$(NC)"

.PHONY: docker-build
docker-build: ## Build Docker image
	@echo "$(YELLOW)Building Docker image...$(NC)"
	docker build -t $(IMAGE_NAME):$(VERSION) .
	docker tag $(IMAGE_NAME):$(VERSION) $(IMAGE_NAME):latest
	@echo "$(GREEN)Docker build complete!$(NC)"

.PHONY: docker-push
docker-push: ## Push Docker image to registry
	@echo "$(YELLOW)Pushing Docker image...$(NC)"
	docker tag $(IMAGE_NAME):$(VERSION) $(REGISTRY)/$(PROJECT_ID)/$(IMAGE_NAME):$(VERSION)
	docker tag $(IMAGE_NAME):$(VERSION) $(REGISTRY)/$(PROJECT_ID)/$(IMAGE_NAME):latest
	docker push $(REGISTRY)/$(PROJECT_ID)/$(IMAGE_NAME):$(VERSION)
	docker push $(REGISTRY)/$(PROJECT_ID)/$(IMAGE_NAME):latest
	@echo "$(GREEN)Docker push complete!$(NC)"

.PHONY: dev
dev: ## Start development environment with Skaffold
	@echo "$(YELLOW)Starting development environment...$(NC)"
	skaffold dev --profile=dev
	@echo "$(GREEN)Development environment stopped!$(NC)"

.PHONY: deploy-infrastructure
deploy-infrastructure: ## Deploy infrastructure using gcloud
	@echo "$(YELLOW)Deploying infrastructure...$(NC)"
	./scripts/deploy-infrastructure.sh
	@echo "$(GREEN)Infrastructure deployment complete!$(NC)"

.PHONY: cleanup-infrastructure
cleanup-infrastructure: ## Clean up infrastructure
	@echo "$(YELLOW)Cleaning up infrastructure...$(NC)"
	./scripts/cleanup-infrastructure.sh
	@echo "$(GREEN)Infrastructure cleanup complete!$(NC)"

.PHONY: deploy-dev
deploy-dev: ## Deploy to development environment
	@echo "$(YELLOW)Deploying to development...$(NC)"
	skaffold run --profile=staging
	@echo "$(GREEN)Development deployment complete!$(NC)"

.PHONY: deploy-prod
deploy-prod: ## Deploy to production environment
	@echo "$(YELLOW)Deploying to production...$(NC)"
	skaffold run --profile=prod
	@echo "$(GREEN)Production deployment complete!$(NC)"

.PHONY: deploy
deploy: ## Deploy infrastructure and application
	@echo "$(YELLOW)Deploying infrastructure and application...$(NC)"
	./scripts/deploy-infrastructure.sh
	@echo "$(GREEN)Deployment complete!$(NC)"

.PHONY: destroy
destroy: ## Destroy infrastructure
	@echo "$(RED)Destroying infrastructure...$(NC)"
	./scripts/cleanup-infrastructure.sh
	@echo "$(GREEN)Infrastructure destroyed!$(NC)"

.PHONY: clean
clean: ## Clean build artifacts
	@echo "$(YELLOW)Cleaning build artifacts...$(NC)"
	rm -rf bin/
	rm -rf tmp/
	rm -rf proto/gen/
	rm -f coverage.out coverage.html
	@echo "$(GREEN)Clean complete!$(NC)"

.PHONY: proto-lint
proto-lint: ## Lint protocol buffers
	@echo "$(YELLOW)Linting protocol buffers...$(NC)"
	buf lint
	@echo "$(GREEN)Protocol buffer linting complete!$(NC)"

.PHONY: proto-breaking
proto-breaking: ## Check for breaking changes in protocol buffers
	@echo "$(YELLOW)Checking for breaking changes...$(NC)"
	buf breaking --against '.git#branch=main'
	@echo "$(GREEN)Breaking change check complete!$(NC)"

.PHONY: helm-lint
helm-lint: ## Lint Helm charts
	@echo "$(YELLOW)Linting Helm charts...$(NC)"
	helm lint helm/grpc-service
	@echo "$(GREEN)Helm linting complete!$(NC)"

.PHONY: helm-template
helm-template: ## Template Helm charts
	@echo "$(YELLOW)Templating Helm charts...$(NC)"
	helm template example-backend helm/grpc-service
	@echo "$(GREEN)Helm templating complete!$(NC)"

.PHONY: install-tools
install-tools: ## Install required tools
	@echo "$(YELLOW)Installing required tools...$(NC)"
	go install github.com/bufbuild/buf/cmd/buf@latest
	go install github.com/air-verse/air@latest
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	@echo "$(GREEN)Tools installation complete!$(NC)"

.PHONY: test-e2e
test-e2e: ## Run end-to-end test against GCP deployment
	@echo "$(YELLOW)Building test client...$(NC)"
	go build -o bin/test-client ./cmd/test-client
	@echo "$(YELLOW)Running end-to-end test against GCP deployment...$(NC)"
	./bin/test-client

.PHONY: all
all: setup generate build test lint ## Run all checks
	@echo "$(GREEN)All checks passed!$(NC)"
