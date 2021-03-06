# Build the manager binary
FROM golang:1.13 as builder
WORKDIR /workspace
# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum
# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
RUN go mod download
# Copy the go source
COPY main.go main.go
COPY api/ api/
COPY controllers/ controllers/
# Build
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GO111MODULE=on go build -a -o manager main.go
#
## Actual operator container image starts here. No need to make changes above this line
#
FROM registry.access.redhat.com/ubi8/ubi-minimal:latest
LABEL name="Memcached Operator" \
      vendor="Red Hat" \
      version="v0.0.1" \
      release="1" \
      summary="This is an example of a Memcached operator." \
      description="This operator will deploy memcached to the cluster."
# Required Licenses
COPY license /licenses
# Set arbitrary User ID
USER 1001
WORKDIR /
COPY --from=builder /workspace/manager .
ENTRYPOINT ["/manager"]
