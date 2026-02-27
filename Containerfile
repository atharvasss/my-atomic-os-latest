FROM quay.io/fedora/fedora-silverblue:43

# 1. Disable broken Fedora 43 updates-archive repo
RUN sed -i 's/^enabled=1/enabled=0/' /etc/yum.repos.d/fedora-updates-archive.repo || true

# Step A: Remove unwanted packages
RUN rpm-ostree override remove firefox firefox-langpacks && \
    ostree container commit

# Step B: Install host packages (Swapped Docker for Podman-Docker)
RUN rpm-ostree install \
        gnome-tweaks \
        distrobox \
        podman-docker \
        podman-compose && \
    ostree container commit

# 2. Setup environment for Docker tool compatibility
# This points all "Docker" tools to the Podman user socket automatically
RUN echo 'export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/podman/podman.sock' >> /etc/bashrc && \
    echo 'alias z="flatpak run dev.zed.Zed ."' >> /etc/bashrc && \
    echo 'alias zen="flatpak run app.zen_browser.zen"' >> /etc/bashrc

# 3. Create the Automation Script

# STEP 6/24: Create the Automation Script
RUN cat > /usr/bin/auto-setup << 'EOF'
#!/bin/bash
set -euo pipefail

[ -f "$HOME/.setup-done" ] && exit 0

# Wait for D-Bus session
echo "Waiting for D-Bus session..."
for i in $(seq 1 30); do
    dbus-send --session --dest=org.freedesktop.DBus \
              --type=method_call --print-reply \
              /org/freedesktop/DBus org.freedesktop.DBus.ListNames \
              >/dev/null 2>&1 && break
    sleep 2
done

# 1. Flatpak remote
flatpak remote-add --if-not-exists --user flathub \
    https://dl.flathub.org

# 2. Install Flatpak apps
flatpak install -y --noninteractive --user flathub \
    app.zen_browser.zen \
    org.videolan.VLC \
    org.onlyoffice.desktopeditors \
    dev.zed.Zed \
    com.github.tchx84.Flatseal \
    com.mattjakeman.ExtensionManager \
    org.gnome.DejaDup \
    com.discordapp.Discord || true

# 3. Set default browser
xdg-settings set default-web-browser app.zen_browser.zen.desktop || true

# 4. Create dev Distrobox container
distrobox create -n dev -i fedora:43 --yes || true

# 5. Enable Podman User Socket
systemctl --user enable --now podman.socket || true

touch "$HOME/.setup-done"
notify-send "Setup Complete" "Podman is ready with Docker compatibility."
EOF

# STEP 7/24: Make it executable
RUN chmod +x /usr/bin/auto-setup


# 4. Autostart Config
RUN mkdir -p /etc/xdg/autostart && \
    printf '[Desktop Entry]\nType=Application\nName=First Run Setup\nExec=/usr/bin/auto-setup\nNoDisplay=true\nTerminal=false\nX-GNOME-Autostart-enabled=true\n' \
    > /etc/xdg/autostart/first-run.desktop

# 5. Global Aliases
RUN echo 'alias z="flatpak run dev.zed.Zed ."' >> /etc/bashrc && \
    echo 'alias zen="flatpak run app.zen_browser.zen"' >> /etc/bashrc
