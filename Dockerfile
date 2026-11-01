# 第一阶段：使用构建机原生架构下载并解压 Caddy 二进制文件（大幅加速 arm64 构建）
FROM --platform=$BUILDPLATFORM alpine:3.24 AS downloader

# Docker Buildx 会自动为 TARGETARCH 赋值 (amd64, arm64)
ARG TARGETARCH
ARG RELEASE_TAG=20261024

# 安装 curl 和 tar
RUN apk add --no-cache curl tar ca-certificates

WORKDIR /tmp

# 根据 TARGETARCH 下载对应架构的 Caddy 二进制文件并解压赋权
RUN if [ "$TARGETARCH" != "amd64" ] && [ "$TARGETARCH" != "arm64" ]; then \
      echo "Unsupported architecture: $TARGETARCH"; \
      exit 1; \
    fi && \
    curl -fL "https://github.com/lxhao61/integrated-examples/releases/download/${RELEASE_TAG}/caddy-linux-${TARGETARCH}.tar.gz" -o caddy.tar.gz && \
    tar -xzf caddy.tar.gz && \
    chmod +x /tmp/caddy

# 第二阶段：构建最终的 Caddy 镜像
FROM caddy:2-alpine

# 将第一阶段下载并解压的 Caddy 可执行文件复制到最终镜像中
COPY --from=downloader /tmp/caddy /usr/bin/caddy

# 验证 Caddy 是否正确复制
RUN /usr/bin/caddy version

# 如果你有 Caddyfile 和其他配置，请在这里复制进来
# COPY ./Caddyfile /etc/caddy/Caddyfile
# COPY ./sites /etc/caddy/sites

# 暴露 Caddy 默认端口（增加 443/udp 以支持 HTTP/3 QUIC 和 L4 UDP）
EXPOSE 80 443 443/udp 2019

# 启动命令
ENTRYPOINT ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
