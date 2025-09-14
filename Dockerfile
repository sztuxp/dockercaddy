# 使用多架构基础镜像
FROM alpine:latest

# 根据构建平台选择对应的二进制文件
ARG TARGETARCH
COPY caddy-${TARGETARCH} /usr/local/bin/caddy
RUN chmod +x /usr/local/bin/caddy

EXPOSE 80 443 2019

ENTRYPOINT ["caddy"]
CMD ["run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
