# Build the manager binary
FROM registry.access.redhat.com/ubi8 as builder 

LABEL name="Memcached Operator" \
      vendor="Red Hat" \
      version="v0.0.1" \
      release="1" \
      summary="This is an example of a Memcached operator." \
      description="This operator will deploy memcached to the cluster."

# Required Licenses
COPY LICENSE /licenses

COPY --chown=1001:0 workspace/ /workspace
WORKDIR /workspace

FROM registry.access.redhat.com/ubi8/go-toolset

# Copy the Go Modules manifests
COPY --chown=1001:0 go.mod go.mod
COPY --chown=1001:0 go.sum go.sum
# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer

RUN go mod download

# Copy the go source
COPY --chown=1001:0 main.go main.go
COPY --chown=1001:0 api/ api/
COPY --chown=1001:0 controllers/ controllers/

# Build
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GO111MODULE=on go build -a -o manager main.go

# Use distroless as minimal base image to package the manager binary
# Refer to https://github.com/GoogleContainerTools/distroless for more details
FROM gcr.io/distroless/static:nonroot
COPY --chown=1001:0 --from=builder /workspace/manager .
USER 65532:65532

ENTRYPOINT ["/manager"]
