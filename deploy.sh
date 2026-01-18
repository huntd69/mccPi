#!/usr/bin/env bash
set -euo pipefail

# mccPi deploy.sh
# Golden-path entrypoint: curl from GitHub, clone into /opt, run deployment.
# Idempotent: safe to re-run for upgrades.

REPO_URL_DEFAULT="https://github.com/huntd69/mccPi.git"
INSTALL_DIR_DEFAULT="/opt/mccPi"
BRANCH_DEFAULT="main"

log() {
  # Plain-text logs; when run under systemd, these will appear in journalctl.
  printf '%s %s\n' "$(date -Is)" "$*"
}

die() {
  log "ERROR: $*"
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

require_root() {
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    die "This script must be run as root (expected workflow: ssh radio@mccpi.local → sudo su)"
  fi
}

clone_or_update_repo() {
  local repo_url="$1"
  local install_dir="$2"
  local branch="$3"

  need_cmd git

  if [[ -d "${install_dir}/.git" ]]; then
    log "Updating existing repo in ${install_dir}"
    git -C "$install_dir" fetch --prune origin "$branch"
    git -C "$install_dir" checkout -q "$branch"
    git -C "$install_dir" reset --hard "origin/${branch}"
  else
    log "Cloning ${repo_url} into ${install_dir}"
    rm -rf "$install_dir"
    git clone --branch "$branch" --single-branch "$repo_url" "$install_dir"
  fi
}

bootstrap_base() {
  # Base filesystem layout and logs.
  local log_dir="/var/log/mccpi"
  local tx_log="${log_dir}/tx.log"
  local config_dir="/etc/mccpi"
  local config_file="${config_dir}/config.env"

  log "Creating base directories"
  install -d -m 0755 "$log_dir" "$config_dir"

  log "Ensuring TX log exists at ${tx_log}"
  touch "$tx_log"
  chmod 0644 "$tx_log"

  if [[ ! -f "$config_file" ]]; then
    log "Creating default config at ${config_file}"
    cat >"$config_file" <<'EOF'
# mccPi configuration
# Callsign is REQUIRED before enabling any transmit-capable modules.
CALLSIGN=""

# MUST be set to 1 to enable any transmit-capable modules.
DISCLAIMER_ACCEPTED=0
EOF
    chmod 0644 "$config_file"
  else
    log "Config exists at ${config_file} (leaving as-is)"
  fi

  log "Base bootstrap complete"
}

main() {
  local repo_url="$REPO_URL_DEFAULT"
  local install_dir="$INSTALL_DIR_DEFAULT"
  local branch="$BRANCH_DEFAULT"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --repo)
        repo_url="$2"; shift 2 ;;
      --dir)
        install_dir="$2"; shift 2 ;;
      --branch)
        branch="$2"; shift 2 ;;
      -h|--help)
        cat <<EOF
mccPi deploy.sh

Golden path:
  curl -fsSL https://raw.githubusercontent.com/huntd69/mccPi/${BRANCH_DEFAULT}/deploy.sh | sudo bash

Options:
  --repo   <git-url>     (default: ${REPO_URL_DEFAULT})
  --dir    <path>        (default: ${INSTALL_DIR_DEFAULT})
  --branch <name>        (default: ${BRANCH_DEFAULT})
EOF
        exit 0
        ;;
      *)
        die "Unknown argument: $1" ;;
    esac
  done

  require_root
  need_cmd date
  need_cmd install
  need_cmd rm

  log "mccPi deploy starting"
  log "Repo: ${repo_url}"
  log "Branch: ${branch}"
  log "Install dir: ${install_dir}"

  clone_or_update_repo "$repo_url" "$install_dir" "$branch"

  # NOTE: Future expansion point: run module installers from the cloned repo.
  # For now we bootstrap the base layout required by the constitution.
  bootstrap_base

  log "mccPi deploy finished successfully"
}

main "$@"
