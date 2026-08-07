#!/bin/bash
set -euo pipefail

DISK_MIN_INODES=${DISK_MIN_INODES:-250000}        # docker needs lots

DOCKER_DIR="$(jq -r '."data-root" // "/var/lib/docker"' /etc/docker/daemon.json)"

DISK_MAX_USED_PERCENT=${DISK_MAX_USED_PERCENT:-90}
# NR==2 skips the header; strip % and output numeric percentage
disk_used_pct=$(df --output=pcent "$DOCKER_DIR" | awk 'NR==2 { sub(/%/, "", $1); print $1 }')
echo "Disk used: ${disk_used_pct:-0}% (cutoff ${DISK_MAX_USED_PERCENT}%)"
if [[ ${disk_used_pct:-0} -ge $DISK_MAX_USED_PERCENT ]]; then
  echo "Disk usage ${disk_used_pct:-0}% ≥ ${DISK_MAX_USED_PERCENT}% cutoff 🚨" >&2
  exit 1
fi

echo "Disk space free: $(df -k -h --output=avail "$DOCKER_DIR" | tail -n1 | sed -e 's/^[[:space:]]//')"

inodes_avail=$(df -k --output=iavail "$DOCKER_DIR" | tail -n1)

echo "Inodes free: $(df -k -h --output=iavail "$DOCKER_DIR" | tail -n1 | sed -e 's/^[[:space:]]//')"

if [[ $inodes_avail -lt $DISK_MIN_INODES ]]; then
  echo "Not enough inodes free: ${inodes_avail} available, cutoff is ${DISK_MIN_INODES} 🚨" >&2
  exit 1
fi
