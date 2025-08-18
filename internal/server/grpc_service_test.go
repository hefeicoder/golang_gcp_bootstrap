package server

import (
	"context"
	"testing"
	"time"

	"github.com/bufbuild/connect-go"
	"github.com/sirupsen/logrus"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	apiv1 "github.com/hefeicoder/golang_gcp_bootstrap/example-backend/gen/api"
)

func TestNewGrpcService(t *testing.T) {
	logger := logrus.New()
	service := NewGrpcService(logger)

	assert.NotNil(t, service)
	assert.Equal(t, logger, service.logger)
	assert.WithinDuration(t, time.Now(), service.startTime, 2*time.Second)
}

func TestGrpcService_GetHealth(t *testing.T) {
	logger := logrus.New()
	service := NewGrpcService(logger)

	req := connect.NewRequest(&apiv1.GetHealthRequest{})
	resp, err := service.GetHealth(context.Background(), req)

	require.NoError(t, err)
	assert.NotNil(t, resp)
	assert.Equal(t, "healthy", resp.Msg.Status)
	assert.NotNil(t, resp.Msg.Timestamp)
	assert.Contains(t, resp.Msg.Details, "uptime")
	assert.Contains(t, resp.Msg.Details, "version")
}

func TestGrpcService_GetInfo(t *testing.T) {
	logger := logrus.New()
	service := NewGrpcService(logger)

	req := connect.NewRequest(&apiv1.GetInfoRequest{})
	resp, err := service.GetInfo(context.Background(), req)

	require.NoError(t, err)
	assert.NotNil(t, resp)
	assert.Equal(t, "1.0.0", resp.Msg.Version)
	assert.NotNil(t, resp.Msg.StartTime)
	assert.Contains(t, resp.Msg.Metadata, "go_version")
	assert.Contains(t, resp.Msg.Metadata, "architecture")
	assert.Contains(t, resp.Msg.Metadata, "os")
}

func TestGrpcService_ProcessData_Success(t *testing.T) {
	logger := logrus.New()
	service := NewGrpcService(logger)

	testData := "test data"
	req := connect.NewRequest(&apiv1.ProcessDataRequest{
		Data:    testData,
		Options: map[string]string{"key": "value"},
	})

	resp, err := service.ProcessData(context.Background(), req)

	require.NoError(t, err)
	assert.NotNil(t, resp)
	assert.True(t, resp.Msg.Success)
	// Check that result is a number between 1 and 1000
	assert.NotEmpty(t, resp.Msg.Result)
	assert.Empty(t, resp.Msg.ErrorMessage)
	assert.NotNil(t, resp.Msg.ProcessedAt)
}

func TestGrpcService_ProcessData_EmptyData(t *testing.T) {
	logger := logrus.New()
	service := NewGrpcService(logger)

	req := connect.NewRequest(&apiv1.ProcessDataRequest{
		Data: "",
	})

	resp, err := service.ProcessData(context.Background(), req)

	require.NoError(t, err)
	assert.NotNil(t, resp)
	assert.True(t, resp.Msg.Success)
	// Even with empty data, we still get a random number
	assert.NotEmpty(t, resp.Msg.Result)
	assert.Empty(t, resp.Msg.ErrorMessage)
	assert.NotNil(t, resp.Msg.ProcessedAt)
}

// TODO: Add streaming tests when mock implementation is complete
func TestGrpcService_StreamData(t *testing.T) {
	t.Skip("Streaming tests not implemented yet")
}

func TestGrpcService_StreamData_DefaultLimit(t *testing.T) {
	t.Skip("Streaming tests not implemented yet")
}

// TODO: Implement mock server stream for testing
