# Personal server infrastructure

PPPersonal server infrastructure for Oracle Cloud VPS (arm64).

## Host

Oracle Cloud free tier — ARM64 (Ampere A1)  
4 cores · 24 GB RAM · Ubuntu 24.04.4 LTS

## Architecture

All services bind to `127.0.0.1` by default. Public-facing services 
are exposed via nginx reverse proxy with TLS termination using 
Let's Encrypt certificates (Certbot) on DuckDNS subdomains. 
Firewall allows inbound on ports 22, 80, and 443 only.

## Services

| Service | How it runs | Port / bind | Public exposure |
|---|---|---|---|
| Gitea | Docker Compose | `127.0.0.1:3000` | no |
| Uptime Kuma | Docker Compose (`network_mode: host`) | `*:3001` | yes, via nginx + TLS |
| Grafana | Docker Compose | `127.0.0.1:3002` | no |
| Homepage | Docker Compose | `127.0.0.1:3005` | no |
| Vikunja | Docker Compose | `127.0.0.1:3456` | no |
| n8n | Docker Compose | `127.0.0.1:5678` | yes, via nginx + TLS |
| Tandoor | Docker Compose | `127.0.0.1:8001` | no |
| Vaultwarden | Docker Compose | `127.0.0.1:8082` | yes, via nginx + TLS |
| Portainer | Docker Compose | `127.0.0.1:9000` | no |
| Prometheus | Docker Compose | `127.0.0.1:9090` | no |
| node_exporter | Docker Compose | `127.0.0.1:9100` | no |
| OpenClaw | systemd user service (`~/.config/systemd/user/openclaw-gateway.service`) | gateway `127.0.0.1:18789`, browser debug `127.0.0.1:18800` | no |
| nginx | system package | `*:80`, `*:443` | yes |
| ssh | system package | `*:22` | yes |

## Repo layout

```text
docker/                  # tracked compose files matching live services
docs/
  services.md            # per-service runtime, ports, data paths
  networking.md          # listening ports, firewall, reverse proxy notes
  operations.md          # start/stop, updates, restore and backup notes
  backups.md             # backup/restore checklist
  todo.md                # known gaps and follow-ups
```

Live service data currently lives under `/home/ubuntu/services/<service>/`.

## Quick links

- [Services](docs/services.md)
- [Networking](docs/networking.md)
- [Operations](docs/operations.md)
- [Backups](docs/backups.md)
- [TODO](docs/todo.md)

