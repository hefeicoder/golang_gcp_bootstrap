package main

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/prometheus/client_golang/prometheus/promhttp"
	"github.com/sirupsen/logrus"
	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"

	"github.com/hefeicoder/golang_gcp_bootstrap/example-backend/gen/api/apiv1connect"
	"github.com/hefeicoder/golang_gcp_bootstrap/example-backend/internal/server"
)

const (
	grpcPort   = 9090
	healthPort = 8080
)

func main() {
	logger := logrus.New()
	logger.SetFormatter(&logrus.JSONFormatter{})
	logger.SetLevel(logrus.InfoLevel)

	// Create gRPC server
	grpcServer := grpc.NewServer()

	// Create Connect server
	grpcService := server.NewGrpcService(logger)
	path, handler := apiv1connect.NewGrpcServiceHandler(grpcService)

	// Register reflection service on gRPC server
	reflection.Register(grpcServer)

	// CORS middleware
	corsMiddleware := func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			// Allow all origins for demo purposes
			w.Header().Set("Access-Control-Allow-Origin", "*")
			w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
			w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

			// Handle preflight requests
			if r.Method == "OPTIONS" {
				w.WriteHeader(http.StatusOK)
				return
			}

			next.ServeHTTP(w, r)
		})
	}

	// Create HTTP server with gRPC and Connect handlers
	mux := http.NewServeMux()
	mux.Handle(path, corsMiddleware(handler))

	// Add health check endpoints
	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"status":"healthy"}`))
	})

	mux.HandleFunc("/ready", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"status":"ready"}`))
	})

	// Add metrics endpoint
	mux.Handle("/metrics", promhttp.Handler())

	// Serve the demo HTML page at root
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		// Only serve the demo page for GET requests to root
		if r.Method == "GET" && r.URL.Path == "/" {
			w.Header().Set("Content-Type", "text/html")
			http.ServeFile(w, r, "web/demo.html")
		} else {
			http.NotFound(w, r)
		}
	})

	// Create HTTP server with h2c support for gRPC
	httpServer := &http.Server{
		Addr:    fmt.Sprintf(":%d", grpcPort),
		Handler: h2c.NewHandler(mux, &http2.Server{}),
	}

	// Create health check server
	healthServer := &http.Server{
		Addr: fmt.Sprintf(":%d", healthPort),
		Handler: http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.WriteHeader(http.StatusOK)
			w.Write([]byte(`{"status":"healthy"}`))
		}),
	}

	// Start servers
	go func() {
		logger.Infof("Starting gRPC server on port %d", grpcPort)
		if err := httpServer.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			logger.Fatalf("Failed to start gRPC server: %v", err)
		}
	}()

	go func() {
		logger.Infof("Starting health check server on port %d", healthPort)
		if err := healthServer.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			logger.Fatalf("Failed to start health server: %v", err)
		}
	}()

	// Wait for interrupt signal
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	logger.Info("Shutting down servers...")

	// Graceful shutdown
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	if err := httpServer.Shutdown(ctx); err != nil {
		logger.Errorf("HTTP server shutdown error: %v", err)
	}

	if err := healthServer.Shutdown(ctx); err != nil {
		logger.Errorf("Health server shutdown error: %v", err)
	}

	logger.Info("Servers stopped")
}
