package prometheushelper

import (
	"context"
	"testing"
	"time"

	"github.com/prometheus/client_golang/api"
	apiv1 "github.com/prometheus/client_golang/api/prometheus/v1"
	"github.com/prometheus/common/model"
	"github.com/stretchr/testify/assert"
)

func Test_CanFetchAScalarValue(t *testing.T) {
	t.Skip("Test only for documentation purposes")

	config := api.Config{
		Address: "http://localhost:9090",
	}
	client, err := api.NewClient(config)

	assert.Nil(t, err)

	var (
		api     = apiv1.NewAPI(client)
		context = context.Background()
		query   = `1000*(rate(mattermost_http_request_duration_seconds_sum[5m])/rate(mattermost_http_request_duration_seconds_count[5m]))`
		ts      = time.Now()
	)

	value, warnings, err := api.Query(context, query, ts)

	assert.NotNil(t, value)

	textValue := ""
	if value.Type() == model.ValVector {
		vec, _ := value.(model.Vector)
		textValue = vec[0].Value.String()
	}

	assert.NotEmpty(t, textValue)
	assert.Nil(t, warnings)
	assert.Nil(t, err)
}
