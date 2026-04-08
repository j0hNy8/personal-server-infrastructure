# Services

Verification date: `2026-04-08`

## Gitea

Self-hosted Git service.

- **Runtime**: Docker Compose (`docker/gitea.yaml`)
- **Image**: `gitea/gitea:1.25.5`
- **Port**: `127.0.0.1:3000`
- **Exposure**: localhost only
- **Live data path**: `/home/ubuntu/services/gitea/data/`
- **Config note**: `ROOT_URL` is still `http://127.0.0.1:3000/`

## Uptime Kuma

Service monitoring dashboard.

- **Runtime**: Docker Compose (`docker/uptime-kuma.yaml`)
- **Image**: `louislam/uptime-kuma:2.2.1`
- **Port**: `127.0.0.1:3001`
- **Network mode**: `host`
- **Bind control**: `UPTIME_KUMA_HOST=127.0.0.1`
- **Public access**: proxied by nginx at `**redacted**.duckdns.org`
- **Live data path**: `/home/ubuntu/services/uptime-kuma/data/`
- **Current posture**: host networking is kept intentionally, but direct access is limited to localhost and exposed publicly only through nginx/TLS

## Vikunja

Task/project management app.

- **Runtime**: Docker Compose (`docker/vikunja.yaml`)
- **Image**: `vikunja/vikunja:2.2.2`
- **Database**: `postgres:18.3` in Docker on the same host
- **Port**: `127.0.0.1:3456`
- **Exposure**: localhost only right now
- **Live env path**: `/home/ubuntu/services/vikunja/.env`
- **Live data paths**:
  - `/home/ubuntu/services/vikunja/db/`
  - `/home/ubuntu/services/vikunja/files/`
- **Runtime note**: container runs as `1001:1001`, with `HOME` and `XDG_CACHE_HOME` pointed at the files volume

## Vaultwarden

Password manager.

- **Runtime**: Docker Compose (`docker/vaultwarden.yaml`)
- **Image**: `vaultwarden/server:1.35.4`
- **Port**: `127.0.0.1:8082`
- **Public access**: proxied by nginx at `**redacted**.duckdns.org`
- **Live data path**: `/home/ubuntu/services/vaultwarden/data/`
- **Live env path**: `/home/ubuntu/services/vaultwarden/.env`

## n8n

Workflow automation service.

- **Runtime**: Docker Compose (`docker/n8n.yaml`)
- **Image**: `n8nio/n8n:1.123.29`
- **Port**: `127.0.0.1:5678`
- **Public access**: proxied by nginx at `**redacted**.duckdns.org`
- **Live env path**: `/home/ubuntu/services/n8n/.env`
- **Live data paths**:
  - `/home/ubuntu/services/n8n/data/`
  - `/home/ubuntu/services/n8n/db/`
- **Database**: dedicated local Postgres container `n8n-db` (`postgres:18.3`)
- **Dependency note**: n8n depends on `n8n-db`; it does not share the Vikunja database

## Homepage

Start page / dashboard.

- **Runtime**: Docker Compose (`docker/homepage.yaml`)
- **Image**: `ghcr.io/gethomepage/homepage:v1.12.3`
- **Port**: `127.0.0.1:3005`
- **Exposure**: localhost only
- **Live config path**: `/home/ubuntu/services/homepage/config/`

## Monitoring stack

### Grafana

- **Runtime**: Docker Compose (`docker/monitoring.yaml`)
- **Image**: `grafana/grafana:12.4.2`
- **Port**: `127.0.0.1:3002`
- **Exposure**: localhost only
- **Live data path**: `/home/ubuntu/services/monitoring/grafana/data/`

### Prometheus

- **Runtime**: Docker Compose (`docker/monitoring.yaml`)
- **Image**: `prom/prometheus:v3.11.0`
- **Port**: `127.0.0.1:9090`
- **Exposure**: localhost only
- **Live config/data path**:
  - `/home/ubuntu/services/monitoring/prometheus/prometheus.yml`
  - `/home/ubuntu/services/monitoring/prometheus/data/`

### node_exporter

- **Runtime**: Docker Compose (`docker/monitoring.yaml`)
- **Image**: `prom/node-exporter:v1.10.2`
- **Port**: `127.0.0.1:9100`
- **Exposure**: localhost only
- **Runtime note**: `pid: host`, host root mounted read-only at `/:/host`

## Tandoor

Recipe manager.

- **Runtime**: Docker Compose (`docker/tandoor.yaml`)
- **Image**: `vabene1111/recipes:2.6.4`
- **Port**: `127.0.0.1:8001`
- **Exposure**: localhost only
- **Live env path**: `/home/ubuntu/services/tandoor/.env`
- **Live data paths**:
  - `/home/ubuntu/services/tandoor/staticfiles/`
  - `/home/ubuntu/services/tandoor/mediafiles/`
  - `/home/ubuntu/services/tandoor/db/`
- **Database**: dedicated local Postgres container `tandoor-db` (`postgres:18.3`)
- **Dependency note**: Tandoor depends on `tandoor-db`; it does not share the Vikunja database

## Portainer

Docker management UI.

- **Runtime**: Docker Compose (`docker/portainer.yaml`)
- **Image**: `portainer/portainer-ce:2.39.1`
- **Port**: `127.0.0.1:9000`
- **Exposure**: localhost only
- **Live data path**: `/home/ubuntu/services/portainer/data/`
- **Privilege note**: Docker socket mounted from `/var/run/docker.sock`

## OpenClaw

AI agent platform.

- **Runtime**: systemd **user** service → `~/.config/systemd/user/openclaw-gateway.service`
- **Enablement**: `enabled`
- **Gateway bind**: `127.0.0.1:18789`
- **Related browser debug bind**: `127.0.0.1:18800`
- **Binary path**: `/usr/bin/node /home/ubuntu/.nvm/versions/node/v22.22.0/lib/node_modules/openclaw/dist/index.js gateway --port 18789`
- **Data/config**: `~/.openclaw/`

Operational note:

- the unit file now loads secrets via `EnvironmentFile=/home/ubuntu/.openclaw/.env`

## nginx

Reverse proxy / web server (system package, not Docker).

- **Status**: installed, active, listening on `*:80` and `*:443`
- **Current use**: reverse proxies are active for Uptime Kuma, Vaultwarden, and n8n with Certbot-managed TLS
- **Tracked repo copies**: `docs/nginx/uptime-kuma.conf`, `docs/nginx/vaultwarden.conf`, `docs/nginx/n8n.conf`

## ssh

- **Status**: active, listening on `*:22`
- **Firewall**: allowed via ufw 
