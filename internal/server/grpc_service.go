package server

import (
	"context"
	"fmt"
	"math/rand"
	"os"
	"time"

	"github.com/bufbuild/connect-go"
	"github.com/sirupsen/logrus"
	"google.golang.org/protobuf/types/known/timestamppb"

	apiv1 "github.com/hefeicoder/golang_gcp_bootstrap/example-backend/gen/api"
)

// GrpcService implements the gRPC service
type GrpcService struct {
	logger    *logrus.Logger
	startTime time.Time
}

// NewGrpcService creates a new gRPC service instance
func NewGrpcService(logger *logrus.Logger) *GrpcService {
	return &GrpcService{
		logger:    logger,
		startTime: time.Now(),
	}
}

// GetHealth returns the health status of the service
func (s *GrpcService) GetHealth(ctx context.Context, req *connect.Request[apiv1.GetHealthRequest]) (*connect.Response[apiv1.GetHealthResponse], error) {
	s.logger.Info("GetHealth called")

	response := &apiv1.GetHealthResponse{
		Status:    "healthy",
		Timestamp: timestamppb.Now(),
		Details: map[string]string{
			"uptime":  time.Since(s.startTime).String(),
			"version": "1.0.0",
		},
	}

	return connect.NewResponse(response), nil
}

// GetInfo returns information about the service
func (s *GrpcService) GetInfo(ctx context.Context, req *connect.Request[apiv1.GetInfoRequest]) (*connect.Response[apiv1.GetInfoResponse], error) {
	s.logger.Info("GetInfo called")

	response := &apiv1.GetInfoResponse{
		Version:     "1.0.0",
		Environment: getEnvironment(),
		StartTime:   timestamppb.New(s.startTime),
		Metadata: map[string]string{
			"go_version":   "1.21",
			"architecture": "amd64",
			"os":           "linux",
		},
	}

	return connect.NewResponse(response), nil
}

// ProcessData processes some data and returns a random number
func (s *GrpcService) ProcessData(ctx context.Context, req *connect.Request[apiv1.ProcessDataRequest]) (*connect.Response[apiv1.ProcessDataResponse], error) {
	s.logger.WithField("data", req.Msg.Data).Info("ProcessData called")

	// Generate a random number between 1 and 1000
	randomNumber := rand.Intn(1000) + 1
	result := fmt.Sprintf("%d", randomNumber)
	success := true
	var errorMessage string

	response := &apiv1.ProcessDataResponse{
		Result:       result,
		Success:      success,
		ErrorMessage: errorMessage,
		ProcessedAt:  timestamppb.Now(),
	}

	return connect.NewResponse(response), nil
}

// StreamData streams data processing results
func (s *GrpcService) StreamData(ctx context.Context, req *connect.Request[apiv1.StreamDataRequest], stream *connect.ServerStream[apiv1.StreamDataResponse]) error {
	s.logger.WithField("query", req.Msg.Query).Info("StreamData called")

	limit := req.Msg.Limit
	if limit <= 0 {
		limit = 10
	}

	for i := 0; i < int(limit); i++ {
		response := &apiv1.StreamDataResponse{
			Data:      fmt.Sprintf("Stream data %d for query: %s", i+1, req.Msg.Query),
			Sequence:  int32(i + 1),
			Timestamp: timestamppb.Now(),
		}

		if err := stream.Send(response); err != nil {
			s.logger.WithError(err).Error("Failed to send stream response")
			return err
		}

		// Simulate processing time
		time.Sleep(100 * time.Millisecond)
	}

	return nil
}

// getEnvironment returns the current environment
func getEnvironment() string {
	env := os.Getenv("ENVIRONMENT")
	if env == "" {
		env = "development"
	}
	return env
}
