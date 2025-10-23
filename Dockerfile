# -------------------------------------------------
# Govix ArchISO Build Container
# -------------------------------------------------
FROM archlinux:latest

LABEL maintainer="Kaushik govixcomputers@gmail.com"
LABEL description="Docker container to build Govix Arch-based ISO with custom GitLab repo"

# Update base system and install dependencies
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm archiso git base-devel wget curl && \
    pacman -Scc --noconfirm

# Initialize pacman keyring
RUN pacman-key --init && \
    pacman-key --populate archlinux

# -------------------------------------------------
# Add your GitLab repo
# -------------------------------------------------
# Replace the URL below with your actual GitLab repo raw file URL
# Example:
#   https://gitlab.com/kaushikb/garch-repo/-/raw/master
# or
#   https://gitlab.com/kaushikb/govix-repo/-/raw/main
RUN echo '[garch-repo]' >> /etc/pacman.conf && \
    echo 'SigLevel = Optional TrustAll' >> /etc/pacman.conf && \
    echo 'Server = https://gitlab.com/Kingcat5503/garch-repo/-/raw/main/$arch' >> /etc/pacman.conf

# -------------------------------------------------
# Copy ISO build project
# -------------------------------------------------
WORKDIR /root/project
COPY . /root/project

# -------------------------------------------------
# Default ISO build command
# -------------------------------------------------
CMD ["bash", "-c", "mkarchiso -v -w /root/work -o /root/out releng"]
