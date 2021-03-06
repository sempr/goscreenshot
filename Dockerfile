FROM golang:1.12 as builder

WORKDIR /code
RUN set -xe
COPY go.mod .
COPY go.sum .
RUN go mod download
COPY cmd/ ./cmd
RUN CGO_ENABLED=0 GO111MODULE=on go build -a -ldflags '-extldflags "-static"' -o /tmp/html2image ./cmd/newweb

FROM sempr/chrome-headless:20190531-notofont
ENV SCREENSHOT_CHROME_PATH /headless-shell/headless-shell
COPY --from=builder /tmp/html2image /usr/bin/html2image
ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
HEALTHCHECK --interval=5s --timeout=3s CMD curl -fs http://localhost:9222 && curl -fs -m 2 -o /dev/null "http://localhost:8080/render?width=300&html=abc" || kill -15 1
USER root
EXPOSE 8080
