# Build stage
FROM golang:1.17 AS build

ADD cmd /work/cmd
ADD pkg /work/pkg
ADD go.mod /work/go.mod
ADD go.sum /work/go.sum

RUN cd /work && \
    CGO_ENABLED=0 go build -o mtz-crypto-service ./cmd/mtz-crypto-service

# Final stage
FROM alpine:3.13

RUN apk --no-cache update && apk add ca-certificates

WORKDIR /app
COPY --from=build /work/mtz-crypto-service .

EXPOSE 4000

ENV MTZ_CRYPTO_LOGGING_FORMAT="json"

ENTRYPOINT [ "./mtz-crypto-service" ]
