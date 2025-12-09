#!/bin/sh

# Force Wayland session metadata
export XDG_SESSION_TYPE=wayland
export DESKTOP_SESSION=sway

# Optional: better rendering for GTK/Qt apps
export QT_QPA_PLATFORM=wayland
export GDK_BACKEND=wayland

# Optional: fallbacks if an app only supports X11
export QT_QPA_PLATFORMTHEME=qt5ct

exec sway
