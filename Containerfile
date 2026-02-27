FROM quay.io/fedora/fedora-silverblue:43

# 1. Disable broken Fedora 43 updates-archive repo
RUN sed -i 's/^enabled=1/enabled=0/' /etc/yum.repos.d/fedora-updates-archive.repo || true

# Step A: Remove unwanted packages
RUN rpm-ostree override remove firefox firefox-langpacks && \
    ostree container commit

# Step B: Install host packages and Flatpaks
RUN rpm-ostree install \
        gnome-tweaks \
        distrobox \
        podman-docker \
        podman-compose && \
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo && \
    flatpak install -y flathub \
        app.zen_browser.zen \
        org.videolan.VLC \
        org.onlyoffice.desktopeditors \
        dev.zed.Zed \
        com.github.tchx84.Flatseal \
        com.mattjakeman.ExtensionManager \
        org.gnome.DejaDup \
        com.discordapp.Discord && \
    ostree container commit

# Step C: Setup Global Environment & Aliases
RUN printf 'export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/podman/podman.sock\n' > /etc/profile.d/docker-compat.sh && \
    printf 'alias z="flatpak run dev.zed.Zed ."\n' >> /etc/profile.d/docker-compat.sh && \
    printf 'alias zen="flatpak run app.zen_browser.zen"\n' >> /etc/profile.d/docker-compat.sh

# Step D: Background Automation (Simplified)
# This only handles things that MUST happen at runtime (like Distrobox creation)
RUN printf '#!/bin/bash\n\
set -euo pipefail\n\
[ -f "$HOME/.setup-done" ] && exit 0\n\
distrobox create -n dev -i fedora:43 --yes || true\n\
systemctl --user enable --now podman.socket || true\n\
xdg-settings set default-web-browser app.zen_browser.zen.desktop || true\n\
touch "$HOME/.setup-done"\n' > /usr/bin/auto-setup && \
chmod +x /usr/bin/auto-setup

# Step E: Keep your Autostart Config as it is
RUN mkdir -p /etc/xdg/autostart && \
    printf '[Desktop Entry]\nType=Application\nName=First Run Setup\nExec=/usr/bin/auto-setup\nNoDisplay=true\nTerminal=false\nX-GNOME-Autostart-enabled=true\n' \
    > /etc/xdg/autostart/first-run.desktop
