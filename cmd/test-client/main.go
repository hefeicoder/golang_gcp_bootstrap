package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os/exec"
	"strconv"
	"strings"
	"time"

	"github.com/bufbuild/connect-go"

	apiv1 "github.com/hefeicoder/golang_gcp_bootstrap/example-backend/gen/api"
	apiv1connect "github.com/hefeicoder/golang_gcp_bootstrap/example-backend/gen/api/apiv1connect"
)

func main() {
	// Configuration
	timeout := 30 * time.Second

	// Dynamically discover the service URL
	serviceURL, err := discoverServiceURL()
	if err != nil {
		log.Fatalf("❌ Failed to discover service URL: %v", err)
	}

	fmt.Printf("🔍 Testing GCP Service at: %s\n", serviceURL)
	fmt.Println(strings.Repeat("=", 50))

	// Create HTTP client
	client := &http.Client{
		Timeout: timeout,
	}

	// Create Connect client
	connectClient := apiv1connect.NewGrpcServiceClient(client, serviceURL)

	// Test ProcessData endpoint
	fmt.Println("📊 Testing ProcessData endpoint...")

	ctx, cancel := context.WithTimeout(context.Background(), timeout)
	defer cancel()

	req := connect.NewRequest(&apiv1.ProcessDataRequest{
		Data: "test-data",
		Options: map[string]string{
			"test": "true",
		},
	})

	resp, err := connectClient.ProcessData(ctx, req)
	if err != nil {
		log.Fatalf("❌ Failed to call ProcessData: %v", err)
	}

	fmt.Printf("✅ ProcessData Response:\n")
	fmt.Printf("   Result: %s\n", resp.Msg.Result)
	fmt.Printf("   Success: %t\n", resp.Msg.Success)
	fmt.Printf("   Error Message: %s\n", resp.Msg.ErrorMessage)
	fmt.Printf("   Processed At: %s\n", resp.Msg.ProcessedAt.AsTime().Format(time.RFC3339))

	// Test GetHealth endpoint
	fmt.Println("\n🏥 Testing GetHealth endpoint...")

	healthReq := connect.NewRequest(&apiv1.GetHealthRequest{})
	healthResp, err := connectClient.GetHealth(ctx, healthReq)
	if err != nil {
		log.Fatalf("❌ Failed to call GetHealth: %v", err)
	}

	fmt.Printf("✅ GetHealth Response:\n")
	fmt.Printf("   Status: %s\n", healthResp.Msg.Status)
	fmt.Printf("   Timestamp: %s\n", healthResp.Msg.Timestamp.AsTime().Format(time.RFC3339))
	fmt.Printf("   Details: %v\n", healthResp.Msg.Details)

	// Test GetInfo endpoint
	fmt.Println("\nℹ️  Testing GetInfo endpoint...")

	infoReq := connect.NewRequest(&apiv1.GetInfoRequest{})
	infoResp, err := connectClient.GetInfo(ctx, infoReq)
	if err != nil {
		log.Fatalf("❌ Failed to call GetInfo: %v", err)
	}

	fmt.Printf("✅ GetInfo Response:\n")
	fmt.Printf("   Version: %s\n", infoResp.Msg.Version)
	fmt.Printf("   Environment: %s\n", infoResp.Msg.Environment)
	fmt.Printf("   Start Time: %s\n", infoResp.Msg.StartTime.AsTime().Format(time.RFC3339))
	fmt.Printf("   Metadata: %v\n", infoResp.Msg.Metadata)

	fmt.Println("\n🎉 All tests passed! Your GCP deployment is working correctly!")
}

// discoverServiceURL dynamically discovers the service URL by querying Kubernetes
func discoverServiceURL() (string, error) {
	// Get the node external IP
	nodeIP, err := getNodeExternalIP()
	if err != nil {
		return "", fmt.Errorf("failed to get node IP: %w", err)
	}

	// Get the NodePort
	nodePort, err := getServiceNodePort()
	if err != nil {
		return "", fmt.Errorf("failed to get NodePort: %w", err)
	}

	return fmt.Sprintf("http://%s:%d", nodeIP, nodePort), nil
}

// getNodeExternalIP gets the external IP of the GKE node
func getNodeExternalIP() (string, error) {
	cmd := exec.Command("kubectl", "get", "nodes", "-o", "jsonpath={.items[0].status.addresses[?(@.type==\"ExternalIP\")].address}")
	output, err := cmd.Output()
	if err != nil {
		return "", fmt.Errorf("kubectl command failed: %w", err)
	}

	ip := strings.TrimSpace(string(output))
	if ip == "" {
		return "", fmt.Errorf("no external IP found for nodes")
	}

	return ip, nil
}

// getServiceNodePort gets the NodePort for the gRPC service
func getServiceNodePort() (int, error) {
	cmd := exec.Command("kubectl", "get", "service", "example-backend-grpc-service", "-o", "jsonpath={.spec.ports[?(@.name==\"grpc\")].nodePort}")
	output, err := cmd.Output()
	if err != nil {
		return 0, fmt.Errorf("kubectl command failed: %w", err)
	}

	portStr := strings.TrimSpace(string(output))
	if portStr == "" {
		return 0, fmt.Errorf("no NodePort found for grpc service")
	}

	port, err := strconv.Atoi(portStr)
	if err != nil {
		return 0, fmt.Errorf("invalid NodePort: %s", portStr)
	}

	return port, nil
}
