FROM golang:latest AS builder

COPY . /build
WORKDIR /build
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix nocgo -o alert-receiver .

FROM scratch
COPY --from=builder /build/alert-receiver ./
ENTRYPOINT ["./alert-receiver"]
EXPOSE 80
