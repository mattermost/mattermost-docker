package prometheushelper

import (
	"context"
	"errors"
	"fmt"
	"strconv"
	"time"

	"github.com/prometheus/common/model"
)

type PrometheusHelper struct {
	API prometheusAPI
}

func (p PrometheusHelper) VectorFirst(query string) (float64, error) {
	var (
		context       = context.Background()
		ts            = time.Now()
		value, _, err = p.API.Query(context, query, ts)
	)

	if err != nil {
		return 0, err
	}

	return p.extractNumericValueFromFirstElement(value)
}

func (p PrometheusHelper) extractNumericValueFromFirstElement(value model.Value) (float64, error) {
	textValue := ""

	if value.Type() == model.ValVector {
		vec, _ := value.(model.Vector)

		if len(vec) == 0 {
			return 0, errors.New("Vector has length = 0")
		}

		textValue = vec[0].Value.String()
	} else {
		return 0, fmt.Errorf("Expected a vector, got a %s", value.Type().String())
	}

	numericValue, err := strconv.ParseFloat(textValue, 64)

	if err != nil {
		return 0, err
	}

	return numericValue, nil
}
