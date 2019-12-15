package main

import "github.com/prometheus/common/model"

type prometheusSample struct {
	name   string
	value  model.SampleValue
	labels map[string]string
}

func (ps prometheusSample) label(name string) string {
	return ps.labels[name]
}

func parsePrometheusSample(sample *model.Sample) prometheusSample {
	outputSample := prometheusSample{
		name:   string(sample.Metric[model.MetricNameLabel]),
		value:  sample.Value,
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
