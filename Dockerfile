# The `temp-builder` stage
FROM --platform=$BUILDPLATFORM alpine AS temp-builder

# Set the working directory
WORKDIR /app

# Copy the binaries into the temporary build stage
COPY caddy-amd64 caddy-amd64
COPY caddy-arm64 caddy-arm64

# Use ARG to get the target architecture from buildx
ARG TARGETARCH

# Based on the architecture, copy the correct binary to a temporary location
RUN case "$TARGETARCH" in \
        "amd64") cp caddy-amd64 /temp/caddy ;; \
        "arm64") cp caddy-arm64 /temp/caddy ;; \
        *) echo "Unsupported architecture: $TARGETARCH" && exit 1 ;; \
    esac

# The `final-builder` stage
FROM caddy:builder-alpine

# Copy the single correct binary from the temp-builder stage
COPY --from=temp-builder /temp/caddy /usr/bin/caddy

# Set the final binary as executable
RUN chmod +x /usr/bin/caddy

# Set the default command and exposed ports
ENTRYPOINT ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
EXPOSE 80 443 2019

# Define volumes for persistence
VOLUME /data /config
WORKDIR /srv
