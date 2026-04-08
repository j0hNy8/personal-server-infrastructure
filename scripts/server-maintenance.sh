#!/bin/bash

LOG_FILE="/var/log/automated-maintenance.log"
echo -e "\n=== System Maintenance Started: $(date) ===" >> "$LOG_FILE"

# 1. Update package lists
echo "--> Updating package lists..." >> "$LOG_FILE"
apt-get update -y >> "$LOG_FILE" 2>&1

# 2. Upgrade system packages
# DEBIAN_FRONTEND=noninteractive prevents the script from getting stuck if an update asks a Y/N question
echo "--> Upgrading packages..." >> "$LOG_FILE"
DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq >> "$LOG_FILE" 2>&1

# 3. Clean up old, unused dependencies and downloaded archives
echo "--> Cleaning up system..." >> "$LOG_FILE"
apt-get autoremove -y >> "$LOG_FILE" 2>&1
apt-get clean >> "$LOG_FILE" 2>&1

# 4. Vacuum system logs (keeps only the last 14 days of logs to prevent disk space exhaustion)
echo "--> Clearing old system logs..." >> "$LOG_FILE"
journalctl --vacuum-time=14d >> "$LOG_FILE" 2>&1

echo "=== Maintenance Finished: $(date) ===" >> "$LOG_FILE"

# 5. Smart Reboot Logic
# Ubuntu automatically creates this file if a kernel/core update needs a restart
if [ -f /var/run/reboot-required ]; then
    echo "⚠️ Reboot required by system updates. Restarting server now..." >> "$LOG_FILE"
    reboot
fi
