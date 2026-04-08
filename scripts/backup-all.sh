cat /opt/backup-all.sh 
#!/usr/bin/env bash
set -Eeuo pipefail

BACKUP_ROOT="/home/ubuntu/backups"
DATE="$(date +%F)"
TARGET_DIR="$BACKUP_ROOT/$DATE"
RETENTION_DAYS=7
SERVICES_DIR="/home/ubuntu/services"
OPENCLAW_DIR="/home/ubuntu/.openclaw"

mkdir -p "$TARGET_DIR"/{postgres,sqlite,archives,meta}

log() {
  printf '[%s] %s\n' "$(date '+%F %T')" "$*"
}

require_file() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    log "Missing required file: $path"
    exit 1
  fi
}

require_file "$SERVICES_DIR/vikunja/.env"
require_file "$SERVICES_DIR/n8n/.env"
require_file "$SERVICES_DIR/tandoor/.env"

set -a
source "$SERVICES_DIR/vikunja/.env"
VIKUNJA_DB_NAME="$POSTGRES_DB"
VIKUNJA_DB_USER="$POSTGRES_USER"
VIKUNJA_DB_PASSWORD="$POSTGRES_PASSWORD"
unset POSTGRES_DB POSTGRES_USER POSTGRES_PASSWORD

source "$SERVICES_DIR/n8n/.env"
N8N_DB_NAME="$POSTGRES_DB"
N8N_DB_USER="$POSTGRES_USER"
N8N_DB_PASSWORD="$POSTGRES_PASSWORD"
unset POSTGRES_DB POSTGRES_USER POSTGRES_PASSWORD

source "$SERVICES_DIR/tandoor/.env"
TANDOOR_DB_NAME="$POSTGRES_DB"
TANDOOR_DB_USER="$POSTGRES_USER"
TANDOOR_DB_PASSWORD="$POSTGRES_PASSWORD"
unset POSTGRES_DB POSTGRES_USER POSTGRES_PASSWORD
set +a

log "Writing metadata"
docker ps --format '{{.Names}}\t{{.Image}}\t{{.Status}}' > "$TARGET_DIR/meta/docker-ps.txt"
docker volume ls > "$TARGET_DIR/meta/docker-volumes.txt"

pg_dump_from_container() {
  local container="$1"
  local db_name="$2"
  local db_user="$3"
  local db_password="$4"
  local output_file="$5"

  log "Dumping PostgreSQL database: $db_name from $container"
  docker exec \
    -e PGPASSWORD="$db_password" \
    "$container" \
    pg_dump -U "$db_user" -d "$db_name" --clean --if-exists --no-owner --no-privileges > "$output_file"
}

pg_dump_from_container "vikunja-db" "$VIKUNJA_DB_NAME" "$VIKUNJA_DB_USER" "$VIKUNJA_DB_PASSWORD" "$TARGET_DIR/postgres/vikunja.sql"
pg_dump_from_container "n8n-db"     "$N8N_DB_NAME"     "$N8N_DB_USER"     "$N8N_DB_PASSWORD"     "$TARGET_DIR/postgres/n8n.sql"
pg_dump_from_container "tandoor-db" "$TANDOOR_DB_NAME" "$TANDOOR_DB_USER" "$TANDOOR_DB_PASSWORD" "$TARGET_DIR/postgres/tandoor.sql"

log "Backing up SQLite databases safely"

# Vaultwarden safe backup
if [[ -f "$SERVICES_DIR/vaultwarden/data/db.sqlite3" ]]; then
  sqlite3 "$SERVICES_DIR/vaultwarden/data/db.sqlite3" ".backup ${TARGET_DIR}/sqlite/vaultwarden.sqlite3"
fi

# Uptime Kuma safe backup
if [[ -f "$SERVICES_DIR/uptime-kuma/data/kuma.db" ]]; then
  sqlite3 "$SERVICES_DIR/uptime-kuma/data/kuma.db" ".backup ${TARGET_DIR}/sqlite/kuma.db"
fi

log "Archiving /home/ubuntu/services"
sudo tar -C /home/ubuntu -czf "$TARGET_DIR/archives/services.tar.gz" services

log "Cleaning browser cache before backup"
rm -rf /home/ubuntu/.openclaw/browser/openclaw/user-data/Default/Cache/
rm -rf /home/ubuntu/.openclaw/browser/openclaw/user-data/Default/"Code Cache"/

log "Archiving /home/ubuntu/.openclaw"
sudo tar -C /home/ubuntu -czf "$TARGET_DIR/archives/openclaw.tar.gz" \
  --exclude='.openclaw/extensions/lossless-claw/node_modules' \
  .openclaw

log "Archiving nginx config"
sudo tar -C /etc -czf "$TARGET_DIR/archives/nginx.tar.gz" nginx

log "Pruning backups older than $RETENTION_DAYS days"
find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -regextype posix-extended -regex '.*/[0-9]{4}-[0-9]{2}-[0-9]{2}' -mtime +$RETENTION_DAYS -print -exec rm -rf {} +

log "Backup complete: $TARGET_DIR"
