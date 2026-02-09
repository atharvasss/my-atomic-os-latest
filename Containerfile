FROM quay.io/fedora/fedora-silverblue:43

# 0. Disable broken Fedora 43 updates-archive repo
RUN sed -i 's/^enabled=1/enabled=0/' /etc/yum.repos.d/fedora-updates-archive.repo || true

# 1. Install Host Tools
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

# 3. Automation Script (Buildah-safe)
RUN printf '#!/bin/bash\n\
\n\
# --- Docker Group Check ---\n\
if ! groups "$(whoami)" | grep -q "\\bdocker\\b"; then\n\
    sudo usermod -aG docker "$(whoami)"\n\
fi\n\
\n\
# --- Flatpak Apps Setup ---\n\
if [ ! -f "$HOME/.flatpak-setup-done" ]; then\n\
    flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo\n\
    flatpak install --user -y flathub \\\n\
        org.mozilla.firefox \\\n\
        com.spotify.Client \\\n\
        app.zen_browser.zen \\\n\
        org.videolan.VLC \\\n\
        org.onlyoffice.desktopeditors \\\n\
        dev.zed.Zed \\\n\
        com.github.tchx84.Flatseal \\\n\
        com.mattjakeman.ExtensionManager \\\n\
        org.gnome.DejaDup \\\n\
        com.discordapp.Discord\n\
    xdg-mime default dev.zed.Zed.desktop text/plain\n\
    xdg-mime default org.gnome.Nautilus.desktop inode/directory\n\
    xdg-settings set default-web-browser org.mozilla.firefox.desktop\n\
    touch "$HOME/.flatpak-setup-done"\n\
fi\n' > /usr/bin/auto-setup-apps && chmod +x /usr/bin/auto-setup-apps

# 4. Autostart Flatpak Setup Script
RUN mkdir -p /etc/xdg/autostart && \
    printf "[Desktop Entry]\nType=Application\nName=Flatpak Auto-Setup\nExec=/usr/bin/auto-setup-apps\nNoDisplay=true\nX-GNOME-Autostart-enabled=true\n" \
    > /etc/xdg/autostart/flatpak-check.desktop

# 5. CLI Aliases
RUN echo 'alias z="flatpak run dev.zed.Zed ."' >> /etc/bashrc && \
    echo 'alias clean="flatpak uninstall --unused -y"' >> /etc/bashrc && \
    echo 'alias cat="bat"' >> /etc/bashrc && \
    echo 'alias firefox="flatpak run org.mozilla.firefox"' >> /etc/bashrc
