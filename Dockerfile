FROM registry.access.redhat.com/ubi9/go-toolset:1.26.7-1791479310@sha256:6f246e8913d082df463b62a74c72f0d2b410583e1b2ac48add39cd7ede59ce62 AS builder
ARG TARGETOS
ARG TARGETARCH

# Copy the Go Modules manifests
COPY go.mod ./
# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
RUN go mod download

# Copy the go source (relies on .dockerignore to filter)
COPY . .

RUN CGO_ENABLED=0 GOOS=${TARGETOS:-linux} GOARCH=${TARGETARCH} go build -a -o /tmp/app main.go

FROM registry.access.redhat.com/ubi9/ubi-micro@sha256:093a704be0eaef9bb52d9bc0219c67ee9db13c2e797da400ddb5d5ae6849fa10
WORKDIR /
COPY --from=builder /tmp/app .
USER 65532:65532

ENTRYPOINT ["/app"]
