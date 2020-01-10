package prometheushealthcheck

import (
	"testing"

	"net/http"
	"net/http/httptest"

	"github.com/stretchr/testify/assert"
)

func Test_CanCreateAHealthProvider(t *testing.T) {
	healthProvider, err := NewHealthProvider("prometheus:9090")

	assert.NotNil(t, healthProvider)
	assert.Nil(t, err)
}

func Test_HealthProvider_ReturnsTrueWhenHealthIsUp(t *testing.T) {
	handler := func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("Prometheus is Healthy."))
	}
	server := httptest.NewServer(http.HandlerFunc(handler))
	defer server.Close()

	healthProvider, _ := NewHealthProvider(server.URL)
	result := healthProvider.Check()

	assert.True(t, result.Healthy)
	assert.Nil(t, result.Error)
	assert.False(t, result.Timestamp.IsZero())
}

func Test_HealthProvider_ReturnsFalseWhenHealthIsDown(t *testing.T) {
	handler := func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusTeapot)
		w.Write([]byte("Prometheus is a Teapot."))
	}
	server := httptest.NewServer(http.HandlerFunc(handler))
	defer server.Close()

	healthProvider, _ := NewHealthProvider(server.URL)
	result := healthProvider.Check()

	assert.False(t, result.Healthy)
	assert.Equal(t, "Prometheus is a Teapot.", result.Error.Error())
	assert.False(t, result.Timestamp.IsZero())
}
