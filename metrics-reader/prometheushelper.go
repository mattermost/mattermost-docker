package main

import "github.com/prometheus/common/model"

// PrometheusSample stores data from parsed metrics from Prometheus,
// using only Golang basic types.
type PrometheusSample struct {
	name   string
	value  float64
	labels map[string]string
}

func (ps PrometheusSample) label(name string) string {
	return ps.labels[name]
}

func parsePrometheusSample(sample *model.Sample) PrometheusSample {
	outputSample := PrometheusSample{
		name:   string(sample.Metric[model.MetricNameLabel]),
		value:  float64(sample.Value),
		labels: make(map[string]string),
	}

	for k, v := range sample.Metric {
		if k == model.MetricNameLabel {
			continue
		}

		outputSample.labels[string(k)] = string(v)
	}

	return outputSample
}

func vectorToMap(metricsVector model.Vector) map[string]PrometheusSample {
	samples := make(map[string]PrometheusSample)

	for _, sample := range metricsVector {
		currentSample := *sample
		parsedMetric := parsePrometheusSample(&currentSample)
		samples[parsedMetric.name] = parsedMetric
	}

	return samples
}
