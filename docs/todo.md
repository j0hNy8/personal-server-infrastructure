# TODO / Known Gaps

## High priority

- [x] **Document OCI ingress rules** — host `ufw` is verified (`22/80/443` allowed, default deny incoming), and OCI currently exposes only `22/80/443` publicly. **Still needed:** capture the actual OCI Security List / NSG ingress/egress rules in repo docs.
- [x] **Document intentional Uptime Kuma networking** — live compose keeps `network_mode: host`, but `UPTIME_KUMA_HOST=127.0.0.1` now binds Kuma to localhost only. nginx proxies `**redacted**.duckdns.org` to `127.0.0.1:3001`, and monitors are working again.
- [ ] **Backups need real automation and off-host retention** — coverage docs are much better now, and a nightly `/home/ubuntu/scripts/backup-all.sh` cron exists (`0 2 * * *`), but off-host retention and restore verification are still not documented here. **Still needed:** document what the script actually backs up, where it stores copies, retention, and restore-test status.

## Medium priority

- [x] **Track nginx config in git** — copied the active reverse-proxy vhosts for Uptime Kuma, Vaultwarden, and n8n into `docs/nginx/` and referenced them from repo docs.
- [ ] **Track certbot/domain inventory** — active DuckDNS hostnames and certs are live (`**redacted**.duckdns.org`, `**redacted**.duckdns.org`, `**redacted**.duckdns.org`), but repo docs do not yet inventory them cleanly. **Still needed:** add a small domain/certificate inventory with renewal method and ownership notes.
- [ ] **SSH hardening doc** — live host now verifies `PasswordAuthentication no`, `KbdInteractiveAuthentication no`, and `fail2ban` jail `sshd` is active. **Still needed:** document `PermitRootLogin`, pubkey expectations, and the current brute-force protection posture in repo docs, if that follow-up is still relevant.
- [ ] **Pin container versions intentionally** — `:latest` is still used by Gitea, Vikunja, Postgres, Vaultwarden, n8n, Grafana, Prometheus, node-exporter, and Portainer. **Still needed:** choose pinned tags/digests and record update policy.
- [ ] **Add env examples / per-service repo guidance** — compose files are mirrored already, but repo-side env examples and service-specific setup notes are still sparse. **Still needed:** add `.env.example` patterns and short per-service notes where setup is non-obvious.

## Low priority / nice to have

- [ ] **Add service install/runbooks** for n8n, Vaultwarden, Homepage, Monitoring, Portainer, and Tandoor.
- [ ] **Resource limits** — no CPU/memory limits are set in the tracked Docker Compose files. **Still needed:** define sane `cpus` / memory constraints per service.
- [ ] **Log rotation** — host `logrotate.timer` exists, but container log growth/retention was not verified in this pass. **Still needed:** inspect Docker log driver/settings and document retention.
- [ ] **Expose selected internal apps cleanly** — if Gitea, Vikunja, Grafana, or Homepage should become public later, add nginx vhosts + TLS instead of raw port exposure.

## Done

- [x] Repo docs updated to match verified live host state on `2026-04-07`
- [x] Verified nginx now terminates TLS on `80/443` for Uptime Kuma, Vaultwarden, and n8n
- [x] Verified Vikunja is live on `127.0.0.1:3456`
- [x] Verified `task-tracker` is no longer present (`systemd` not found, no listener)
- [x] Added tracked compose files for Homepage, Monitoring, n8n, Portainer, Tandoor, and Vaultwarden
- [x] Verified OpenClaw gateway user unit now loads secrets via `EnvironmentFile=/home/ubuntu/.openclaw/.env` instead of embedding them directly in the unit
