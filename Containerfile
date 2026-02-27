FROM quay.io/fedora/fedora-silverblue:43

# 1. Disable broken Fedora 43 updates-archive repo
RUN sed -i 's/^enabled=1/enabled=0/' /etc/yum.repos.d/fedora-updates-archive.repo || true

# Step A: Remove unwanted packages
RUN rpm-ostree override remove firefox firefox-langpacks && \
    ostree container commit

# Step B: Install host packages
RUN rpm-ostree install \
        gnome-tweaks \
        distrobox \
        podman-docker \
        podman-compose && \
    ostree container commit

# 2. Setup Global Environment & Aliases
# Using /etc/profile.d/ ensures these are available in any shell and survive updates.
RUN printf 'export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/podman/podman.sock\n' > /etc/profile.d/docker-compat.sh && \
    printf 'alias z="flatpak run dev.zed.Zed ."\n' >> /etc/profile.d/docker-compat.sh && \
    printf 'alias zen="flatpak run app.zen_browser.zen"\n' >> /etc/profile.d/docker-compat.sh

# 3. Create the Automation Script
# We use backslashes to ensure the builder treats this as ONE single RUN command
RUN printf '#!/bin/bash\n\
set -euo pipefail\n\
\n\
[ -f "$HOME/.setup-done" ] && exit 0\n\
\n\
echo "Waiting for D-Bus session..."\n\
for i in $(seq 1 30); do\n\
    dbus-send --session --dest=org.freedesktop.DBus \\\n\
              --type=method_call --print-reply \\\n\
              /org/freedesktop/DBus org.freedesktop.DBus.ListNames \\\n\
              >/dev/null 2>&1 && break\n\
    sleep 2\n\
done\n\
\n\
flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org\n\
\n\
flatpak install -y --noninteractive --user flathub \\\n\
    app.zen_browser.zen \\\n\
    org.videolan.VLC \\\n\
    org.onlyoffice.desktopeditors \\\n\
    dev.zed.Zed \\\n\
    com.github.tchx84.Flatseal \\\n\
    com.mattjakeman.ExtensionManager \\\n\
    org.gnome.DejaDup \\\n\
    com.discordapp.Discord || true\n\
\n\
xdg-settings set default-web-browser app.zen_browser.zen.desktop || true\n\
\n\
distrobox create -n dev -i fedora:43 --yes || true\n\
\n\
systemctl --user enable --now podman.socket || true\n\
\n\
touch "$HOME/.setup-done"\n\
notify-send "Setup Complete" "Podman is ready with Docker compatibility."\n' > /usr/bin/auto-setup && \
chmod +x /usr/bin/auto-setup


# 4. Autostart Config
RUN mkdir -p /etc/xdg/autostart && \
    printf '[Desktop Entry]\nType=Application\nName=First Run Setup\nExec=/usr/bin/auto-setup\nNoDisplay=true\nTerminal=false\nX-GNOME-Autostart-enabled=true\n' \
    > /etc/xdg/autostart/first-run.desktop
