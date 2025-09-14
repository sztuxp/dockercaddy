# 第一阶段: builder
# 从一个轻量级基础镜像开始，用于复制二进制文件
FROM --platform=$BUILDPLATFORM busybox AS builder

# 将宿主机构建上下文中的两个二进制文件复制到容器的 /app 目录下
COPY caddy-amd64 /app/caddy-amd64
COPY caddy-arm64 /app/caddy-arm64

# 第二阶段: final
# 从官方 Caddy 镜像的 builder-alpine 阶段开始
FROM caddy:builder-alpine

# 从第一阶段复制正确的二进制文件到最终镜像
ARG TARGETARCH
COPY --from=builder /app/caddy-${TARGETARCH} /usr/bin/caddy

# 确保二进制文件可执行
RUN chmod +x /usr/bin/caddy

# 保持 Caddy 的标准配置
EXPOSE 80 443 2019
VOLUME /data /config
WORKDIR /srv
