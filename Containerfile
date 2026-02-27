FROM quay.io/fedora/fedora-silverblue:43

# 1. Disable broken Fedora 43 updates-archive repo
RUN sed -i 's/^enabled=1/enabled=0/' /etc/yum.repos.d/fedora-updates-archive.repo || true

# 2. Host Layering - Kept lean for 2026 speed
RUN rpm-ostree override remove firefox firefox-langpacks && \
    rpm-ostree install \
        gnome-tweaks distrobox \
        moby-engine docker-compose && \
    # Fix: Enable Docker daemon at the system level during build
    systemctl enable docker.service && \
    rpm-ostree cleanup -m && \
    ostree container commit


# 2. Setup Docker Group
RUN groupadd -f docker

# 3. Create the Automation Script
RUN printf '%s\n' '#!/bin/bash' \
    '# Run once setup' \
    'if [ ! -f "$HOME/.setup-done" ]; then' \
    '    # 1. Docker Group' \
    '    sudo usermod -aG docker "$USER"' \
    '    ' \
    '    # 2. Flatpak Setup (Added --noninteractive to prevent hanging)' \
    '    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo' \
    '    flatpak install -y --noninteractive flathub \
            app.zen_browser.zen \
            org.videolan.VLC org.onlyoffice.desktopeditors dev.zed.Zed \
            com.github.tchx84.Flatseal com.mattjakeman.ExtensionManager \
            org.gnome.DejaDup com.discordapp.Discord' \
    '    ' \
    '    # 3. Defaults & Distrobox' \
    '    xdg-settings set default-web-browser app.zen_browser.zen.desktop' \
    '    distrobox create -n dev -i fedora:43 --yes' \
    '    ' \
    '    touch "$HOME/.setup-done"' \
    '    notify-send "Setup Complete" "Please reboot to apply Docker permissions."' \
    'fi' > /usr/bin/auto-setup && chmod +x /usr/bin/auto-setup

# 4. Autostart Config
RUN mkdir -p /etc/xdg/autostart && \
    printf "[Desktop Entry]\nType=Application\nName=Setup\nExec=/usr/bin/auto-setup\nNoDisplay=true\n" \
    > /etc/xdg/autostart/first-run.desktop

# 5. Global Aliases
RUN echo 'alias z="flatpak run dev.zed.Zed ."' >> /etc/bashrc && \
    echo 'alias zen="flatpak run app.zen_browser.zen"' >> /etc/bashrc
