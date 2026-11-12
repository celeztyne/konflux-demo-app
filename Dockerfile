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

FROM registry.access.redhat.com/ubi9/ubi-micro@sha256:dbd325b96bcd432dd42816d31412bdf1dc0fb973b79ed310344bc23c76c068db
WORKDIR /
COPY --from=builder /tmp/app .
USER 65532:65532

ENTRYPOINT ["/app"]
