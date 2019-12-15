package main

import (
	"io"
	"io/ioutil"
	"net/http"

	"github.com/prometheus/common/expfmt"
	"github.com/prometheus/common/model"
)

var (
	metricsURL = "http://metric-prometheus.test.mattermost.cloud/metrics"
)

func main() {
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

// TODO: return io.Reader
func downloadMetrics(url string) (string, error) {
	response, err := http.Get(url)

	if err != nil {
		return "", err
	}

	defer response.Body.Close()

	body, err := ioutil.ReadAll(response.Body)

	if err != nil {
		return "", err
	}

	return string(body), nil
}
