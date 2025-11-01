#!/usr/bin/env bash
set -euo pipefail

LIVE_USER=govix
LIVE_UID=1000

# create user if missing
if ! id -u "${LIVE_USER}" >/dev/null 2>&1; then
    useradd -m -u "${LIVE_UID}" -G wheel -s /bin/bash "${LIVE_USER}"
    echo "${LIVE_USER}:govix" | chpasswd
fi

# ensure home exists and ownership
mkdir -p "/home/${LIVE_USER}"
chown -R "${LIVE_USER}:${LIVE_USER}" "/home/${LIVE_USER}"
chmod 0755 "/home/${LIVE_USER}"

# ensure runtime dir exists and correct perms
mkdir -p "/run/user/${LIVE_UID}"
chown "${LIVE_USER}:${LIVE_USER}" "/run/user/${LIVE_UID}"
chmod 700 "/run/user/${LIVE_UID}"

# ensure /tmp sticky bit
chmod 1777 /tmp || true

exit 0
