package main

import (
	"io"
	"log"
	"net/http"
	"sync"
	"time"

	"github.com/prometheus/common/expfmt"
	"github.com/prometheus/common/model"
)

var (
	metricsURL = "http://localhost:8067/metrics"
)

func main() {
	var wg sync.WaitGroup

	wg.Add(1)
	go func() {
		for {
			log.Println("Reading metrics")

			metrics, err := LoadMetrics(metricsURL)

			if err != nil {
				log.Printf("Error: %s. Will sleep for 60 seconds and try again.\n", err.Error())
				time.Sleep(60 * time.Second)
				continue
			}

			// TODO:
			// - Store the data of the last 5min
			// - Calculate the average for that period, not instant.

			checkHTTPErrors(metrics)
			log.Println("")

			time.Sleep(5 * time.Second)
		}
	}()

	wg.Wait()
}

func checkHTTPErrors(metrics map[string]PrometheusSample) {
	var (
		httpErrorsTotal   = metrics["mattermost_http_errors_total"]
		httpRequestsTotal = metrics["mattermost_http_requests_total"]
	)

	log.Printf("\tPercentual of errors per request: %1.f\n", httpErrorsTotal.value)
	log.Printf("\tTotal amount of requests: %1.f\n", httpRequestsTotal.value)

}

// LoadMetrics downloads and parses metrics from a Prometheus metrics
// endpoint and converts them to a structure made of Golang basic types.
func LoadMetrics(metricsURL string) (map[string]PrometheusSample, error) {
	bodyReader, err := downloadMetrics(metricsURL)

	if err != nil {
		return nil, err
	}

	defer bodyReader.Close()

	metricsVector, err := parseMetrics(bodyReader, expfmt.FmtText)

	if err != nil {
		return nil, err
	}

	return vectorToMap(metricsVector), nil
}

func downloadMetrics(url string) (io.ReadCloser, error) {
	response, err := http.Get(url)

	if err != nil {
		return nil, err
	}

	return response.Body, nil
}

// This function can be confusing.
// For more information about how Prometheus decoder works, see
// https://github.com/prometheus/common/blob/master/expfmt/decode_test.go.
func parseMetrics(metricsReader io.Reader, format expfmt.Format) (model.Vector, error) {
	decoder := expfmt.NewDecoder(metricsReader, format)

	sampleDecoder := expfmt.SampleDecoder{
		Dec:  decoder,
		Opts: &expfmt.DecodeOptions{},
	}

	var all model.Vector

	for {
		var samples model.Vector
		err := sampleDecoder.Decode(&samples)

		if err == io.EOF {
			break
		}

		if err != nil {
			return nil, err
		}
		all = append(all, samples...)
	}

	return all, nil
}
