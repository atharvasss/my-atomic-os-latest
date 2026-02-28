FROM quay.io/fedora/fedora-silverblue:43

# 1. Disable broken Fedora 43 updates-archive repo
RUN sed -i 's/^enabled=1/enabled=0/' /etc/yum.repos.d/fedora-updates-archive.repo || true

# Steps A & B: Combined Atomic Package Management
# Chaining removal and installation prevents unnecessary image layers
RUN rpm-ostree override remove firefox firefox-langpacks && \
    rpm-ostree install \
        gnome-tweaks \
        distrobox \
        podman-docker \
        podman-compose \
        libnotify && \
    groupadd -f docker && \
    rpm-ostree cleanup -m && \
    ostree container commit

# Step C: Setup Global Environment & Aliases
RUN printf 'export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/podman/podman.sock\n' > /etc/profile.d/docker-compat.sh && \
    printf 'alias z="flatpak run dev.zed.Zed ."\n' >> /etc/profile.d/docker-compat.sh && \
    printf 'alias zen="flatpak run app.zen_browser.zen"\n' >> /etc/profile.d/docker-compat.sh

# Step D: Background Automation (With Robust Network Check & Notifications)
RUN mkdir -p /usr/libexec && \
    printf '#!/usr/bin/env bash\n\
set -euo pipefail\n\
\n\
# Check if already completed\n\
[ -f "$HOME/.setup-done" ] && exit 0\n\
\n\
# Wait for internet (max 60 seconds)\n\
MAX_RETRIES=30\n\
COUNT=0\n\
until curl -s --head https://www.google.com | grep "200" > /dev/null || [ $COUNT -eq $MAX_RETRIES ]; do\n\
  echo "Waiting for internet connection..."\n\
  sleep 2\n\
  ((COUNT++))\n\
done\n\
\n\
# Exit if no connection\n\
if [ $COUNT -eq $MAX_RETRIES ]; then\n\
  notify-send -u critical "Setup Failed" "No internet connection detected. Please connect and restart your session."\n\
  exit 1\n\
fi\n\
\n\
# Initialize Flatpak flathub repo\n\
flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo\n\
\n\
# Install apps\n\
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
# Final configurations\n\
systemctl --user enable --now podman.socket || true\n\
xdg-settings set default-web-browser app.zen_browser.zen.desktop || true\n\
\n\
# Mark as done and Notify\n\
touch \"$HOME/.setup-done\"\n\
notify-send -u critical "Setup Complete" "Your apps are installed. Restart your session to see them in the menu."\n' \
    > /usr/libexec/first-run-setup && \
    chmod +x /usr/libexec/first-run-setup

# Step E: Autostart Config
RUN mkdir -p /etc/xdg/autostart && \
    printf '[Desktop Entry]\n\
Type=Application\n\
Name=First Run Setup\n\
Exec=/usr/libexec/first-run-setup\n\
NoDisplay=false\n\
Terminal=true\n\
X-GNOME-Autostart-enabled=true\n' \
    > /etc/xdg/autostart/first-run.desktop
