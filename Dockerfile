# 第一阶段：下载并准备 Caddy 二进制文件
FROM alpine:3.18 as downloader

# Docker Buildx 会自动为 TARGETARCH 赋值 (amd64, arm64)
ARG TARGETARCH

WORKDIR /tmp

# 根据 TARGETARCH 变量下载对应的 Caddy 二进制文件
RUN if [ "$TARGETARCH" = "amd64" ]; then \
      curl -L "https://github.com/lxhao61/integrated-examples/releases/download/20250826/caddy-linux-amd64.tar.gz" -o caddy.tar.gz; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
      curl -L "https://github.com/lxhao61/integrated-examples/releases/download/20250826/caddy-linux-arm64.tar.gz" -o caddy.tar.gz; \
    else \
      echo "Unsupported architecture: $TARGETARCH"; exit 1; \
    fi

# 解压文件
RUN tar -xzf caddy.tar.gz

# 第二阶段：构建最终的 Caddy 镜像
FROM caddy:2.7.6-alpine

# 将第一阶段下载并解压的 Caddy 可执行文件复制到最终镜像中
COPY --from=downloader /tmp/caddy /usr/bin/caddy

# 验证 Caddy 是否正确复制
RUN /usr/bin/caddy version

# 如果你有 Caddyfile 和其他配置，请在这里复制进来
# COPY ./Caddyfile /etc/caddy/Caddyfile
# COPY ./sites /etc/caddy/sites

# 暴露 Caddy 默认端口
EXPOSE 80 443 2019

# 启动命令
ENTRYPOINT ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
