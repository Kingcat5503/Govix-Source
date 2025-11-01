systemctl enable sddm.service
systemctl enable dbus.service
systemctl enable NetworkManager.service
systemctl enable systemd-logind.service
systemctl enable bluetooth.service
systemctl enable govix-setup.service

# Create live user and ensure sudo access (ensure UID 1000)
LIVE_USER=govix
LIVE_PASS=govix
LIVE_UID=1000

if ! id -u "${LIVE_USER}" >/dev/null 2>&1; then
    useradd -m -u "${LIVE_UID}" -G wheel -s /bin/bash "${LIVE_USER}"
    echo "${LIVE_USER}:${LIVE_PASS}" | chpasswd
fi

# Ensure home ownership and basic skeleton files
mkdir -p /home/"${LIVE_USER}"
chown -R "${LIVE_USER}:${LIVE_USER}" /home/"${LIVE_USER}"
chmod 0755 /home/"${LIVE_USER}"

# Give wheel group passwordless sudo (safe for live images)
if [[ ! -f /etc/sudoers.d/90-govix ]]; then
    cat > /etc/sudoers.d/90-govix <<'EOF'
%wheel ALL=(ALL) NOPASSWD: ALL
EOF
    chmod 0440 /etc/sudoers.d/90-govix
fi

# Ensure runtime and tmp permissions
mkdir -p /run/user/"${LIVE_UID}"
chown "${LIVE_USER}:${LIVE_USER}" /run/user/"${LIVE_UID}"
chmod 700 /run/user/"${LIVE_UID}"

chmod 1777 /tmp

# Export runtime dir for any build-time processes that need it
export XDG_RUNTIME_DIR=/run/user/"${LIVE_UID}"
