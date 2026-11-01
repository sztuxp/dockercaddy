# 第一阶段：强制使用构建机原生架构 (amd64) 执行下载与解压，避免 QEMU 模拟导致缓慢
FROM --platform=$BUILDPLATFORM alpine:3.24 AS downloader

# Docker Buildx 会自动根据目标平台注入 TARGETARCH (amd64 或 arm64)
ARG TARGETARCH
ARG RELEASE_TAG=20261024

RUN apk add --no-cache curl tar ca-certificates

WORKDIR /tmp

# 校验架构并直接拼接下载对应架构的 Caddy 二进制包
RUN if [ "$TARGETARCH" != "amd64" ] && [ "$TARGETARCH" != "arm64" ]; then \
      echo "Unsupported architecture: $TARGETARCH"; \
      exit 1; \
    fi && \
    curl -fL "https://github.com/lxhao61/integrated-examples/releases/download/${RELEASE_TAG}/caddy-linux-${TARGETARCH}.tar.gz" -o caddy.tar.gz && \
    tar -xzf caddy.tar.gz && \
    chmod +x /tmp/caddy

# 第二阶段：构建最终的 Caddy 镜像 (20261024 对应 Caddy v2.11.7)
FROM caddy:2-alpine

# 将第一阶段解压好的对应架构二进制文件覆盖进官方镜像
COPY --from=downloader /tmp/caddy /usr/bin/caddy

# 验证 Caddy 可执行文件及版本
RUN /usr/bin/caddy version

# 如需将配置文件打包进镜像，取消下方注释
# COPY ./Caddyfile /etc/caddy/Caddyfile
# COPY ./sites /etc/caddy/sites

# 暴露 HTTP、HTTPS、HTTP/3 (QUIC/UDP) 以及默认管理端口
EXPOSE 80 443 443/udp 2019

ENTRYPOINT ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
