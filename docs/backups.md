Log: `/var/log/backups.log`

## Current data protected

| Service | Type | What is backed up |
|---|---|---|
| Vikunja | PostgreSQL dump | Database via pg_dump |
| n8n | PostgreSQL dump | Database via pg_dump |
| Tandoor | PostgreSQL dump | Database via pg_dump |
| Vaultwarden | SQLite | `data/db.sqlite3` via sqlite3 .backup |
| Uptime Kuma | SQLite | `kuma.db` via sqlite3 .backup |
| All services | tar archive | `/home/ubuntu/services/` |
| OpenClaw | tar archive | `/home/ubuntu/.openclaw/` |
| Docker state | metadata | `docker ps`, `docker volume ls` output |
| nginx config | tar archive | `/etc/nginx/` |


## What is NOT backed up

- Let's Encrypt certificates (`/etc/letsencrypt/`) — reissue with certbot if lost
- systemd unit files — tracked in this repo under `systemd/`

## Backup location

Local only: `/home/ubuntu/backups/YYYY-MM-DD/`  
Retention: 7 days.  
**No off-host backup exists yet** — if the VPS is lost, all backups are lost with it.

## Restore

### Generic Docker service
```bash
# Stop the affected stack
docker compose -f ~/repos/personal-server-infrastructure/docker/<service>.yaml down

# Restore archive
tar -xzf ~/backups/YYYY-MM-DD/archives/services.tar.gz \
  -C /home/ubuntu --strip-components=1 services/<service>/

# Start and verify
docker compose -f ~/repos/personal-server-infrastructure/docker/<service>.yaml up -d
docker logs <service> --tail 50
```

### PostgreSQL restore
```bash
docker compose -f ~/repos/personal-server-infrastructure/docker/vikunja.yaml down
cat ~/backups/YYYY-MM-DD/postgres/vikunja.sql | \
  docker exec -i vikunja-db psql -U vikunja vikunja
docker compose -f ~/repos/personal-server-infrastructure/docker/vikunja.yaml up -d
```

### SQLite restore
```bash
# Stop the service first
docker compose -f ~/repos/personal-server-infrastructure/docker/vaultwarden.yaml down

# Replace the live database
cp ~/backups/YYYY-MM-DD/sqlite/vaultwarden.sqlite3 \
  /home/ubuntu/services/vaultwarden/data/db.sqlite3

# Start and verify
docker compose -f ~/repos/personal-server-infrastructure/docker/vaultwarden.yaml up -d
```

## Known gaps

- No off-host backup — OCI Object Storage or Backblaze B2 via rclone is the recommended next step
- Restore procedure has not been tested against a real failure
- Let's Encrypt certificates are not included in automated backup
