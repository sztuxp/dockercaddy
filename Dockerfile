# 第一阶段: 从一个临时镜像开始，复制正确的架构二进制文件
# 我们使用 BUILDPLATFORM 变量，它会自动匹配构建机架构
FROM --platform=$BUILDPLATFORM busybox AS temp-builder

ARG TARGETARCH

# 根据不同的 TARGETARCH 复制相应的二进制文件
# --from=temp-builder 指令是多余的，但为了清晰，我们保留它
RUN case "$TARGETARCH" in \
        "amd64") cp caddy-amd64 /temp/caddy ;; \
        "arm64") cp caddy-arm64 /temp/caddy ;; \
        *) echo "Unsupported architecture: $TARGETARCH" && exit 1 ;; \
    esac

# 第二阶段: 构建最终的镜像
FROM caddy:builder-alpine AS final-builder

# 将第一阶段的 caddy 二进制文件复制到最终镜像中
COPY --from=temp-builder /temp/caddy /usr/bin/caddy

# 其他配置保持不变
ENTRYPOINT ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
EXPOSE 80 443 2019
VOLUME /data /config
WORKDIR /srv
