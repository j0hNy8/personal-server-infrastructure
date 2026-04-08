# Operations

## Scheduled jobs

| Schedule | Script | Log | Cron owner |
|---|---|---|---|
| 02:00 daily | `/opt/backup-all.sh` | `/var/log/backups.log` | root |
| 03:00 Sunday | `/opt/server-maintenance.sh` | `/var/log/automated-maintenance.log` | root |

### server-maintenance.sh

Weekly system maintenance. Runs as root via root crontab.

What it does:
1. `apt-get update` — refreshes package lists
2. `apt-get upgrade` — installs available updates non-interactively
3. `apt-get autoremove && apt-get clean` — removes unused packages and cached archives
4. `journalctl --vacuum-time=14d` — deletes journal archives older than 14 days
5. Smart reboot — checks `/var/run/reboot-required` and reboots if a kernel update needs it

Known issue: if `unattended-upgrades` holds the apt lock when the script runs, the update/upgrade steps fail silently but the rest continues. Consider disabling `unattended-upgrades` since this script handles updates anyway.

### backup-all.sh

See [Backups](backups.md) for full documentation.

## Start / stop services

### Docker services

```bash
cd ~/repos/infra/docker

# Gitea
docker compose -f gitea-compose.yaml up -d
docker compose -f gitea-compose.yaml down

# Uptime Kuma
docker compose -f uptime-kuma-compose.yaml up -d
docker compose -f uptime-kuma-compose.yaml down

# Vikunja
docker compose -f vikunja-compose.yaml up -d
docker compose -f vikunja-compose.yaml down

# Vaultwarden
docker compose -f vaultwarden-compose.yaml up -d
docker compose -f vaultwarden-compose.yaml down

# n8n
docker compose -f n8n-compose.yaml up -d
docker compose -f n8n-compose.yaml down

# Homepage
docker compose -f homepage-compose.yaml up -d
docker compose -f homepage-compose.yaml down

# Monitoring stack
docker compose -f monitoring-compose.yaml up -d
docker compose -f monitoring-compose.yaml down

# Portainer
docker compose -f portainer-compose.yaml up -d
docker compose -f portainer-compose.yaml down

# Tandoor
docker compose -f tandoor-compose.yaml up -d
docker compose -f tandoor-compose.yaml down

# Check containers
docker ps
```

### systemd user services

```bash
systemctl --user status openclaw-gateway
systemctl --user restart openclaw-gateway
journalctl --user -u openclaw-gateway -f
```

### systemd system services

```bash
sudo systemctl status nginx
sudo systemctl reload nginx
```

## Updating services

### Dockerized services

Preferred flow for each tracked compose file:

```bash
cd ~/repos/infra/docker
$EDITOR <service-compose>.yaml
docker compose -f <service-compose>.yaml pull
docker compose -f <service-compose>.yaml up -d
```

Relevant compose files:

- `gitea-compose.yaml`
- `uptime-kuma-compose.yaml`
- `vikunja-compose.yaml`
- `vaultwarden-compose.yaml`
- `n8n-compose.yaml`
- `homepage-compose.yaml`
- `monitoring-compose.yaml`
- `portainer-compose.yaml`
- `tandoor-compose.yaml`

Check logs after updates:

```bash
docker logs gitea --tail 100
docker logs uptime-kuma --tail 100
docker logs vikunja --tail 100
docker logs vikunja-db --tail 100
docker logs vaultwarden --tail 100
docker logs n8n --tail 100
docker logs homepage --tail 100
docker logs grafana --tail 100
docker logs prometheus --tail 100
docker logs portainer --tail 100
docker logs tandoor --tail 100
```

### Update OpenClaw

```bash
npm update -g openclaw
systemctl --user restart openclaw-gateway
```

### nginx and certbot

```bash
sudo nginx -t
sudo systemctl reload nginx
sudo certbot certificates
```

## Logs

```bash
docker logs gitea --tail 50 -f
docker logs uptime-kuma --tail 50 -f
docker logs vikunja --tail 50 -f
docker logs vikunja-db --tail 50 -f
docker logs vaultwarden --tail 50 -f
docker logs n8n --tail 50 -f
docker logs homepage --tail 50 -f
docker logs grafana --tail 50 -f
docker logs prometheus --tail 50 -f
docker logs portainer --tail 50 -f
docker logs tandoor --tail 50 -f
journalctl --user -u openclaw-gateway -f
sudo journalctl -u nginx -f
```

## Useful checks

```bash
# Listening ports
ss -tlnp

# Container state
docker ps

# Firewall
sudo ufw status verbose
sudo iptables -S

# nginx sites
ls -l /etc/nginx/sites-enabled
sudo nginx -T

# Disk usage
df -h
du -sh /home/ubuntu/services/*
```
