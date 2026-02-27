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

# 3. Create the Automation Script (Improved Connectivity & Retry Logic)
RUN cat > /usr/bin/auto-setup << 'EOF'
#!/bin/bash
set -euo pipefail

# Exit if setup already done
[ -f "$HOME/.setup-done" ] && exit 0

# A. Wait for D-Bus session to be ready
echo "Waiting for D-Bus session..."
for i in $(seq 1 30); do
    dbus-send --session --dest=org.freedesktop.DBus \
              --type=method_call --print-reply \
              /org/freedesktop/DBus org.freedesktop.DBus.ListNames \
              >/dev/null 2>&1 && break
    sleep 2
done

# B. NEW: Wait for Internet Connection (Avoids race condition)
echo "Checking for internet connection..."
until ping -c 1 8.8.8.8 &>/dev/null; do
    echo "Waiting for network..."
    sleep 5
done

# C. Setup Flatpak
flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org

# D. NEW: Install Flatpak apps with Retry Logic
echo "Installing Flatpaks..."
until flatpak install -y --noninteractive --user flathub \
    app.zen_browser.zen \
    org.videolan.VLC \
    org.onlyoffice.desktopeditors \
    dev.zed.Zed \
    com.github.tchx84.Flatseal \
    com.mattjakeman.ExtensionManager \
    org.gnome.DejaDup \
    com.discordapp.Discord; do
    echo "Flatpak install failed, retrying in 10 seconds..."
    sleep 10
done

# E. Final System Configs
xdg-settings set default-web-browser app.zen_browser.zen.desktop || true
distrobox create -n dev -i fedora:43 --yes || true
systemctl --user enable --now podman.socket || true

# Mark as done and notify
touch "$HOME/.setup-done"
notify-send "Setup Complete" "Your system is ready with Docker compatibility."
EOF

# Ensure script is executable
RUN chmod +x /usr/bin/auto-setup

# 4. Autostart Config
RUN mkdir -p /etc/xdg/autostart && \
    printf '[Desktop Entry]\nType=Application\nName=First Run Setup\nExec=/usr/bin/auto-setup\nNoDisplay=true\nTerminal=false\nX-GNOME-Autostart-enabled=true\n' \
    > /etc/xdg/autostart/first-run.desktop
