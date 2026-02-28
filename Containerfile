FROM quay.io/fedora/fedora-silverblue:43

# 1. Disable broken Fedora 43 updates-archive repo
RUN sed -i 's/^enabled=1/enabled=0/' /etc/yum.repos.d/fedora-updates-archive.repo || true

# Step A: Remove unwanted packages (Internal to image)
RUN rpm-ostree override remove firefox firefox-langpacks

# Step B: Install host packages (These stay in the image /usr)
RUN rpm-ostree install \
        gnome-tweaks \
        distrobox \
        podman-docker \
        podman-compose

# Step C: Setup Global Environment & Aliases
RUN printf 'export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/podman/podman.sock\n' > /etc/profile.d/docker-compat.sh && \
    printf 'alias z="flatpak run dev.zed.Zed ."\n' >> /etc/profile.d/docker-compat.sh && \
    printf 'alias zen="flatpak run app.zen_browser.zen"\n' >> /etc/profile.d/docker-compat.sh

# Step D: Background Automation (NOW INCLUDES FLATPAKS)
# We move the flatpak commands here so they run on your actual machine.
RUN mkdir -p /usr/libexec && \
    printf '#!/usr/bin/env bash\n\
set -euo pipefail\n\
sleep 5\n\
[ -f "$HOME/.setup-done" ] && exit 0\n\
\n\
flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo\n\
\n\
flatpak install --user -y flathub \\\n\
    app.zen_browser.zen \\\n\
    org.videolan.VLC \\\n\
    org.onlyoffice.desktopeditors \\\n\
    dev.zed.Zed \\\n\
    com.github.tchx84.Flatseal \\\n\
    com.mattjakeman.ExtensionManager \\\n\
    org.gnome.DejaDup \\\n\
    com.discordapp.Discord\n\
\n\
distrobox create -n dev -i fedora:43 --yes || true\n\
systemctl --user enable --now podman.socket || true\n\
xdg-settings set default-web-browser app.zen_browser.zen.desktop || true\n\
touch \"$HOME/.setup-done\"\n' \
    > /usr/libexec/first-run-setup && \
    chmod +x /usr/libexec/first-run-setup

# Step E: Autostart Config
RUN mkdir -p /etc/xdg/autostart && \
    printf '[Desktop Entry]\n\
Type=Application\n\
Name=First Run Setup\n\
Exec=/usr/libexec/first-run-setup\n\
NoDisplay=true\n\
Terminal=false\n\
X-GNOME-Autostart-enabled=true\n' \
    > /etc/xdg/autostart/first-run.desktop
