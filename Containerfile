FROM quay.io/fedora/fedora-silverblue:43

# 0. Disable broken Fedora 43 updates-archive repo
RUN sed -i 's/^enabled=1/enabled=0/' /etc/yum.repos.d/fedora-updates-archive.repo || true

# 1. Install Host Tools (clean install, avoid firefox from repos)
# FIX: clean dnf cache before removing/installing to avoid metadata write errors
RUN dnf clean all && \
    dnf remove -y firefox || true && \
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

# 3. Create Automation Script (Fixed Formatting)
RUN printf '%s\n' '#!/bin/bash' \
    '' \
    '# --- Docker Group Check ---' \
    'if ! groups "$(whoami)" | grep -q "\bdocker\b"; then' \
    '    sudo usermod -aG docker "$(whoami)"' \
    'fi' \
    '' \
    '    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo' \
    '    flatpak install --system -y --noninteractive flathub \' \
    '        org.mozilla.firefox \' \
    '        com.spotify.Client \' \
    '        app.zen_browser.zen \' \
    '        org.videolan.VLC \' \
    '        org.onlyoffice.desktopeditors \' \
    '        dev.zed.Zed \' \
    '        com.github.tchx84.Flatseal \' \
    '        com.mattjakeman.ExtensionManager \' \
    '        org.gnome.DejaDup \' \
    '        com.discordapp.Discord' \
    '    xdg-mime default dev.zed.Zed.desktop text/plain' \
    '    xdg-mime default org.gnome.Nautilus.desktop inode/directory' \
    '    xdg-settings set default-web-browser org.mozilla.firefox.desktop' \
    '    touch "$HOME/.flatpak-setup-done"' \
    'fi' > /usr/bin/auto-setup-apps && chmod +x /usr/bin/auto-setup-apps

# 4. Setup autostart and aliases safely (check if files exist before sed)
RUN mkdir -p /etc/xdg/autostart && \
    printf "[Desktop Entry]\nType=Application\nName=Flatpak Auto-Setup\nExec=/usr/bin/auto-setup-apps\nNoDisplay=true\nX-GNOME-Autostart-enabled=true\n" \
    > /etc/xdg/autostart/flatpak-check.desktop && \
    # Safely hide Firefox if file exists
    [ -f /usr/share/applications/firefox.desktop ] && sed -i 's/NoDisplay=false/NoDisplay=true/g' /usr/share/applications/firefox.desktop || true && \
    # Add alias globally (bashrc)
    echo 'alias firefox="flatpak run org.mozilla.firefox"' >> /etc/bashrc

# 5. UI Cleanup & Aliases (check file existence before sed)
RUN [ -f /usr/share/applications/org.gnome.Console.desktop ] && sed -i 's/NoDisplay=false/NoDisplay=true/g' /usr/share/applications/org.gnome.Console.desktop || true && \
    [ -f /usr/share/applications/firefox.desktop ] && sed -i 's/NoDisplay=false/NoDisplay=true/g' /usr/share/applications/firefox.desktop || true && \
    echo 'alias z="flatpak run dev.zed.Zed ."' >> /etc/bashrc && \
    echo 'alias clean="flatpak uninstall --unused -y"' >> /etc/bashrc && \
    echo 'alias cat="bat"' >> /etc/bashrc && \
    echo 'alias firefox="flatpak run org.mozilla.firefox"' >> /etc/bashrc
