FROM --platform=${BUILDPLATFORM:-linux/amd64} golang:1.14

ARG BUILDPLATFORM
ARG TARGETARCH=amd64
ARG TARGETOS=linux

ENV GO111MODULE=on
WORKDIR /go/src/github.com/wish/pod-netstat-exporter

# Cache dependencies
ENV GOPROXY=https://goproxy.cn
COPY go.mod .
COPY go.sum .
RUN go mod download

COPY . /go/src/github.com/wish/pod-netstat-exporter/

RUN CGO_ENABLED=0 GOARCH=${TARGETARCH} GOOS=${TARGETOS} go build -o ./pod-netstat-exporter -a -installsuffix cgo .

FROM alpine:3.16.2

RUN /bin/sh -c set -x \
    && sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk --no-cache add ca-certificates tzdata \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone

WORKDIR /root/
COPY --from=0 /go/src/github.com/wish/pod-netstat-exporter/pod-netstat-exporter /root/pod-netstat-exporter
