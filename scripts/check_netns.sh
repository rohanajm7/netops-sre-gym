#!/bin/sh
# Checks that this container can do what the sandbox needs: create network
# namespaces, wire them with a veth pair, forward packets and filter them.
set -eu

A=chk-a-$$
B=chk-b-$$
cleanup() {
    ip netns del "$A" 2>/dev/null || true
    ip netns del "$B" 2>/dev/null || true
}
trap cleanup EXIT

ip netns add "$A"
ip netns add "$B"
ip link add veth-a netns "$A" type veth peer name veth-b netns "$B"
ip -n "$A" addr add 10.255.0.1/24 dev veth-a
ip -n "$B" addr add 10.255.0.2/24 dev veth-b
ip -n "$A" link set veth-a up
ip -n "$B" link set veth-b up

ip netns exec "$A" ping -c 1 -W 1 10.255.0.2 >/dev/null
echo "ok  namespaces + veth + ping"

ip netns exec "$B" sysctl -qw net.ipv4.ip_forward=1
echo "ok  ip_forward"

ip netns exec "$B" iptables -I FORWARD -p tcp --dport 5432 -j DROP
ip netns exec "$B" iptables -C FORWARD -p tcp --dport 5432 -j DROP
echo "ok  iptables"

for tool in dig traceroute curl ss dnsmasq; do
    command -v "$tool" >/dev/null || { echo "missing tool: $tool"; exit 1; }
done
echo "ok  tools"
