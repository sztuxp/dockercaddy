FROM alpine:latest

ARG TARGETARCH

RUN apk add --no-cache ca-certificates

# 根据架构复制正确的二进制
RUN case "$TARGETARCH" in \
    "amd64")  cp caddy-amd64 /usr/local/bin/caddy ;; \
    "arm64")  cp caddy-arm64 /usr/local/bin/caddy ;; \
    *) echo "Unsupported architecture: $TARGETARCH" && exit 1 ;; \
esac && chmod +x /usr/local/bin/caddy

EXPOSE 80 443 2019

ENTRYPOINT ["caddy"]
CMD ["run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
