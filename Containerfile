FROM quay.io/fedora/fedora-silverblue:43

# 0. Disable broken Fedora 43 updates-archive repo
RUN sed -i 's/^enabled=1/enabled=0/' /etc/yum.repos.d/fedora-updates-archive.repo || true

# 1. Install Host Tools 
# 1. Install Host Tools (Fixed for container / Buildah)
RUN dnf remove -y firefox || true && \
    dnf install -y \
        htop \
        btop \
        nvtop \
        tmux \
        bat \
        gnome-tweaks \
        git \
        nautilus-python \
        fzf \
        distrobox \
        moby-engine \
        docker-compose && \
    dnf clean all


# 2. Setup Docker Group
RUN groupadd -f docker

# 3. Automation Script (Fixed)
RUN cat <<'EOF' > /usr/bin/auto-setup-apps
#!/bin/bash

# --- Docker Group Check ---
if ! groups "$(whoami)" | grep -q '\bdocker\b'; then
    sudo usermod -aG docker "$(whoami)"
fi

# --- Flatpak Apps Setup ---
if [ ! -f "$HOME/.flatpak-setup-done" ]; then
    flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    flatpak install --user -y flathub \
        org.mozilla.firefox \
        com.spotify.Client \
        app.zen_browser.zen \
        org.videolan.VLC \
        org.onlyoffice.desktopeditors \
        dev.zed.Zed \
        com.github.tchx84.Flatseal \
        com.mattjakeman.ExtensionManager \
        org.gnome.DejaDup \
        com.discordapp.Discord

    xdg-mime default dev.zed.Zed.desktop text/plain
    xdg-mime default org.gnome.Nautilus.desktop inode/directory
    xdg-settings set default-web-browser org.mozilla.firefox.desktop

    touch "$HOME/.flatpak-setup-done"
fi
EOF

RUN chmod +x /usr/bin/auto-setup-apps

# 4. Permissions, Autostart, and Firefox Flatpak Alias
RUN chmod +x /usr/bin/auto-setup-apps && \
    mkdir -p /etc/xdg/autostart && \
    printf "[Desktop Entry]\nType=Application\nName=Flatpak Auto-Setup\nExec=/usr/bin/auto-setup-apps\nNoDisplay=true\nX-GNOME-Autostart-enabled=true\n" \
    > /etc/xdg/autostart/flatpak-check.desktop && \
    # Hide system Firefox launcher
    sed -i 's/NoDisplay=false/NoDisplay=true/g' /usr/share/applications/firefox.desktop || true && \
    # Alias Firefox to Flatpak version
    echo 'alias firefox="flatpak run org.mozilla.firefox"' >> /etc/bashrc

# 5. UI Cleanup & Aliases
RUN sed -i 's/NoDisplay=false/NoDisplay=true/g' /usr/share/applications/org.gnome.Console.desktop || true && \
    sed -i 's/NoDisplay=false/NoDisplay=true/g' /usr/share/applications/firefox.desktop || true && \   # <-- ADD THIS (hide system Firefox)
    echo 'alias z="flatpak run dev.zed.Zed ."' >> /etc/bashrc && \
    echo 'alias clean="flatpak uninstall --unused -y"' >> /etc/bashrc && \
    echo 'alias cat="bat"' >> /etc/bashrc && \
    echo 'alias firefox="flatpak run org.mozilla.firefox"' >> /etc/bashrc   # <-- ADD THIS (firefox CLI alias)

