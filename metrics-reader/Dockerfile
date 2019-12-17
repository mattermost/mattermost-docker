FROM golang:latest AS builder

COPY . /build
WORKDIR /build
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix nocgo -o metrics-reader .

FROM scratch
COPY --from=builder /build/metrics-reader ./
ENTRYPOINT ["./metrics-reader"]
