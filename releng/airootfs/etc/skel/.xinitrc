#!/bin/sh

# Force Wayland session metadata
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=niri
export XDG_SESSION_DESKTOP=niri
export DESKTOP_SESSION=niri

# Optional: better rendering for GTK/Qt apps
export QT_QPA_PLATFORM=wayland
export GDK_BACKEND=wayland

# Optional: fallbacks if an app only supports X11
export QT_QPA_PLATFORMTHEME=qt5ct

# If you need XWayland, niri enables it automatically if available.
# Nothing to export for that.

exec niri
