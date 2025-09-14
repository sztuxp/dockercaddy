# 使用官方 Caddy 基础镜像，它已经为我们准备好了环境
FROM caddy:latest

# 复制对应架构的 Caddy 二进制文件到镜像中
# $TARGETARCH 变量将由 GitHub Actions 自动传入，值为 amd64 或 arm64
COPY ./caddy-${TARGETARCH} /usr/bin/caddy

# 暴露 Caddy 的默认端口
EXPOSE 80 443 443/udp

# 启动 Caddy
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
