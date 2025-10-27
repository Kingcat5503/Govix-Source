#!/bin/bash
#
# ~/.xinitrc
# X session startup script for ArchISO (Govix)
#

# Load user Xresources and keymaps
[ -f ~/.Xresources ] && xrdb -merge ~/.Xresources
[ -f ~/.Xmodmap ] && xmodmap ~/.Xmodmap

# Set a default cursor
xsetroot -cursor_name left_ptr

# Start essential background daemons
if command -v nm-applet >/dev/null 2>&1; then
    nm-applet &
fi

if command -v kdeconnect-indicator >/dev/null 2>&1; then
    kdeconnect-indicator &
fi

# Optional compositor (uncomment if using plain X11)
# picom --experimental-backends &

# Check if Plasma Wayland session is available
if [ -x /usr/bin/startplasma-wayland ]; then
    echo "Starting KDE Plasma (Wayland)..."
    exec dbus-run-session startplasma-wayland
fi

# Fallback to X11 Plasma if Wayland not found
if [ -x /usr/bin/startplasma-x11 ]; then
    echo "Starting KDE Plasma (X11)..."
    exec dbus-run-session startplasma-x11
fi

# As last resort, start simple xterm
exec xterm
