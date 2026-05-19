# Builder stage
FROM golang:1.22-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o hello-server .

# Final stage
FROM gcr.io/distroless/static-debian12

ARG UID=65532
ARG GID=65532

RUN groupadd -g ${GID} nonroot && \
    useradd -r -u ${UID} -g ${GID} nonroot

USER nonroot:nonroot

COPY --from=builder /app/hello-server /hello-server

EXPOSE 8080

LABEL org.opencontainers.image.title="Hello World Server" \
      org.opencontainers.image.description="A simple Go HTTP server" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.authors="Your Name <your.email@example.com>" \
      org.opencontainers.image.url="https://example.com" \
      org.opencontainers.image.source="https://github.com/yourusername/hello-world-server"

HEALTHCHECK --interval=30s --timeout=10s CMD ["/hello-server", "health"]

ENTRYPOINT ["/hello-server"]