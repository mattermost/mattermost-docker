package main

import (
	"io"
	"io/ioutil"
	"net/http"
	"net/http/httptest"
	"sort"
	"strings"
	"testing"

	"github.com/prometheus/common/expfmt"
	"github.com/stretchr/testify/suite"
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

func TestSuite(t *testing.T) {
	suite.Run(t, new(MetricsReaderTest))
}

type MetricsReaderTest struct {
	suite.Suite
	server *httptest.Server
}

func (t *MetricsReaderTest) SetupTest() {
	mux := http.NewServeMux()

	mux.HandleFunc("/metrics", func(rw http.ResponseWriter, req *http.Request) {
		rw.WriteHeader(http.StatusOK)
		rw.Header().Set("Content-Type", "text/plain; version=0.0.4; charset=utf-8")
		io.WriteString(rw, sampleMetrics)
	})

	t.server = httptest.NewServer(mux)
}

func (t *MetricsReaderTest) TearDownSuite() {
	t.server.Close()
}

func (t *MetricsReaderTest) Test_download() {
	var (
		url                     = t.server.URL + "/metrics"
		responseBodyReader, err = downloadMetrics(url)
	)

	t.Assert().Nil(err)

	defer responseBodyReader.Close()
	body, _ := ioutil.ReadAll(responseBodyReader)
	t.Assert().Equal(sampleMetrics, string(body))
}

func (t *MetricsReaderTest) Test_parseMetrics() {
	reader := strings.NewReader(sampleMetrics)
	metrics, err := parseMetrics(reader, expfmt.FmtText)

	t.Assert().Nil(err)
	t.Assert().Equal(3, metrics.Len())

	sort.Sort(metrics)

	t.Assert().Equal("go_goroutines", parsePrometheusSample(metrics[0]).name)
	t.Assert().Equal(float64(1073), parsePrometheusSample(metrics[0]).value)

	t.Assert().Equal("go_memstats_alloc_bytes", parsePrometheusSample(metrics[1]).name)
	t.Assert().Equal(float64(5.2909488e+07), parsePrometheusSample(metrics[1]).value)

	t.Assert().Equal("go_info", parsePrometheusSample(metrics[2]).name)
	t.Assert().Equal("go1.12", parsePrometheusSample(metrics[2]).label("version"))
}

func (t *MetricsReaderTest) Test_LoadMetrics() {
	var (
		url     = t.server.URL + "/metrics"
		metrics = LoadMetrics(url)

		metricsGoRoutines, hasKeyGoGoroutines = metrics["go_goroutines"]
		metricsGoMemstats, hasKeyGoMemstats   = metrics["go_memstats_alloc_bytes"]
		metricsGoInfo, hasKeyGoInfo           = metrics["go_info"]
	)

	t.Assert().True(hasKeyGoGoroutines)
	t.Assert().True(hasKeyGoMemstats)
	t.Assert().True(hasKeyGoInfo)

	t.Assert().Equal(float64(1073), metricsGoRoutines.value)
	t.Assert().Equal(float64(5.2909488e+07), metricsGoMemstats.value)
	t.Assert().Equal(float64(1), metricsGoInfo.value)
	t.Assert().Equal("go1.12", metricsGoInfo.labels["version"])
}
