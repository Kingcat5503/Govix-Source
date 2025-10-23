# -------------------------------------------------
# Arch ISO Build Environment
# -------------------------------------------------
FROM archlinux:latest

LABEL maintainer="Your Name <you@example.com>"
LABEL description="Docker container for building custom Arch ISO using archiso"

# Update system and install dependencies
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm archiso git base-devel && \
    pacman -Scc --noconfirm

# Set working directory
WORKDIR /root/project

# Copy your ArchISO build files into container
# (If you want to mount your repo during build, skip this COPY line)
COPY . /root/project

# Initialize keyring (needed for pacman to work inside Docker)
RUN pacman-key --init && \
    pacman-key --populate archlinux

# Default command builds the ISO
CMD ["bash", "-c", "mkarchiso -v -w /root/work -o /root/out releng"]
