#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(readlink -f "$(dirname "$0")")"
AIROOTFS="${REPO_ROOT}/releng/airootfs"

# paths
SDDM_CONF_DIR="${AIROOTFS}/etc/sddm.conf.d"
XSETUP_DIR="${AIROOTFS}/usr/share/sddm/scripts"
GOVIX_BIN_DIR="${AIROOTFS}/usr/local/bin"
SYSTEMD_DIR="${AIROOTFS}/etc/systemd/system"
CUSTOMIZE="${AIROOTFS}/root/customize_airootfs.sh"

mkdir -p "${SDDM_CONF_DIR}" "${XSETUP_DIR}" "${GOVIX_BIN_DIR}" "${SYSTEMD_DIR}"

cat > "${SDDM_CONF_DIR}/99-govix.conf" <<'EOF'
[General]
Session=plasma.desktop

[Wayland]
Enable=false

[X11]
ServerPath=/usr/bin/Xorg

[Theme]
Current=breeze
EOF

cat > "${XSETUP_DIR}/Xsetup" <<'EOF'
#!/bin/sh
set -e

# ensure /tmp sticky bit
chmod 1777 /tmp || true

# ensure runtime dir for uid 1000 exists and owned by govix
RUN_DIR="/run/user/1000"
mkdir -p "${RUN_DIR}"
chown govix:govix "${RUN_DIR}" || true
chmod 700 "${RUN_DIR}" || true

exit 0
EOF

cat > "${GOVIX_BIN_DIR}/govix-setup.sh" <<'EOF'
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
EOF

cat > "${SYSTEMD_DIR}/govix-setup.service" <<'EOF'
[Unit]
Description=Govix early setup (ensure live user & runtime dir)
DefaultDependencies=no
After=local-fs.target
Before=display-manager.service
Wants=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/govix-setup.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# make scripts executable
chmod +x "${XSETUP_DIR}/Xsetup" "${GOVIX_BIN_DIR}/govix-setup.sh"

# ensure govix-setup.service is enabled at build-time in customize_airootfs.sh
ENABLE_LINE='systemctl enable govix-setup.service'
if ! grep -Fq "${ENABLE_LINE}" "${CUSTOMIZE}"; then
    if grep -Fq 'systemctl enable bluetooth.service' "${CUSTOMIZE}"; then
        # insert after bluetooth enable line
        awk -v add="${ENABLE_LINE}" '
        { print }
        /systemctl enable bluetooth.service/ && !added { print add; added=1 }
        ' "${CUSTOMIZE}" > "${CUSTOMIZE}.tmp" && mv "${CUSTOMIZE}.tmp" "${CUSTOMIZE}"
    else
        # append if anchor not found
        printf "\n%s\n" "${ENABLE_LINE}" >> "${CUSTOMIZE}"
    fi
    chmod +x "${CUSTOMIZE}" || true
    echo "Patched ${CUSTOMIZE} to enable govix-setup.service"
else
    echo "govix-setup.service already enabled in ${CUSTOMIZE}"
fi

echo "Created SDDM config, Xsetup, govix-setup script and systemd unit under releng/airootfs."
echo "Make sure plasma session files and KDE packages are present in releng/packages.x86_64, then rebuild the ISO."