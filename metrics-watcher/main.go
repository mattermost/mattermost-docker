package main

import (
	"sync"
	"time"

	"github.com/mattermost/mattermost-docker/metrics-watcher/prometheushealthcheck"
	"github.com/mattermost/mattermost-docker/metrics-watcher/prometheushelper"

	"github.com/borderstech/logmatic"
	"github.com/kelseyhightower/envconfig"
	"github.com/prometheus/client_golang/api"
	apiv1 "github.com/prometheus/client_golang/api/prometheus/v1"
)

type Configuration struct {
	PrometheusServer string `default:"http://localhost:9090" split_words:"true"`
}

var (
	configuration Configuration
	logger        = logmatic.NewLogger()
)

func main() {
	readConfiguration()

	var wg sync.WaitGroup
	wg.Add(2)

	go healthcheck()
	go checkMetrics()

	wg.Wait()
}

func readConfiguration() {
	if err := envconfig.Process("Mattermost", &configuration); err != nil {
		logger.Fatal(err.Error())
	}
}

func healthcheck() {
	healthCheck, err := prometheushealthcheck.NewHealthProvider(configuration.PrometheusServer)

	if err != nil {
		logger.Fatal(err.Error())
	}

	for {
		healthcheckResult := healthCheck.Check()

		if !healthcheckResult.Healthy && healthcheckResult.Error != nil {
			logger.Error("Prometheus is not healthy: %s", healthcheckResult.Error.Error())
		}

		time.Sleep(60 * time.Second)
	}
}

func checkMetrics() {
	var (
		config      = api.Config{Address: configuration.PrometheusServer}
		client, err = api.NewClient(config)
	)

	if err != nil {
		logger.Fatal(err.Error())
	}

	var (
		api        = apiv1.NewAPI(client)
		prometheus = &prometheushelper.PrometheusHelper{api}
	)

	for {
		printRequestDuration(prometheus)
		printCurrentWebsockets(prometheus)

		time.Sleep(5 * time.Second)
	}
}
