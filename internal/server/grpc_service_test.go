package server

import (
	"context"
	"net/http"
	"testing"
	"time"

	"github.com/bufbuild/connect-go"
	"github.com/sirupsen/logrus"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	apiv1 "github.com/your-org/golang-grpc-gke/gen/api/v1"
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
	assert.Equal(t, "Processed: "+testData, resp.Msg.Result)
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
	assert.False(t, resp.Msg.Success)
	assert.Empty(t, resp.Msg.Result)
	assert.Equal(t, "Data cannot be empty", resp.Msg.ErrorMessage)
	assert.NotNil(t, resp.Msg.ProcessedAt)
}

func TestGrpcService_StreamData(t *testing.T) {
	logger := logrus.New()
	service := NewGrpcService(logger)

	req := connect.NewRequest(&apiv1.StreamDataRequest{
		Query: "test query",
		Limit: 3,
	})

	// Create a mock stream
	stream := &mockServerStream{}

	err := service.StreamData(context.Background(), req, stream)

	require.NoError(t, err)
	assert.Len(t, stream.responses, 3)

	for i, resp := range stream.responses {
		assert.Equal(t, int32(i+1), resp.Sequence)
		assert.Contains(t, resp.Data, "test query")
		assert.NotNil(t, resp.Timestamp)
	}
}

func TestGrpcService_StreamData_DefaultLimit(t *testing.T) {
	logger := logrus.New()
	service := NewGrpcService(logger)

	req := connect.NewRequest(&apiv1.StreamDataRequest{
		Query: "test query",
		Limit: 0, // Should default to 10
	})

	stream := &mockServerStream{}

	err := service.StreamData(context.Background(), req, stream)

	require.NoError(t, err)
	assert.Len(t, stream.responses, 10)
}

// Mock server stream for testing
type mockServerStream struct {
	responses []*apiv1.StreamDataResponse
}

func (m *mockServerStream) Send(msg *apiv1.StreamDataResponse) error {
	m.responses = append(m.responses, msg)
	return nil
}

func (m *mockServerStream) RequestHeader() http.Header {
	return make(http.Header)
}

func (m *mockServerStream) ResponseHeader() http.Header {
	return make(http.Header)
}

func (m *mockServerStream) ResponseTrailer() http.Header {
	return make(http.Header)
}

func (m *mockServerStream) Context() context.Context {
	return context.Background()
}

func (m *mockServerStream) Peer() connect.Peer {
	return connect.Peer{}
}
