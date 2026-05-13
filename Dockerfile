FROM golang:1.23 AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /coordinator ./cmd/coordinator

FROM gcr.io/distroless/static-debian12
COPY --from=builder /coordinator /coordinator
COPY configs/ /configs/
ENTRYPOINT ["/coordinator", "--config", "/configs/coordinator.yaml"]
