package main

import (
	"io"
	"net/http"

	"github.com/prometheus/common/expfmt"
	"github.com/prometheus/common/model"
)

var (
	metricsURL = "http://metric-prometheus.test.mattermost.cloud/metrics"
)

func main() {
}

// TODO: refresh samples every 5s
// TODO: check for same metric from Grafana
func LoadMetrics(metricsURL string) map[string]prometheusSample {
	bodyReader, _ := downloadMetrics(metricsURL)
	defer bodyReader.Close()

	var (
		metricsVector, _ = parseMetrics(bodyReader, expfmt.FmtText)
		samples          = make(map[string]prometheusSample)
		currentSample    model.Sample
	)

	for _, sample := range metricsVector {
		currentSample = *sample
		parsedMetric := parsePrometheusSample(&currentSample)
		samples[parsedMetric.name] = parsedMetric
	}

	return samples
}

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

func downloadMetrics(url string) (io.ReadCloser, error) {
	response, err := http.Get(url)

	if err != nil {
		return nil, err
	}

	return response.Body, nil
}
