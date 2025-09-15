# 使用一个轻量级的 Caddy 镜像作为基础
FROM caddy:2.7.6-alpine

# Caddy 可执行文件将被复制到这个路径，我们假设它们在工作流的某个子目录中
# ARG TARGETARCH 变量由 github actions 自动提供，根据目标平台为 amd64 或 arm64
ARG TARGETARCH

# 将编译好的 Caddy 可执行文件复制到镜像中
# 假设在工作流中，我们下载并解压的二进制文件路径是 `./artifacts/caddy-binaries-linux-${TARGETARCH}/caddy-linux-${TARGETARCH}`
COPY ./artifacts/caddy-binaries-linux-${TARGETARCH}/caddy-linux-${TARGETARCH} /usr/bin/caddy

# 验证 Caddy 是否正确复制
RUN /usr/bin/caddy version

# 如果你有 Caddyfile 和其他配置，请在这里复制进来
# COPY ./Caddyfile /etc/caddy/Caddyfile
# COPY ./sites /etc/caddy/sites

# 暴露 Caddy 默认端口
EXPOSE 80 443 2019

# 启动命令
ENTRYPOINT ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
