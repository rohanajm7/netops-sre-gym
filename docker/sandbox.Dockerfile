# Privileged container that hosts the network namespaces and runs netopsd.

# Networking tools shared by the dev and runtime stages.
FROM debian:bookworm-slim AS base
RUN apt-get update && apt-get install -y --no-install-recommends \
        iproute2 iptables iputils-ping traceroute dnsutils dnsmasq curl procps ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Go toolchain on top of the tools, so namespace tests can run here.
FROM base AS dev
COPY --from=golang:1.24-bookworm /usr/local/go /usr/local/go
ENV PATH=/usr/local/go/bin:$PATH CGO_ENABLED=0
WORKDIR /src/daemon
COPY daemon/ .
RUN go build -o /out/netopsd ./cmd/netopsd

FROM base AS sandbox
COPY --from=dev /out/netopsd /usr/local/bin/netopsd
WORKDIR /app
COPY scripts/ scripts/
EXPOSE 8700
CMD ["netopsd"]
