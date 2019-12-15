package main

import (
	"io"
	"net/http"
	"net/http/httptest"
	"sort"
	"strings"
	"testing"

	"github.com/prometheus/common/expfmt"
	"github.com/prometheus/common/model"
	"github.com/stretchr/testify/assert"
)

var sampleMetrics = `
# SOME comment
# TYPE go_goroutines gauge
go_goroutines 1073
# HELP go_info Information about the Go environment.
# TYPE go_info gauge
go_info{version="go1.12"} 1
# HELP go_memstats_alloc_bytes Number of bytes allocated and still in use.
# TYPE go_memstats_alloc_bytes gauge
go_memstats_alloc_bytes 5.2909488e+07
`

func Test_download(t *testing.T) {
	mux := http.NewServeMux()

	mux.HandleFunc("/metrics", func(rw http.ResponseWriter, req *http.Request) {
		rw.WriteHeader(http.StatusOK)
		rw.Header().Set("Content-Type", "text/plain; version=0.0.4; charset=utf-8")
		io.WriteString(rw, sampleMetrics)
	})

	server := httptest.NewServer(mux)
	defer server.Close()

	client := server.Client()
	http.DefaultClient = client

	var (
		url       = server.URL + "/metrics"
		body, err = downloadMetrics(url)
	)

	assert.Nil(t, err)
	assert.Equal(t, sampleMetrics, body)
}

func Test_parseMetrics(t *testing.T) {
	reader := strings.NewReader(sampleMetrics)
	metrics, err := parseMetrics(reader, expfmt.FmtText)

	assert.Nil(t, err)
	assert.Equal(t, 3, metrics.Len())

	sort.Sort(metrics)

	assert.Equal(t, "go_goroutines", parsePrometheusSample(metrics[0]).name)
	assert.Equal(t, model.SampleValue(1073), parsePrometheusSample(metrics[0]).value)

	assert.Equal(t, "go_memstats_alloc_bytes", parsePrometheusSample(metrics[1]).name)
	assert.Equal(t, model.SampleValue(5.2909488e+07), parsePrometheusSample(metrics[1]).value)

	assert.Equal(t, "go_info", parsePrometheusSample(metrics[2]).name)
	assert.Equal(t, "go1.12", parsePrometheusSample(metrics[2]).label("version"))
}
