FROM golang:1.23.3-alpine AS build

RUN apk add --no-cache \
    make \
    git \
    curl

WORKDIR /go/src/github.com/coredns/coredns
RUN curl -L https://github.com/coredns/coredns/archive/refs/tags/v1.12.0.tar.gz | tar xz --strip-components=1

# Add the Docker plugin to the plugin.cfg file
RUN echo "docker:github.com/coredns/docker" >> plugin.cfg

RUN make

FROM debian:bullseye-slim
COPY --from=build /go/src/github.com/coredns/coredns/coredns /coredns

EXPOSE 53/udp 53/tcp 8080/tcp

ENTRYPOINT ["/coredns"]