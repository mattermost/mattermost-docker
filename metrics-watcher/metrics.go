package main

import "github.com/mattermost/mattermost-docker/metrics-watcher/prometheushelper"

func printRequestDuration(prometheus *prometheushelper.PrometheusHelper) {
	query := `rate(mattermost_http_request_duration_seconds_sum[5m])/rate(mattermost_http_request_duration_seconds_count[5m])`

	if requestDuration, err := prometheus.VectorFirst(query); err == nil {
		logger.Info("Request duration is %2.8f", requestDuration)
	} else {
		logger.Error("Error while querying Prometheus for request duration: %s", err.Error())
	}
}

func printCurrentWebsockets(prometheus *prometheushelper.PrometheusHelper) {
	requestDurationQuery := `mattermost_http_websockets_total`

	if amountOfWebsockets, err := prometheus.VectorFirst(requestDurationQuery); err == nil {
		logger.Info("Current amount of websockets is %1.0f", amountOfWebsockets)
	} else {
		logger.Error("Error while querying Prometheus for current amount of websockets: %s", err.Error())
	}
}
