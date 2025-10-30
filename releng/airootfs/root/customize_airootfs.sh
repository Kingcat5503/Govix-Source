systemctl enable sddm.service
systemctl enable dbus.service
systemctl enable NetworkManager.service
systemctl enable systemd-logind.service
systemctl enable bluetooth.service

mkdir -p /run/user/1000
chown govix:govix /run/user/1000
chmod 700 /run/user/1000
export XDG_RUNTIME_DIR=/run/user/1000
