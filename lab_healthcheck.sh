#!/usr/bin/env bash
#
# lab_healthcheck.sh
#
# Purpose:
#   Checks whether the core services in my VirtualBox home lab
#   (SSH, Apache2, Samba) are running and reachable, plus a basic
#   network connectivity check. Logs every run with a timestamp so
#   I can show a history of the lab's uptime, not just a single
#   snapshot.
#
# Usage:
#   ./lab_healthcheck.sh
#
# Notes:
#   - Run this ON the Ubuntu Server VM itself (not from the host),
#     since it checks local service status via systemctl.
#   - Requires: bash, systemctl, curl, smbclient (optional), ping
#   - Exit code 0 = everything OK, 1 = at least one check failed
#
# Author: Thierry
# ---------------------------------------------------------------

set -uo pipefail

LOG_FILE="./lab_healthcheck.log"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"
OVERALL_OK=true

# --- helper: colored + logged output ---------------------------
log() {
    local level="$1"
    local message="$2"
    local color=""
    local reset="\033[0m"

    case "$level" in
        OK)   color="\033[0;32m" ;;  # green
        FAIL) color="\033[0;31m" ;;  # red
        INFO) color="\033[0;34m" ;;  # blue
    esac

    echo -e "${color}[${level}]${reset} ${message}"
    echo "${TIMESTAMP} [${level}] ${message}" >> "$LOG_FILE"
}

check_service() {
    local service_name="$1"

    if systemctl is-active --quiet "$service_name"; then
        log "OK" "${service_name} is running"
    else
        log "FAIL" "${service_name} is NOT running"
        OVERALL_OK=false
    fi
}

check_port() {
    local host="$1"
    local port="$2"
    local label="$3"

    if timeout 2 bash -c "echo > /dev/tcp/${host}/${port}" 2>/dev/null; then
        log "OK" "${label} port ${port} is open on ${host}"
    else
        log "FAIL" "${label} port ${port} is NOT reachable on ${host}"
        OVERALL_OK=false
    fi
}

check_gateway() {
    local gateway
    gateway="$(ip route | awk '/default/ {print $3; exit}')"

    if [[ -z "$gateway" ]]; then
        log "FAIL" "Could not determine default gateway"
        OVERALL_OK=false
        return
    fi

    if ping -c 1 -W 2 "$gateway" &>/dev/null; then
        log "OK" "Gateway ${gateway} is reachable"
    else
        log "FAIL" "Gateway ${gateway} is NOT reachable"
        OVERALL_OK=false
    fi
}

# --- run checks ---------------------------------------------------
log "INFO" "Starting lab health check"

check_gateway
check_service "ssh"
check_service "apache2"
check_service "smbd"

check_port "127.0.0.1" 22 "SSH"
check_port "127.0.0.1" 80 "Apache2"
check_port "127.0.0.1" 445 "Samba"

if $OVERALL_OK; then
    log "OK" "All checks passed"
    exit 0
else
    log "FAIL" "One or more checks failed — see ${LOG_FILE}"
    exit 1
fi
