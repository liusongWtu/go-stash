FROM golang:1.16-buster AS builder

LABEL stage=gobuilder

ARG project
ENV CGO_ENABLED 0
ENV GOOS linux
ENV GOPROXY https://goproxy.cn|direct

WORKDIR /go/src/app

ADD go.mod .
ADD go.sum .
RUN go mod download
#RUN go mod download -x
#RUN echo $(ls .)
COPY . .
COPY  stash/etc /app/etc
#RUN echo $(ls .)
RUN go build -ldflags="-s -w" -o /app/stash stash/stash.go
#RUN echo $(ls .)


FROM alpine

RUN apk update --no-cache && apk add --no-cache ca-certificates tzdata
ENV TZ Asia/Shanghai

WORKDIR /app

COPY --from=builder /app/ /app/
COPY --from=builder /app/etc /app/etc
CMD ["./stash", "-f", "etc/config.yaml"]