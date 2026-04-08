# Networking

## Host

- **Provider**: Oracle Cloud (arm64 VM)
- **Hostname**: `openclaw-main-2026`
- **OS**: Ubuntu 24.04.4 LTS
- **Kernel**: `6.17.0-1009-oracle`
- **Verification date**: `2026-04-07`

## Listening ports (verified locally)

Source commands used:

```bash
ss -tlnp
sudo ufw status verbose
sudo iptables -S
```

| Port | Bound to | Service | Verified state |
|---|---|---|---|
| 22 | `*` | ssh | exposed and explicitly allowed in ufw |
| 80 | `*` | nginx | exposed and explicitly allowed in ufw |
| 443 | `*` | nginx | exposed and explicitly allowed in ufw |
| 3000 | `127.0.0.1` | Gitea | localhost only |
| 3001 | `*` | Uptime Kuma (Docker, host network) | broad bind, but public path is intended via nginx/TLS |
| 3002 | `127.0.0.1` | Grafana | localhost only |
| 3005 | `127.0.0.1` | Homepage | localhost only |
| 3456 | `127.0.0.1` | Vikunja | localhost only |
| 5678 | `127.0.0.1` | n8n | localhost only |
| 8001 | `127.0.0.1` | Tandoor | localhost only |
| 8082 | `127.0.0.1` | Vaultwarden | localhost only |
| 9000 | `127.0.0.1` | Portainer | localhost only |
| 9090 | `127.0.0.1` | Prometheus | localhost only |
| 9100 | `127.0.0.1` | node_exporter | localhost only |
| 18789 | `127.0.0.1` and `::1` | OpenClaw gateway | localhost only |
| 18800 | `127.0.0.1` | Chromium remote debugging | localhost only |

## nginx reverse proxy and TLS

Current nginx state from enabled sites:

- `**redacted**.duckdns.org` → `http://127.0.0.1:3001`
- `**redacted**.duckdns.org` → `http://127.0.0.1:8082`
- `**redacted**.duckdns.org` → `http://127.0.0.1:5678`
- all three have Certbot-managed TLS on `:443`
- no proxy vhost is configured for Gitea, Vikunja, Grafana, Homepage, Portainer, Prometheus, or Tandoor

## Uptime Kuma exposure status

### What is verified

- `ss -tlnp` shows port `3001` listening on `*`
- live compose uses `network_mode: host`
- ufw allows inbound `80/tcp` and `443/tcp`, not `3001/tcp`
- nginx proxies `**redacted**.duckdns.org` to `127.0.0.1:3001`

### Practical conclusion

Uptime Kuma is intentionally reachable publicly through nginx on HTTPS, while direct access to `3001/tcp` is not explicitly allowed in ufw.

## Firewall

Current host firewall posture:

- ufw: **active**
- default incoming: **deny**
- default outgoing: **allow**
- explicit inbound allow: **22/tcp**, **80/tcp**, **443/tcp**

Useful checks:

```bash
sudo ufw status verbose
sudo iptables -S
```

## SSH

Verified locally:

- sshd listens on `*:22`
- ufw allows `22/tcp`

Still worth documenting separately later:

- key-only auth status
- root-login policy
- fail2ban or equivalent

## Caveats

- OCI Security List / NSG rules were not inspected in this pass
- some extra localhost listeners were visible (`39201`, `43293`) but were not treated as stable infrastructure endpoints
