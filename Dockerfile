# Dockerfile
# 使用多阶段构建来明确指定基础镜像的架构
# BUILDPLATFORM 将被设置为例如 linux/amd64 或 linux/arm64
# 这能确保我们从一个正确的、原生的基础镜像开始
FROM --platform=$BUILDPLATFORM caddy:latest

# 定义一个名为 TARGETARCH 的构建参数
ARG TARGETARCH

# 复制对应架构的 Caddy 二进制文件到镜像中
# $TARGETARCH 变量将由 GitHub Actions 自动传入，值为 amd64 或 arm64
COPY ./caddy-${TARGETARCH} /usr/bin/caddy

# 暴露 Caddy 的默认端口
EXPOSE 80 443 443/udp

# 启动 Caddy
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
