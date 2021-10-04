ARG GO_VERSION=1.17

# STAGE 1: build executable
FROM golang:${GO_VERSION}-alpine AS build

RUN apk add --no-cache git

WORKDIR /work
ADD cmd ./cmd
ADD pkg ./pkg
ADD go.mod ./go.mod
ADD go.sum ./go.sum

# Build the executable
RUN CGO_ENABLED=0 go build -o /service ./cmd/mtz-crypto-service

# STAGE 2: build the final image
FROM gcr.io/distroless/static AS final

ARG SVC_NAME
ARG APP_VSN
ARG GIT_COMMIT
ARG BUILD_DATE

USER nonroot:nonroot
 
# copy compiled app
COPY --from=build --chown=nonroot:nonroot /service /service


# setup environment
ENV MTZ_CRYPTO_LOGGING_FORMAT="json" \
    VERSION=${APP_VSN}

# the container listens on the specified network ports at runtime
EXPOSE 8000/tcp

# run binary
ENTRYPOINT ["/service"]

# ----------------------------------------------------------------------------------------
# IMPORTANTE: Mantener estas líneas al FINAL del archivo
# ----------------------------------------------------------------------------------------
LABEL org.opencontainers.image.url="https://github.com/matbarofex/mtz-crypto" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.vendor="Matriz SA" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.ref.name="mtzio/mtz-crypto" \
      org.opencontainers.image.title="mtz-crypto" \
      org.opencontainers.image.description="Servicio de ejemplo para capacitación Go" \
      org.opencontainers.image.revision="${GIT_COMMIT}" \
      org.opencontainers.image.created="${BUILD_DATE}"
# ----------------------------------------------------------------------------------------
