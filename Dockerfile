# syntax=docker/dockerfile:1
ARG GO_VERSION=1.21
# ARG GOLANGCI_LINT_VERSION=v1.55

FROM --platform=$BUILDPLATFORM golang:${GO_VERSION}-alpine as build-root
WORKDIR /src
RUN --mount=type=cache,target=/go/pkg/mod/ \
    --mount=type=bind,source=go.mod,target=go.mod \
    --mount=type=bind,source=go.sum,target=go.sum \
    go mod download -x

ARG APP_VERSION="v0.0.0+unknown"

FROM build-root as build-server
RUN --mount=type=bind,target=. \
    GOOS=${TARGETOS} GOARCH=${TARGETARCH} CGO_ENABLED=0 go build --ldflags "-s" --ldflags "-X main.version=$APP_VERSION" -o /bin/server ./cmd/server

FROM build-root as build-client
RUN --mount=type=bind,target=. \
    GOOS=${TARGETOS} GOARCH=${TARGETARCH} CGO_ENABLED=0 go build --ldflags "-s" --ldflags "-X main.version=$APP_VERSION" -o /bin/client ./cmd/client

# FROM golangci/golangci-lint:${GOLANGCI_LINT_VERSION} as lint
# WORKDIR /test
# RUN --mount=type=bind,target=. \
#     golangci-lint run

FROM scratch as server
COPY --from=build-server /bin/server /bin/
ENTRYPOINT [ "/bin/server" ]
CMD ["--arg", "hello_server"]
EXPOSE 8080

FROM scratch as client
COPY --from=build-client /bin/client /bin/
ENTRYPOINT [ "/bin/client" ]
CMD ["--arg", "hello_client"]
EXPOSE 8081



