package prometheushelper

import (
	"context"
	"time"

	apiv1 "github.com/prometheus/client_golang/api/prometheus/v1"
	"github.com/prometheus/common/model"
)

// prometheusAPI is a subset of Prometheus API interface.
// https://github.com/prometheus/client_golang/blob/803ef2a759d7caaaa0de58e3815f1be4c8b5a42a/api/prometheus/v1/api.go#L218-L251
// This subset allows us to implement in our tests only the functions we use,
// while allowing compatibility with Prometheus API interface.
type prometheusAPI interface {
	Query(ctx context.Context, query string, ts time.Time) (model.Value, apiv1.Warnings, error)
}
