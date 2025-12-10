systemctl enable greetd.service
systemctl enable dbus.service
systemctl enable seatd.service
systemctl enable systemd-logind.service

LIVE_USER=govix
LIVE_PASS=govix
LIVE_UID=1000

if ! id -u "${LIVE_USER}" >/dev/null 2>&1; then

    useradd -m -u "${LIVE_UID}" -G wheel -s /bin/bash "${LIVE_USER}"

    echo "${LIVE_USER}:${LIVE_PASS}" | chpasswd

fi

mkdir -p /home/"${LIVE_USER}"
chown -R "${LIVE_USER}:${LIVE_USER}" /home/"${LIVE_USER}"
chmod 0755 /home/"${LIVE_USER}"

if [[ ! -f /etc/sudoers.d/90-govix ]]; then

    cat > /etc/sudoers.d/90-govix <<'EOF'

%wheel ALL=(ALL) NOPASSWD: ALL

EOF

    chmod 0440 /etc/sudoers.d/90-govix

fi