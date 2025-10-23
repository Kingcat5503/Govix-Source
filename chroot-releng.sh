#!/usr/bin/env bash
# ============================================================
#  ArchISO Build Chroot Helper for Govix (releng profile)
#  Path: /mnt/main/Project/Linux/Archiso/releng/chroot-releng.sh
# ============================================================

set -e  # stop on error

# ---- CONFIG ------------------------------------------------
PROFILE_DIR="/mnt/main/Project/Linux/Archiso/releng"
WORK_DIR="/mnt/main/Project/Linux/Archiso/work"
ARCH="x86_64"
AIROOTFS="$WORK_DIR/$ARCH/airootfs"

# ---- COLORS ------------------------------------------------
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

# ---- FUNCTIONS ---------------------------------------------
msg() { echo -e "${GREEN}==>${RESET} $*"; }
warn() { echo -e "${YELLOW}==> WARNING:${RESET} $*"; }
err() { echo -e "${RED}==> ERROR:${RESET} $*" >&2; exit 1; }

# ---- CHECKS ------------------------------------------------
[[ $EUID -ne 0 ]] && err "Please run as root (use sudo)."
[[ ! -d "$PROFILE_DIR" ]] && err "Profile directory not found: $PROFILE_DIR"

# ---- STEP 1: PREPARE WORK DIR ------------------------------
msg "Preparing ArchISO work directory..."
mkdir -p "$WORK_DIR"
mkarchiso -w "$WORK_DIR" -p "base" -v "$PROFILE_DIR"

# ---- STEP 2: MOUNT SYSTEM DIRECTORIES ----------------------
msg "Mounting necessary filesystems into airootfs..."

for d in dev proc sys run; do
    mountpoint -q "$AIROOTFS/$d" || mount --bind "/$d" "$AIROOTFS/$d"
done

# Ensure DNS works inside chroot
cp -f /etc/resolv.conf "$AIROOTFS/etc/resolv.conf"

# ---- STEP 3: ENTER CHROOT ---------------------------------
msg "Entering chroot environment..."
echo -e "${YELLOW}Tip:${RESET} Type 'exit' when done to leave the chroot."

arch-chroot "$AIROOTFS" /bin/bash

# ---- STEP 4: CLEANUP --------------------------------------
msg "Cleaning up mounts..."
for d in dev proc sys run; do
    umount -R "$AIROOTFS/$d" 2>/dev/null || true
done

msg "Done. You have successfully exited the ArchISO chroot."