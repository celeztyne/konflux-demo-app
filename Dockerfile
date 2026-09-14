FROM registry.access.redhat.com/ubi9/go-toolset:1.25.7-1772454089@sha256:b3b98e0b21ddbb979d968ca319b8eebdca121e30d58994072cbf99ce86e5d24e AS builder
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

FROM registry.access.redhat.com/ubi9/ubi-micro@sha256:7a0454cbd9bd847e8f6a63b6f0254a6efbeb6e0ed71a5d824a4f6cccbe626650
WORKDIR /
COPY --from=builder /tmp/app .
USER 65532:65532

ENTRYPOINT ["/app"]
