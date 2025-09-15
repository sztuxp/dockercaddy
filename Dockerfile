FROM alpine:latest
RUN apk --no-cache add ca-certificates tzdata
COPY caddy /usr/bin/caddy
RUN chmod +x /usr/bin/caddy
RUN adduser -D -H -u 1001 caddy
USER caddy
EXPOSE 80 443 2019
ENTRYPOINT ["/usr/bin/caddy"]
CMD ["run", "--config", "/etc/caddy/Caddyfile"]
